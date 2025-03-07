// Copyright 2025 Politecnico di Torino.
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// File: dma_pea_xbar.sv
// Author: Alessio Naclerio
// Date: 26/02/2025
// Description: Crossbar between the DMA input and the PEA

module dma_pea_xbar
  import stream_intf_pkg::*;
  import pea_pkg::*;
(
    input  logic [ N_DMA_CH_PER_IN_STREAM-1:0]                                     dma_ch_valid_i,
    input  logic [ N_DMA_CH_PER_IN_STREAM-1:0][                        N_BITS-1:0] dma_ch_din_i,
    input  logic [N_PEA_DIN_PER_IN_STREAM-1:0][$clog2(N_DMA_CH_PER_IN_STREAM)-1:0] sel_i,
    output logic [N_PEA_DIN_PER_IN_STREAM-1:0][                        N_BITS-1:0] din_pea_o,
    output logic [N_PEA_DIN_PER_IN_STREAM-1:0]                                     valid_pea_o
);

  always_comb begin
    for (int i = 0; i < N_PEA_DIN_PER_IN_STREAM; i = i + 1) begin
      din_pea_o[i]   = dma_ch_din_i[sel_i[i]];
      valid_pea_o[i] = dma_ch_valid_i[sel_i[i]];
    end
  end

endmodule
