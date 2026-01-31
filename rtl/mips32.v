module mips_32(clk1,clk2);
     input clk1,clk2;
     reg [31:0] PC,IF_ID_IR,IF_ID_NPC;
     reg [31:0] ID_EX_A,ID_EX_B,ID_EX_IMM,ID_EX_NPC,ID_EX_IR;
     reg [2:0] ID_EX_TYPE,EX_MEM_TYPE,MEM_WB_TYPE;
     reg EX_MEM_COND;
     reg [31:0] EX_MEM_ALUOUT, EX_MEM_B, EX_MEM_IR;
     reg [31:0] MEM_WB_LMD,MEM_WB_ALUOUT,MEM_WB_IR;
     reg [31:0] REG [0:31];
     reg [31:0] MEM [0:1023];
     reg HALTED;
     reg TAKEN_BRANCH;
     parameter ADD=6'd0,SUB=6'd1,AND=6'd2,OR=6'D3,SLT=6'd4,MUL=6'd5,LW=6'd8,SW=6'd9,ADDI=6'D10,SUBI=6'd11,SLTI=6'd12,BNEQZ=6'd13,BEQZ=6'd14,HLT=6'b111111;
     parameter RR_ALU=3'd0,RI_ALU=3'd1,LOAD=3'd2,STORE=3'd3,HALT=3'd4,BRANCH=3'd5;
     always @(posedge clk1)   //information fetch stage
        begin
            if (HALTED==0) begin
                if ((EX_MEM_TYPE==BRANCH && EX_MEM_COND==1))
                    begin
                      IF_ID_IR<=MEM[EX_MEM_ALUOUT];
                      IF_ID_NPC<=EX_MEM_ALUOUT + 1;
                      PC<=EX_MEM_ALUOUT+1;
                      TAKEN_BRANCH<=1'b1;  
                    end
                else 
                     begin
                      IF_ID_IR<=MEM[PC];
                      PC<=PC+1;   //new data continuously
                      IF_ID_NPC<=PC+1;  //track on current data
                     end
            end
        end
    always @(posedge clk2) //information decode stage
        begin
            if (HALTED==0)  begin
                if (IF_ID_IR[25:21]==5'b00000)  ID_EX_A<=0;
                else ID_EX_A<=REG[IF_ID_IR[25:21]];
                 
                if (IF_ID_IR[20:16]==5'b00000)  ID_EX_B<=0;
                else ID_EX_B<=REG[IF_ID_IR[20:16]];
                ID_EX_IR<=IF_ID_IR;
                ID_EX_NPC<=IF_ID_NPC;
                ID_EX_IMM<={{16{IF_ID_IR[15]}},{IF_ID_IR[15:0]}};
                case(IF_ID_IR[31:26])
                  ADD,SUB,AND,OR,SLT,MUL :ID_EX_TYPE<=RR_ALU;
                  ADDI,SUBI,SLTI: ID_EX_TYPE<=RI_ALU;
                  SW: ID_EX_TYPE<=STORE;
                  LW: ID_EX_TYPE<=LOAD;
                  BNEQZ,BEQZ: ID_EX_TYPE<=BRANCH;
                  HLT:  ID_EX_TYPE<=HALT;
                  default: ID_EX_TYPE<=HALT;  //invalid opcode
                endcase
                end
            end
    always @(posedge clk1)  //execution stage
         begin
          if (HALTED==0) begin
            EX_MEM_IR<=ID_EX_IR;
            EX_MEM_TYPE<=ID_EX_TYPE;
            TAKEN_BRANCH<=0;
            case (ID_EX_TYPE)
                RR_ALU: begin
                  case(ID_EX_IR[31:26])
                    ADD: EX_MEM_ALUOUT<=ID_EX_A + ID_EX_B;
                    SUB: EX_MEM_ALUOUT<=ID_EX_A - ID_EX_B;
                    AND: EX_MEM_ALUOUT<=ID_EX_A & ID_EX_B;                  
                    OR: EX_MEM_ALUOUT<=ID_EX_A | ID_EX_B;
                    SLT: EX_MEM_ALUOUT<=ID_EX_A < ID_EX_B;
                    MUL: EX_MEM_ALUOUT<=ID_EX_A * ID_EX_B;
                    default:EX_MEM_ALUOUT<=32'd0;
                  endcase
                end
                RI_ALU: begin
                  case(ID_EX_IR[31:26]) 
                    ADDI: EX_MEM_ALUOUT<=ID_EX_A + ID_EX_IMM;
                    SUBI: EX_MEM_ALUOUT<=ID_EX_A - ID_EX_IMM;
                    SLTI : EX_MEM_ALUOUT<=ID_EX_A < ID_EX_IMM;
                    default:EX_MEM_ALUOUT<=32'd0;
                  endcase
                end
                STORE,LOAD: begin
                    EX_MEM_ALUOUT<= ID_EX_A + ID_EX_IMM;
                    EX_MEM_B<= ID_EX_B;
                end
                BRANCH: begin
                    EX_MEM_ALUOUT <= ID_EX_NPC + ID_EX_IMM;
                    if (ID_EX_IR[31:26] == BEQZ)
                        EX_MEM_COND <= (ID_EX_A == 0);
                    else
                        EX_MEM_COND <= (ID_EX_A != 0);
                end
            endcase                                
         end
         end
        always @(posedge clk2) //MEMORY STAGE
            begin
             if(HALTED==0) begin
               MEM_WB_IR<=EX_MEM_IR;
               MEM_WB_TYPE<=EX_MEM_TYPE;
               case(EX_MEM_TYPE)
                  RR_ALU,RI_ALU: MEM_WB_ALUOUT<=EX_MEM_ALUOUT;
                  LOAD: MEM_WB_LMD<= MEM[EX_MEM_ALUOUT];
                  STORE: if(TAKEN_BRANCH==0)
                            MEM[EX_MEM_ALUOUT]<=EX_MEM_B;
               endcase
            end
            end
        always @(posedge clk1) //WRITE BACK STAGE
             begin
               if(!HALTED && !TAKEN_BRANCH)
                  begin
                    case(MEM_WB_TYPE)
                      RR_ALU: REG[MEM_WB_IR[15:11]]<=MEM_WB_ALUOUT;
                      RI_ALU: REG[MEM_WB_IR[20:16]]<=MEM_WB_ALUOUT;
                      LOAD: REG[MEM_WB_IR[20:16]] <= MEM_WB_LMD;
                      HALT: HALTED<=1;
                    endcase
                  end

         end
endmodule

            

     