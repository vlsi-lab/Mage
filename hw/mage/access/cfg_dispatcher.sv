// Copyright 2025 Politecnico di Torino.
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// File: cfg_dispatcher.sv
// Author: Alessio Naclerio
// Date: 26/02/2025
// Description: This module handles the dispatching of configurations to all different Streams.

module cfg_dispatcher
  import mage_pkg::*;
(
    input logic clk_i,
    input logic rst_n_i,
    input logic [ACC_CFGMEM_SIZE-1:0][N_AGE_TOT-1:0][NBIT_CFG_STREAM_WORD-1:0] cfgmem_content_i,
    //ROU
    output logic [N_AGE_TOT-1:0] is_age_active_rou_o,
    output logic [N_AGE_TOT-1:0][LOG2_HWLP_RF_SIZE-1:0] hwlp_sel_o,
    output logic [N_AGE_TOT-1:0][LOG2_N_LP-1+1:0] iv_constraint_sel_o,
    output logic [N_AGE_TOT-1:0] is_acc_store_rou_o,
    //SUBS_GEN
    output logic [N_AGE_TOT-1:0] is_age_active_o,
    //FLAT_ADDR_GEN
    output logic [N_AGE_TOT-1:0][NBIT_IV_CONST-1:0] const_iv_o,
    //BA_GEN
    output logic [N_AGE_TOT-1:0][NBIT_N_BANKS-1:0] n_banks_o,
    output logic [N_AGE_TOT-1:0][NBIT_START_BANK-1:0] start_banks_o,
    output logic [N_AGE_TOT-1:0][NBIT_BLOCK_SIZE-1:0] block_size_o,
    output logic [N_AGE_TOT-1:0] stream_lns_o,
    output logic [N_AGE_TOT-1:0] is_acc_store_o
);

  //BA_GEN Signals have to go through 3 registers
  logic [1:0][N_AGE_TOT-1:0][NBIT_N_BANKS-1:0] tmp_n_banks;
  logic [1:0][N_AGE_TOT-1:0][NBIT_START_BANK-1:0] tmp_start_banks;
  logic [1:0][N_AGE_TOT-1:0][NBIT_BLOCK_SIZE-1:0] tmp_block_size;
  logic [1:0][N_AGE_TOT-1:0] tmp_stream_lns;
  logic [1:0][N_AGE_TOT-1:0] tmp_is_acc_store;
  logic [N_AGE_TOT-1:0][NBIT_IV_CONST-1:0] tmp_const_iv;
  logic [N_AGE_TOT-1:0][NBIT_CFG_STREAM_WORD-1:0] cfg_word;
  stream_inst_t [N_AGE_TOT-1:0] stream_inst;

  always_comb begin
    cfg_word = cfgmem_content_i[0];
  end

  //Constructing stream instruction fields
  always_comb begin
    for (int i = 0; i < N_AGE_TOT; i = i + 1) begin

      stream_inst[i].hwlp_rf_sel = cfg_word[i][LOG2_HWLP_RF_SIZE-1:0];
      stream_inst[i].n_banks = cfg_word[i][N_END_SUBS+NBIT_N_BANKS-1-:NBIT_N_BANKS];
      stream_inst[i].bank_start = cfg_word[i][N_END_BANKS+NBIT_START_BANK-1-:NBIT_START_BANK];
      stream_inst[i].block_size = cfg_word[i][N_END_BANK_START+NBIT_BLOCK_SIZE-1-:NBIT_BLOCK_SIZE];
      stream_inst[i].lns = cfg_word[i][N_END_BS+1-1-:1];
      stream_inst[i].iv_constraint_sel = cfg_word[i][N_END_LNS+LOG2_N_LP+1-1-:LOG2_N_LP+1];
      stream_inst[i].is_acc_store = cfg_word[i][N_END_CONSTRAINTS];
      stream_inst[i].iv_const = cfg_word[i][N_END_IS_ACC_STORE+NBIT_IV_CONST-1-:NBIT_IV_CONST];
      stream_inst[i].valid = cfg_word[i][N_END_CONSTANT];

    end
  end

  always_comb begin
    for (int i = 0; i < N_AGE_TOT; i = i + 1) begin
      hwlp_sel_o[i] = stream_inst[i].hwlp_rf_sel;
      iv_constraint_sel_o[i] = stream_inst[i].iv_constraint_sel;
      is_acc_store_rou_o[i] = stream_inst[i].is_acc_store;
      is_age_active_rou_o[i] = stream_inst[i].valid;
    end
  end


  //Constructing output to BA_GEN which has to go through two registers
  always_ff @(posedge clk_i, negedge rst_n_i) begin
    if (!rst_n_i) begin
      n_banks_o <= '0;
      block_size_o <= '0;
      const_iv_o <= '0;
      tmp_const_iv <= '0;
      is_age_active_o <= '0;
      tmp_n_banks <= '0;
      tmp_start_banks <= '0;
      tmp_block_size <= '0;
      tmp_stream_lns <= '0;
    end else begin
      for (int i = 0; i < N_AGE_TOT; i = i + 1) begin
        tmp_is_acc_store[0][i] <= stream_inst[i].is_acc_store;
        tmp_is_acc_store[1][i] <= tmp_is_acc_store[0][i];
        is_acc_store_o[i] <= tmp_is_acc_store[1][i];

        tmp_n_banks[0][i] <= stream_inst[i].n_banks;
        tmp_n_banks[1][i] <= tmp_n_banks[0][i];
        n_banks_o[i] <= tmp_n_banks[1][i];

        tmp_start_banks[0][i] <= stream_inst[i].bank_start;
        tmp_start_banks[1][i] <= tmp_start_banks[0][i];
        start_banks_o[i] <= tmp_start_banks[1][i];

        tmp_block_size[0][i] <= stream_inst[i].block_size;
        tmp_block_size[1][i] <= tmp_block_size[0][i];
        block_size_o[i] <= tmp_block_size[1][i];

        tmp_stream_lns[0][i] <= stream_inst[i].lns;
        tmp_stream_lns[1][i] <= tmp_stream_lns[0][i];
        stream_lns_o[i] <= tmp_stream_lns[1][i];

        tmp_const_iv[i] <= stream_inst[i].iv_const;
        const_iv_o[i] <= tmp_const_iv[i];

        is_age_active_o[i] <= stream_inst[i].valid;
      end
    end
  end

endmodule : cfg_dispatcher
