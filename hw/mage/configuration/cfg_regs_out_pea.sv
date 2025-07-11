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
    input logic [N-1:0][1:0][KMEM_SIZE-1:0][LOG_M-1:0] reg_cfg_sel_out_pea_i,
    input logic [N_CFG_ADDR_BITS-1:0] rcfg_ctrl_addr_i,
    output logic [N-1:0][1:0][LOG_M-1:0] sel_output_o
);

  always_comb begin
    for (int i = 0; i < N; i = i + 1) begin
      for (int j = 0; j < 2; j = j + 1) begin
        sel_output_o[i][j] = reg_cfg_sel_out_pea_i[i][j][rcfg_ctrl_addr_i];
      end
    end
  end

endmodule : cfg_regs_out_pea
