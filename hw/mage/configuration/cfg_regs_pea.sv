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
    input logic [N-1:0][M-1:0][KMEM_SIZE-1:0][N_CFG_BITS_PE-1:0] reg_cfg_pea_i,
    input logic [N_ADDR_BITS_KMEM-1:0] rcfg_ctrl_addr_i,
    output logic [N-1:0][M-1:0][N_CFG_BITS_PE-1:0] ctrl_pea_o
);

  always_comb begin
    for (int i = 0; i < N; i = i + 1) begin
      for (int j = 0; j < M; j = j + 1) begin
        ctrl_pea_o[i][j] = reg_cfg_pea_i[i][j][rcfg_ctrl_addr_i];
      end
    end
  end

endmodule : cfg_regs_pea
