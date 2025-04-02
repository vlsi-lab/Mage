// Copyright 2025 Politecnico di Torino.
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// File: p_shifter.sv
// Author: Alessio Naclerio
// Date: 26/02/2025
// Description: Partitioned Shifter

module p_shifter
  import pea_pkg::*;
(
    input logic [N_BITS-1:0] a_i,
    input logic [N_BITS-1:0] b_i,
    input fu_instr_t instr_i,
    input logic in_valid_i,
    output logic [N_BITS-1:0] res_o,
    output logic [31:0] shift_left_result_o,
    output logic [31:0] operand_a_rev_o,
    output logic [31:0] operand_a_neg_rev_o,
    output logic valid_o
);

  logic        shift_left;  // should we shift left
  logic        shift_arithmetic;

  logic [31:0] operand_a_rev;
  logic [31:0] operand_a_neg;
  logic [31:0] operand_a_neg_rev;

  logic [31:0] shift_amt_left;  // amount of shift, if to the left
  logic [31:0] shift_amt;  // amount of shift, to the right
  logic [31:0] shift_amt_int;  // amount of shift, used for the actual shifters
  logic [31:0] shift_op_a;  // input of the shifter
  logic [31:0] shift_result;
  logic [31:0] shift_right_result;
  logic [31:0] shift_left_result;

  assign shift_amt = b_i;  //div_enable ? div_shift : b_i;

  assign operand_a_neg = ~a_i;
  // bit reverse operand_a_neg for left shifts and bit counting
  generate
    genvar m;
    for (m = 0; m < 32; m++) begin : gen_operand_a_neg_rev
      assign operand_a_neg_rev[m] = operand_a_neg[31-m];
    end
  endgenerate

  // bit reverse operand_a for left shifts
  generate
    genvar k;
    for (k = 0; k < 32; k++) begin : gen_operand_a_rev
      assign operand_a_rev[k] = a_i[31-k];
    end
  endgenerate

  // by reversing the bits of the input, we also have to reverse the order of shift amounts
  always_comb begin
    shift_amt_left[31:0] = shift_amt[31:0];
  end

  // ALU_FL1 and ALU_CBL are used for the bit counting ops later
  assign shift_left = (instr_i == LSH) || (instr_i == DIV) || (instr_i == DIVU);

  assign shift_arithmetic = (instr_i == ARSH) ;

  // choose the bit reversed or the normal input for shift operand a
  assign shift_op_a    = shift_left ? operand_a_rev : a_i;
  assign shift_amt_int = shift_left ? shift_amt_left : shift_amt;

  // right shifts, we let the synthesizer optimize this
  logic [63:0] shift_op_a_32;

  assign shift_op_a_32 = $signed({{32{shift_arithmetic & shift_op_a[31]}}, shift_op_a});

  always_comb begin
    shift_right_result = shift_op_a_32 >> shift_amt_int[4:0];
  end

  // bit reverse the shift_right_result for left shifts
  genvar j;
  generate
    for (j = 0; j < 32; j++) begin : gen_shift_left_result
      assign shift_left_result[j] = shift_right_result[31-j];
    end
  endgenerate

  assign shift_result = shift_left ? shift_left_result : shift_right_result;

  assign shift_left_result_o = shift_left_result;


endmodule
