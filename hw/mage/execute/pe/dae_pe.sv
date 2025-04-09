// Copyright 2025 Politecnico di Torino.
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// File: dae_pe.sv
// Author: Alessio Naclerio
// Date: 26/02/2025
// Description: This module is the main building block of the Processing Element Array (PEA) for Mage in Decoupled Access_execute mode.
//              It contains the partitioned functional unit (FU) and the input operand multiplexers.

module dae_pe
  import pea_pkg::*;
(
    input  logic                                 clk_i,
    input  logic                                 rst_n_i,
    input  logic [  N_INPUTS_PE-1:0][N_BITS-1:0] pe_op_i,
    input  logic [N_CFG_BITS_PE-1:0]             ctrl_pe_i,
    output logic [       N_BITS-1:0]             pe_res_o
);

  //output of input muxes
  logic      [         N_BITS-1:0] op_a;
  logic      [         N_BITS-1:0] op_b;
  logic      [LOG_N_INPUTS_PE-1:0] mux_a_sel;
  logic      [LOG_N_INPUTS_PE-1:0] mux_b_sel;
  logic      [                1:0] vec_mode;

  //fu signals
  logic      [         N_BITS-1:0] fu_out;
  fu_instr_t                       fu_instr;

  ////////////////////////////////////////////////////////////////
  //                      PE Control Word                       //
  ////////////////////////////////////////////////////////////////
  assign mux_a_sel = pe_mux_sel_t'(ctrl_pe_i[LOG_N_INPUTS_PE-1 : 0]);
  assign mux_b_sel = pe_mux_sel_t'(ctrl_pe_i[2*LOG_N_INPUTS_PE-1 : LOG_N_INPUTS_PE]);
  assign fu_instr  = fu_instr_t'(ctrl_pe_i[2 * LOG_N_INPUTS_PE + LOG_N_OPERATIONS - 1 : 2 * LOG_N_INPUTS_PE]);
  assign vec_mode  = ctrl_pe_i[2 * LOG_N_INPUTS_PE + LOG_N_OPERATIONS + 1 : 2 * LOG_N_INPUTS_PE + LOG_N_OPERATIONS];

  //input operand muxes
  assign op_a = pe_op_i[mux_a_sel];
  assign op_b = pe_op_i[mux_b_sel];

  ////////////////////////////////////////////////////////////////
  //                Partitioned Functional Unit                 //
  ////////////////////////////////////////////////////////////////
  fu_partitioned int_fu (
      .clk_i(clk_i),
      .rst_n_i(rst_n_i),
      .a_i(op_a),
      .b_i(op_b),
      .instr_i(fu_instr),
      .vec_mode_i(vec_mode),
      .res_o(fu_out)
  );

  //PE output register
  always_ff @(posedge clk_i, negedge rst_n_i) begin
    if (!rst_n_i) begin
      pe_res_o <= 0;
    end else begin
      pe_res_o <= fu_out;
    end
  end

endmodule
