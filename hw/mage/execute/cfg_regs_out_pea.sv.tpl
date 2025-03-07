// Copyright 2025 Politecnico di Torino.
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// File: cfg_regs_out_pea.sv
// Author: Alessio Naclerio
// Date: 26/02/2025
// Description: This module arranges the selectors for PEA outputs and also chooses the correct selector based on the configuration address (rcfg_ctrl_addr_i)

module cfg_regs_out_pea
  import pea_pkg::*;
  import xbar_pkg::*;
(
    input  logic [(N_CFG_REGS_32_SEL_OUT_PEA*32)-1:0]            reg_cfg_sel_out_pea_i,
% if kernel_len != 1:
    input  logic [               N_CFG_ADDR_BITS-1:0]            rcfg_ctrl_addr_i,
% endif
    output logic [                     N_OUT_PEA-1:0][LOG_M-1:0] sel_output_o
);

  //N_OUT_PEA = N*2

  logic [CFG_BANK_SIZE-1:0][N_OUT_PEA-1:0][LOG_M-1:0] cfg_sel_out_pea;

  always_comb begin
    for (int i = 0; i < CFG_BANK_SIZE; i = i + 1) begin
      for (int j = 0; j < N_OUT_PEA; j = j + 1) begin
        cfg_sel_out_pea[i][j] = reg_cfg_sel_out_pea_i[((i*N_OUT_PEA+j+1)*LOG_M)-1-:LOG_M];
      end
    end
  end

% if kernel_len != 1:
  always_comb begin
    for (int i = 0; i < N_OUT_PEA; i = i + 1) begin
      sel_output_o[i] = cfg_sel_out_pea[rcfg_ctrl_addr_i][i];
    end
  end
% else:
  always_comb begin
    for (int i = 0; i < N_OUT_PEA; i = i + 1) begin
      sel_output_o[i] = cfg_sel_out_pea[0][i];
    end
  end
% endif
endmodule : cfg_regs_out_pea
