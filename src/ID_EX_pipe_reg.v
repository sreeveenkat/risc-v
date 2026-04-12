`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: ID_EX_pipe_reg
//
// FIXES APPLIED:
//   BUG (Critical) - Incomplete flush: on flush, only control signals were
//   zeroed. Data fields rs1_EX, rs2_EX, rd_EX, PC_EX, rs1_data_EX,
//   rs2_data_EX, immediate_EX, funct3_EX, funct7_EX were left holding
//   stale values from the instruction being flushed.
//
//   Consequences of the original bug:
//     1. forwarding_unit checks (rd_MEM == rs1_EX) and (rd_MEM == rs2_EX).
//        Stale rs1_EX/rs2_EX could match rd_MEM and fire spurious forwarding,
//        silently injecting wrong values into the ALU inputs.
//     2. hazard_detection_unit checks (rd_EX == rs1_ID) || (rd_EX == rs2_ID).
//        Stale rd_EX could trigger a false load-use stall, freezing the
//        pipeline for one cycle when no stall was needed.
//
//   FIX: flush block now clears ALL fields (data + control) to zero,
//   exactly matching the reset block - making the flushed register
//   behave as a clean NOP bubble in every downstream unit.
//////////////////////////////////////////////////////////////////////////////////

module ID_EX_pipe_reg(
    input Clk,
    input Reset,
    input flush,

    // Data inputs
    input [31:0] PC_ID,
    input [6:0]  opcode_ID,
    input [31:0] rs1_data_ID,
    input [31:0] rs2_data_ID,
    input [31:0] immediate_ID,
    input [4:0]  rs1_ID,
    input [4:0]  rs2_ID,
    input [4:0]  rd_ID,
    input [2:0]  funct3_ID,
    input [6:0]  funct7_ID,

    // EX control inputs
    input [1:0]  ALUOp_ID,
    input [1:0]  ALUSrcA_ID,
    input        ALUSrcB_ID,
    input        Branch_ID,

    // MEM control inputs
    input        MemRead_ID,
    input        MemWrite_ID,

    // WB control inputs
    input [1:0]  WriteBackSel_ID,
    input        RegWrite_ID,

    // Data outputs
    output reg [31:0] PC_EX,
    output reg [6:0]  opcode_EX,
    output reg [31:0] rs1_data_EX,
    output reg [31:0] rs2_data_EX,
    output reg [31:0] immediate_EX,
    output reg [4:0]  rs1_EX,
    output reg [4:0]  rs2_EX,
    output reg [4:0]  rd_EX,
    output reg [2:0]  funct3_EX,
    output reg [6:0]  funct7_EX,

    // EX control outputs
    output reg [1:0]  ALUOp_EX,
    output reg [1:0]  ALUSrcA_EX,
    output reg        ALUSrcB_EX,
    output reg        Branch_EX,

    // MEM control outputs
    output reg        MemRead_EX,
    output reg        MemWrite_EX,

    // WB control outputs
    output reg [1:0]  WriteBackSel_EX,
    output reg        RegWrite_EX
);

always @(posedge Clk or negedge Reset) begin
    if (!Reset) begin
        // Full reset - clear everything
        PC_EX           <= 32'd0;
        opcode_EX       <= 7'd0;
        rs1_data_EX     <= 32'd0;
        rs2_data_EX     <= 32'd0;
        immediate_EX    <= 32'd0;
        rs1_EX          <= 5'd0;
        rs2_EX          <= 5'd0;
        rd_EX           <= 5'd0;
        funct3_EX       <= 3'd0;
        funct7_EX       <= 7'd0;
        ALUOp_EX        <= 2'd0;
        ALUSrcA_EX      <= 2'd0;
        ALUSrcB_EX      <= 1'b0;
        Branch_EX       <= 1'b0;
        MemRead_EX      <= 1'b0;
        MemWrite_EX     <= 1'b0;
        WriteBackSel_EX <= 2'd0;
        RegWrite_EX     <= 1'b0;
    end

    else if (flush) begin
        // FIX: flush ALL fields - not just control signals.
        // Stale rs1_EX/rs2_EX cause false forwarding;
        // stale rd_EX causes false load-use stalls.
        PC_EX           <= 32'd0;   // FIX: was missing
        opcode_EX       <= 7'd0;
        rs1_data_EX     <= 32'd0;   // FIX: was missing
        rs2_data_EX     <= 32'd0;   // FIX: was missing
        immediate_EX    <= 32'd0;   // FIX: was missing
        rs1_EX          <= 5'd0;    // FIX: was missing - caused false forwarding
        rs2_EX          <= 5'd0;    // FIX: was missing - caused false forwarding
        rd_EX           <= 5'd0;    // FIX: was missing - caused false load-use stall
        funct3_EX       <= 3'd0;    // FIX: was missing
        funct7_EX       <= 7'd0;    // FIX: was missing
        ALUOp_EX        <= 2'd0;
        ALUSrcA_EX      <= 2'd0;
        ALUSrcB_EX      <= 1'b0;
        Branch_EX       <= 1'b0;
        MemRead_EX      <= 1'b0;
        MemWrite_EX     <= 1'b0;
        WriteBackSel_EX <= 2'd0;
        RegWrite_EX     <= 1'b0;
    end

    else begin
        PC_EX           <= PC_ID;
        opcode_EX       <= opcode_ID;
        rs1_data_EX     <= rs1_data_ID;
        rs2_data_EX     <= rs2_data_ID;
        immediate_EX    <= immediate_ID;
        rs1_EX          <= rs1_ID;
        rs2_EX          <= rs2_ID;
        rd_EX           <= rd_ID;
        funct3_EX       <= funct3_ID;
        funct7_EX       <= funct7_ID;
        ALUOp_EX        <= ALUOp_ID;
        ALUSrcA_EX      <= ALUSrcA_ID;
        ALUSrcB_EX      <= ALUSrcB_ID;
        Branch_EX       <= Branch_ID;
        MemRead_EX      <= MemRead_ID;
        MemWrite_EX     <= MemWrite_ID;
        WriteBackSel_EX <= WriteBackSel_ID;
        RegWrite_EX     <= RegWrite_ID;
    end
end

endmodule
