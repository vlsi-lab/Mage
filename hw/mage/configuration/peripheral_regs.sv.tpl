// Copyright 2025 Politecnico di Torino.
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// File: peripheral_registers.sv
// Author: Alessio Naclerio
// Date: 26/02/2025
// Description: This module handles the relationship between the peripheral registers and Mage-Cgra

module peripheral_regs
%if enable_streaming_interface == str(1):
  import stream_intf_pkg::*;
%endif
%if enable_decoupling == str(1):
  import mage_pkg::*;
  import xbar_pkg::*;
%endif
  import pea_pkg::*;
  import reg_pkg::*;
  import mage_reg_pkg::*;
(
    input logic clk_i,
    input logic rst_n_i,
    input reg_req_t reg_req_i,
    output reg_rsp_t reg_rsp_o,
%if enable_decoupling == str(1):
    ////////////////////////////////////////////////////////////////
    //                  DAE Mage Configuration                    //
    ////////////////////////////////////////////////////////////////
    input state_t state_i,
    ////////////////////////////////////////////////////////////////
    //                 General Configuration Bits                 //
    ////////////////////////////////////////////////////////////////
    output logic reg_start_o,
    output logic [3:0] reg_block_size_o,
    output logic [NBIT_II-1:0] reg_II_o,
    output logic [N-1:0][M-1:0] reg_static_n_timemux_cgra_pea_o,
    output logic reg_static_n_timemux_mage_o,
    output logic reg_static_n_timemux_cgra_pea_out_regs_o,
    output logic reg_static_n_timemux_cgra_xbar_o,//packed simdy mode
    output logic [1:0] reg_acc_vec_mode_o,
    ////////////////////////////////////////////////////////////////
    //                      Agu Configuration                     //
    ////////////////////////////////////////////////////////////////
    output loop_pipeline_info_t reg_lp_info_o,
    output loop_vars_t [N_LP-1:0] reg_loop_vars_o,
    output logic [N_STREAMS-1:0][N_AGE_PER_STREAM-1:0][NBIT_LP_IV-1:0] reg_iv_contraints_o,
    output logic [N_AGE_TOT-1:0][N_SUBSCRIPTS-1:0][N_IV_PER_SUBSCRIPT-1:0][NBIT_LP_IV-1:0] reg_age_strides_o,
    output logic [ACC_CFGMEM_SIZE-1:0][N_AGE_TOT-1:0][NBIT_CFG_STREAM_WORD-1:0] reg_mage_cfgmem_o,
    ////////////////////////////////////////////////////////////////
    //                  Crossbars Configuration                   //
    ////////////////////////////////////////////////////////////////
    output logic [(N_CFG_REGS_32_SEL_OUT_PEA*32)-1:0] reg_cfg_sel_out_pea_o,
    output logic [(N_CFG_REGS_32_SEL_L_STREAM*32)-1:0] reg_cfg_l_stream_sel_o,
    output logic [(N_CFG_REGS_32_SEL_S_STREAM*32)-1:0] reg_cfg_s_stream_sel_o,
%endif
%if enable_streaming_interface == str(1):
    ////////////////////////////////////////////////////////////////
    //               Mage Streaming Configuration                 //
    ////////////////////////////////////////////////////////////////
    output logic [1:0] reg_separate_cols_o,
    output logic [N_DMA_CH-1:0] reg_dma_ch_cfg_o,
    output logic [M-1:0][LOG_N:0] reg_sel_out_col_pea_o,
    output logic [N-1:0][M-1:0][31:0] reg_acc_value_pe_o,
  %if out_stream_xbar == str(1):
    output logic [N_OUT_STREAM-1:0][N_DMA_CH_PER_OUT_STREAM-1:0][LOG_N_PEA_DOUT_PER_OUT_STREAM-1:0] reg_out_stream_sel_o,
  %endif
  %if in_stream_xbar == str(1):
    output logic [N_IN_STREAM-1:0][N_DMA_CH_PER_IN_STREAM-1:0][LOG_N_DMA_CH_PER_IN_STREAM-1:0] reg_in_stream_sel_o,
  %endif
%endif
    ////////////////////////////////////////////////////////////////
    //           Processing Element Array Configuration           //
    ////////////////////////////////////////////////////////////////
    output logic [N-1:0][M-1:0][31:0] reg_pea_constants_o,
    output logic [N-1:0][M-1:0][N_CFG_REGS_PE-1:0][32-1:0] reg_cfg_pea_o
);
%if enable_decoupling == str(1):
  mage_hw2reg_t hw2reg;
