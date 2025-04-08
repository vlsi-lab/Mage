// Copyright 2025 Politecnico di Torino.
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// File: fu_wrapper.sv
// Author: Alessio Naclerio
// Date: 26/02/2025
// Description: wrapper for functional unit

module fu_wrapper_div
  import pea_pkg::*;
(
    input  logic                   clk_i,
    input  logic                   rst_n_i,
    input  logic      [N_BITS-1:0] a_i,
    input  logic      [N_BITS-1:0] b_i,
    input  fu_instr_t              instr_i,
%if enable_streaming_interface == str(1):
    input  logic      [N_BITS-1:0] const_i,
    input  logic                   ops_valid_i,
    input  logic                   pea_ready_i,
    input  logic     [       31:0] reg_acc_value_i,
    output logic                   acc_loopback_o,
    output logic                   valid_o,
    output logic                   ready_o,
    output logic      [N_BITS-1:0] rem_q_o,
%endif
%if enable_decoupling == str(1):
    input  logic      [       1:0] vec_mode_i,
%endif
    output logic      [N_BITS-1:0] res_o
);

  // Internal signed versions of the inputs
  logic signed [N_BITS-1:0] a_signed;
  logic signed [N_BITS-1:0] b_signed;

  assign a_signed = $signed(a_i);
  assign b_signed = $signed(b_i); 
%if enable_streaming_interface == str(1):
  ////////////////////////////////////////////////////////////////
  //                    Ready-Valid Handling                    //
  ////////////////////////////////////////////////////////////////
  // division ready-valid
  logic       out_div_valid;
  logic       div_ready;
  logic       div_busy;
  logic       div_input_valid;
  logic       div_used_once;
  // acuumulation ready-valid
  logic [15:0] acc_cnt;
  logic       acc_ready;
  logic       acc_valid;
  // ready-valid
  logic       valid;
  logic       ready;
