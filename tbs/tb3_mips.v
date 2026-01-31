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

    dut.MEM[0]  = 32'h280A00C8; // ADDI  R10, R0, 200
    dut.MEM[1]  = 32'h28020001; // ADDI  R2,  R0, 1
    dut.MEM[2]  = 32'h0E94A000; // OR    R20, R20, R20  (dummy)
    dut.MEM[3]  = 32'h21430000; // LW    R3,  0(R10)
    dut.MEM[4]  = 32'h0E94A000; // OR    R20, R20, R20  (dummy)
    dut.MEM[5]  = 32'h14431000; // Loop: MUL   R2, R2, R3
    dut.MEM[6]  = 32'h2C630001; // SUBI  R3, R3, 1
    dut.MEM[7]  = 32'h0E94A000; // OR    R20, R20, R20  (dummy)
    dut.MEM[8]  = 32'h3460FFFC; // BNEQZ R3, Loop (-4)
    dut.MEM[9]  = 32'h2542FFFE; // SW    R2, -2(R10)
    dut.MEM[10] = 32'hFC000000; // HLT

    dut.MEM[200] = 5;          // input n = 5

    dut.PC = 0;
    dut.HALTED = 0;
    dut.TAKEN_BRANCH = 0;

    #1200;
    $display("Input  (n)        : %0d", dut.MEM[200]);
    $display("Factorial result  : %0d", dut.MEM[198]);
  end

  // Waveform dump
  initial begin
    $dumpfile("factorial_mips.vcd");
    $dumpvars(0, tb_factorial);
    #2000 $finish;
  end

endmodule
