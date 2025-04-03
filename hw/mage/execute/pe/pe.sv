// Copyright 2025 Politecnico di Torino.
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// File: pe.sv
// Author: Alessio Naclerio
// Date: 26/02/2025
// Description: This module is the main building block of the Processing Element Array (PEA).
//              It contains the functional unit (FU) and the input operand multiplexers.

module pe
  import pea_pkg::*;
(
    input  logic                                 clk_i,
    input  logic                                 rst_n_i,
    input  logic [N_CFG_BITS_PE-1:0]             ctrl_pe_i,
    // Streaming Interface
    input  logic [              7:0]             reg_acc_value_i,
    input  logic                                 pea_ready_i,
    input  logic [  N_INPUTS_PE-4:0][N_BITS-1:0] neigh_pe_op_i,
    input  logic [  N_INPUTS_PE-4:0]             neigh_pe_op_valid_i,
    input  logic [   N_NEIGH_PE-1:0][N_BITS-1:0] neigh_delay_op_i,
    input  logic [   N_NEIGH_PE-1:0]             neigh_delay_op_valid_i,
    output logic                                 valid_o,
    output logic                                 ready_o,
    output logic                                 delay_op_valid_o,
    output logic [       N_BITS-1:0]             delay_op_o,
    output logic [       N_BITS-1:0]             pe_res_o
    // end Streaming Interface
);

  // output of operands muxes
  logic              [     N_BITS-1:0]             op_a;
  logic              [     N_BITS-1:0]             op_b;
  // mux selectors
  pe_mux_sel_t                                     mux_sel_a;
  pe_mux_sel_t                                     mux_sel_b;
  // output of operands-valid muxes
  logic                                            op_a_valid;
  logic                                            op_b_valid;
  // delay operands signals
  delay_pe_mux_sel_t                               delay_op_sel;
  logic              [     N_BITS-1:0]             delay_op_fu;
  logic              [     N_BITS-1:0]             delay_op_out;
  logic                                            delay_op_valid;
  logic                                            delay_op_valid_out;
  // actual inputs to muxes
  logic              [N_INPUTS_PE-1:0][N_BITS-1:0] operands;
  logic              [N_INPUTS_PE-1:0]             operands_valid;
  // fu signals
  logic                                            fu_ops_valid;
  logic                                            fu_valid;
  logic                                            fu_ready;
  // accumulation signals
  logic                                            valid;
  logic                                            acc_loopback;
  // accumulation signals
  logic              [            1:0]             vec_mode;
  logic                                            acc_counter_sel;
  //fu signals
  logic              [     N_BITS-1:0]             fu_out;
  logic              [     N_BITS-1:0]             rem_out;
  fu_instr_t                                       fu_instr;
  // RF
  logic              [     N_BITS-1:0]             rf;
  logic                                            rf_en;

  always_comb begin
    for (int i = 0; i < N_INPUTS_PE - 2; i++) begin
      operands[i] = neigh_pe_op_i[i];
      operands_valid[i] = neigh_pe_op_valid_i[i];
    end
    operands[N_INPUTS_PE-3] = pe_res_o;
    operands_valid[N_INPUTS_PE-3] = valid_o;
    operands[N_INPUTS_PE-2] = rf;
    operands_valid[N_INPUTS_PE-2] = 1'b1;
    operands[N_INPUTS_PE-1] = delay_op_fu;
    operands_valid[N_INPUTS_PE-1] = delay_op_valid;
  end

  ////////////////////////////////////////////////////////////////
  //                      PE Control Word                       //
  ////////////////////////////////////////////////////////////////
  always_comb begin
    mux_sel_a = pe_mux_sel_t'(ctrl_pe_i[LOG_N_INPUTS_PE-1 : 0]);
    mux_sel_b = pe_mux_sel_t'(ctrl_pe_i[2*LOG_N_INPUTS_PE-1 : LOG_N_INPUTS_PE]);
    if (acc_loopback) begin
      mux_sel_a = SELF;
    end
  end
  assign fu_instr         = fu_instr_t'(ctrl_pe_i[2 * LOG_N_INPUTS_PE + LOG_N_OPERATIONS - 1 : 2 * LOG_N_INPUTS_PE]);
  assign vec_mode         = ctrl_pe_i[2 * LOG_N_INPUTS_PE + LOG_N_OPERATIONS + 1 : 2 * LOG_N_INPUTS_PE + LOG_N_OPERATIONS];
  assign rf_en = ctrl_pe_i[2*LOG_N_INPUTS_PE+LOG_N_OPERATIONS+2];
  assign delay_op_sel     = delay_pe_mux_sel_t'(ctrl_pe_i[2 * LOG_N_INPUTS_PE + LOG_N_OPERATIONS + 5 : 2 * LOG_N_INPUTS_PE + LOG_N_OPERATIONS + 3]);

  ////////////////////////////////////////////////////////////////
  //                       Operand Selection                    //
  ////////////////////////////////////////////////////////////////
  assign op_a = operands[mux_sel_a];
  assign op_b = operands[mux_sel_b];
  assign op_a_valid = (mux_sel_a == SELF) ? 1'b1 : operands_valid[mux_sel_a];
  assign op_b_valid = (mux_sel_b == SELF) ? 1'b1 : operands_valid[mux_sel_b];
  assign fu_ops_valid = op_a_valid && op_b_valid;

  ////////////////////////////////////////////////////////////////
  //                   1-entry Register File                    //
  ////////////////////////////////////////////////////////////////
  always_ff @(posedge clk_i, negedge rst_n_i) begin
    if (!rst_n_i) begin
      rf <= '0;
    end else begin
      if (rf_en && fu_valid) begin
        rf <= fu_out;
      end
    end
  end

  ////////////////////////////////////////////////////////////////
  //                         Functional Unit                    //
  ////////////////////////////////////////////////////////////////
  fu_wrapper fu_wrapper_i (
      .clk_i(clk_i),
      .rst_n_i(rst_n_i),
      .a_i(op_a),
      .b_i(op_b),
      .reg_acc_value_i,
      .ops_valid_i(fu_ops_valid),
      .valid_o(fu_valid),
      .ready_o(fu_ready),
      .rem_o(rem_out),
      .acc_loopback_o(acc_loopback),
      .instr_i(fu_instr),
      .res_o(fu_out)
  );

  ////////////////////////////////////////////////////////////////
  //                    Delay Operand Selection                 //
  ////////////////////////////////////////////////////////////////
  assign delay_op_fu    = neigh_delay_op_i[delay_op_sel];
  assign delay_op_valid = neigh_delay_op_valid_i[delay_op_sel];
  always_comb begin
    delay_op_out = (delay_op_sel == D_PE_RES) ? ((fu_instr == DIVU) ? -rem_out : fu_out) : (
                   (delay_op_sel == D_PE_OP_A) ? op_a : (
                   (delay_op_sel == D_PE_OP_B) ? op_b : delay_op_fu
                  ));
    delay_op_valid_out = (delay_op_sel == D_PE_RES) ? fu_valid : (
                   (delay_op_sel == D_PE_OP_A) ? op_a_valid : (
                   (delay_op_sel == D_PE_OP_B) ? op_b_valid : delay_op_valid
                  ));
  end

  // Delay Operand Reg
  always_ff @(posedge clk_i, negedge rst_n_i) begin
    if (!rst_n_i) begin
      delay_op_o <= '0;
    end else begin
      if (pea_ready_i) begin
        delay_op_o <= delay_op_out;
      end else begin
        delay_op_o <= delay_op_o;
      end
    end
  end

  always_ff @(posedge clk_i, negedge rst_n_i) begin
    if (!rst_n_i) begin
      delay_op_valid_o <= 1'b0;
    end else begin
      if (pea_ready_i) begin
        delay_op_valid_o <= delay_op_valid_out;
      end else begin
        delay_op_valid_o <= delay_op_valid_o;
      end
    end
  end

  ////////////////////////////////////////////////////////////////
  //                      Output Register                       //
  ////////////////////////////////////////////////////////////////
  always_ff @(posedge clk_i, negedge rst_n_i) begin
    if (!rst_n_i) begin
      pe_res_o <= '0;
    end else begin
      if (fu_instr == NOP) begin
        pe_res_o <= '0;
      end else if((pea_ready_i && fu_valid) || ((fu_instr == ACC || fu_instr == MAX) && fu_ops_valid)) begin
        pe_res_o <= fu_out;
      end else begin
        pe_res_o <= pe_res_o;
      end
    end
  end

  ////////////////////////////////////////////////////////////////
  //                       Output Ready/Valid                   //
  ////////////////////////////////////////////////////////////////
  always_ff @(posedge clk_i, negedge rst_n_i) begin
    if (!rst_n_i) begin
      valid <= '0;
    end else begin
      if (fu_instr == NOP) begin
        valid <= 1'b0;
      end else if (pea_ready_i) begin
        valid <= fu_valid;
      end else begin
        valid <= valid_o;
      end
    end
  end

  assign valid_o = valid;
  assign ready_o = fu_ready;

endmodule
