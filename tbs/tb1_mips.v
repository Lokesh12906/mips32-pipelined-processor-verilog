module tb1;
  reg clk1,clk2;
  integer k;
  mips_32 dut (clk1,clk2);

  initial 
     begin
       clk1=0;clk2=0;
       repeat(20)
         begin
            #5 clk1=1;clk2=0;
            #5 clk1=0;clk2=1;
         end
     end
   initial 
      begin
        for(k=0; k<31;k++)
           dut.REG[k]=k;
        dut.MEM[0] =32'h2801000a;
        dut.MEM[1] =32'h28020014;
        dut.MEM[2] =32'h28030019;
        dut.MEM[3]= 32'h0ce77800;
        dut.MEM[4]= 32'h0ce77800;   
        dut.MEM[5]= 32'h00222000;
        dut.MEM[6]= 32'h0ce77800;
        dut.MEM[7]= 32'h00832800;
        dut.MEM[8]= 32'hfc000000;
        dut.HALTED=0;
        dut.PC=0;
        dut.TAKEN_BRANCH=0;
        #300
        for (k=0;k<6;k++)
           $display("R%1d - %2d",k,dut.REG[k]);           
   end
   initial begin
        
        $dumpfile("mips1.vcd");
        $dumpvars (0,tb1);
        #320 $finish;
      end 
endmodule
