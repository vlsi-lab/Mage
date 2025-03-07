// Copyright 2025 Politecnico di Torino.
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// File: stream_intf_pkg.sv
// Author: Alessio Naclerio
// Date: 26/02/2025
// Description: stream interface package

package stream_intf_pkg;

  // Number of DMA Channels used for streaming data in and out of Mage
  localparam unsigned N_DMA_CH = 1;

  //Number of input streams to Mage
  //An input stream has multiple DMA channels coming in with input data, and they are
  //"reorganized" using crossbars or assignments towards PEA inputs
  localparam unsigned N_IN_STREAM = 1;
  // In each inputs stream, N_DMA_CH_PER_IN_STREAM DMA channels can be grouped
  localparam unsigned N_DMA_CH_PER_IN_STREAM = 1;
  // In each inputs stream, N_PEA_DIN_PER_IN_STREAM PEA inputs can be grouped
  localparam unsigned N_PEA_DIN_PER_IN_STREAM = 1;

  //Number of output streams exiting from Mage
  //An output stream has multiple PEA outputs coming in with input data, and they are
  //"reorganized" using crossbars or assignments towards DMA channels
  localparam unsigned N_OUT_STREAM = 1;
  // In each inputs stream, N_PEA_DOUT_PER_OUT_STREAM PEA outputs can be grouped
  localparam unsigned N_PEA_DOUT_PER_OUT_STREAM = 1;
  // In each inputs stream, N_DMA_CH_PER_OUT_STREAM DMA channels can be grouped
  localparam unsigned N_DMA_CH_PER_OUT_STREAM = 1;


  localparam unsigned N_STREAM_OUT_PEA = N_OUT_STREAM * N_PEA_DOUT_PER_OUT_STREAM;
  localparam unsigned N_STREAM_IN_PEA = N_IN_STREAM * N_PEA_DIN_PER_IN_STREAM;

  localparam unsigned LOG_N_DMA_CH_PER_IN_STREAM = (N_DMA_CH_PER_IN_STREAM == 1) ? 1 : $clog2(
      N_DMA_CH_PER_IN_STREAM
  );
  localparam unsigned LOG_N_PEA_DOUT_PER_OUT_STREAM = (N_PEA_DOUT_PER_OUT_STREAM == 1) ? 1 : $clog2(
      N_PEA_DOUT_PER_OUT_STREAM
  );

endpackage
