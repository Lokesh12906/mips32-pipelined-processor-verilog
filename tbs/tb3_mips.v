module tb_factorial;
  reg clk1, clk2;
  integer k;

  mips_32 dut (clk1, clk2);

  // Clock generation
  initial begin
    clk1 = 0; clk2 = 0;
    repeat (50) begin
      #5 clk1 = 1; clk2 = 0;
      #5 clk1 = 0; clk2 = 1;
    end
  end

  // Program + data initialization
  initial begin
    for (k = 0; k < 31; k = k + 1)
        dut.REG[k] = k;

    dut.MEM[0]  = 32'h2801000a; // ADDI  R1, R0, 10
    dut.MEM[1]  = 32'h28020014; // ADDI  R2, R0, 20
    dut.MEM[2]  = 32'h00222000; // ADD   R4, R1, R2
    dut.MEM[3]  = 32'h04812800; // SUB   R5, R4, R1
    dut.MEM[4]  = 32'hFC000000; // HLT

    dut.PC = 0;
    dut.HALTED = 0;
    dut.TAKEN_BRANCH = 0;

    #1200;
    $display("R1 - %0d", dut.REG[1]);
    $display("R2 - %0d", dut.REG[2]);
    $display("R4 - %0d", dut.REG[4]);
    $display("R5 - %0d", dut.REG[5]);
  end

  // Waveform dump
  initial begin
    $dumpfile("factorial_mips.vcd");
    $dumpvars(0, tb_factorial);
    #2000 $finish;
  end

endmodule
