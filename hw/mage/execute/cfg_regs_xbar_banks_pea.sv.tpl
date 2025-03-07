// Copyright 2025 Politecnico di Torino.
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// File: cfg_regs_xbar_banks_pea.sv
// Author: Alessio Naclerio
// Date: 26/02/2025
// Description: This module reorganizes configuration bits to properly assign them to the crossbars mux

module cfg_regs_xbar_banks_pea
  import pea_pkg::*;
  import mage_pkg::*;
  import xbar_pkg::*;
(
    input logic [(N_CFG_REGS_32_XBAR_DMEM_PEA*32)-1:0] reg_cfg_xbar_dmem_pea_i,
    input logic [(N_CFG_REGS_32_XBAR_PEA_DMEM*32)-1:0] reg_cfg_xbar_pea_dmem_i,
% if kernel_len != 1:
    input logic [N_CFG_ADDR_BITS-1:0] rcfg_ctrl_addr_i,
% endif
    output logic [N_PE_GROUP-1:0][N_PE_PER_GROUP-1:0][LOG_N_BANKS_PER_STREAM-1:0] sel_dmem_pea_o,
    output logic [N_BANKS_GROUP-1:0][N_BANKS_PER_STREAM-1:0][LOG_N_PE_PER_GROUP-1:0] sel_pea_dmem_o
);

  logic [CFG_BANK_SIZE-1:0][N_PE_GROUP-1:0][N_PE_PER_GROUP-1:0][LOG_N_BANKS_PER_STREAM-1:0] cfg_xbar_dmem_pea;
  logic [CFG_BANK_SIZE-1:0][N_BANKS_GROUP-1:0][N_BANKS_PER_STREAM-1:0][LOG_N_PE_PER_GROUP-1:0] cfg_xbar_pea_dmem;

  always_comb begin
    for (int i = 0; i < CFG_BANK_SIZE; i = i + 1) begin
      for (int j = 0; j < N_PE_GROUP; j = j + 1) begin
        for (int k = 0; k < N_PE_PER_GROUP; k = k + 1) begin
          cfg_xbar_dmem_pea[i][j][k] =
              reg_cfg_xbar_dmem_pea_i[((i * N_PE_GROUP * N_PE_PER_GROUP + j * N_PE_PER_GROUP + k + 1) * LOG_N_BANKS_PER_STREAM) - 1 -: LOG_N_BANKS_PER_STREAM];

        end
      end
    end
  end

  always_comb begin
    for (int i = 0; i < CFG_BANK_SIZE; i = i + 1) begin
      for (int j = 0; j < N_BANKS_GROUP; j = j + 1) begin
        for (int k = 0; k < N_BANKS_PER_STREAM; k = k + 1) begin
          cfg_xbar_pea_dmem[i][j][k] =
              reg_cfg_xbar_pea_dmem_i[((i * N_BANKS_GROUP * N_BANKS_PER_STREAM + j * N_BANKS_PER_STREAM + k + 1) * LOG_N_PE_PER_GROUP) - 1 -: LOG_N_PE_PER_GROUP];
        end
      end
    end
  end

% if kernel_len != 1:
  always_comb begin
    for (int i = 0; i < N_PE_GROUP; i = i + 1) begin
      for (int j = 0; j < N_PE_PER_GROUP; j = j + 1) begin
        sel_dmem_pea_o[i][j] = cfg_xbar_dmem_pea[rcfg_ctrl_addr_i][i][j];
      end
    end
  end

  always_comb begin
    for (int i = 0; i < N_BANKS_GROUP; i = i + 1) begin
      for (int j = 0; j < N_BANKS_PER_STREAM; j = j + 1) begin
        sel_pea_dmem_o[i][j] = cfg_xbar_pea_dmem[rcfg_ctrl_addr_i][i][j];

      end
    end
  end
% else:
  always_comb begin
    for (int i = 0; i < N_PE_GROUP; i = i + 1) begin
      for (int j = 0; j < N_PE_PER_GROUP; j = j + 1) begin
        sel_dmem_pea_o[i][j] = cfg_xbar_dmem_pea[0][i][j];
      end
    end
  end

  always_comb begin
    for (int i = 0; i < N_BANKS_GROUP; i = i + 1) begin
      for (int j = 0; j < N_BANKS_PER_STREAM; j = j + 1) begin
        sel_pea_dmem_o[i][j] = cfg_xbar_pea_dmem[0][i][j];
      end
    end
  end 
% endif

endmodule : cfg_regs_xbar_banks_pea
