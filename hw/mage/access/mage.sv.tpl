// Copyright 2025 Politecnico di Torino.
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// File: mage.sv
// Author: Alessio Naclerio
// Date: 26/02/2025
// Description: Address Generation Unit top module

module mage
  import mage_pkg::*;
  import pea_pkg::*;
(
    input logic clk_i,
    input logic rst_n_i,
    input logic start_i,
    input logic [1:0] reg_acc_vec_mode_i,
    ////////////////////////////////////////////////////////////////
    //                Hardware Loops Configuration                //
    ////////////////////////////////////////////////////////////////
    input loop_vars_t [N_LP-1:0] reg_loop_vars_i,
    ////////////////////////////////////////////////////////////////
    //                  Controller Configuration                  //
    ////////////////////////////////////////////////////////////////
% if kernel_len != 1:
    input logic reg_static_no_timemux_i,
    input loop_pipeline_info_t reg_lp_info_i,
% endif
    input logic [NBIT_II-1:0] reg_II_i,
    ////////////////////////////////////////////////////////////////
    //                Re-Order Unit Configuration                 //
    ////////////////////////////////////////////////////////////////
    input logic [N_STREAMS-1:0][N_AGE_PER_STREAM-1:0][NBIT_LP_IV-1:0] reg_iv_contraints_i,
    ////////////////////////////////////////////////////////////////
    //                        Stride Sizes                        //
    ////////////////////////////////////////////////////////////////
    input logic [N_AGE_TOT-1:0][N_IVS-1:0][NBIT_LP_IV-1:0] reg_age_strides_i,
    ////////////////////////////////////////////////////////////////
    //                   Streams Configuration                    //
    ////////////////////////////////////////////////////////////////
    input logic [ACC_CFGMEM_SIZE-1:0][N_AGE_TOT-1:0][NBIT_CFG_STREAM_WORD-1:0] cfgmem_content_i,
    ////////////////////////////////////////////////////////////////
    //                     Start/End Signals                      //
    ////////////////////////////////////////////////////////////////
    output logic start_d_o,
    output logic end_lp_o,
% if kernel_len != 1:
    ////////////////////////////////////////////////////////////////
    //                PC for Configuration Memory                 //
    ////////////////////////////////////////////////////////////////
    output logic [N_CFG_ADDR_BITS-1:0] cfgmem_addr_d_o,
% endif
    ////////////////////////////////////////////////////////////////
    //                Interface to Multi-Bank SpM                 //
    ////////////////////////////////////////////////////////////////
    output logic [N_STREAMS-1:0][N_AGE_PER_STREAM-1:0][NBIT_ADDR-1:0] mage_addr_o,
    output logic [N_STREAMS-1:0][N_AGE_PER_STREAM-1:0][N_BANKS_PER_STREAM-1:0] mage_bank_o,
    output logic [N_STREAMS-1:0][N_AGE_PER_STREAM-1:0][LOG_N_BANKS_PER_STREAM-1:0] mage_bank_ls_o,
    output logic [N_STREAMS-1:0][N_AGE_PER_STREAM-1:0] mage_valid_o,
    output logic [N_STREAMS-1:0][N_AGE_PER_STREAM-1:0] mage_valid_ls_o,
    output logic [N_STREAMS-1:0][N_AGE_PER_STREAM-1:0] mage_lns_o,
    output logic mage_pea_acc_reset_o
);
% if kernel_len != 1:
  ////////////////////////////////////////////////////////////////
  //                Stream Configuration Memory                 //
  ////////////////////////////////////////////////////////////////
  logic [LOG2_ACC_CFGMEM_SIZE-1:0] cfgmem_addr_disp;
  logic [LOG2_ACC_CFGMEM_SIZE-1:0] cfgmem_addr;
