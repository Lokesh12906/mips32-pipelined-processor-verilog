module tb_arithmetic;

  reg clk1, clk2;
  integer k;

  // Instantiate the MIPS Processor (Device Under Test)
  mips_32 dut (clk1, clk2);

  //=========================================================
  // Clock Generation
  // Generates two non-overlapping clocks
  // clk1 -> IF, EX, WB
  // clk2 -> ID, MEM
  //=========================================================
  initial begin
    clk1 = 0;
    clk2 = 0;

    repeat (50) begin
      #5 clk1 = 1; clk2 = 0;   // Rising edge of clk1
      #5 clk1 = 0; clk2 = 1;   // Rising edge of clk2
    end
  end

  //=========================================================
  // Initialize Register File and Load Test Program
  //=========================================================
  initial begin

    // Initialize registers
    // R0=0, R1=1, R2=2, ...
    for (k = 0; k < 31; k = k + 1)
      dut.REG[k] = k;

    //=====================================================
    // Test Program
    //=====================================================

    // ADDI R1, R0, 10
    // R1 = 10
    dut.MEM[0] = 32'h2801000a;

    // ADDI R2, R0, 20
    // R2 = 20
    dut.MEM[1] = 32'h28020014;

    // ADD R4, R1, R2
    // R4 = 10 + 20 = 30
    dut.MEM[2] = 32'h00222000;

    // SUB R5, R4, R1
    // R5 = 30 - 10 = 20
    dut.MEM[3] = 32'h04812800;

    // Halt processor
    dut.MEM[4] = 32'hFC000000;

    // Processor Initialization
    dut.PC = 0;
    dut.HALTED = 0;
    dut.TAKEN_BRANCH = 0;

    // Wait for program execution
    #1200;

    // Display register contents
    $display("R1 = %0d", dut.REG[1]);
    $display("R2 = %0d", dut.REG[2]);
    $display("R4 = %0d", dut.REG[4]);
    $display("R5 = %0d", dut.REG[5]);

  end


  initial begin
    $dumpfile("factorial_mips.vcd");   // Output waveform file
    $dumpvars(0, tb_factorial);        // Dump all signals

    // End simulation
    #2000 $finish;
  end

endmodule
