// Copyright 2025 Politecnico di Torino.
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// File: xbar_banks_pea_bb.sv
// Author: Alessio Naclerio
// Date: 26/02/2025
// Description: Basic Block for the Pipelined Crossbar between Banks and PE Array

module xbar_banks_pea_bb
  import pea_pkg::*;
  import mage_pkg::*;
  import xbar_pkg::*;
(
    //Input signals from PE and SpM Group
    input  logic [       N_PE_PER_BB-1:0][N_BITS-1:0] out_pea_bb_i,
    input  logic [    N_BANKS_PER_BB-1:0][N_BITS-1:0] out_dmem_bb_i,
    //Selectors
    input  logic [LOG_N_BANKS_PER_BB-1:0]             sel_dmem_pea_bb_i,
    input  logic [   LOG_N_PE_PER_BB-1:0]             sel_pea_dmem_bb_i,
    //Output signals to PE and SpM Group
    output logic [            N_BITS-1:0]             in_pea_bb_o,
    output logic [            N_BITS-1:0]             in_dmem_bb_o
);

  always_comb begin
    in_pea_bb_o  = out_dmem_bb_i[sel_dmem_pea_bb_i];
    in_dmem_bb_o = out_pea_bb_i[sel_pea_dmem_bb_i];
  end

endmodule
