// Copyright 2025 Politecnico di Torino.
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// File: pea_dma_xbar.sv
// Author: Alessio Naclerio
// Date: 26/02/2025
// Description: Crossbar between the PEA and the DMA

module pea_dma_xbar
  import stream_intf_pkg::*;
  import pea_pkg::*;
(
    input logic [N_PEA_DOUT_PER_OUT_STREAM-1:0] valid_pea_i,
    input logic [N_PEA_DOUT_PER_OUT_STREAM-1:0][N_BITS-1:0] dout_pea_i,
    input logic [N_DMA_CH_PER_OUT_STREAM-1:0][$clog2(N_PEA_DOUT_PER_OUT_STREAM)-1:0] sel_i,
    output logic [N_DMA_CH_PER_OUT_STREAM-1:0][N_BITS-1:0] dma_ch_dout_o,
    output logic [N_DMA_CH_PER_OUT_STREAM-1:0] dma_ch_valid_o
);

  always_comb begin
    for (int i = 0; i < N_DMA_CH_PER_OUT_STREAM; i = i + 1) begin
      dma_ch_dout_o[i]  = dout_pea_i[sel_i[i]];
      dma_ch_valid_o[i] = valid_pea_i[sel_i[i]];
    end
  end

endmodule
