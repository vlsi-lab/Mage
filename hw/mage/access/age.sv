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
    input logic [N_SUBSCRIPTS-1:0][N_IV_PER_SUBSCRIPT-1:0][NBIT_LP_IV-1:0] iv_i,
    input logic pea_acc_reset_i,
    //constant for index
    input logic [NBIT_IV_CONST-1:0] iv_const_i,
    //Flat Address Generation Stage
    //CSR containing all column sizes neeeded for calculating flat address
    input logic [N_SUBSCRIPTS-1:0][N_IV_PER_SUBSCRIPT-1:0][NBIT_LP_IV-1:0] reg_strides_i,
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

  logic [      N_SUBSCRIPTS-1:0][NBIT_FLAT_ADDR-1:0] subscripts_out_sub_gen;
  logic [      N_SUBSCRIPTS-1:0][NBIT_FLAT_ADDR-1:0] subscripts_in_fa_gen;
  logic [    NBIT_FLAT_ADDR-1:0]                     flat_address_out_fa_gen;
  logic [    NBIT_FLAT_ADDR-1:0]                     flat_address_in_ba_gen;
  logic                                              valid;
  logic                                              valid_acc_store;
  logic [N_BANKS_PER_STREAM-1:0]                     age_bank;
  logic                                              pea_acc_reset;
  logic                                              active;
  logic                                              end_lp;
  //logic issue_load;

  /* always_comb begin
    if (is_acc_store_i) begin
      valid_acc_store = end_accumulation_i;
    end else begin
      valid_acc_store = 1'b1;
    end
  end */

  ////////////////////////////////////////////////////////////////
  //                                                            //
  //                     Pipeline Registers                     //
  //                                                            //
  ////////////////////////////////////////////////////////////////
  always_ff @(posedge clk_i, negedge rst_n_i) begin
    if (!rst_n_i) begin
      subscripts_in_fa_gen   <= '0;
      flat_address_in_ba_gen <= '0;
      valid                  <= '0;
      lns_o                  <= 1'b0;
      pea_acc_reset          <= '0;
    end else begin
      if (start_i == 1'b1 && active_i == 1'b1) begin
        subscripts_in_fa_gen   <= subscripts_out_sub_gen;
        flat_address_in_ba_gen <= flat_address_out_fa_gen;
        valid                  <= valid_i;  // & valid_acc_store;
        valid_o                <= valid;
        pea_acc_reset          <= pea_acc_reset_i;
        pea_acc_reset_o        <= pea_acc_reset && is_acc_store_i;
        lns_o                  <= lns_i;

        /* if(flat_address_out_fa_gen == flat_address_in_ba_gen && lns_i == 1'b1) begin
          issue_load <= 1'b0;
        end else begin
          issue_load <= 1'b1;
        end */

      end else begin
        subscripts_in_fa_gen   <= '0;
        flat_address_in_ba_gen <= '0;
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

  /* always_comb begin
    if(issue_load) begin
      age_bank_o = age_bank;
    end else begin
      age_bank_o = '0;
    end
  end */
  assign age_bank_o = age_bank;

  ////////////////////////////////////////////////////////////////
  //                                                            //
  //              Address Generation Engine Stages              //
  //                                                            //
  ////////////////////////////////////////////////////////////////
  //Subscript Generation Stage
  subscripts_gen subscripts_gen_inst (
      .iv_i(iv_i),
      .reg_strides_i(reg_strides_i),
      .subscripts_o(subscripts_out_sub_gen)
  );
  //Flat Address Generation Stage
  flat_address_gen flat_address_gen_inst (
      .subscripts_i  (subscripts_in_fa_gen),
      .iv_const_i    (iv_const_i),
      .flat_address_o(flat_address_out_fa_gen)
  );
  //Bank-Address Generation Stage
  ba_gen bank_gen_inst (
      .flat_address_i(flat_address_in_ba_gen),
      .start_bank_i(start_bank_i),
      .n_banks_i(n_banks_i),
      .block_size_i(block_size_i),
      .age_addr_o(age_addr_o),
      .age_bank_o(age_bank),
      .age_bank_ls_stream_o(age_bank_ls_stream_o)
  );

endmodule : age
