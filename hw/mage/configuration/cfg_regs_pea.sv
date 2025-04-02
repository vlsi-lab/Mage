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
    output logic [N-1:0][M-1:0][N_CFG_BITS_PE-1:0] ctrl_pea_o
);
  logic [N-1:0][M-1:0][0:0][N_CFG_BITS_PE-1:0] tmp_reg_cfg_pea;

  //transform reg_cfg_pea_i to tmp_reg_cfg_pea
  always_comb begin
    for (int i = 0; i < N; i = i + 1) begin
      for (int j = 0; j < M; j = j + 1) begin
        // N_CFG_BITS_PE = 16
        tmp_reg_cfg_pea[i][j][0] = reg_cfg_pea_i[i][j][0][N_CFG_BITS_PE-1:0];
      end
    end
  end

  always_comb begin
    for (int i = 0; i < N; i = i + 1) begin
      for (int j = 0; j < M; j = j + 1) begin
        ctrl_pea_o[i][j] = tmp_reg_cfg_pea[i][j][0];
      end
    end
  end

endmodule : cfg_regs_pea