%endif
%if enable_streaming_interface == str(1):
  always_ff @(posedge clk_i, negedge rst_n_i) begin
    if (!rst_n_i) begin
      acc_cnt <= 16'd0;
      acc_loopback_o <= 1'b0;
    end else begin
      if (instr_i == ACC || instr_i == MAX) begin
        if (acc_cnt == reg_acc_value_i) begin
          acc_cnt <= 16'd0;
          acc_loopback_o <= 1'b0;
        end else if (ops_valid_i && pea_ready_i) begin
          acc_cnt <= acc_cnt + 16'd1;
          acc_loopback_o <= 1'b1;
        end
      end else begin
        acc_cnt <= 16'd0;
        acc_loopback_o <= 1'b0;
      end
    end
  end

  assign acc_ready = 1'b1;
  assign acc_valid = (acc_cnt == reg_acc_value_i && acc_cnt != '0);
  assign div_input_valid = (ops_valid_i) & ((instr_i == DIV) || (instr_i == DIVU) || (instr_i == REM) || (instr_i == ABSDIV && valid_mo_instr));

  always_ff @(posedge clk_i, negedge rst_n_i) begin
    if (!rst_n_i) begin
      div_busy <= 1'b0;
    end else begin
      if (out_div_valid) begin
        div_busy <= 1'b0;
      end else begin
        if (div_input_valid) begin
          div_busy <= 1'b1;
        end
      end
    end
  end

  always_ff @(posedge clk_i, negedge rst_n_i) begin
    if (!rst_n_i) begin
      div_used_once <= 1'b0;
    end else begin
      if (div_busy) begin
        div_used_once <= 1'b1;
      end
    end
  end

  always_comb begin
    if (div_busy) begin
      div_ready = 1'b0;
      if (out_div_valid) begin
        div_ready = 1'b1;
      end
    end else begin
      div_ready = 1'b1;
      if (div_input_valid) begin
        div_ready = 1'b0;
      end
    end
  end

  always_comb begin
    valid = ops_valid_i;
    ready = 1'b1;
    case (instr_i)
      DIV: begin
        valid = out_div_valid && div_used_once;
        ready = div_ready;
      end
      DIVU: begin
        valid = out_div_valid && div_used_once;
        ready = div_ready;
      end
      REM: begin
        valid = out_div_valid && div_used_once;
        ready = div_ready;
      end
      ABSDIV: begin
        valid = out_div_valid && div_used_once;
        ready = div_ready;
      end
      ACC: begin
        valid = acc_valid;
        ready = acc_ready;
      end
      MAX: begin
        valid = (reg_acc_value_i == '0) ? ops_valid_i : acc_valid;
        ready = 1'b1;
      end
      ADDPOW: begin
        valid = valid_mo_instr;
        ready = 1'b1;
      end
      ADDMUL: begin
        valid = valid_mo_instr;
        ready = 1'b1;
      end
    endcase
  end

  assign valid_o = valid;
  assign ready_o = ready;

  logic [N_BITS-1:0] quotient_div;
  logic [N_BITS-1:0] remainder_div;

  div_wrapper div_wrapper_i (
      .clk_i(clk_i),
      .rst_n_i(rst_n_i),
      .a_i(div_op1),
      .b_i(div_op2),
      .in_valid_i(div_input_valid),
      .q_o(quotient_div),
      .r_o(remainder_div),
      .valid_o(out_div_valid)
  );
  %endif

  %if enable_streaming_interface == str(1) and enable_decoupling == str(0):
  logic [N_BITS:0] add_res;
  logic [N_BITS-1:0] mul_res;
  logic [N_BITS-1:0] shift_res;
  logic [N_BITS-1:0] lsh_res;

  logic [N_BITS-1:0] mul_op1;
  logic [N_BITS-1:0] mul_op2;

  logic [N_BITS-1:0] div_op1;
  logic [N_BITS-1:0] div_op2;

  logic [N_BITS-1:0] lsh_op1_rev;
  logic [2*N_BITS-1:0] shift_op1;
  logic [N_BITS-1:0] shift_op2;

  logic [N_BITS:0] add_op1;
  logic [N_BITS:0] add_op2;

  logic [N_BITS-1:0] op2_neg;
  
  logic sign_op1;

  logic [N_BITS-1:0] temp_res;

  logic valid_mo_instr;

  assign op2_neg = ~b_signed;

  assign add_res = add_op1 + add_op2;
  assign mul_res = mul_op1 * mul_op2;
  assign shift_res = shift_op1 >>> shift_op2;
  generate
    genvar m;
    for (m = 0; m < 32; m++) begin
      assign lsh_res[31-m] = shift_res[m];
    end
  endgenerate

  assign sign_op1 = a_signed[N_BITS-1];

  generate
    genvar n;
    for (n = 0; n < 32; n++) begin
      assign lsh_op1_rev[n] = a_signed[31-n];
    end
  endgenerate

  always_ff @(posedge clk_i, negedge rst_n_i) begin
    if (!rst_n_i) begin
      temp_res <= '0;
      valid_mo_instr <= 1'b0;
    end else begin
      if (instr_i == ADDPOW) begin
        temp_res <= add_res[N_BITS:1];
        valid_mo_instr <= ops_valid_i;
      end else if (instr_i == ADDMUL) begin
        temp_res <= add_res[N_BITS:1];
        valid_mo_instr <= ops_valid_i;
      end else if (instr_i == ABSDIV) begin
        temp_res <= add_res[N_BITS:1];
        valid_mo_instr <= ops_valid_i;
      end
    end
  end

  always_comb begin

    add_op1 = {a_signed, 1'b0};
    add_op2 = {b_signed, 1'b0};
    mul_op1 = a_signed;
    mul_op2 = b_signed;
    div_op1 = a_signed;
    div_op2 = b_signed;
    shift_op1 = a_signed;
    shift_op2 = b_signed;

    case(instr_i)
      NOP: begin
        add_op1   = '0;
        add_op2   = '0;
        mul_op1   = '0;
        mul_op2   = '0;
        div_op1   = '0;
        div_op2   = '0;
        shift_op1 = '0;
        shift_op2 = '0;
      end

      ABS: begin
        add_op1 = {a_signed, 1'b0};
        add_op2 = sign_op1 ? {32'd1, 1'b0} : {32'd0, 1'b0};
      end

      SGNMUL: begin
        add_op1 = {b_signed, 1'b0};
        add_op2 = sign_op1 ? {32'd1, 1'b0} : {32'd0, 1'b0};
      end

      SUB: begin
        add_op1 = {a_signed, 1'b1};
        add_op2 = {op2_neg, 1'b1};
      end

      MIN: begin
        add_op1 = {a_signed, 1'b1};
        add_op2 = {op2_neg, 1'b1};
      end

      MAX: begin
        add_op1 = {a_signed, 1'b1};
        add_op2 = {op2_neg, 1'b1};
      end

      ARSH: begin 
        shift_op1 = {{32{a_signed[N_BITS-1]}}, a_signed};
        shift_op2 = b_signed;
      end

      LRSH: begin 
        shift_op1 = {32'd0, a_signed};
      end

      LSH: begin 
        shift_op1 = {32'd0, lsh_op1_rev};
      end

      ADDPOW: begin
        mul_op1 = temp_res;
        mul_op2 = temp_res;
      end
      
      ADDMUL: begin
        mul_op1 = temp_res;
        mul_op2 = const_i;
      end

      SGNSUB: begin
        add_op1 = {const_i, 1'b1};
        add_op2 = {op2_neg, 1'b1};
      end

      ABSDIV: begin
        add_op1 = {a_signed, 1'b0};
        add_op2 = sign_op1 ? {32'd1, 1'b0} : {32'd0, 1'b0};
        div_op1 = temp_res;
      end

    endcase
  end
  

  always_comb begin
    case (instr_i)
      NOP: res_o = 0;
      ADD: res_o = add_res[N_BITS:1];
      ACC: res_o = add_res[N_BITS:1];
      MUL: res_o = mul_res;
      SUB: res_o = add_res[N_BITS:1];
      LSH: res_o = lsh_res;
      ARSH: res_o = shift_res;
      LRSH: res_o = shift_res;
      MAX: res_o = (add_res[N_BITS-1]) ? b_i : a_i;
      MIN: res_o = (add_res[N_BITS-1]) ? a_i : b_i;
      DIV: res_o = quotient_div;
      DIVU: res_o = quotient_div;
      ABS: res_o = add_res[N_BITS:1];
      SGNMUL: res_o = add_res[N_BITS:1];
      REM: res_o = remainder_div;
      ADDPOW: res_o = mul_res;
      ABSDIV: res_o = quotient_div;
      ADDMUL: res_o = mul_res;
      SGNSUB: res_o = sign_op1 ? add_res[N_BITS:1] : b_signed;
      default: res_o = 0;
    endcase
  end

  assign rem_q_o = (instr_i == DIVU || instr_i == DIV || instr_i == ABSDIV) ? remainder_div : ((instr_i == REM) ? quotient_div : 0);

  %elif enable_streaming_interface == str(0) and enable_decoupling == str(1):
  fu_partitioned fu_partitioned_i (
    .clk_i,
    .rst_n_i,
    .a_i,
    .b_i,
    .instr_i,
    .vec_mode_i;
    .res_o,
  )
  %elif enable_streaming_interface == str(1) and enable_decoupling == str(1):
  %endif

endmodule