% endif
  ////////////////////////////////////////////////////////////////
  //              Configuration Dispatcher Outputs              //
  ////////////////////////////////////////////////////////////////
  logic [N_AGE_TOT-1:0] is_age_active_rou;
  logic [N_AGE_TOT-1:0] is_age_active;
  logic [N_AGE_TOT-1:0][LOG2_HWLP_RF_SIZE-1:0] hwlp_sel;
  logic [N_AGE_TOT-1:0][LOG2_N_LP-1+1:0] iv_contraints_sel;
  logic [N_AGE_TOT-1:0][NBIT_IV_CONST-1:0] const_iv;
  logic [N_AGE_TOT-1:0][NBIT_N_BANKS-1:0] n_banks;
  logic [N_AGE_TOT-1:0][NBIT_START_BANK-1:0] start_banks;
  logic [N_AGE_TOT-1:0][NBIT_BLOCK_SIZE-1:0] block_size;
  logic [N_AGE_TOT-1:0] stream_lns;
  logic [N_AGE_TOT-1:0] is_acc_store;
  logic [N_AGE_TOT-1:0] is_acc_store_rou;
  ////////////////////////////////////////////////////////////////
  //                        HWLP Outputs                        //
  ////////////////////////////////////////////////////////////////
  logic hwlp_valid;
  logic [N_LP-1:0][NBIT_LP_IV-1:0] loop_vars;
  logic [N_LP-1:0] hwlp_end_condition;
  ////////////////////////////////////////////////////////////////
  //                      HWLP RF Outputs                       //
  ////////////////////////////////////////////////////////////////
  logic [HWLP_RF_SIZE-1:0] hwlp_rf_valid;
  logic [HWLP_RF_SIZE-1:0][N_LP-1:0][NBIT_LP_IV-1:0] hwlp_rf;
  logic [N_LP-1:0] hwlp_rf_end_condition;
  ////////////////////////////////////////////////////////////////
  //                      HWLP ROU Outputs                      //
  ////////////////////////////////////////////////////////////////
  logic [N_AGE_TOT-1:0][N_IVS-1:0][NBIT_LP_IV-1:0] hwlp_rou_in_reg;
  logic [N_AGE_TOT-1:0] stream_valid_in_reg;
  logic [N_AGE_TOT-1:0] pea_acc_reset_in_reg;
  ////////////////////////////////////////////////////////////////
  //                   Pipe Registers Signals                   //
  ////////////////////////////////////////////////////////////////
  logic [N_AGE_TOT-1:0] stream_valid_out_reg;
  logic [N_AGE_TOT-1:0] pea_acc_reset_out_reg;
  logic [N_AGE_TOT-1:0][N_IVS-1:0][NBIT_LP_IV-1:0] hwlp_rou_out_reg;
  logic [N_STREAMS-1:0][N_AGE_PER_STREAM-1:0] stream_pea_acc_reset_out_reg;
  ////////////////////////////////////////////////////////////////
  //                      AGE Unit Outputs                      //
  ////////////////////////////////////////////////////////////////
  logic [N_STREAMS-1:0][N_AGE_PER_STREAM-1:0][NBIT_ADDR-1:0] mage_addr_in_reg;
  logic [N_STREAMS-1:0][N_AGE_PER_STREAM-1:0][N_BANKS_PER_STREAM-1:0] mage_bank_in_reg;
  logic [N_STREAMS-1:0][N_AGE_PER_STREAM-1:0][LOG_N_BANKS_PER_STREAM-1:0] mage_bank_ls_in_reg;
  logic [N_STREAMS-1:0][N_AGE_PER_STREAM-1:0][LOG_N_BANKS_PER_STREAM-1:0] mage_bank_ls_out_age;
  logic [N_STREAMS-1:0][N_AGE_PER_STREAM-1:0] mage_valid_in_reg;
  logic [N_STREAMS-1:0][N_AGE_PER_STREAM-1:0] mage_lns_in_reg;
  logic [N_STREAMS-1:0][N_AGE_PER_STREAM-1:0] stream_pea_acc_reset_in_reg;
  ////////////////////////////////////////////////////////////////
  //                     Start/End Signals                      //
  ////////////////////////////////////////////////////////////////
  logic hwlp_end_lp;
  logic hwlp_end_lp_set;
  logic [HWLP_RF_SIZE-1:0] hwlp_rf_end_lp;
  logic [N_AGE_TOT-1:0] hwlp_rou_end_lp;
  logic [N_AGE_TOT-1:0] stream_active;


  ////////////////////////////////////////////////////////////////
  //                                                            //
  //                     Pipeline Registers                     //
  //                                                            //
  ////////////////////////////////////////////////////////////////
  always_ff @(posedge clk_i or negedge rst_n_i) begin
    if (~rst_n_i) begin

      // AGU outputs
      mage_addr_o <= '0;
      mage_bank_o <= '0;
      mage_bank_ls_o <= '0;
      mage_valid_o <= '0;
      mage_valid_ls_o <= '0;
      mage_lns_o <= '0;

      // AGU bank_ls signal delayed one extra cycle
      mage_bank_ls_in_reg <= '0;

      // ROU - AGU stream_valid signals
      stream_valid_out_reg <= '0;
      hwlp_rou_out_reg <= '0;

      // ROU - AGU pea_acc signals
      pea_acc_reset_out_reg <= '0;
      stream_pea_acc_reset_out_reg <= '0;
      
    end else begin
      if (start_i) begin
        
        // ROU - AGU pea_acc signals
        stream_pea_acc_reset_out_reg <= stream_pea_acc_reset_in_reg;
        pea_acc_reset_out_reg <= pea_acc_reset_in_reg;
        
        // ROU - AGU stream_valid signals
        stream_valid_out_reg <= stream_valid_in_reg;
        hwlp_rou_out_reg <= hwlp_rou_in_reg;

        // AGU bank_ls signal delayed one extra cycle
        mage_bank_ls_in_reg <= mage_bank_ls_out_age;
        mage_bank_ls_o <= mage_bank_ls_in_reg;

        // AGU outputs
        mage_addr_o <= mage_addr_in_reg;
        mage_bank_o <= mage_bank_in_reg;
        mage_valid_o <= mage_valid_in_reg;
        mage_valid_ls_o <= mage_valid_o;
        mage_lns_o <= mage_lns_in_reg;

      end
    end
  end

  //mage cfgmem controller
  k_controller k_controller_inst (
      .clk_i(clk_i),
      .rst_n_i(rst_n_i),
      .start_i(start_i),
% if kernel_len != 1:
      .reg_lp_info_i(reg_lp_info_i),
      .count_pke_o(cfgmem_addr_disp),
      .count_pke_d_o(cfgmem_addr_d_o),
% endif
      .start_d_o(start_d_o)
  );

  assign end_lp_o = hwlp_end_lp_set & (&(~stream_active));

  always_ff @(posedge clk_i or negedge rst_n_i) begin
    if(!rst_n_i) begin
      hwlp_end_lp_set <= 1'b0;
    end else begin
      if(hwlp_end_lp) begin
        hwlp_end_lp_set <= 1'b1;
      end else begin
        hwlp_end_lp_set <= hwlp_end_lp_set;
      end
    end
  end

  //hwlp module
  hwlp hwlp_inst (
      .clk_i(clk_i),
      .rst_n_i(rst_n_i),
      .count_en_i(start_i),
      .end_condition_lp_o(hwlp_end_condition),
      .reg_II_i(reg_II_i),
      .reg_loop_vars_i(reg_loop_vars_i),
      .loop_vars_o(loop_vars),
      .hwlp_valid_o(hwlp_valid),
      .end_lp_o(hwlp_end_lp)
  );


  //hwlp_rf module
  hwlp_rf hwlp_rf_inst (
      .clk_i(clk_i),
      .rst_n_i(rst_n_i),
      .start_i(start_i),
      .end_lp_i(hwlp_end_lp),
      .end_condition_lp_i(hwlp_end_condition),
      .end_condition_lp_o(hwlp_rf_end_condition),
      .hwlp_valid_i(hwlp_valid),
      .loop_vars_i(loop_vars),
      .hwlp_valid_o(hwlp_rf_valid),
      .hwlp_rf_o(hwlp_rf),
      .end_lp_o(hwlp_rf_end_lp)
  );

  //hwlp_rou module
  hwlp_rou hwlp_rou_inst (
      .clk_i(clk_i),
      .rst_n_i(rst_n_i),
      .hwlp_sel_i(hwlp_sel),
      .hwlp_rf_i(hwlp_rf),
      .end_lp_i(hwlp_rf_end_lp),
      .hwlp_end_condition_i(hwlp_rf_end_condition),
      .is_age_active_i(is_age_active_rou),
      .reg_iv_constraints_i(reg_iv_contraints_i),
      .iv_constraints_sel_i(iv_contraints_sel),
      .hwlp_valid_i(hwlp_rf_valid),
      .is_acc_store_rou_i(is_acc_store_rou),
      .reg_acc_vec_mode_i(reg_acc_vec_mode_i),
      .stream_valid_o(stream_valid_in_reg),
      .pea_acc_reset_o(pea_acc_reset_in_reg),
      .hwlp_rou_o(hwlp_rou_in_reg),
      .end_lp_o(hwlp_rou_end_lp)
  );

  //age_unit module
  age_unit age_unit_inst (
      .clk_i(clk_i),
      .rst_n_i(rst_n_i),
      .start_i(start_i),
      .end_lp_i(hwlp_rou_end_lp),
      .reg_age_strides_i(reg_age_strides_i),
      .rou_i(hwlp_rou_out_reg),
      .pea_acc_reset_i(pea_acc_reset_out_reg),
      .stream_valid_i(stream_valid_out_reg),
      .is_age_active_i(is_age_active),
      .const_iv_i(const_iv),
      .n_banks_i(n_banks),
      .start_banks_i(start_banks),
      .block_size_i(block_size),
      .is_acc_store_i(is_acc_store),
      .stream_lns_i(stream_lns),
      .stream_addr_o(mage_addr_in_reg),
      .stream_bank_o(mage_bank_in_reg),
      .stream_bank_ls_o(mage_bank_ls_out_age),
      .stream_pea_acc_reset_o(stream_pea_acc_reset_in_reg),
      .stream_valid_o(mage_valid_in_reg),
      .stream_lns_o(mage_lns_in_reg),
      .stream_active_o(stream_active)
  );

  assign mage_pea_acc_reset_o = |stream_pea_acc_reset_out_reg;

% if kernel_len != 1:
  // Configuration Memory Address (PC)
  always_comb begin
    if (reg_static_no_timemux_i) begin
      cfgmem_addr = '0;
    end else begin
      cfgmem_addr = cfgmem_addr_disp;
    end
  end
% endif

  //cfg_dispatcher module
  cfg_dispatcher cfg_dispatcher_inst (
      .clk_i(clk_i),
      .rst_n_i(rst_n_i),
% if kernel_len != 1:
      .cfgmem_addr_i(cfgmem_addr),
% endif
      .cfgmem_content_i(cfgmem_content_i),
      //To hwlp_rou
      .hwlp_sel_o(hwlp_sel),
      .iv_constraint_sel_o(iv_contraints_sel),
      .is_acc_store_rou_o(is_acc_store_rou),
      .is_age_active_rou_o(is_age_active_rou),
      //To age_unit
      .const_iv_o(const_iv),
      .is_age_active_o(is_age_active),
      .n_banks_o(n_banks),
      .start_banks_o(start_banks),
      .block_size_o(block_size),
      .stream_lns_o(stream_lns),
      .is_acc_store_o(is_acc_store)
  );

endmodule : mage
