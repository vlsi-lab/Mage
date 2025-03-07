// Copyright 2025 Politecnico di Torino.
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// File: cfg_regs_pea.sv
// Author: Alessio Naclerio
// Date: 26/02/2025
// Description: This module receives the configuration registers for the PEA set by the
//              external system in the order [PEA_ROW[TIME[PEA_COL * CFG_BITS_PE]]] and arranges them in the correct order for the PEA.
//              It also receives the address of the configuration register to be read and outputs the configuration of the PEA.

module cfg_regs_pea
  import pea_pkg::*;
(
    input logic [N-1:0][M-1:0][N_CFG_REGS_PE-1:0][32-1:0] reg_cfg_pea_i,
% if kernel_len != 1:
    input logic [N_CFG_ADDR_BITS-1:0] rcfg_ctrl_addr_i,
% endif
    output logic [N-1:0][M-1:0][N_CFG_BITS_PE-1:0] ctrl_pea_o
);
%if enable_streaming_interface == str(1):
  logic [N-1:0][M-1:0][0:0][N_CFG_BITS_PE-1:0] tmp_reg_cfg_pea;
%else:
  logic [N-1:0][M-1:0][CFG_BANK_SIZE-1:0][N_CFG_BITS_PE-1:0] tmp_reg_cfg_pea;
%endif

  //transform reg_cfg_pea_i to tmp_reg_cfg_pea
  always_comb begin
    for (int i = 0; i < N; i = i + 1) begin
      for (int j = 0; j < M; j = j + 1) begin
        // N_CFG_BITS_PE = 16
% for k in range(kernel_len):
  % if k%2 == 0:
        tmp_reg_cfg_pea[i][j][${k}] = reg_cfg_pea_i[i][j][${int(k/2)}][N_CFG_BITS_PE-1:0];
  % else:
        tmp_reg_cfg_pea[i][j][${k}] = reg_cfg_pea_i[i][j][${int(k/2)}][2*(N_CFG_BITS_PE)-1:N_CFG_BITS_PE];
  % endif
% endfor
      end
    end
  end

  always_comb begin
    for (int i = 0; i < N; i = i + 1) begin
      for (int j = 0; j < M; j = j + 1) begin
% if kernel_len == 1:
          ctrl_pea_o[i][j] = tmp_reg_cfg_pea[i][j][0];
% else:
          ctrl_pea_o[i][j] = tmp_reg_cfg_pea[i][j][rcfg_ctrl_addr_i];
% endif
      end
    end
  end

endmodule : cfg_regs_pea
