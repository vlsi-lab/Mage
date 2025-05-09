// Copyright 2025 Politecnico di Torino.
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// File: streaming_interface.sv
// Author: Alessio Naclerio
// Date: 26/02/2025
// Description: Streaming interface to let work the execute part of Mage in streaming with the DMA

module streaming_interface
  import stream_intf_pkg::*;
  import fifo_pkg::*;
  import pea_pkg::*;
(
    input logic clk_i,
    input logic rst_n_i,
    // HW FIFO Interface
    input  fifo_req_t [N_DMA_CH-1:0] fifo_req_i,
    output fifo_resp_t [N_DMA_CH-1:0] fifo_resp_o,
    // Configuration signals
    input logic [M-1:0] pea_ready_i,
    input logic [1:0] reg_separate_cols_i,
    input logic reg_synch_dma_ch_i,
    input logic [N_DMA_CH-1:0][N_BITS-1:0] reg_trans_size_i,
%if out_stream_xbar == str(1):
    input logic [N_OUT_STREAM-1:0][N_DMA_CH_PER_OUT_STREAM-1:0][LOG_N_PEA_DOUT_PER_OUT_STREAM-1:0] reg_out_stream_sel_i,
%endif
%if in_stream_xbar == str(1):
    input logic [N_IN_STREAM-1:0][N_DMA_CH_PER_IN_STREAM-1:0][LOG_N_DMA_CH_PER_IN_STREAM-1:0] reg_in_stream_sel_i,
%endif
    // I/O interface with PEA
    input logic  [M-1:0][N_BITS-1:0] dout_pea_i,
    input logic  [M-1:0] valid_pea_out_i,
    output logic [N_STREAM_IN_PEA-1:0] valid_pea_in_o,
    output logic [N_STREAM_IN_PEA-1:0][N_BITS-1:0] din_pea_o,
    output logic mage_done_o
);

  // Fifo signals
  logic [N_DMA_CH-1:0][N_BITS-1:0] trans_counter;
  logic [N_DMA_CH-1:0] hw_r_fifo_pop;
  logic [N_DMA_CH-1:0] hw_r_fifo_pop_enable;
  logic [N_DMA_CH-1:0] hw_r_fifo_empty;
  logic [N_DMA_CH-1:0] hw_r_fifo_full;
  logic [N_DMA_CH-1:0][$clog2(4)-1:0] hw_r_usage;
  logic [N_DMA_CH-1:0][N_BITS-1:0] hw_r_fifo_dout;
  logic [N_DMA_CH-1:0] hw_w_fifo_push;
  logic [N_DMA_CH-1:0] hw_w_fifo_full;
  logic [N_DMA_CH-1:0][N_BITS-1:0] hw_w_fifo_din;

  // I/O Valid Signals
  logic [N_IN_STREAM-1:0][N_DMA_CH_PER_IN_STREAM-1:0] stream_in_dma_ch_valid;
  logic [N_IN_STREAM-1:0][N_PEA_DIN_PER_IN_STREAM-1:0] stream_in_pea_valid;
  logic [N_OUT_STREAM-1:0][N_PEA_DOUT_PER_OUT_STREAM-1:0] stream_out_pea_valid;
  logic [N_OUT_STREAM-1:0][N_DMA_CH_PER_OUT_STREAM-1:0] stream_out_dma_ch_valid;

  // input streaming interface
  logic [N_IN_STREAM-1:0][N_DMA_CH_PER_IN_STREAM-1:0][N_BITS-1:0] stream_in_dma_ch_data;
  logic [N_IN_STREAM-1:0][N_PEA_DIN_PER_IN_STREAM-1:0][N_BITS-1:0] stream_in_pea_data;
  // output streaming interface
  logic [N_OUT_STREAM-1:0][N_PEA_DOUT_PER_OUT_STREAM-1:0][N_BITS-1:0] stream_out_pea_data;
  logic [N_OUT_STREAM-1:0][N_DMA_CH_PER_OUT_STREAM-1:0][N_BITS-1:0] stream_out_dma_ch_data;

  // --------------------------------- HW FIFO

  /* Hardware Read Fifo */
  genvar rf;
  generate
    for (rf = 0; rf < N_DMA_CH; rf++) begin : gen_hw_r_fifo
      fifo_v3 #(
          .DEPTH(4),
          .FALL_THROUGH(1'b0),
          .DATA_WIDTH(32)
      ) hw_r_fifo_i (
          .clk_i(clk_i),
          .rst_ni(rst_n_i),
          .flush_i(),
          .testmode_i(1'b0),
          .full_o(hw_r_fifo_full[rf]),
          .empty_o(hw_r_fifo_empty[rf]),
          .usage_o(hw_r_usage[rf]),
          .data_i(fifo_req_i[rf].data),
          .push_i(fifo_req_i[rf].push),
          .data_o(hw_r_fifo_dout[rf]),
          .pop_i(hw_r_fifo_pop[rf])
      );
    end
  endgenerate

  /* Hardware Write Fifo */
  genvar wf;
  generate
    for (wf = 0; wf < N_DMA_CH; wf++) begin : gen_hw_w_fifo
      fifo_v3 #(
          .DEPTH(4),
          .FALL_THROUGH(1'b0),
          .DATA_WIDTH(32)
      ) hw_w_fifo_i (
          .clk_i(clk_i),
          .rst_ni(rst_n_i),
          .testmode_i(1'b0),
          .flush_i(),
          .full_o(hw_w_fifo_full[wf]),
          .empty_o(fifo_resp_o[wf].empty),
          .usage_o(),
          .data_i(hw_w_fifo_din[wf]),
          .push_i(hw_w_fifo_push[wf]),
          .data_o(fifo_resp_o[wf].data),
          .pop_i(fifo_req_i[wf].pop)
      );
    end
  endgenerate

  always_ff @(posedge clk_i or negedge rst_n_i) begin
    for (int i = 0; i < N_DMA_CH; i++) begin
      if (~rst_n_i) begin
        trans_counter[i] <= reg_trans_size_i[i];
      end else begin
        if (fifo_req_i[i].flush) begin
          trans_counter[i] <= reg_trans_size_i[i];
        end else if (fifo_req_i[i].push) begin
          trans_counter[i] <= trans_counter[i] - 1;
        end
      end
    end
  end

  assign mage_done_o = (trans_counter == '0);

  always_comb begin
    for (int i = 0; i < N_DMA_CH; i = i + 1) begin
      fifo_resp_o[i].full = hw_r_fifo_full[i];
      fifo_resp_o[i].alm_full = hw_r_usage == 2'd3;
    end
  end

  // Pop from Read FIFO
  always_comb begin
    for (int i = 0; i < N_DMA_CH; i = i + 1) begin
      hw_r_fifo_pop_enable[i] = 1'b0;
      if (hw_r_fifo_empty[i] == 1'b0 && pea_ready_i[i] == 1'b1) begin
        hw_r_fifo_pop_enable[i] = 1'b1;
      end
    end
  end

  always_comb begin
    hw_r_fifo_pop = '0;
    if(reg_synch_dma_ch_i == 1'b0) begin
      for (int i = 0; i < N_DMA_CH; i = i + 1) begin
        hw_r_fifo_pop[i] = hw_r_fifo_pop_enable[i];
      end
    end else if(reg_synch_dma_ch_i == 1'b1) begin
%for c in range(n_pea_cols):
      hw_r_fifo_pop[${c}] =
  %for i in range(len(pea_in_stream_placement[c])):
    %if pea_in_stream_placement[c][i] != None:
      %if i != len(pea_in_stream_placement[c]) - 1:
        hw_r_fifo_pop_enable[${pea_in_stream_placement[c][i]}] &
      %else:
        hw_r_fifo_pop_enable[${pea_in_stream_placement[c][i]}];
      %endif
    %endif
  %endfor 
%endfor
    end
  end

  //--------------------------------- Interface Management and Crossbars

% for nis in range(n_in_stream):
  % for ndc in range(n_dma_ch_per_in_stream):
    % for i in range(len(in_stream_dma_ch_placement)):
      % for j in range(len(in_stream_dma_ch_placement[i])):
        % if i == nis and j == ndc:
          %if in_stream_dma_ch_placement[i][j] != None:
  assign stream_in_dma_ch_data[${nis}][${ndc}] = hw_r_fifo_dout[${in_stream_dma_ch_placement[i][j]}];
  assign stream_in_dma_ch_valid[${nis}][${ndc}] = hw_r_fifo_pop[${in_stream_dma_ch_placement[i][j]}] && pea_ready_i[${in_stream_dma_ch_placement[i][j]}];
          %else:
  assign stream_in_dma_ch_data[${nis}][${ndc}] = '0;
  assign stream_in_dma_ch_valid[${nis}][${ndc}] = 1'b0;
          %endif
        % endif       
      % endfor
    % endfor
  % endfor
% endfor

% for nos in range(n_out_stream):
  % for ndc in range(n_pea_dout_per_out_stream):
    % for i in range(len(out_stream_pea_dout_placement)):
      % for j in range(len(out_stream_pea_dout_placement[i])):
        % if i == nos and j == ndc:
          %if out_stream_pea_dout_placement[i][j] != None:
  assign stream_out_pea_data[${nos}][${ndc}] = dout_pea_i[${out_stream_pea_dout_placement[i][j]}];
  assign stream_out_pea_valid[${nos}][${ndc}] = valid_pea_out_i[${out_stream_pea_dout_placement[i][j]}];
          %else:
  assign stream_out_pea_data[${nos}][${ndc}] = '0;
  assign stream_out_pea_valid[${nos}][${ndc}] = 1'b0;
          %endif
        % endif       
      % endfor
    % endfor
  % endfor
% endfor

% if in_stream_xbar == str(1):
  genvar k;
  generate
    for (k = 0; k < N_IN_STREAM; k++) begin : gen_xbar_dma_pea
      dma_pea_xbar dma_pea_xbar_inst (
          .dma_ch_valid_i(stream_in_dma_ch_valid[k]),
          .dma_ch_din_i(stream_in_dma_ch_data[k]),
          .sel_i(reg_in_stream_sel_i[k]),
          .din_pea_o(stream_in_pea_data[k]),
          .valid_pea_o(stream_in_pea_valid[k])
      );
    end
  endgenerate
% else:
  always_comb begin
    for (int i = 0; i < N_IN_STREAM; i = i + 1) begin
      for (int j = 0; j < N_DMA_CH_PER_IN_STREAM; j = j + 1) begin // in this case N_DMA_CH_PER_IN_STREAM = N_PEA_DIN_PER_IN_STREAM
        stream_in_pea_data[i][j] = stream_in_dma_ch_data[i][j];
        stream_in_pea_valid[i][j] = stream_in_dma_ch_valid[i][j];
      end
    end
  end
% endif

  // Outputs to PEA construction
  always_comb begin
    for (int i = 0; i < N_IN_STREAM; i = i + 1) begin
      for (int j = 0; j < N_PEA_DIN_PER_IN_STREAM; j = j + 1) begin
        din_pea_o[i*N_PEA_DIN_PER_IN_STREAM+j] = stream_in_pea_data[i][j];
        valid_pea_in_o[i*N_PEA_DIN_PER_IN_STREAM+j] = stream_in_pea_valid[i][j];
      end
    end
  end

% if out_stream_xbar == str(1):
  genvar l;
  generate
    for (l = 0; l < N_OUT_STREAM; l++) begin : gen_xbar_pea_dma
      pea_dma_xbar pea_dma_xbar_inst (
          .dout_pea_i(stream_out_pea_data[l]),
          .valid_pea_i(stream_out_pea_valid[l]),
          .sel_i(reg_out_stream_sel_i[l]),
          .dma_ch_dout_o(stream_out_dma_ch_data[l]),
          .dma_ch_valid_o(stream_out_dma_ch_valid[l])
      );
    end
  endgenerate
% else:
  always_comb begin
    for (int i = 0; i < N_IN_STREAM; i = i + 1) begin
      for (int j = 0; j < N_DMA_CH_PER_IN_STREAM; j = j + 1) begin // in this case N_DMA_CH_PER_OUT_STREAM = N_PEA_DOUT_PER_OUT_STREAM
        stream_out_dma_ch_data[i][j] = stream_out_pea_data[i][j];
        stream_out_dma_ch_valid[i][j] = stream_out_pea_valid[i][j];
      end
    end
  end
% endif

  // Write fifo input construction
  always_comb begin
    for (int i = 0; i < N_OUT_STREAM; i = i + 1) begin
      for (int j = 0; j < N_DMA_CH_PER_OUT_STREAM; j = j + 1) begin
        hw_w_fifo_din[i*N_DMA_CH_PER_OUT_STREAM+j] = stream_out_dma_ch_data[i][j];
        hw_w_fifo_push[i*N_DMA_CH_PER_OUT_STREAM+j] = stream_out_dma_ch_valid[i][j] && pea_ready_i[i*N_DMA_CH_PER_OUT_STREAM+j];
      end
    end
  end
endmodule
