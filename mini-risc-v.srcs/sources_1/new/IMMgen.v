`timescale 1ns / 1ps

module imm_gen #(
    parameter WIDTH = 32,
    parameter LEN_OPCODE = 7)
(
    input      [WIDTH-1:0] in,
    output reg [WIDTH-1:0] out
);

    ////////////////////////////////////////////////////////////////////////
    //                      Instruction Formats                           //
    // ------------------------------------------------------------------ //
    //                           //R-type//                               //
    //  31        25 24     20 19     15 14  12 11      7 6           0   //
    //  +------------+---------+---------+------+---------+-------------+ //
    //  | funct7     | rs2     | rs1     |funct3| rd      | opcode      | //
    //  +------------+---------+---------+------+---------+-------------+ //
    //                           //I-type//                               //
    //  31                  20 19     15 14  12 11      7 6           0   //
    //  +----------------------+---------+------+---------+-------------+ //
    //  | imm                  | rs1     |funct3| rd      | opcode      | //
    //  +----------------------+---------+------+---------+-------------+ //
    //                           //S-type//                               //
    //  31        25 24     20 19     15 14  12 11      7 6           0   //
    //  +------------+---------+---------+------+---------+-------------+ //
    //  | imm        | rs2     | rs1     |funct3| imm     | opcode      | //
    //  +------------+---------+---------+------+---------+-------------+ //
    //                           //U-type//                               //
    //  31                                      11      7 6           0   //
    //  +---------------------------------------+---------+-------------+ //
    //  | imm                                   | rd      | opcode      | //
    //  +---------------------------------------+---------+-------------+ //
    //                  Immediate Instruction Formats                     //
    // ------------------------------------------------------------------ //
    //                         //I-immediate//                            //
    //  31                                        10        5 4     1  0  //
    // +-----------------------------------------+-----------+-------+--+ //
    // |                                  <-- 31 | 30:25     | 24:21 |20| //
    // +-----------------------------------------+-----------+-------+--+ //
    //                           //S-immediate//                          //
    //  31                                        10        5 4     1  0  //
    // +-----------------------------------------+-----------+-------+--+ //
    // |                                  <-- 31 | 30:25     | 11:8  |7 | //
    // +-----------------------------------------+-----------+-------+--+ //
    //                           //B-immediate//                          //
    //  31                                  12 11 10        5 4     1  0  //
    // +--------------------------------------+--+-----------+-------+--+ //
    // |                               <-- 31 |7 | 30:25     | 11:8  |z | //
    // +--------------------------------------+--+-----------+-------+--+ //
    //                          //U-immediate//                           //
    //  31 30               20 19           12 11                      0  //
    // +--+-------------------+---------------+-------------------------+ //
    // |31| 30:20             | 19:12         |                   <-- z | //
    // +--+-------------------+---------------+-------------------------+ //
    ////////////////////////////////////////////////////////////////////////
    
    always @(*) begin
        casez({in[14:12], in[LEN_OPCODE-1:0]})
            // Load instructions
            10'b???0000011: out <= {{20{in[31]}}, in[31:20]};
            // Store instructions
            10'b???0100011: out <= {{20{in[31]}}, in[31:25], in[11:7]};
            // Branch instructions
            10'b???1100011: out <= {{20{in[31]}}, in[7], in[30:25], in[11:8], 1'b0};

            // Immediate arithmetic instructions
            10'b0000010011: out <= {{20{in[31]}}, in[31:20]}; // addi
            10'b1110010011: out <= {{20{in[31]}}, in[31:20]}; // andi
            10'b1100010011: out <= {{20{in[31]}}, in[31:20]}; // ori
            10'b1000010011: out <= {{20{in[31]}}, in[31:20]}; // xori
            10'b0100010011: out <= {{20{in[31]}}, in[31:20]}; // slti
            10'b0110010011: out <= {{20{in[31]}}, in[31:20]}; // sltiu

            // Shift right and left instructions (shift amount is in bits [24:20])
            10'b1010010011: out <= {27'b0, in[24:20]};        // srli, srai
            10'b0010010011: out <= {27'b0, in[24:20]};        // slli

            // Default case to handle unmatched patterns
            default: out <= 32'b0;
        endcase
    end

endmodule