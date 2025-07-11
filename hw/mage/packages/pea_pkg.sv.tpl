// Copyright 2025 Politecnico di Torino.
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// File: pea_pkg.sv
// Author: Alessio Naclerio
// Date: 26/02/2025
// Description: Package for the execute part of Mage

package pea_pkg;
%if enable_streaming_interface == str(1):
  import stream_intf_pkg::*;
%endif
%if enable_decoupling == str(1):
  import mage_pkg::*;
%endif
  <%import math as m%>
  ////////////////////////////////////////////////////////////////
  //             Configuration Registers Parameters             //
  ////////////////////////////////////////////////////////////////
  localparam unsigned KMEM_SIZE = ${kernel_len};
  localparam unsigned N_CFG_ADDR_BITS = (KMEM_SIZE == 1) ? 1 : $clog2(KMEM_SIZE);
  localparam unsigned N_CFG_BITS_PE = 32;

  ////////////////////////////////////////////////////////////////
  //         Processing Element Array (PEA) Parameters          //
  ////////////////////////////////////////////////////////////////
  localparam unsigned N_BITS = 32;

  localparam unsigned M = ${n_pea_cols};
  localparam unsigned N = ${n_pea_rows};
  localparam unsigned LOG_M = $clog2(M);
  localparam unsigned LOG_N = $clog2(N);

%if enable_decoupling == str(1):
  localparam unsigned N_PE_GROUP = N_STREAMS;
  localparam unsigned N_PE_PER_GROUP = N_AGE_PER_STREAM;
  localparam unsigned LOG_N_PE_PER_GROUP = $clog2(N_PE_PER_GROUP);

  localparam unsigned N_IN_PEA = N_BANKS_GROUP*N_BANKS_PER_STREAM;
  localparam unsigned N_OUT_PEA = N_PE_GROUP*N_PE_PER_GROUP;
%endif

%if enable_streaming_interface == str(1):
  localparam unsigned N_RADIX = 16;
  localparam unsigned N_DIV_STAGE = 8;
%endif

  localparam unsigned N_NEIGH_PE = ${n_neigh_pe};
%if enable_streaming_interface == str(1):
  localparam unsigned N_INPUTS_PE = ${n_pe_in_stream + n_neigh_pe + 4};
  localparam unsigned N_OPERATIONS = 32;
  localparam unsigned LOG_N_OPERATIONS = (N_OPERATIONS == 1) ? 1 : $clog2(N_OPERATIONS);
%elif enable_decoupling == str(1):
  localparam unsigned N_INPUTS_PE = ${n_neigh_pe + n_pe_in_mem + 4};
  localparam unsigned N_OPERATIONS = 16;
  localparam unsigned LOG_N_OPERATIONS = (N_OPERATIONS == 1) ? 1 : $clog2(N_OPERATIONS);
%endif
  localparam unsigned LOG_N_INPUTS_PE = (N_INPUTS_PE == 1) ? 1 : $clog2(N_INPUTS_PE);

  localparam unsigned RF_CFG_BITS = 5;

  localparam unsigned END_CFG_MUX_SEL_0       = LOG_N_INPUTS_PE - 1;
  localparam unsigned END_CFG_MUX_SEL_1       = 2 * LOG_N_INPUTS_PE - 1;
  localparam unsigned END_CFG_OP              = 2 * LOG_N_INPUTS_PE + LOG_N_OPERATIONS - 1;
  localparam unsigned END_RF_CFG              = 2 * LOG_N_INPUTS_PE + LOG_N_OPERATIONS + RF_CFG_BITS - 1;
  localparam unsigned END_DELAY_PE_MUX_SEL    = 2 * LOG_N_INPUTS_PE + LOG_N_OPERATIONS + RF_CFG_BITS + $clog2(N_NEIGH_PE) - 1;
  localparam unsigned END_DELAY_PE_OP_MUX_SEL = 2 * LOG_N_INPUTS_PE + LOG_N_OPERATIONS + RF_CFG_BITS + $clog2(N_NEIGH_PE) + 2 - 1;
%if enable_decoupling == str(1):
  ////////////////////////////////////////////////////////////////
  //                Kernel Controller Parameters                //
  ////////////////////////////////////////////////////////////////

  localparam unsigned NBIT_LP_P_K_E = 2;

  typedef struct packed {
    logic [NBIT_LP_P_K_E-1:0] len_e;
    logic [NBIT_LP_P_K_E-1:0] len_k;
    logic [NBIT_LP_P_K_E-1:0] len_p;
    logic [4-1:0] len_dfg;
  } loop_pipeline_info_t;
