module tb2;

  reg clk1, clk2;
  integer k;

  // Instantiate the MIPS processor (Device Under Test)
  mips_32 dut (clk1, clk2);

  //=========================================================
  // Clock Generation
  // Generates two non-overlapping clocks
  // clk1 -> IF, EX, WB
  // clk2 -> ID, MEM
  //=========================================================
  initial
  begin
    clk1 = 0;
    clk2 = 0;

    repeat (20)
    begin
      #5 clk1 = 1; clk2 = 0;   // Rising edge of clk1
      #5 clk1 = 0; clk2 = 1;   // Rising edge of clk2
    end
  end

  //=========================================================
  // Initialize Registers and Load Test Program
  //=========================================================
  initial
  begin

    // Initialize register file
    // R0=0, R1=1, R2=2, ...
    for (k = 0; k < 31; k = k + 1)
      dut.REG[k] = k;

    //=====================================================
    // Test Program
    //=====================================================

    // ADDI R1, R0, 120
    // R1 = 120 (Base address)
    dut.MEM[0] = 32'h28010078;

    // ADDI R2, R0, 45
    // R2 = 45 (Data to be stored)
    dut.MEM[1] = 32'h2802002d;

    // SW R2, 1(R1)
    // Memory[R1 + 1] = R2
    // Memory[121] = 45
    dut.MEM[2] = 32'h24220001;

    // Halt processor
    dut.MEM[3] = 32'hfc000000;

    // Processor Initialization
    dut.PC = 0;
    dut.HALTED = 0;
    dut.TAKEN_BRANCH = 0;

    // Wait for program execution
    #500;

    // Display memory contents
    $display("MEM[120] = %0d", dut.MEM[120]);
    $display("MEM[121] = %0d", dut.MEM[121]);

  end

  initial
  begin
    $dumpfile("mips2.vcd");    // Output waveform file
    $dumpvars(0, tb2);         // Dump all signals

    // End simulation
    #600 $finish;
  end

endmodule
