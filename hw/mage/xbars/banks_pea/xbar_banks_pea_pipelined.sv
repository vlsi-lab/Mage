// Copyright 2025 Politecnico di Torino.
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// File: xbar_banks_pea_pipelined.sv
// Author: Alessio Naclerio
// Date: 26/02/2025
// Description: SpM Bank Group <-> PE Group Pipelinable Crossbar
//              This modlule describes a modular pipelinable crossbar connection between a Bank Group and a PE Group

module xbar_banks_pea_pipelined
  import pea_pkg::*;
  import mage_pkg::*;
  import xbar_pkg::*;
(
    //Input signals from PE and SpM Group
    input  logic [    N_PE_PER_GROUP-1:0][                N_BITS-1:0] out_pea_i,
    input  logic [N_BANKS_PER_STREAM-1:0][                N_BITS-1:0] out_dmem_i,
    //Selectors
    input  logic [    N_PE_PER_GROUP-1:0][LOG_N_BANKS_PER_STREAM-1:0] sel_dmem_pea_i,
    input  logic [N_BANKS_PER_STREAM-1:0][    LOG_N_PE_PER_GROUP-1:0] sel_pea_dmem_i,
    //Output signals to PE and SpM Group
    output logic [N_BANKS_PER_STREAM-1:0][                N_BITS-1:0] in_pea_o,
    output logic [N_BANKS_PER_STREAM-1:0][                N_BITS-1:0] in_dmem_o
);

