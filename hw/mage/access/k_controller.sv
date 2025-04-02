// Copyright 2025 Politecnico di Torino.
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// File: k_controller.sv
// Author: Alessio Naclerio
// Date: 26/02/2025
// Description: This module implements the PKE-based controller of the Mage-Cgra. However, P and E are not used.
//              Only K and the number of repetitions of the kernel are used. It also handles the delivery of the start signal
//              to Pea. Moreover, the count signal of the counter is used to the address to select the current configuration both in
//              Mage and Pea.

module k_controller
  import pea_pkg::*;
(
    input  logic                clk_i,
    input  logic                rst_n_i,
    input  logic                start_i,
    input  loop_pipeline_info_t reg_lp_info_i,
    output logic                start_d_o
);

  logic [3:0] start;


  always_ff @(posedge clk_i, negedge rst_n_i) begin : pke_controller_d_proc
    if (!rst_n_i) begin
      start <= '0;
      start_d_o <= '0;
    end else begin
      start[0]  <= start_i;
      start[1]  <= start[0];
      start[2]  <= start[1];
      start[3]  <= start[2];
      start_d_o <= start[3];
    end
  end

endmodule
