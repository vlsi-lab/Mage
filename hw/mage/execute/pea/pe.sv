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
    input  logic                                     clk_i,
    input  logic                                     rst_n_i,
    input  logic [      N_INPUTS_PE-1:0][N_BITS-1:0] pe_op_i,
    input  logic [    N_CFG_BITS_PE-1:0]             ctrl_pe_i,
    // Streaming Interface
    input  logic [                  7:0]             reg_acc_value_i,
    input  logic [N_INPUTS_VALID_PE-1:0]             stream_valid_i,
    output logic                                     stream_valid_o,
    // end Streaming Interface
    output logic [           N_BITS-1:0]             pe_res_o
);

  //output of input muxes
  logic      [         N_BITS-1:0] mux1_out;
  logic      [         N_BITS-1:0] mux2_out;
  logic                            stream_valid_a;
  logic                            stream_valid_b;
  logic      [LOG_N_INPUTS_PE-1:0] mux1_sel;
  logic      [LOG_N_INPUTS_PE-1:0] mux2_sel;
  logic      [LOG_N_INPUTS_PE-1:0] mux1_sel_valid;
  logic      [LOG_N_INPUTS_PE-1:0] mux2_sel_valid;
  logic      [                1:0] vec_mode;
  logic                            acc_counter_sel;

  //fu signals
  logic      [         N_BITS-1:0] fu_out;
  fu_instr_t                       fu_sel;
  logic      [                7:0] acc_cnt;
  logic                            acc_ready;


  ////////////////////////////////////////////////////////////////
  //                      PE Control Word                       //
  ////////////////////////////////////////////////////////////////
  assign mux1_sel = ctrl_pe_i[LOG_N_INPUTS_PE-1 : 0];
  assign mux2_sel = ctrl_pe_i[LOG_N_INPUTS_PE+LOG_N_INPUTS_PE-1 : LOG_N_INPUTS_PE];
  assign fu_sel = fu_instr_t'(ctrl_pe_i[LOG_N_INPUTS_PE+LOG_N_INPUTS_PE+LOG_N_OPERATIONS-1 : LOG_N_INPUTS_PE+LOG_N_INPUTS_PE]);
  assign acc_counter_sel = ctrl_pe_i[LOG_N_INPUTS_PE+LOG_N_INPUTS_PE+LOG_N_OPERATIONS];
  assign vec_mode = ctrl_pe_i[LOG_N_INPUTS_PE+LOG_N_INPUTS_PE+LOG_N_OPERATIONS+2 : LOG_N_INPUTS_PE+LOG_N_INPUTS_PE+LOG_N_OPERATIONS+1];

  always_comb begin
    case (mux1_sel)
      3'b000:  mux1_sel_valid = mux1_sel;
      3'b001:  mux1_sel_valid = 3'b110;
      default: mux1_sel_valid = mux1_sel - 1;
    endcase
  end
  always_comb begin
    case (mux2_sel)
      3'b000:  mux2_sel_valid = mux2_sel;
      3'b001:  mux2_sel_valid = 3'b110;
      default: mux2_sel_valid = mux2_sel - 1;
    endcase
  end
  assign stream_valid_a = (mux1_sel_valid == 3'b110) ? 1'b1 : stream_valid_i[mux1_sel_valid];
  assign stream_valid_b = (mux2_sel_valid == 3'b110) ? 1'b1 : stream_valid_i[mux2_sel_valid];

  ////////////////////////////////////////////////////////////////
  //                Partitioned Functional Unit                 //
  ////////////////////////////////////////////////////////////////
  fu int_fu (
      .clk_i(clk_i),
      .rst_n_i(rst_n_i),
      .a_i(mux1_out),
      .b_i(mux2_out),
      .reg_acc_value_i,
      .acc_ready_i(acc_ready),
      .stream_valid_a_i(stream_valid_a),
      .stream_valid_b_i(stream_valid_b),
      .stream_valid_o,
      .instr_i(fu_sel),
      //.vec_mode_i(vec_mode),
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

  always_ff @(posedge clk_i, negedge rst_n_i) begin
    if (!rst_n_i) begin
      acc_cnt <= 8'd0;
    end else begin
      if (fu_sel == ACC && stream_valid_a && stream_valid_b) begin
        if (acc_ready) begin
          acc_cnt <= 8'd0;
        end else begin
          acc_cnt <= acc_cnt + 8'd1;
        end
      end
    end
  end

  assign acc_ready = (acc_cnt == reg_acc_value_i);

  always_comb begin
    if (fu_sel == ACC) begin
      if (acc_cnt == 8'd0) begin
        mux1_out = pe_op_i[mux1_sel];
        mux2_out = pe_op_i[mux2_sel];
      end else begin
        mux1_out = pe_res_o;
        mux2_out = pe_op_i[mux2_sel];
      end
    end else begin
      mux1_out = pe_op_i[mux1_sel];
      mux2_out = pe_op_i[mux2_sel];
    end
  end
endmodule