`ifndef PIPE_XBAR_PEA

  /* xbar_banks_pea xbar_banks_pea_inst (
      .out_pea_i(out_pea_i),
      .out_dmem_i(out_dmem_i),
      .sel_dmem_pea_i(sel_dmem_pea_i),
      .sel_pea_dmem_i(sel_pea_dmem_i),
      .in_pea_o(in_pea_o),
      .in_dmem_o(in_dmem_o)
  ); */

  generate
    ;
    for (genvar i = 0; i < N_BANKS_PER_STREAM; i++) begin : gen_xbar_bb_no_pipe
      xbar_banks_pea_bb xbar_banks_pea_bb_inst (
          .out_pea_bb_i(out_pea_i),
          .out_dmem_bb_i(out_dmem_i),
          .sel_dmem_pea_bb_i(sel_dmem_pea_i[i]),
          .sel_pea_dmem_bb_i(sel_pea_dmem_i[i]),
          .in_pea_bb_o(in_pea_o[i]),
          .in_dmem_bb_o(in_dmem_o[i])
      );
    end
  endgenerate


`else

  // Signals entering dmem -> pea pipe registers
  logic [N_PIPE_STAGE_BANKS_PEA-1:0][N_PE_PER_GROUP-1:0][N_BANKS_PER_STREAM-1:0][N_BITS-1:0] out_dmem_pipe_in_reg;
  logic [N_PIPE_STAGE_BANKS_PEA-1:0][N_PE_PER_GROUP-1:0][LOG_N_BANKS_PER_STREAM-1:0] sel_dmem_pea_pipe_in_reg;
  // Signals exiting dmem -> pea pipe registers
  logic [N_PIPE_STAGE_BANKS_PEA-1:0][N_PE_PER_GROUP-1:0][N_BANKS_PER_STREAM-1:0][N_BITS-1:0] out_dmem_pipe_out_reg;
  logic [N_PIPE_STAGE_BANKS_PEA-1:0][N_PE_PER_GROUP-1:0][LOG_N_BANKS_PER_STREAM-1:0] sel_dmem_pea_pipe_out_reg;

  // Signals entering pea -> dmem pipe registers
  logic [N_PIPE_STAGE_BANKS_PEA-1:0][N_BANKS_PER_STREAM-1:0][N_PE_PER_GROUP-1:0][N_BITS-1:0] out_pea_pipe_in_reg;
  logic [N_PIPE_STAGE_BANKS_PEA-1:0][N_BANKS_PER_STREAM-1:0][LOG_N_PE_PER_GROUP-1:0] sel_pea_dmem_pipe_in_reg;
  // Signals exiting pea -> dmem pipe registers
  logic [N_PIPE_STAGE_BANKS_PEA-1:0][N_BANKS_PER_STREAM-1:0][N_PE_PER_GROUP-1:0][N_BITS-1:0] out_pea_pipe_out_reg;
  logic [N_PIPE_STAGE_BANKS_PEA-1:0][N_BANKS_PER_STREAM-1:0][LOG_N_PE_PER_GROUP-1:0] sel_pea_dmem_pipe_out_reg;

  // Assign out_reg signals of pipe stage 0, which are connected to the inputs of the crossbars
  always_comb begin
    for (int i = 0; i < N_PE_PER_GROUP; i = i + 1) begin
      out_dmem_pipe_out_reg[0][i] = out_dmem_i;
    end
    for (int i = 0; i < N_BANKS_PER_STREAM; i = i + 1) begin
      out_pea_pipe_out_reg[0][i] = out_pea_i;
    end
    sel_dmem_pea_pipe_out_reg[0] = sel_dmem_pea_i;
    sel_pea_dmem_pipe_out_reg[0] = sel_pea_dmem_i;
  end

  // Pipe registers
  always_ff @(posedge clk_i or negedge rst_n_i) begin
    if (~rst_n_i) begin
      out_pea_pipe_out_reg <= '0;
      out_dmem_pipe_out_reg <= '0;
      sel_dmem_pea_pipe_out_reg <= '0;
      sel_pea_dmem_pipe_out_reg <= '0;
    end else begin
      for (int i = 1; i < N_PIPE_STAGE_BANKS_PEA; i = i + 1) begin
        sel_dmem_pea_pipe_out_reg[i] <= sel_dmem_pea_pipe_in_reg[i-1];
        sel_pea_dmem_pipe_out_reg[i] <= sel_pea_dmem_pipe_in_reg[i-1]; //reduce number of bits to delay
        out_pea_pipe_out_reg[i] <= out_pea_pipe_in_reg[i-1];
        out_dmem_pipe_out_reg[i] <= out_dmem_pipe_in_reg[i-1];
      end
    end
  end

  generate
    for (
        genvar i = 0; i < N_BANKS_PER_STREAM; i++
    ) begin : gen_xbar_per_banks_stage_0  // N_BANKS_PER_STREAM = N_PE_PER_GROUP
      for (genvar j = 0; j < N_BB_BANKS_PEA_STG_0; j++) begin : gen_xbar_bb_stage_0
        xbar_banks_to_pea_bb xbar_banks_to_pea_bb_inst_0 (
            // inputs to xbar bb
            .out_pea_bb_i(out_pea_pipe_out_reg[0][i][N_PE_PER_BB*(1+j)-1-:N_PE_PER_BB-1]),
            .out_dmem_bb_i(out_dmem_pipe_out_reg[0][i][N_BANKS_PER_BB*(1+j)-1-:N_BANKS_PER_BB-1]),
            // xbar selectors
            .sel_dmem_pea_bb_i(sel_dmem_pea_pipe_out_reg[0][i][LOG_N_BANKS_PER_BB-1:0]),
            .sel_pea_dmem_bb_i(sel_pea_dmem_pipe_out_reg[0][i][LOG_N_PE_PER_BB-1:0]),
            // outputs from xbar bb
            .in_pea_bb_o(out_pea_pipe_in_reg[0][i][j]),
            .in_dmem_bb_o(out_dmem_pipe_in_reg[0][i][j])
        );
      end
    end
  endgenerate

  generate
    for (
        genvar i = 0; i < N_BANKS_PER_STREAM; i++
    ) begin : gen_xbar_per_banks_stage_1  // N_BANKS_PER_STREAM = N_PE_PER_GROUP
      for (genvar j = 0; j < N_BB_BANKS_PEA_STG_1; j++) begin : gen_xbar_bb_stage_1
        xbar_banks_to_pea_bb xbar_banks_to_pea_bb_inst_1 (
            // inputs to xbar bb
            .out_pea_bb_i(out_pea_pipe_out_reg[1][i][N_PE_PER_BB*(1+j)-1-:N_PE_PER_BB-1]),
            .out_dmem_bb_i(out_dmem_pipe_out_reg[1][i][N_BANKS_PER_BB*(1+j)-1-:N_BANKS_PER_BB-1]),
            // xbar selectors
            .sel_dmem_pea_bb_i(sel_dmem_pea_pipe_out_reg[1][i][LOG_N_BANKS_PER_BB-1:0]),
            .sel_pea_dmem_bb_i(sel_pea_dmem_pipe_out_reg[1][i][LOG_N_PE_PER_BB-1:0]),
            // outputs from xbar bb
            .in_pea_bb_o(out_pea_pipe_in_reg[1][i][j]),
            .in_dmem_bb_o(out_dmem_pipe_in_reg[1][i][j])
        );
      end
    end
  endgenerate

  generate
    for (
        genvar i = 0; i < N_BANKS_PER_STREAM; i++
    ) begin : gen_xbar_per_banks_stage_2  // N_BANKS_PER_STREAM = N_PE_PER_GROUP
      for (genvar j = 0; j < N_BB_BANKS_PEA_STG_2; j++) begin : gen_xbar_bb_stage_2
        xbar_banks_to_pea_bb xbar_banks_to_pea_bb_inst_2 (
            // inputs to xbar bb
            .out_pea_bb_i(out_pea_pipe_out_reg[2][i][N_PE_PER_BB*(1+j)-1-:N_PE_PER_BB-1]),
            .out_dmem_bb_i(out_dmem_pipe_out_reg[2][i][N_BANKS_PER_BB*(1+j)-1-:N_BANKS_PER_BB-1]),
            // xbar selectors
            .sel_dmem_pea_bb_i(sel_dmem_pea_pipe_out_reg[2][i][LOG_N_BANKS_PER_BB-1:0]),
            .sel_pea_dmem_bb_i(sel_pea_dmem_pipe_out_reg[2][i][LOG_N_PE_PER_BB-1:0]),
            // outputs from xbar bb
            .in_pea_bb_o(out_pea_pipe_in_reg[2][i][j]),
            .in_dmem_bb_o(out_dmem_pipe_in_reg[2][i][j])
        );
      end
    end
  endgenerate

  always_comb begin
    for (int i = 0; i < N_PE_PER_GROUP; i = i + 1) begin
      in_dmem_o[i] = out_dmem_pipe_in_reg[N_PIPE_STAGE_BANKS_PEA-1][i][0];
    end
    for (int i = 0; i < N_BANKS_PER_STREAM; i = i + 1) begin
      in_pea_o[i] = out_pea_pipe_in_reg[N_PIPE_STAGE_BANKS_PEA-1][0][i];
    end
  end

`endif

endmodule