%endif
  mage_reg2hw_t reg2hw;

  mage_reg_top #(
      .reg_req_t(reg_req_t),
      .reg_rsp_t(reg_rsp_t)
  ) mage_reg_top_i (
      .clk_i(clk_i),
      .rst_ni(rst_n_i),
      .reg_req_i(reg_req_i),
      .reg_rsp_o(reg_rsp_o),
      .reg2hw(reg2hw),
%if enable_decoupling == str(1):
      .hw2reg(hw2reg),
%endif
      .devmode_i(1'b1)
  );

  always_comb begin
%if enable_decoupling == str(1):
    ////////////////////////////////////////////////////////////////
    //                   DAE Mage Configuration                   //
    ////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////
    //                        Mage status                         //
    ////////////////////////////////////////////////////////////////
    hw2reg.status.done.de = 1'b1;
    hw2reg.status.done.d = (state_i == DONE) ? 1'b1 : 1'b0;
    hw2reg.status.start.de = (state_i == DONE) ? 1'b1 : 1'b0;
    hw2reg.status.start.d = 1'b0;
    reg_start_o = reg2hw.status.start.q;
    ////////////////////////////////////////////////////////////////
    //                 Mage general configuration                 //
    ////////////////////////////////////////////////////////////////
    reg_II_o = reg2hw.gen_cfg.ii.q;
    for(int i = 0; i < N; i++) begin
        for(int j = 0; j < M; j++) begin
            reg_static_n_timemux_cgra_pea_o[i][j] = reg2hw.pea_control_snt.q[i * M + j];
        end
    end
    //reg_static_n_timemux_cgra_pea_o = reg2hw.gen_cfg.s_n_t_mage_pea.q;
    reg_static_n_timemux_cgra_pea_out_regs_o = reg2hw.gen_cfg.s_n_t_mage_pea_out_regs.q;
    reg_static_n_timemux_cgra_xbar_o = reg2hw.gen_cfg.s_n_t_mage_xbar.q;
    reg_static_n_timemux_mage_o = reg2hw.gen_cfg.s_n_t_mage.q;
    reg_block_size_o = reg2hw.gen_cfg.blocksize.q;
    reg_acc_vec_mode_o = reg2hw.gen_cfg.acc_vec_mode.q[1:0];
    ////////////////////////////////////////////////////////////////
    //            Mage Iteration Variables Constraints            //
    ////////////////////////////////////////////////////////////////
%for s in range(n_age_tot):
    reg_iv_contraints_o[${int(s/n_age_per_stream)}][${int(s%n_age_per_stream)}] = reg2hw.age_iv_constraints[${int(s/4)}].c${int(s%4)}.q;
%endfor
    ////////////////////////////////////////////////////////////////
    //                     Mage Strides Size                      //
    ////////////////////////////////////////////////////////////////
    for(int i = 0; i < N_AGE_TOT; i++) begin
      reg_age_strides_o[i][0][0] = reg2hw.strides[i].s0.q;
      reg_age_strides_o[i][0][1] = reg2hw.strides[i].s1.q;
      reg_age_strides_o[i][1][0] = reg2hw.strides[i].s2.q;
      reg_age_strides_o[i][1][1] = reg2hw.strides[i].s3.q;
    end
    ////////////////////////////////////////////////////////////////
    //             Mage Hardware Loops Configuration              //
    ////////////////////////////////////////////////////////////////
    reg_loop_vars_o[0].iv = reg2hw.ilb_hwl.ilb_0.q;
    reg_loop_vars_o[1].iv = reg2hw.ilb_hwl.ilb_1.q;
    reg_loop_vars_o[2].iv = reg2hw.ilb_hwl.ilb_2.q;
    reg_loop_vars_o[3].iv = reg2hw.ilb_hwl.ilb_3.q;
    reg_loop_vars_o[0].fv = reg2hw.flb_hwl.flb_0.q;
    reg_loop_vars_o[1].fv = reg2hw.flb_hwl.flb_1.q;
    reg_loop_vars_o[2].fv = reg2hw.flb_hwl.flb_2.q;
    reg_loop_vars_o[3].fv = reg2hw.flb_hwl.flb_3.q;
    reg_loop_vars_o[0].inc = reg2hw.inc_hwl.inc_0.q;
    reg_loop_vars_o[1].inc = reg2hw.inc_hwl.inc_1.q;
    reg_loop_vars_o[2].inc = reg2hw.inc_hwl.inc_2.q;
    reg_loop_vars_o[3].inc = reg2hw.inc_hwl.inc_3.q;
    ////////////////////////////////////////////////////////////////
    //                  Mage AGEs Configuration                   //
    ////////////////////////////////////////////////////////////////
  <%import math as m%>
    for(int i = 0; i < ACC_CFGMEM_SIZE; i++) begin
%for i in range(int(n_age_tot/n_age_per_stream)):
  %for j in range(n_age_per_stream):
      reg_mage_cfgmem_o[i][${i*n_age_per_stream+j}] = reg2hw.cfg_mage_s${i}_age${j}[i].q[NBIT_CFG_STREAM_WORD-1:0];
  %endfor
%endfor

    end
    ////////////////////////////////////////////////////////////////
    //                   Mage PKE Configuration                   //
    ////////////////////////////////////////////////////////////////
    reg_lp_info_o.len_e = reg2hw.pke.len_e.q[N_CFG_ADDR_BITS-1:0];
    reg_lp_info_o.len_k = reg2hw.pke.len_k.q[N_CFG_ADDR_BITS-1:0];
    reg_lp_info_o.len_p = reg2hw.pke.len_p.q[N_CFG_ADDR_BITS-1:0];
    reg_lp_info_o.len_dfg = reg2hw.pke.len_dfg.q;
    //reg_lp_info_o.n_rep_k = reg2hw.pke.nrk.q;
    ////////////////////////////////////////////////////////////////
    //                Mage Crossbars Configuration                //
    ////////////////////////////////////////////////////////////////
%if n_age_tot * n_age_per_stream > 32:
    reg_cfg_l_stream_sel_o = {reg2hw.l_stream_sel_age[1].q, reg2hw.l_stream_sel_age[0].q};
    reg_cfg_s_stream_sel_o = {reg2hw.s_stream_sel_age[1].q, reg2hw.s_stream_sel_age[0].q};
%else:
    reg_cfg_l_stream_sel_o = reg2hw.l_stream_sel_age[0].q;
    reg_cfg_s_stream_sel_o = reg2hw.s_stream_sel_age[0].q;
%endif
    reg_cfg_sel_out_pea_o = {reg2hw.sel_out_pea[1].q, reg2hw.sel_out_pea[0].q};
%endif
%if enable_streaming_interface == str(1):
    ////////////////////////////////////////////////////////////////
    //                Streaming Mage Configuration                //
    ////////////////////////////////////////////////////////////////
    reg_separate_cols_o = reg2hw.separate_cols.q;
    reg_dma_ch_cfg_o = reg2hw.stream_dma_cfg.q;
  %for c in range(n_pea_cols):
    reg_sel_out_col_pea_o[${c}] = reg2hw.sel_out_col_pea[0].sel_col_${c}.q;
  %endfor
  %for r in range(n_pea_rows):
    %for c in range(n_pea_cols):
    reg_acc_value_pe_o[${r}][${c}] = reg2hw.acc_value[${r*n_pea_cols+c}].q;
    %endfor 
  %endfor
  %if out_stream_xbar == str(1):
    %for i in range(n_out_stream):
      %for j in range(n_dma_ch_per_out_stream):
    reg_out_stream_sel_o[${i}][${j}] = reg2hw.stream_out_xbar_sel.sel_out_xbar_${i*n_dma_ch_per_out_stream+j};  
      %endfor
    %endfor
  %endif
  %if in_stream_xbar == str(1):
    %for i in range(n_in_stream):
      %for j in range(n_dma_ch_per_out_stream):
    reg_in_stream_sel_o[${i}][${j}] = reg2hw.stream_in_xbar_sel.sel_in_xbar_${i*n_dma_ch_per_out_stream+j};  
      %endfor
    %endfor
  %endif
%endif
    ////////////////////////////////////////////////////////////////
    //                   Mage PEA Configuration                   //
    ////////////////////////////////////////////////////////////////
%for r in range(n_pea_rows):
  %for c in range(n_pea_cols):
    reg_pea_constants_o[${r}][${c}] = reg2hw.pea_constants[${r*n_pea_cols+c}].q; 
  %endfor
%endfor
    for (int i = 0; i < N_CFG_REGS_PE; i++) begin
%for r in range(n_pea_rows):
  %for c in range(n_pea_cols):
      reg_cfg_pea_o[${r}][${c}][i] = reg2hw.cfg_pe_${r}${c}[i].q; 
  %endfor
%endfor
    end
  end

endmodule : peripheral_regs