%endif
  ////////////////////////////////////////////////////////////////
  //         PE Instructions and Interconnections Types         //
  ////////////////////////////////////////////////////////////////
%if enable_streaming_interface == str(1):
  typedef enum logic[4:0]{
    NOP       = 5'b00000,
    ABS       = 5'b00001,
    ADD       = 5'b00010,
    SUB       = 5'b00011,
    MUL       = 5'b00100,
    LSH       = 5'b00101,
    ARSH      = 5'b00110,
    LRSH      = 5'b00111,
    MAX       = 5'b01000,
    MIN       = 5'b01001,
    DIV       = 5'b01010,
    REM       = 5'b01011,
    ACC       = 5'b01100,
    MAXS      = 5'b01101,
    SHACC     = 5'b01110,
    SGNSEL    = 5'b01111,
    ABSDIV    = 5'b10000,
    ABSMIN    = 5'b10001,
    ABSREM    = 5'b10010,
    ADDPOW    = 5'b10011,
    SUBPOW    = 5'b10100,
    SGNCSUB   = 5'b10101,
    CADDMUL   = 5'b10110,
    ADDCMUL   = 5'b10111,
    CMULADD   = 5'b11000,
    CADDDIV   = 5'b11001,
    MULCARSH  = 5'b11010,
    CLSHSUB   = 5'b11011
  } fu_instr_t;
%elif enable_decoupling == str(1):
  typedef enum logic[3:0]{
    NOP = 4'b0000,
    MUL = 4'b0001,
    SUB = 4'b0010,
    LSH = 4'b0011,
    LRSH = 4'b0100,
    ARSH = 4'b0101,
    MAX = 4'b0110,
    MIN = 4'b0111,
    ABS = 4'b1000,
    SGNMUL = 4'b1001,
    ADD = 4'b1010
  } fu_instr_t;
%elif enable_streaming_interface == str(1):

%endif

  typedef enum logic [LOG_N_INPUTS_PE-1:0]{
%if  enable_streaming_interface == str(1):
  CONSTANT   = 4'b0000,
  %for i in range(n_pe_in_stream):
    STREAM_IN${i} = 4'b${'{:04b}'.format(i+1)},
  %endfor
  UP         = 4'b${'{:04b}'.format(n_pe_in_stream+1)},
  LEFT       = 4'b${'{:04b}'.format(n_pe_in_stream+2)},
  RIGHT      = 4'b${'{:04b}'.format(n_pe_in_stream+3)},
  DOWN       = 4'b${'{:04b}'.format(n_pe_in_stream+4)},
  SELF       = 4'b${'{:04b}'.format(n_pe_in_stream+5)},
  RF         = 4'b${'{:04b}'.format(n_pe_in_stream+6)},
  DELAY_OP   = 4'b${'{:04b}'.format(n_pe_in_stream+7)}
%elif enable_decoupling == str(1):
  CONSTANT   = 4'b0000,
  MEMLEFT0   = 4'b0001,
  MEMLEFT1   = 4'b0010,
  MEMRIGHT0  = 4'b0011,
  MEMRIGHT1  = 4'b0100,
  UP         = 4'b0101,
  LEFT       = 4'b0110,
  RIGHT      = 4'b0111,
  DOWN       = 4'b1000,
  SELF       = 4'b1001,
  RF         = 4'b1010
%endif
  }pe_mux_sel_t;

%if enable_streaming_interface == str(1):
  typedef enum logic [$clog2(N_NEIGH_PE)-1:0] {
    D_UP      = 2'b00,
    D_LEFT    = 2'b01,
    D_RIGHT   = 2'b10,
    D_DOWN    = 2'b11
  } delay_pe_mux_sel_t;

  typedef enum logic [1:0] {
    D_PE_OP_NONE  = 2'b00,
    D_PE_RES      = 2'b01,
    D_PE_OP_A     = 2'b10,
    D_PE_OP_B     = 2'b11
  } delay_pe_op_mux_sel_t;
%endif
%if enable_decoupling == str(1):
  ////////////////////////////////////////////////////////////////
  //                         FSM States                         //
  ////////////////////////////////////////////////////////////////
  typedef enum logic [1:0] {
    IDLE,
    EXEC,
    DONE
  } state_t;
%endif
endpackage : pea_pkg
