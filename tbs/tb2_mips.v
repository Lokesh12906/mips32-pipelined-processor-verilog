module tb2;
  reg clk1, clk2;
  integer k;
  mips_32 dut (clk1, clk2);

  initial 
  begin
    clk1 = 0; clk2 = 0;
    repeat (20)
    begin
      #5 clk1 = 1; clk2 = 0;
      #5 clk1 = 0; clk2 = 1;
    end
  end

  initial
  begin
    for (k = 0; k < 31; k = k + 1)
      dut.REG[k] = k;

    dut.MEM[0] = 32'h28010078; // ADDI R1, R0, 120
    dut.MEM[1] = 32'h2802002d; // ADDI R2, R0, 45
    dut.MEM[2] = 32'h24220001; // SW   R2, 1(R1)
    dut.MEM[3] = 32'hfc000000; // HLT

    dut.PC = 0;
    dut.HALTED = 0;
    dut.TAKEN_BRANCH = 0;

    #500;
    $display("MEM[120]: %0d", dut.MEM[120]);
    $display("MEM[121]: %0d", dut.MEM[121]);
  end

  initial 
  begin
    $dumpfile("mips2.vcd");
    $dumpvars(0, tb2);
    #600 $finish;
  end
endmodule
