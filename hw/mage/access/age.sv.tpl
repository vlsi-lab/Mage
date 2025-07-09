// Copyright 2025 Politecnico di Torino.
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// File: age.sv
// Author: Alessio Naclerio
// Date: 26/02/2025
// Description: This module describes the Address Generation Engine (AGE) that generates the address, bank
//              and load_not_store signals

module age
  import mage_pkg::*;
(
    input logic clk_i,
    input logic rst_n_i,
    input logic start_i,
    input logic valid_i,
    input logic active_i,
    input logic end_lp_i,
    //Subscript Generation Stage
    //ivs for each subscript
    input logic [N_IVS-1:0][NBIT_LP_IV-1:0] iv_i,
    input logic pea_acc_reset_i,
    //constant for index
    input logic [NBIT_IV_CONST-1:0] iv_const_i,
    //Flat Address Generation Stage
    //CSR containing all column sizes neeeded for calculating flat address
    input logic [N_IVS-1:0][NBIT_LP_IV-1:0] reg_strides_i,
    //Bank-Address Generation Stage
    //number of banks
    input logic [NBIT_N_BANKS-1:0] n_banks_i,
    input logic [NBIT_START_BANK-1:0] start_bank_i,
    //block size
    input logic [NBIT_BLOCK_SIZE-1:0] block_size_i,
    //is accumulation store
    input logic is_acc_store_i,
    //load_not_store
    input logic lns_i,
    //OUTPUTS: address-bank-validity-lns are generated
    output logic [NBIT_ADDR-1:0] age_addr_o,
    output logic [N_BANKS_PER_STREAM-1:0] age_bank_o,
    output logic [LOG_N_BANKS_PER_STREAM-1:0] age_bank_ls_stream_o,
    output logic pea_acc_reset_o,
    output logic valid_o,
    output logic lns_o,
    output logic active_o
);

  // Stage 0
  logic [1:0][NBIT_FLAT_ADDR-1:0]         mult_temp_res;
  logic [      N_IVS-1:0][NBIT_FLAT_ADDR-1:0] mult_ivs_in_reg;
  logic [      N_IVS-1:0][NBIT_FLAT_ADDR-1:0] mult_ivs_out_reg;
  // Stage 1
  logic [    NBIT_FLAT_ADDR-1:0]              flat_address_in_reg;
  logic [    NBIT_FLAT_ADDR-1:0]              flat_address_out_reg;
  // Stage 2
  logic [NBIT_FLAT_ADDR-1:0] x_div_bs;
  logic [NBIT_FLAT_ADDR-1:0] x_rem_bs;
  logic [3-1:0] age_bank_ls_stream;
  logic                                              valid;
  logic                                              valid_acc_store;
  logic [N_BANKS_PER_STREAM-1:0]                     age_bank;
  logic                                              pea_acc_reset;
  logic                                              active;
  logic                                              end_lp;

  ////////////////////////////////////////////////////////////////
  //                     Pipeline Registers                     //
  ////////////////////////////////////////////////////////////////

  always_ff @(posedge clk_i, negedge rst_n_i) begin
    if (!rst_n_i) begin
      mult_ivs_out_reg       <= '0;
      flat_address_out_reg   <= '0;
      valid                  <= '0;
      lns_o                  <= 1'b0;
      pea_acc_reset          <= '0;
    end else begin
      if (start_i == 1'b1 && active_i == 1'b1) begin
        mult_ivs_out_reg       <= mult_ivs_in_reg;
        flat_address_out_reg   <= flat_address_in_reg;
        valid                  <= valid_i;
        valid_o                <= valid;
        pea_acc_reset          <= pea_acc_reset_i;
        pea_acc_reset_o        <= pea_acc_reset && is_acc_store_i;
        lns_o                  <= lns_i;
      end else begin
        mult_ivs_out_reg       <= '0;
        flat_address_out_reg   <= '0;
        valid                  <= '0;
        valid_o                <= 1'b0;
        lns_o                  <= 1'b0;
      end
    end
  end

  //Asserts and deasserts the active signal based on the end_lp signal (that signals that the kernel is terminated)
  always_ff @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
      end_lp   <= 1'b0;
      active   <= 1'b0;
      active_o <= 1'b0;
    end else begin

      if (end_lp_i) begin
        end_lp <= 1'b1;
      end else begin
        end_lp <= end_lp;
      end

      if (!end_lp) begin
        active <= active_i;
      end else begin
        active <= 1'b0;
      end
      active_o <= active;
    end
  end

  ////////////////////////////////////////////////////////////////
  //              Address Generation Engine Stages              //
  ////////////////////////////////////////////////////////////////
  
  // Stage 0
  always_comb begin
    for (int i = 0; i < N_IVS; i = i + 1) begin
      mult_ivs_in_reg[i] = iv_i[i] * reg_strides_i[i];
    end
  end

  // Stage 1
  assign mult_temp_res[0] = mult_ivs_out_reg[0] + mult_ivs_out_reg[1];
  assign mult_temp_res[1] = mult_ivs_out_reg[2] + mult_ivs_out_reg[3];
  always_comb begin
    flat_address_in_reg = mult_temp_res[0] + mult_temp_res[1] + iv_const_i;
  end

  // Stage 2
  always_comb begin
    x_div_bs = (flat_address_out_reg >> block_size_i);
    case(n_banks_i)
      2'b00: age_bank_ls_stream = start_bank_i;
      2'b01: age_bank_ls_stream = {2'b0, x_div_bs[0]} + start_bank_i;
      2'b10: age_bank_ls_stream = {1'b0, x_div_bs[1:0]} + start_bank_i;
      2'b11: age_bank_ls_stream = x_div_bs[2:0] + start_bank_i;
    endcase

    age_bank_o = 1 << age_bank_ls_stream;

    case(block_size_i)
      2'b00: x_rem_bs = '0;
      2'b01: x_rem_bs = {{NBIT_FLAT_ADDR-1{1'b0}},flat_address_out_reg[0]};
      2'b10: x_rem_bs = {{NBIT_FLAT_ADDR-2{1'b0}},flat_address_out_reg[1:0]};
      2'b11: x_rem_bs = {{NBIT_FLAT_ADDR-3{1'b0}},flat_address_out_reg[2:0]};
    endcase

    age_addr_o = ((flat_address_out_reg >> (block_size_i + n_banks_i)) << (block_size_i)) + x_rem_bs;

% if n_age_per_stream == 4:
    age_bank_ls_stream_o = age_bank_ls_stream[1:0];
% elif n_age_per_stream == 2:
    age_bank_ls_stream_o = age_bank_ls_stream[0];
% elif n_age_per_stream == 8:
    age_bank_ls_stream_o = age_bank_ls_stream[3:0];
% endif
  end

  assign age_bank_o = age_bank;

endmodule : age
