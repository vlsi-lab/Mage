// Copyright 2025 Politecnico di Torino.
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// File: div_wrapper.sv
// Author: Alessio Naclerio
// Date: 26/02/2025
// Description: Wrapper for Mage divider

module div_wrapper
  import pea_pkg::*;
(
    input logic rst_n_i,
    input logic clk_i,
    input logic [N_BITS-1:0] a_i,
    input logic [N_BITS-1:0] b_i,
    input logic in_valid_i,
    output logic [N_BITS-1:0] q_o,
    output logic [N_BITS-1:0] r_o,
    output logic valid_o
    // cv32e40p CLZ divider IF
    //input  fu_instr_t              instr_i,
    //input  logic [C_LOG_WIDTH-1:0] OpBShift_DI_i,
    //input logic [31:0] operand_a_rev_i,
    //input logic [31:0] operand_a_neg_rev_i
);

  r_div r_div_inst (
      .rst_n_i(rst_n_i),
      .clk_i(clk_i),
      .en_i(in_valid_i),
      .n_i(a_i),
      .d_i(b_i),
      .r_o(r_o),
      .q_o(q_o),
      .valid_o(valid_o)
  );


  /////////////////////////////////////////////////////////////////////
  //   ____  _ _      ____                  _      ___               //
  //  | __ )(_) |_   / ___|___  _   _ _ __ | |_   / _ \ _ __  ___    //
  //  |  _ \| | __| | |   / _ \| | | | '_ \| __| | | | | '_ \/ __|   //
  //  | |_) | | |_  | |__| (_) | |_| | | | | |_  | |_| | |_) \__ \_  //
  //  |____/|_|\__|  \____\___/ \__,_|_| |_|\__|  \___/| .__/|___(_) //
  //                                                   |_|           //
  /////////////////////////////////////////////////////////////////////

  /* logic [31:0] ff_input;  // either op_a_i or its bit reversed version
    logic [ 5:0] clb_result;  // count leading bits
    logic [ 4:0] ff1_result;  // holds the index of the first '1'
    logic        ff_no_one;  // if no ones are found
    logic [ 5:0] cnt_result;  // population count

    always_comb begin
        ff_input = '0;

        case (instr_i)
        DIVU: ff_input = operand_a_rev_i;

        DIV: begin
            if (a_i[31]) ff_input = operand_a_neg_rev_i;
            else ff_input = operand_a_rev_i;
        end
        endcase
    end

    cv32e40p_popcnt popcnt_i (
        .in_i    (a_i),
        .result_o(cnt_result)
    );

    mage_cv32e40p_ff_one ff_one_i (
        .in_i       (ff_input),
        .first_one_o(ff1_result),
        .no_ones_o  (ff_no_one)
    );

    assign clb_result = ff1_result - 5'd1; */


  ////////////////////////////////////////////////////
  //  ____ _____     __     __  ____  _____ __  __  //
  // |  _ \_ _\ \   / /    / / |  _ \| ____|  \/  | //
  // | | | | | \ \ / /    / /  | |_) |  _| | |\/| | //
  // | |_| | |  \ V /    / /   |  _ <| |___| |  | | //
  // |____/___|  \_/    /_/    |_| \_\_____|_|  |_| //
  //                                                //
  ////////////////////////////////////////////////////

  /* logic [31:0] result_div;
    logic        div_signed;
    logic        div_op_a_signed;
    logic [ 5:0] div_shift_int;
    logic [ 5:0] div_shift;
    logic        div_input_valid;
    logic [ 1:0] div_opcode;
    logic        div_enable;

    assign div_opcode = (instr_i == DIV) ? 2'b01 : 2'b00;

    assign div_signed = (instr_i == DIV);

    assign div_op_a_signed = a_i[31] & div_signed;

    assign div_shift_int = ff_no_one ? 6'd31 : clb_result;
    assign div_shift = div_shift_int + (div_op_a_signed ? 6'd0 : 6'd1);

    assign div_input_valid = (in_valid_i) & ((instr_i == DIV) || (instr_i == DIVU));
    assign div_enable = (instr_i == DIV) || (instr_i == DIVU);

    mage_cv32e40p_alu_div alu_div_i (
      .Clk_CI (clk_i),
      .Rst_RBI(rst_n_i),

      // input IF
      .OpA_DI      (b_i),
      .OpB_DI      (OpBShift_DI_i),
      .OpBShift_DI (div_shift),
      .OpBIsZero_SI((cnt_result == 0)),

      .OpBSign_SI(div_op_a_signed),
      .OpCode_SI (div_opcode),

      .Res_DO(q_o),

      // Hand-Shake
      .InVld_SI(div_input_valid),
      .OutRdy_SI(div_enable),  //TO BE CHECKED
      .OutVld_SO(valid_o)
    ); */

  /* mage_cv32e40p_alu_div alu_div_i (
      .Clk_CI (clk_i),
      .Rst_RBI(rst_n_i),

      // input IF
      .OpA_DI      (b_i),
      .OpB_DI      (shift_left_result),
      .OpBShift_DI (div_shift),
      .OpBIsZero_SI((cnt_result == 0)),

      .OpBSign_SI(div_op_a_signed),
      .OpCode_SI (div_opcode),

      .Res_DO(result_div),

      // Hand-Shake
      .InVld_SI(div_input_valid),
      .OutRdy_SI(div_enable),  //TO BE CHECKED
      .OutVld_SO(out_div_valid)
    ); */

endmodule
