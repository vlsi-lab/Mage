// Copyright 2025 Politecnico di Torino.
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// File: peripheral_registers.sv
// Author: Alessio Naclerio
// Date: 26/02/2025
// Description: This module handles the relationship between the peripheral registers and Mage-Cgra

module peripheral_regs
  import stream_intf_pkg::*;
  import pea_pkg::*;
  import reg_pkg::*;
  import mage_reg_pkg::*;
(
    input logic clk_i,
    input logic rst_n_i,
    input reg_req_t reg_req_i,
    output reg_rsp_t reg_rsp_o,
    ////////////////////////////////////////////////////////////////
    //               Mage Streaming Configuration                 //
    ////////////////////////////////////////////////////////////////
    output logic reg_separate_cols_o,
    output logic [N_DMA_CH-1:0] reg_dma_ch_cfg_o,
    output logic [M-1:0][LOG_N:0] reg_sel_out_col_pea_o,
    output logic [N-1:0][M-1:0][7:0] reg_acc_value_pe_o,
    output logic [N_OUT_STREAM-1:0][N_DMA_CH_PER_OUT_STREAM-1:0][LOG_N_PEA_DOUT_PER_OUT_STREAM-1:0] reg_out_stream_sel_o,
    output logic [N_IN_STREAM-1:0][N_DMA_CH_PER_IN_STREAM-1:0][LOG_N_DMA_CH_PER_IN_STREAM-1:0] reg_in_stream_sel_o,
    ////////////////////////////////////////////////////////////////
    //           Processing Element Array Configuration           //
    ////////////////////////////////////////////////////////////////
    output logic [N-1:0][M-1:0][31:0] reg_pea_constants_o,
    output logic [N-1:0][M-1:0][N_CFG_REGS_PE-1:0][32-1:0] reg_cfg_pea_o
);
  mage_reg2hw_t reg2hw;

  mage_reg_top #(
      .reg_req_t(reg_req_t),
      .reg_rsp_t(reg_rsp_t)
  ) mage_reg_top_i (
      .clk_i(clk_i),
      .rst_ni(rst_n_i),
      .reg_req_i(reg_req_i),
      .reg_rsp_o(reg_rsp_o),
      .reg2hw(reg2hw),
      .devmode_i(1'b1)
  );

  always_comb begin
    ////////////////////////////////////////////////////////////////
    //                Streaming Mage Configuration                //
    ////////////////////////////////////////////////////////////////
    reg_separate_cols_o = reg2hw.separate_cols.q;
    reg_dma_ch_cfg_o = reg2hw.stream_dma_cfg.q;
    reg_sel_out_col_pea_o[0] = reg2hw.sel_out_col_pea[0].sel_col_0.q;
    reg_sel_out_col_pea_o[1] = reg2hw.sel_out_col_pea[0].sel_col_1.q;
    reg_sel_out_col_pea_o[2] = reg2hw.sel_out_col_pea[0].sel_col_2.q;
    reg_sel_out_col_pea_o[3] = reg2hw.sel_out_col_pea[0].sel_col_3.q;
    reg_acc_value_pe_o[0][0] = reg2hw.acc_value[0].pe_0.q;
    reg_acc_value_pe_o[0][1] = reg2hw.acc_value[0].pe_1.q;
    reg_acc_value_pe_o[0][2] = reg2hw.acc_value[0].pe_2.q;
    reg_acc_value_pe_o[0][3] = reg2hw.acc_value[0].pe_3.q;
    reg_acc_value_pe_o[1][0] = reg2hw.acc_value[1].pe_0.q;
    reg_acc_value_pe_o[1][1] = reg2hw.acc_value[1].pe_1.q;
    reg_acc_value_pe_o[1][2] = reg2hw.acc_value[1].pe_2.q;
    reg_acc_value_pe_o[1][3] = reg2hw.acc_value[1].pe_3.q;
    reg_acc_value_pe_o[2][0] = reg2hw.acc_value[2].pe_0.q;
    reg_acc_value_pe_o[2][1] = reg2hw.acc_value[2].pe_1.q;
    reg_acc_value_pe_o[2][2] = reg2hw.acc_value[2].pe_2.q;
    reg_acc_value_pe_o[2][3] = reg2hw.acc_value[2].pe_3.q;
    reg_acc_value_pe_o[3][0] = reg2hw.acc_value[3].pe_0.q;
    reg_acc_value_pe_o[3][1] = reg2hw.acc_value[3].pe_1.q;
    reg_acc_value_pe_o[3][2] = reg2hw.acc_value[3].pe_2.q;
    reg_acc_value_pe_o[3][3] = reg2hw.acc_value[3].pe_3.q;
    reg_out_stream_sel_o[0][0] = reg2hw.stream_out_xbar_sel.sel_out_xbar_0;
    reg_out_stream_sel_o[0][1] = reg2hw.stream_out_xbar_sel.sel_out_xbar_1;
    reg_out_stream_sel_o[1][0] = reg2hw.stream_out_xbar_sel.sel_out_xbar_2;
    reg_out_stream_sel_o[1][1] = reg2hw.stream_out_xbar_sel.sel_out_xbar_3;
    reg_in_stream_sel_o[0][0] = reg2hw.stream_in_xbar_sel.sel_in_xbar_0;
    reg_in_stream_sel_o[0][1] = reg2hw.stream_in_xbar_sel.sel_in_xbar_1;
    reg_in_stream_sel_o[1][0] = reg2hw.stream_in_xbar_sel.sel_in_xbar_2;
    reg_in_stream_sel_o[1][1] = reg2hw.stream_in_xbar_sel.sel_in_xbar_3;
    ////////////////////////////////////////////////////////////////
    //                   Mage PEA Configuration                   //
    ////////////////////////////////////////////////////////////////
    reg_pea_constants_o[0][0] = reg2hw.pea_constants[0].q;
    reg_pea_constants_o[0][1] = reg2hw.pea_constants[1].q;
    reg_pea_constants_o[0][2] = reg2hw.pea_constants[2].q;
    reg_pea_constants_o[0][3] = reg2hw.pea_constants[3].q;
    reg_pea_constants_o[1][0] = reg2hw.pea_constants[4].q;
    reg_pea_constants_o[1][1] = reg2hw.pea_constants[5].q;
    reg_pea_constants_o[1][2] = reg2hw.pea_constants[6].q;
    reg_pea_constants_o[1][3] = reg2hw.pea_constants[7].q;
    reg_pea_constants_o[2][0] = reg2hw.pea_constants[8].q;
    reg_pea_constants_o[2][1] = reg2hw.pea_constants[9].q;
    reg_pea_constants_o[2][2] = reg2hw.pea_constants[10].q;
    reg_pea_constants_o[2][3] = reg2hw.pea_constants[11].q;
    reg_pea_constants_o[3][0] = reg2hw.pea_constants[12].q;
    reg_pea_constants_o[3][1] = reg2hw.pea_constants[13].q;
    reg_pea_constants_o[3][2] = reg2hw.pea_constants[14].q;
    reg_pea_constants_o[3][3] = reg2hw.pea_constants[15].q;
    for (int i = 0; i < N_CFG_REGS_PE; i++) begin
      reg_cfg_pea_o[0][0][i] = reg2hw.cfg_pe_00[i].q;
      reg_cfg_pea_o[0][1][i] = reg2hw.cfg_pe_01[i].q;
      reg_cfg_pea_o[0][2][i] = reg2hw.cfg_pe_02[i].q;
      reg_cfg_pea_o[0][3][i] = reg2hw.cfg_pe_03[i].q;
      reg_cfg_pea_o[1][0][i] = reg2hw.cfg_pe_10[i].q;
      reg_cfg_pea_o[1][1][i] = reg2hw.cfg_pe_11[i].q;
      reg_cfg_pea_o[1][2][i] = reg2hw.cfg_pe_12[i].q;
      reg_cfg_pea_o[1][3][i] = reg2hw.cfg_pe_13[i].q;
      reg_cfg_pea_o[2][0][i] = reg2hw.cfg_pe_20[i].q;
      reg_cfg_pea_o[2][1][i] = reg2hw.cfg_pe_21[i].q;
      reg_cfg_pea_o[2][2][i] = reg2hw.cfg_pe_22[i].q;
      reg_cfg_pea_o[2][3][i] = reg2hw.cfg_pe_23[i].q;
      reg_cfg_pea_o[3][0][i] = reg2hw.cfg_pe_30[i].q;
      reg_cfg_pea_o[3][1][i] = reg2hw.cfg_pe_31[i].q;
      reg_cfg_pea_o[3][2][i] = reg2hw.cfg_pe_32[i].q;
      reg_cfg_pea_o[3][3][i] = reg2hw.cfg_pe_33[i].q;
    end
  end

endmodule : peripheral_regs
