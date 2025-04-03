// Copyright 2025 Politecnico di Torino.
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// File: mage_top.sv
// Author: Alessio Naclerio
// Date: 26/02/2025
// Description: Top level entity of Mage

module mage_top
  import hw_fifo_pkg::*;
  import stream_intf_pkg::*;
  import pea_pkg::*;
  import reg_pkg::*;
(
    input  logic                                          clk_i,
    input  logic                                          rst_n_i,
    //HW FIFO Interface
    input hw_fifo_req_t [N_DMA_CH-1:0] hw_fifo_req_i,
    output hw_fifo_resp_t [N_DMA_CH-1:0] hw_fifo_resp_o,
    //Reg Interface
    input  reg_req_t                                      reg_req_i,
    output reg_rsp_t                                      reg_rsp_o
);
  ////////////////////////////////////////////////////////////////
  //                      Streaming Interface                   //
  ////////////////////////////////////////////////////////////////
  logic [N_STREAM_OUT_PEA-1:0]             stream_pea_out_valid;
  logic [N_STREAM_OUT_PEA-1:0][N_BITS-1:0] stream_pea_data_out;
  logic [ N_STREAM_IN_PEA-1:0]             stream_pea_in_valid;
  logic [ N_STREAM_IN_PEA-1:0][N_BITS-1:0] stream_pea_data_in;
  logic [M-1:0] pea_ready;
  ////////////////////////////////////////////////////////////////
  //                 Stream Peripheral Registers                //
  ////////////////////////////////////////////////////////////////
  logic [N_DMA_CH-1:0] reg_dma_ch_cfg;
  logic [1:0] reg_separate_cols;
  logic [M-1:0][LOG_N:0] reg_stream_sel_out_pea;
  logic [N-1:0][M-1:0][7:0] reg_acc_value_pe;
  // xbar in signals
  logic [N_IN_STREAM-1:0][N_DMA_CH_PER_IN_STREAM-1:0][LOG_N_DMA_CH_PER_IN_STREAM-1:0] reg_in_stream_sel;
  // xbar out signals
  logic [N_OUT_STREAM-1:0][N_DMA_CH_PER_OUT_STREAM-1:0][LOG_N_PEA_DOUT_PER_OUT_STREAM-1:0] reg_out_stream_sel;
  ////////////////////////////////////////////////////////////////
  //           Processing Element Array Configuration           //
  ////////////////////////////////////////////////////////////////
  logic [N-1:0][M-1:0][N_CFG_REGS_PE-1:0][32-1:0] reg_cfg_pea;
  logic [N-1:0][M-1:0][N_CFG_BITS_PE-1:0] cfg_pea;
  logic [N-1:0][M-1:0][31:0] reg_constant_op_pea;


  ////////////////////////////////////////////////////////////////
  //              CSR and Configuration Registers               //
  ////////////////////////////////////////////////////////////////
  peripheral_regs peripheral_regs_inst (
      .clk_i(clk_i),
      .rst_n_i(rst_n_i),
      // reg interface
      .reg_req_i(reg_req_i),
      .reg_rsp_o(reg_rsp_o),
      .reg_separate_cols_o(reg_separate_cols),
      .reg_dma_ch_cfg_o(reg_dma_ch_cfg),
      .reg_sel_out_col_pea_o(reg_stream_sel_out_pea),
      .reg_acc_value_pe_o(reg_acc_value_pe),
      .reg_out_stream_sel_o(reg_out_stream_sel),
      .reg_in_stream_sel_o(reg_in_stream_sel),
      ////////////////////////////////////////////////////////////////
      //           Processing Element Array Configuration           //
      ////////////////////////////////////////////////////////////////
      .reg_pea_constants_o(reg_constant_op_pea),
      .reg_cfg_pea_o(reg_cfg_pea)
  );

  ////////////////////////////////////////////////////////////////
  //            MAGE Processing Element Array (PEA)             //
  ////////////////////////////////////////////////////////////////
  cfg_regs_pea cfg_regs_pea_inst (
      .reg_cfg_pea_i(reg_cfg_pea),
      .ctrl_pea_o(cfg_pea)
  );

  pea pea_inst (
      .clk_i(clk_i),
      .rst_n_i(rst_n_i),
      .ctrl_pea_i(cfg_pea),
      .reg_separate_cols_i(reg_separate_cols),
      .reg_acc_value_i(reg_acc_value_pe),
      .reg_stream_sel_out_pea_i(reg_stream_sel_out_pea),
      .stream_valid_o(stream_pea_out_valid),
      .stream_data_o(stream_pea_data_out),
      .stream_valid_i(stream_pea_in_valid),
      .stream_data_i(stream_pea_data_in),
      .pea_ready_o(pea_ready),
      .reg_constant_op_i(reg_constant_op_pea)
  );


  ////////////////////////////////////////////////////////////////
  //                      Streaming Interface                   //
  ////////////////////////////////////////////////////////////////

  streaming_interface streaming_interface_inst (
      .clk_i(clk_i),
      .rst_n_i(rst_n_i),
      .pea_ready_i(pea_ready),
      .reg_dma_ch_type_i(reg_dma_ch_cfg),
      .hw_fifo_req_i(hw_fifo_req_i),
      .hw_fifo_resp_o(hw_fifo_resp_o),
      .reg_separate_cols_i(reg_separate_cols),
      .reg_out_stream_sel_i(reg_out_stream_sel),
      .reg_in_stream_sel_i(reg_in_stream_sel),
      .dout_pea_i(stream_pea_data_out),
      .valid_pea_out_i(stream_pea_out_valid),
      .valid_pea_in_o(stream_pea_in_valid),
      .din_pea_o(stream_pea_data_in)
  );

endmodule : mage_top
