// Copyright 2025 Politecnico di Torino.
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// File: cfg_regs_ls_stream_sel.sv
// Author: Alessio Naclerio
// Date: 26/02/2025
// Description: This module reorganizes configuration bits to properly assign them to the crossbars mux

module cfg_regs_ls_stream_sel
  import pea_pkg::*;
  import mage_pkg::*;
  import xbar_pkg::*;
(
    input logic [(N_CFG_REGS_LOAD_STREAM*32)-1:0] reg_cfg_l_stream_sel_i,
    input logic [(N_CFG_REGS_STORE_STREAM*32)-1:0] reg_cfg_s_stream_sel_i,
% if kernel_len != 1:
    input logic [N_ADDR_BITS_KMEM-1:0] rcfg_ctrl_addr_i,
% endif
    output logic [N_BANKS_GROUP-1:0][N_BANKS_PER_STREAM-1:0][LOG_N_AGE_PER_STREAM-1:0] l_stream_sel_o,
    output logic [N_BANKS_GROUP-1:0][N_BANKS_PER_STREAM-1:0][LOG_N_PE_PER_GROUP-1:0] s_stream_sel_o
);

  logic [KMEM_SIZE-1:0][N_BANKS_GROUP-1:0][N_BANKS_PER_STREAM-1:0][LOG_N_AGE_PER_STREAM-1:0] cfg_l_stream_sel;
  logic [KMEM_SIZE-1:0][N_BANKS_GROUP-1:0][N_BANKS_PER_STREAM-1:0][LOG_N_PE_PER_GROUP-1:0] cfg_s_stream_sel;

  always_comb begin
    for (int i = 0; i < KMEM_SIZE; i = i + 1) begin
      for (int j = 0; j < N_BANKS_GROUP; j = j + 1) begin
        for (int k = 0; k < N_BANKS_PER_STREAM; k = k + 1) begin
          cfg_l_stream_sel[i][j][k] =
              reg_cfg_l_stream_sel_i[((i * N_BANKS_GROUP * N_BANKS_PER_STREAM + j * N_BANKS_PER_STREAM + k + 1) * LOG_N_AGE_PER_STREAM) - 1 -: LOG_N_AGE_PER_STREAM];

        end
      end
    end
  end

  always_comb begin
    for (int i = 0; i < KMEM_SIZE; i = i + 1) begin
      for (int j = 0; j < N_BANKS_GROUP; j = j + 1) begin
        for (int k = 0; k < N_BANKS_PER_STREAM; k = k + 1) begin
          cfg_s_stream_sel[i][j][k] =
              reg_cfg_s_stream_sel_i[((i * N_BANKS_GROUP * N_BANKS_PER_STREAM + j * N_BANKS_PER_STREAM + k + 1) * LOG_N_PE_PER_GROUP) - 1 -: LOG_N_PE_PER_GROUP];
        end
      end
    end
  end

% if kernel_len == 1:
  always_comb begin
    for (int i = 0; i < N_BANKS_GROUP; i = i + 1) begin
      for (int j = 0; j < N_BANKS_PER_STREAM; j = j + 1) begin
        l_stream_sel_o[i][j] = cfg_l_stream_sel[0][i][j];
      end
    end
  end

  always_comb begin
    for (int i = 0; i < N_BANKS_GROUP; i = i + 1) begin
      for (int j = 0; j < N_BANKS_PER_STREAM; j = j + 1) begin
        s_stream_sel_o[i][j] = cfg_s_stream_sel[0][i][j];
      end
    end
  end
% else:
  always_comb begin
    for (int i = 0; i < N_BANKS_GROUP; i = i + 1) begin
      for (int j = 0; j < N_BANKS_PER_STREAM; j = j + 1) begin
        l_stream_sel_o[i][j] = cfg_l_stream_sel[rcfg_ctrl_addr_i][i][j];
      end
    end
  end

  always_comb begin
    for (int i = 0; i < N_BANKS_GROUP; i = i + 1) begin
      for (int j = 0; j < N_BANKS_PER_STREAM; j = j + 1) begin
        s_stream_sel_o[i][j] = cfg_s_stream_sel[rcfg_ctrl_addr_i][i][j];
      end
    end
  end
% endif


endmodule : cfg_regs_ls_stream_sel
