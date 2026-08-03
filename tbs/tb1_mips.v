module tb1;

  reg clk1, clk2;
  integer k;

  // Instantiate the MIPS processor (Device Under Test)
  mips_32 dut (clk1, clk2);

  //=========================================================
  // Clock Generation
  // Generates two non-overlapping clocks:
  // clk1 drives IF, EX and WB stages
  // clk2 drives ID and MEM stages
  //=========================================================
  initial
  begin
    clk1 = 0;
    clk2 = 0;

    repeat(20)
    begin
      #5 clk1 = 1; clk2 = 0;   // Rising edge of clk1
      #5 clk1 = 0; clk2 = 1;   // Rising edge of clk2
    end
  end

  //=========================================================
  // Initialize Register File and Instruction Memory
  //=========================================================
  initial
  begin

    // Initialize registers with their index values
    // R0=0, R1=1, R2=2, ...
    for(k = 0; k < 31; k++)
      dut.REG[k] = k;

    //=====================================================
    // Program loaded into Instruction Memory
    //=====================================================

    // ADDI R1, R0, 10      --> R1 = 10
    dut.MEM[0] = 32'h2801000a;

    // ADDI R2, R0, 20      --> R2 = 20
    dut.MEM[1] = 32'h28020014;

    // ADD R4, R1, R2       --> R4 = R1 + R2 = 30
    dut.MEM[2] = 32'h00222000;

    // HLT                  --> Stop processor execution
    dut.MEM[3] = 32'hfc000000;

    // Processor Initialization
    dut.HALTED = 0;
    dut.PC = 0;
    dut.TAKEN_BRANCH = 0;

    // Wait for the program to complete
    #300;

    // Display final register contents
    $display("R1 = %0d", dut.REG[1]);
    $display("R2 = %0d", dut.REG[2]);
    $display("R4 = %0d", dut.REG[4]);

  end

  initial
  begin
    $dumpfile("mips1.vcd");     // Output waveform file
    $dumpvars(0, tb1);          // Dump all signals

    // End simulation
    #320 $finish;
  end

endmodule
