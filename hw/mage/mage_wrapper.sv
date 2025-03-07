// Copyright 2025 Politecnico di Torino.
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// File: mage_wrapper.sv
// Author: Alessio Naclerio
// Date: 26/02/2025
// Description: Top entity for Mage ecnompassing the SpM, memory decoder and the CGRA

module mage_wrapper
  import hw_fifo_pkg::*;
  import stream_intf_pkg::*;
  import pea_pkg::*;
  import reg_pkg::*;
  import obi_pkg::*;
(
    input  logic      clk_i,
    input  logic      rst_n_i,
    // HW FIFO interface
    input hw_fifo_req_t [N_DMA_CH-1:0] hw_fifo_req_i,
    output hw_fifo_resp_t [N_DMA_CH-1:0] hw_fifo_resp_o,
    // APB interface
    input  reg_req_t  reg_req_i,
    output reg_rsp_t  reg_rsp_o
);

  ////////////////////////////////////////////////////////////////
  //                            Mage                            //
  ////////////////////////////////////////////////////////////////
  mage_top mage_top_inst (
      .clk_i(clk_i),
      .rst_n_i(rst_n_i),
      .hw_fifo_req_i(hw_fifo_req_i),
      .hw_fifo_resp_o(hw_fifo_resp_o),
      .reg_req_i(reg_req_i),
      .reg_rsp_o(reg_rsp_o)
  );


endmodule : mage_wrapper
