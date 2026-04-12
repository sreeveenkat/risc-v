`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: processor_tb
//
// CHANGES vs original:
//   1. Connected reg_flat_debug [1023:0] from processor/register_file.
//   2. Added 32 individual wires x0..x31 sliced from reg_flat_debug so every
//      register appears as its own named signal in the waveform viewer.
//   3. $dumpvars now also dumps reg_flat_debug and all xN wires.
//   4. debug_reg_select / debug_reg_out already connected (kept as-is).
//////////////////////////////////////////////////////////////////////////////////
module processor_tb;

// ── Clock and Reset ───────────────────────────────────────────────────────────
reg Clk;
reg Reset;

// ── Register debug interface ──────────────────────────────────────────────────
reg  [4:0]  debug_reg_select;
wire [31:0] debug_reg_out;

// ── NEW: flat register bus (all 32 regs visible in waveform) ─────────────────
wire [1023:0] reg_flat_debug;

// ── Individual register wires sliced from reg_flat_debug ─────────────────────
// In your waveform viewer add these signals; each updates every cycle.
wire [31:0] x0  = reg_flat_debug[  0*32 +: 32]; // always 0
wire [31:0] x1  = reg_flat_debug[  1*32 +: 32];
wire [31:0] x2  = reg_flat_debug[  2*32 +: 32];
wire [31:0] x3  = reg_flat_debug[  3*32 +: 32];
wire [31:0] x4  = reg_flat_debug[  4*32 +: 32];
wire [31:0] x5  = reg_flat_debug[  5*32 +: 32];
wire [31:0] x6  = reg_flat_debug[  6*32 +: 32];
wire [31:0] x7  = reg_flat_debug[  7*32 +: 32];
wire [31:0] x8  = reg_flat_debug[  8*32 +: 32];
wire [31:0] x9  = reg_flat_debug[  9*32 +: 32];
wire [31:0] x10 = reg_flat_debug[ 10*32 +: 32];
wire [31:0] x11 = reg_flat_debug[ 11*32 +: 32];
wire [31:0] x12 = reg_flat_debug[ 12*32 +: 32];
wire [31:0] x13 = reg_flat_debug[ 13*32 +: 32];
wire [31:0] x14 = reg_flat_debug[ 14*32 +: 32];
wire [31:0] x15 = reg_flat_debug[ 15*32 +: 32];
wire [31:0] x16 = reg_flat_debug[ 16*32 +: 32];
wire [31:0] x17 = reg_flat_debug[ 17*32 +: 32];
wire [31:0] x18 = reg_flat_debug[ 18*32 +: 32];
wire [31:0] x19 = reg_flat_debug[ 19*32 +: 32];
wire [31:0] x20 = reg_flat_debug[ 20*32 +: 32];
wire [31:0] x21 = reg_flat_debug[ 21*32 +: 32];
wire [31:0] x22 = reg_flat_debug[ 22*32 +: 32];
wire [31:0] x23 = reg_flat_debug[ 23*32 +: 32];
wire [31:0] x24 = reg_flat_debug[ 24*32 +: 32];
wire [31:0] x25 = reg_flat_debug[ 25*32 +: 32];
wire [31:0] x26 = reg_flat_debug[ 26*32 +: 32];
wire [31:0] x27 = reg_flat_debug[ 27*32 +: 32];
wire [31:0] x28 = reg_flat_debug[ 28*32 +: 32];
wire [31:0] x29 = reg_flat_debug[ 29*32 +: 32];
wire [31:0] x30 = reg_flat_debug[ 30*32 +: 32];
wire [31:0] x31 = reg_flat_debug[ 31*32 +: 32];

// ── IF debug wires ────────────────────────────────────────────────────────────
wire [31:0] PC_IF_debug;
wire [31:0] instruction_IF_debug;

// ── ID debug wires ────────────────────────────────────────────────────────────
wire [31:0] PC_ID_debug;
wire [31:0] instruction_ID_debug;
wire [31:0] immediate_ID_debug;
wire [4:0]  rs1_ID_debug;
wire [4:0]  rs2_ID_debug;
wire [31:0] rs1_data_ID_debug;
wire [31:0] rs2_data_ID_debug;

// ── EX debug wires ────────────────────────────────────────────────────────────
wire [31:0] PC_EX_debug;
wire [31:0] ALU_result_EX_debug;
wire [4:0]  rd_EX_debug;
wire        Branch_EX_debug;
wire [31:0] ALU_in_A_debug;
wire [31:0] ALU_in_B_debug;
wire [1:0]  forward_A_debug;
wire [1:0]  forward_B_debug;

// ── MEM debug wires ───────────────────────────────────────────────────────────
wire [31:0] PC_MEM_debug;
wire [31:0] ALU_result_MEM_debug;
wire [31:0] memory_data_MEM_debug;
wire [4:0]  rd_MEM_debug;
wire        MemRead_MEM_debug;
wire        MemWrite_MEM_debug;

// ── WB debug wires ────────────────────────────────────────────────────────────
wire [31:0] PC_WB_debug;
wire [31:0] ALU_result_WB_debug;
wire [31:0] memory_data_WB_debug;
wire [31:0] write_data_debug;
wire [4:0]  rd_WB_debug;
wire        RegWrite_WB_debug;

// ── DUT instantiation ─────────────────────────────────────────────────────────
processor uut (
    .Clk(Clk),
    .Reset(Reset),
    .debug_reg_select(debug_reg_select),
    .debug_reg_out(debug_reg_out),
    // NEW
    .reg_flat_debug(reg_flat_debug),
    .PC_IF_debug(PC_IF_debug),
    .instruction_IF_debug(instruction_IF_debug),
    .PC_ID_debug(PC_ID_debug),
    .instruction_ID_debug(instruction_ID_debug),
    .immediate_ID_debug(immediate_ID_debug),
    .rs1_ID_debug(rs1_ID_debug),
    .rs2_ID_debug(rs2_ID_debug),
    .rs1_data_ID_debug(rs1_data_ID_debug),
    .rs2_data_ID_debug(rs2_data_ID_debug),
    .PC_EX_debug(PC_EX_debug),
    .forward_A_debug(forward_A_debug),
    .forward_B_debug(forward_B_debug),
    .ALU_result_EX_debug(ALU_result_EX_debug),
    .rd_EX_debug(rd_EX_debug),
    .Branch_EX_debug(Branch_EX_debug),
    .ALU_in_A_debug(ALU_in_A_debug),
    .ALU_in_B_debug(ALU_in_B_debug),
    .PC_MEM_debug(PC_MEM_debug),
    .ALU_result_MEM_debug(ALU_result_MEM_debug),
    .memory_data_MEM_debug(memory_data_MEM_debug),
    .rd_MEM_debug(rd_MEM_debug),
    .MemRead_MEM_debug(MemRead_MEM_debug),
    .MemWrite_MEM_debug(MemWrite_MEM_debug),
    .PC_WB_debug(PC_WB_debug),
    .ALU_result_WB_debug(ALU_result_WB_debug),
    .memory_data_WB_debug(memory_data_WB_debug),
    .write_data_debug(write_data_debug),
    .rd_WB_debug(rd_WB_debug),
    .RegWrite_WB_debug(RegWrite_WB_debug)
);

// ── Clock generation: 10 ns period (100 MHz) ──────────────────────────────────
initial begin
    Clk = 0;
    forever #5 Clk = ~Clk;
end

// ── Per-cycle pipeline monitor ─────────────────────────────────────────────────
initial begin
    $monitor("[%0t ns] IF: PC=%08h INST=%08h | WB: rd=x%0d val=%08h wen=%b",
             $time,
             PC_IF_debug,
             instruction_IF_debug,
             rd_WB_debug,
             write_data_debug,
             RegWrite_WB_debug);
end

// ── Register read task ─────────────────────────────────────────────────────────
task read_reg;
    input  [4:0]  reg_num;
    output [31:0] reg_val;
    begin
        debug_reg_select = reg_num;
        #1;
        reg_val = debug_reg_out;
    end
endtask

// ── Self-checking task ─────────────────────────────────────────────────────────
integer pass_cnt;
integer fail_cnt;

task check_reg;
    input [4:0]  reg_num;
    input [31:0] expected;
    reg   [31:0] actual;
    begin
        read_reg(reg_num, actual);
        if (actual === expected) begin
            $display("  PASS  x%0d = 0x%08h (%0d)", reg_num, actual, $signed(actual));
            pass_cnt = pass_cnt + 1;
        end else begin
            $display("  FAIL  x%0d = 0x%08h (%0d)  expected 0x%08h (%0d)",
                     reg_num, actual, $signed(actual), expected, $signed(expected));
            fail_cnt = fail_cnt + 1;
        end
    end
endtask

// ── Full register dump ─────────────────────────────────────────────────────────
task dump_regs;
    integer i;
    reg [31:0] val;
    begin
        $display("─── Register file dump ────────────────────────");
        for (i = 0; i < 32; i = i + 1) begin
            read_reg(i[4:0], val);
            $display("  x%-2d = 0x%08h  (%0d)", i, val, $signed(val));
        end
        $display("───────────────────────────────────────────────");
    end
endtask

// ── Main test sequence ─────────────────────────────────────────────────────────
initial begin
    pass_cnt         = 0;
    fail_cnt         = 0;
    debug_reg_select = 5'd0;

    Reset = 0;
    #20;
    Reset = 1;

    // Wait for program to complete.
    // Adjust #N to (number_of_instructions + 10) * 10 ns.
    #50000;

    $display("");
    $display("=== Simulation complete ===");
    dump_regs;

    $display("── Spot checks ────────────────────────────────");
    check_reg(5'd0, 32'd0);   // x0 must always be 0
    // Add your own expected values here, e.g.:
    // check_reg(5'd10, 32'd500500);
    $display("───────────────────────────────────────────────");
    $display("Result: %0d PASSED, %0d FAILED", pass_cnt, fail_cnt);
    if (fail_cnt == 0)
        $display("ALL CHECKS PASSED");
    else
        $display("SOME CHECKS FAILED - inspect waveform");

    $finish;
end

// ── VCD waveform dump ──────────────────────────────────────────────────────────
// All xN wires declared in this module are plain wires so $dumpvars captures
// them automatically - no need to enumerate them individually.
initial begin
    $dumpfile("processor_tb.vcd");
    $dumpvars(0, processor_tb);
end

endmodule