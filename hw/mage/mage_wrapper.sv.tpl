// Copyright 2025 Politecnico di Torino.
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// File: mage_wrapper.sv
// Author: Alessio Naclerio
// Date: 26/02/2025
// Description: Top entity for Mage ecnompassing the SpM, memory decoder and the CGRA

module mage_wrapper
%if enable_decoupling == str(1):
  import mage_pkg::*;
  import xbar_pkg::*;
%endif
%if enable_streaming_interface == str(1):
  import fifo_pkg::*;
  import stream_intf_pkg::*;
%endif
  import pea_pkg::*;
  import reg_pkg::*;
  import obi_pkg::*;
(
    input  logic      clk_i,
    input  logic      rst_n_i,
%if enable_streaming_interface == str(1):
    // HW FIFO interface
    input fifo_req_t [N_DMA_CH-1:0] fifo_req_i,
    output fifo_resp_t [N_DMA_CH-1:0] fifo_resp_o,
    output logic mage_done_o,
%endif
%if enable_decoupling == str(1):
    // AHB Slave
    input  obi_req_t  slave_req_i,
    output obi_resp_t slave_resp_o,
    //Interrupts
    output logic      mage_intr_o,
%endif
    // APB interface
    input  reg_req_t  reg_req_i,
    output reg_rsp_t  reg_rsp_o
);
%if enable_decoupling == str(1):
  //mage fsm state
  state_t                                                  state;
  //block size for dmem decoder
  logic   [                    3:0]                        reg_block_size;
  ////////////////////////////////////////////////////////////////
  //                Mage signals to Data Memory                 //
  ////////////////////////////////////////////////////////////////
  logic   [            N_BANKS-1:0]                        mage_dmem_req;
  logic   [            N_BANKS-1:0]                        mage_dmem_we;
  logic   [            N_BANKS-1:0]                        mage_dmem_valid;
  logic   [            N_BANKS-1:0][$clog2(BANK_SIZE)-1:0] mage_dmem_addr;
  logic   [            N_BANKS-1:0][           N_BITS-1:0] mage_dmem_wdata;
  logic   [            N_BANKS-1:0][           N_BITS-1:0] mage_dmem_rdata;
  ////////////////////////////////////////////////////////////////
  //               Decoded signals to Data Memory               //
  ////////////////////////////////////////////////////////////////
  logic   [            N_BANKS-1:0]                        dmem_req;
  logic   [            N_BANKS-1:0]                        dmem_we;
  logic   [            N_BANKS-1:0][$clog2(BANK_SIZE)-1:0] dmem_addr;
  logic   [            N_BANKS-1:0][           N_BITS-1:0] dmem_wdata;
  logic   [            N_BANKS-1:0][           N_BITS-1:0] dmem_rdata;
  ////////////////////////////////////////////////////////////////
  //              External signals to Data Memory               //
  ////////////////////////////////////////////////////////////////
  logic                                                    ext_dmem_req;
  logic                                                    ext_dmem_we;
  logic   [32-1:0]                        ext_dmem_addr;
  logic   [32-1:0]                        ext_dmem_wdata;
  logic   [32-1:0]                        ext_dmem_rdata;
  logic                                                    ext_dmem_valid;
%endif

  ////////////////////////////////////////////////////////////////
  //                            Mage                            //
  ////////////////////////////////////////////////////////////////
  mage_top mage_top_inst (
      .clk_i(clk_i),
      .rst_n_i(rst_n_i),
%if enable_streaming_interface == str(1):
      .fifo_req_i(fifo_req_i),
      .fifo_resp_o(fifo_resp_o),
      .mage_done_o(mage_done_o),
%endif
%if enable_decoupling == str(1):
      .state_o(state),
      .dmem_req_o(mage_dmem_req),
      .dmem_we_o(mage_dmem_we),
      .dmem_valid_o(mage_dmem_valid),
      .dmem_addr_o(mage_dmem_addr),
      .dmem_wdata_o(mage_dmem_wdata),
      .dmem_rdata_i(mage_dmem_rdata),
      .reg_block_size_o(reg_block_size),
      .mage_intr_o(mage_intr_o),
%endif
      .reg_req_i(reg_req_i),
      .reg_rsp_o(reg_rsp_o)
  );

%if enable_decoupling == str(1):
  ////////////////////////////////////////////////////////////////
  //                        Internal SpM                        //
  ////////////////////////////////////////////////////////////////
  data_memory data_memory_inst (
      .clk_i(clk_i),
      .rst_n_i(rst_n_i),
      .dmem_set_retentive_i(1'b0),
      .dmem_req_i(dmem_req),
      .dmem_be_i({N_BANKS{1'b1}}),
      .dmem_we_i(dmem_we),
      .dmem_addr_i(dmem_addr),
      .dmem_wdata_i(dmem_wdata),
      .dmem_rdata_o(dmem_rdata)
  );

  ////////////////////////////////////////////////////////////////
  //                        SpM Decoder                         //
  ////////////////////////////////////////////////////////////////
  dmem_decoder dmem_decoder_inst (
      .clk_i,
      .rst_n_i,
      .state_i(state),
      .reg_block_size_i(reg_block_size),
      .mage_dmem_req_i(mage_dmem_req),
      .mage_dmem_we_i(mage_dmem_we),
      .mage_dmem_valid_i(mage_dmem_valid),
      .mage_dmem_addr_i(mage_dmem_addr),
      .mage_dmem_wdata_i(mage_dmem_wdata),
      .ext_dmem_req_i(ext_dmem_req),
      .ext_dmem_we_i(ext_dmem_we),
      .ext_dmem_addr_i(ext_dmem_addr),
      .ext_dmem_wdata_i(ext_dmem_wdata),
      .dmem_req_o(dmem_req),
      .dmem_we_o(dmem_we),
      .dmem_addr_o(dmem_addr),
      .dmem_wdata_o(dmem_wdata),
      .mage_dmem_rdata_o(mage_dmem_rdata),
      .dmem_rdata_i(dmem_rdata),
      .ext_dmem_valid_o(ext_dmem_valid),
      .ext_dmem_gnt_o(),
      .ext_dmem_rdata_o(ext_dmem_rdata)
  );

  /* always_comb begin
    case(state)

      EXEC: begin
        slave_resp_o.gnt    = 1'b0;
        slave_resp_o.rvalid = 1'b0;
      end

      default: begin
        slave_resp_o.gnt    = 1'b1;
        slave_resp_o.rvalid = 1'b1;
      end
    endcase
  end */

  assign slave_resp_o.gnt    = 1'b1;
  assign slave_resp_o.rvalid = ext_dmem_valid;
  assign slave_resp_o.rdata  = ext_dmem_rdata;
  assign ext_dmem_req        = slave_req_i.req;
  assign ext_dmem_addr       = slave_req_i.addr;
  assign ext_dmem_we         = slave_req_i.we;
  //assign cm_be               = slave_req_i.be;
  assign ext_dmem_wdata      = slave_req_i.wdata;
%endif

endmodule : mage_wrapper
