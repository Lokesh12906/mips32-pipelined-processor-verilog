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
        dut.MEM[2] =32'h00222000;
        dut.MEM[3] =32'hfc000000;
        dut.HALTED=0;
        dut.PC=0;
        dut.TAKEN_BRANCH=0;
        #300;
        $display("R1 - %0d", dut.REG[1]);
        $display("R2 - %0d", dut.REG[2]);
        $display("R4 - %0d", dut.REG[4]);
   end
   initial begin
        
        $dumpfile("mips1.vcd");
        $dumpvars (0,tb1);
        #320 $finish;
      end 
endmodule
