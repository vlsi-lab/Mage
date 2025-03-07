// Copyright 2025 Politecnico di Torino.
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// File: fu.sv
// Author: Alessio Naclerio
// Date: 26/02/2025
// Description: functional unit

module fu
  import pea_pkg::*;
(
    input  logic                   clk_i,
    input  logic                   rst_n_i,
    input  logic      [N_BITS-1:0] a_i,
    input  logic      [N_BITS-1:0] b_i,
    input  fu_instr_t              instr_i,
    input  logic      [       7:0] reg_acc_value_i,
    input  logic                   acc_ready_i,
    input  logic                   stream_valid_a_i,
    input  logic                   stream_valid_b_i,
    output logic                   stream_valid_o,
    output logic      [N_BITS-1:0] res_o
);

  // Internal signed versions of the inputs
  logic signed [N_BITS-1:0] a_signed;
  logic signed [N_BITS-1:0] b_signed;
  logic                     div_ready;
  logic                     valid;

  assign a_signed = $signed(a_i);
  assign b_signed = $signed(b_i);

  always_comb begin
    case (instr_i)
      DIV || DIVU: begin
        valid = div_ready;
      end
      ACC: begin
        valid = acc_ready_i;
      end
      default: valid = 1;
    endcase
  end

  always_ff @(posedge clk_i, negedge rst_n_i) begin
    if (!rst_n_i) begin
      stream_valid_o <= '0;
    end else begin
      stream_valid_o <= valid;
    end
  end

  ////////////////////////////////////////////////////////////////
  //                                                            //
  //                  Partitioned Shifter                       //
  //                                                            //
  ////////////////////////////////////////////////////////////////

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

  assign shift_amt = b_i;

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
  assign shift_left = (instr_i == LSH);

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

  /////////////////////////////////////////////////////////////////////
  //   ____  _ _      ____                  _      ___               //
  //  | __ )(_) |_   / ___|___  _   _ _ __ | |_   / _ \ _ __  ___    //
  //  |  _ \| | __| | |   / _ \| | | | '_ \| __| | | | | '_ \/ __|   //
  //  | |_) | | |_  | |__| (_) | |_| | | | | |_  | |_| | |_) \__ \_  //
  //  |____/|_|\__|  \____\___/ \__,_|_| |_|\__|  \___/| .__/|___(_) //
  //                                                   |_|           //
  /////////////////////////////////////////////////////////////////////

  logic [31:0] ff_input;  // either op_a_i or its bit reversed version
  logic [ 5:0] clb_result;  // count leading bits
  logic [ 4:0] ff1_result;  // holds the index of the first '1'
  logic        ff_no_one;  // if no ones are found

  always_comb begin
    ff_input = '0;

    case (instr_i)
      DIVU: ff_input = operand_a_rev;

      DIV: begin
        if (a_i[31]) ff_input = operand_a_neg_rev;
        else ff_input = operand_a_rev;
      end
    endcase
  end

  cv32e40p_ff_one ff_one_i (
      .in_i       (ff_input),
      .first_one_o(ff1_result),
      .no_ones_o  (ff_no_one)
  );

  assign clb_result = ff1_result - 5'd1;


  ////////////////////////////////////////////////////
  //  ____ _____     __     __  ____  _____ __  __  //
  // |  _ \_ _\ \   / /    / / |  _ \| ____|  \/  | //
  // | | | | | \ \ / /    / /  | |_) |  _| | |\/| | //
  // | |_| | |  \ V /    / /   |  _ <| |___| |  | | //
  // |____/___|  \_/    /_/    |_| \_\_____|_|  |_| //
  //                                                //
  ////////////////////////////////////////////////////

  logic [31:0] result_div;
  logic        div_signed;
  logic        div_op_a_signed;
  logic [ 5:0] div_shift_int;
  logic [ 5:0] div_shift;
  logic        div_valid;
  logic        div_opcode;

  assign div_opcode = (instr_i == DIV) ? 1'b1 : 1'b0;

  assign div_signed = (instr_i == DIV);

  assign div_op_a_signed = a_i[31] & div_signed;

  assign div_shift_int = ff_no_one ? 6'd31 : clb_result;
  assign div_shift = div_shift_int + (div_op_a_signed ? 6'd0 : 6'd1);

  assign div_valid = (stream_valid_a_i & stream_valid_b_i) & ((instr_i == DIV) || (instr_i == DIVU));

  // inputs A and B are swapped
  cv32e40p_alu_div alu_div_i (
      .Clk_CI (clk_i),
      .Rst_RBI(rst_n_i),

      // input IF
      .OpA_DI      (b_i),
      .OpB_DI      (shift_left_result),
      .OpBShift_DI (div_shift),
      .OpBIsZero_SI((a_i == 0)),

      .OpBSign_SI(div_op_a_signed),
      .OpCode_SI (div_opcode),

      .Res_DO(result_div),

      // Hand-Shake
      .InVld_SI (div_valid),
      .OutRdy_SI(div_valid),  //TO BE CHECKED
      .OutVld_SO(div_ready)
  );

  always_comb begin
    case (instr_i)
      ADD: res_o = a_signed + b_signed;
      MUL: res_o = a_signed * b_signed;
      SUB: res_o = a_signed - b_signed;
      LSH: res_o = shift_result;
      ARSH: res_o = shift_result;
      LRSH: res_o = shift_result;
      MAX: res_o = (a_i > b_i) ? a_i : b_i;
      MIN: res_o = (a_i < b_i) ? a_i : b_i;
      DIV: res_o = result_div;
      DIVU: res_o = result_div;
      ABS: res_o = (a_i[31]) ? -a_signed : a_signed;
      SGNMUL: res_o = (a_i[31]) ? -b_signed : b_signed;
      default: res_o = 0;
    endcase
  end

endmodule
