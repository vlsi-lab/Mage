// Copyright 2025 Politecnico di Torino.
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// File: s_pe.sv
// Author: Alessio Naclerio
// Date: 26/02/2025
// Description: This module is the main building block of the Processing Element Array (PEA) for Mage in streaming mode.
//              It contains the functional unit (FU) and the input operand multiplexers.

module s_pe
  import pea_pkg::*;
(
    input  logic                                 clk_i,
    input  logic                                 rst_n_i,
    input  logic                                 mage_done_i,
    input  logic [N_CFG_BITS_PE-1:0]             ctrl_pe_i,
    // Streaming Interface
    input  logic [             31:0]             reg_acc_value_i,
    input  logic                                 pea_ready_i,
    input  logic [       N_BITS-1:0]             reg_const_i,
    output logic                                 reg_pea_rf_de_o,
    output logic [       N_BITS-1:0]             reg_pea_rf_d_o,
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
  logic              [     N_BITS-1:0]             delay_op_out_d1;
  logic              [     N_BITS-1:0]             delay_op_out_d2;
  logic                                            delay_op_valid;
  logic                                            delay_op_valid_out;
  logic                                            delay_op_valid_out_d1;
  logic                                            delay_op_valid_out_d2;
  // actual inputs to muxes
  logic              [N_INPUTS_PE-1:0][N_BITS-1:0] operands;
  logic              [N_INPUTS_PE-1:0]             operands_valid;
  // fu signals
  logic                                            fu_ops_valid;
  logic                                            fu_valid;
  logic                                            fu_ready;
  logic                                            multi_op_instr;
  // accumulation signals
  logic                                            valid;
  logic                                            acc_loopback;
  // accumulation signals
  logic              [            1:0]             vec_mode;
  logic                                            acc_counter_sel;
  //fu signals
  logic              [     N_BITS-1:0]             fu_out;
  fu_instr_t                                       fu_instr;
  // RF
  logic              [     N_BITS-1:0]             rf;
  logic                                            rf_en;

  always_comb begin
    for (int i = 0; i < N_INPUTS_PE - 3; i++) begin
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

  always_comb begin
    reg_pea_rf_de_o = rf_en && valid_o;
    reg_pea_rf_d_o  = pe_res_o;
  end

  ////////////////////////////////////////////////////////////////
  //                         Functional Unit                    //
  ////////////////////////////////////////////////////////////////
  fu_wrapper fu_wrapper_i (
      .clk_i(clk_i),
      .rst_n_i(rst_n_i),
      .a_i(op_a),
      .b_i(op_b),
      .const_i(reg_const_i),
      .reg_acc_value_i,
      .pea_ready_i,
      .ops_valid_i(fu_ops_valid),
      .valid_o(fu_valid),
      .ready_o(fu_ready),
      .acc_loopback_o(acc_loopback),
      .instr_i(fu_instr),
      .res_o(fu_out)
  );

  ////////////////////////////////////////////////////////////////
  //                    Delay Operand Selection                 //
  ////////////////////////////////////////////////////////////////

  // delayed operand selection, it is one among the possible operands of the PE FU 
  assign delay_op_fu    = neigh_delay_op_i[delay_op_sel];
  // delayed operand valid selection
  assign delay_op_valid = neigh_delay_op_valid_i[delay_op_sel];
  /* output delay data selection
    ->  delay_op_out = fu_out      if delay_op_sel == D_PE_RES
    ->  delay_op_out = op_a        if delay_op_sel == D_PE_OP_A
    ->  delay_op_out = op_b        if delay_op_sel == D_PE_OP_B
    ->  delay_op_out = delay_op_fu if delay_op_sel == D_PE_DELAY_OP
    in the default case, delay_op_out is set fed with delay_op_fu,
    but it can be decided to forward also the result of the PE FU or one of its operands
  */
  always_comb begin
    delay_op_out = (delay_op_sel == D_PE_RES) ? fu_out : (
                   (delay_op_sel == D_PE_OP_A) ? op_a : (
                   (delay_op_sel == D_PE_OP_B) ? op_b : delay_op_fu
                  ));
    delay_op_valid_out = (delay_op_sel == D_PE_RES) ? fu_valid : (
                   (delay_op_sel == D_PE_OP_A) ? op_a_valid : (
                   (delay_op_sel == D_PE_OP_B) ? op_b_valid : delay_op_valid
                  ));
  end

  // multi_op_instr is asserted when the instruction is a multi-operand one
  assign multi_op_instr = (fu_instr == ABSDIV || fu_instr == ABSMIN || fu_instr[4] == 1'b1);

  // Delay Operand Reg
  always_ff @(posedge clk_i, negedge rst_n_i) begin
    if (!rst_n_i) begin
      delay_op_out_d1 <= '0;
      delay_op_out_d2 <= '0;
    end else begin
      if (!mage_done_i && pea_ready_i) begin
        delay_op_out_d1 <= delay_op_out;
        delay_op_out_d2 <= delay_op_out_d1;
      end
    end
  end

  // Delay Operand Valid Reg
  always_ff @(posedge clk_i, negedge rst_n_i) begin
    if (!rst_n_i) begin
      delay_op_valid_out_d1 <= 1'b0;
      delay_op_valid_out_d2 <= 1'b0;
    end else begin
      if (!mage_done_i && pea_ready_i) begin
        delay_op_valid_out_d1 <= delay_op_valid_out;
        delay_op_valid_out_d2 <= delay_op_valid_out_d1;
      end
    end
  end

  /* 
  Delay Operand Output Mux
    The output of the delay operand is selected based on the instruction
    If the instruction is a multi-operand one, the output is selected from the second delay register
    Otherwise, the output is selected from the first delay register
  */
  always_comb begin
    delay_op_o = (!multi_op_instr || delay_op_sel == D_PE_RES) ? delay_op_out_d1 : delay_op_out_d2;
    delay_op_valid_o = (!multi_op_instr || delay_op_sel == D_PE_RES) ? delay_op_valid_out_d1 : delay_op_valid_out_d2;
  end

  ////////////////////////////////////////////////////////////////
  //                      Output Register                       //
  ////////////////////////////////////////////////////////////////

  /*
    The output register of the PE is set to:
      -> 0 when the instruction is NOP
      -> result of the FU when the instruction is not NOP, the output of the FU is valid and the pea is ready
      -> result of the FU when the instruction is ACC or MAX, the operands are valid and the pea is ready
      -> to itself otherwise, to preserve the current value
  */
  always_ff @(posedge clk_i, negedge rst_n_i) begin
    if (!rst_n_i) begin
      pe_res_o <= '0;
    end else begin
      if (!mage_done_i) begin
        if (fu_instr == NOP) begin
          pe_res_o <= '0;
        end else if((pea_ready_i && fu_valid) || ((fu_instr == ACC || fu_instr == MAX) && fu_ops_valid && pea_ready_i)) begin
          pe_res_o <= fu_out;
        end else begin
          pe_res_o <= pe_res_o;
        end
      end else begin
        pe_res_o <= '0;
      end
    end
  end

  ////////////////////////////////////////////////////////////////
  //                       Output Ready/Valid                   //
  ////////////////////////////////////////////////////////////////

  /*
    The output valid signal is set to:
      -> 0 when the instruction is NOP
      -> the FU valid signal when the pea is ready
      -> to itself otherwise, to preserve the current value
  */
  always_ff @(posedge clk_i, negedge rst_n_i) begin
    if (!rst_n_i) begin
      valid <= '0;
    end else begin
      if (!mage_done_i) begin
        if (fu_instr == NOP) begin
          valid <= 1'b0;
        end else if (pea_ready_i) begin
          valid <= fu_valid;
        end else begin
          valid <= valid_o;
        end
      end else begin
        valid <= 1'b0;
      end
    end
  end

  assign valid_o = valid;
  assign ready_o = fu_ready;

endmodule
