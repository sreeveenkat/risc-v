`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: register_file
//
// CHANGE: Added reg_flat_debug [1023:0] output.
//   This is a flat wire that exposes all 32 registers simultaneously so that
//   waveform viewers (Vivado xsim, GTKWave) can display them.
//   reg_flat_debug[31:0]   = x0
//   reg_flat_debug[63:32]  = x1
//   reg_flat_debug[95:64]  = x2
//   ...
//   reg_flat_debug[1023:992] = x31
//////////////////////////////////////////////////////////////////////////////////

module register_file(
    input Clk,
    input Reset,
    input  [4:0]  read_reg1,
    input  [4:0]  read_reg2,
    input  [4:0]  write_reg,
    input  [31:0] data,
    input         RegWrite,

    output [31:0] read_data1,
    output [31:0] read_data2,

    input  [4:0]    debug_reg_select,
    output [31:0]   debug_reg_out,

    // NEW: flat bus – all 32 registers visible in waveform at once
    output [1023:0] reg_flat_debug
);

reg [31:0] registers [31:0];
integer i;

always @(posedge Clk or negedge Reset) begin
    if (!Reset) begin
        for (i = 0; i < 32; i = i + 1)
            registers[i] <= 32'd0;
    end else if (RegWrite && (write_reg != 5'b00000)) begin
        registers[write_reg] <= data;
    end
end

assign read_data1 = (read_reg1 == 5'd0) ? 32'd0 :
                    (RegWrite && (write_reg == read_reg1) && (write_reg != 0)) ? data :
                    registers[read_reg1];

assign read_data2 = (read_reg2 == 5'd0) ? 32'd0 :
                    (RegWrite && (write_reg == read_reg2) && (write_reg != 0)) ? data :
                    registers[read_reg2];

assign debug_reg_out = registers[debug_reg_select];

// Flatten all 32 registers into one wide bus for waveform visibility
genvar gi;
generate
    for (gi = 0; gi < 32; gi = gi + 1) begin : gen_flat
        assign reg_flat_debug[gi*32 +: 32] = registers[gi];
    end
endgenerate

endmodule