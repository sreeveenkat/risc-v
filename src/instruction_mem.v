`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: instruction_mem
//
// FIXES APPLIED:
//   BUG (Critical) - Out-of-bounds array index:
//     BEFORE: instruction_reg[read_addr[31:2]]
//       read_addr[31:2] is a 30-bit index. The array has only 256 entries
//       (indices 0-255). Any PC >= 0x400 (1024) produces an index > 255,
//       which is out-of-bounds. In simulation this returns X (unknown),
//       causing the entire pipeline to fill with X values. In synthesis it
//       wraps around unpredictably depending on the tool.
//
//     AFTER: instruction_reg[read_addr[9:2]]
//       read_addr[9:2] is an 8-bit index covering 0-255, matching the 256
//       word-aligned locations exactly (addresses 0x000 to 0x3FC).
//       Bits [1:0] are always dropped (word-aligned addressing).
//////////////////////////////////////////////////////////////////////////////////

module instruction_mem(
    input  [31:0] read_addr,
    output [31:0] instruction
);

reg [31:0] instruction_reg [0:255];   // 256 words = 1 KB instruction memory

initial begin
    $readmemh("program.mem", instruction_reg);
end

// FIX: [9:2] gives an 8-bit index (0-255) matching the 256-entry array.
// Original [31:2] was a 30-bit index - out of bounds for any PC >= 0x400.
assign instruction = instruction_reg[read_addr[9:2]];

endmodule
