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
%if enable_decoupling == str(1):
  localparam unsigned CFG_BANK_SIZE = ${kernel_len};
  localparam unsigned N_CFG_ADDR_BITS = (CFG_BANK_SIZE == 1) ? 1 : $clog2(CFG_BANK_SIZE);
%endif
  localparam unsigned N_CFG_BITS_PE = 16;
  localparam unsigned N_CFG_REGS_PE = ${m.ceil(kernel_len/2)};

  ////////////////////////////////////////////////////////////////
  //         Processing Element Array (PEA) Parameters          //
  ////////////////////////////////////////////////////////////////
  localparam unsigned N_BITS = 32;

  localparam unsigned M = ${n_pea_rows};
  localparam unsigned N = ${n_pea_cols};
  localparam unsigned LOG_M = $clog2(M);
  localparam unsigned LOG_N = $clog2(N);

%if enable_decoupling == str(1):
  localparam unsigned N_PE_GROUP = N_STREAMS;
  localparam unsigned N_PE_PER_GROUP = N_AGE_PER_STREAM;
  localparam unsigned LOG_N_PE_PER_GROUP = $clog2(N_PE_PER_GROUP);

  localparam unsigned N_IN_PEA = N_BANKS_GROUP*N_BANKS_PER_STREAM;
  localparam unsigned N_OUT_PEA = N_PE_GROUP*N_PE_PER_GROUP;
%endif

  localparam unsigned N_OPERATIONS = 16;
  localparam unsigned N_NEIGH_PE = ${n_neigh_pe};
%if enable_streaming_interface == str(1) and enable_decoupling == str(1):
  localparam unsigned N_INPUTS_PE = ${n_pe_in_stream + n_neigh_pe + n_pe_in_mem + 3};
  localparam unsigned N_INPUTS_VALID_PE = ${n_pe_in_stream + n_neigh_pe + 1} ;
%elif enable_streaming_interface == str(1) and enable_decoupling == str(0):
  localparam unsigned N_INPUTS_PE = ${n_pe_in_stream + n_neigh_pe + 3};
  localparam unsigned N_INPUTS_VALID_PE = ${n_pe_in_stream + n_neigh_pe + 1};
%elif enable_streaming_interface == str(0) and enable_decoupling == str(1):
  localparam unsigned N_INPUTS_PE = ${n_neigh_pe + n_pe_in_mem + 2};
%endif
  localparam unsigned LOG_N_OPERATIONS = (N_OPERATIONS == 1) ? 1: $clog2(N_OPERATIONS);
  localparam unsigned LOG_N_INPUTS_PE = (N_INPUTS_PE == 1) ? 1 : $clog2(N_INPUTS_PE);
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
  typedef enum logic[3:0]{
    ADD = 4'b0000,
    MUL = 4'b0001,
    SUB = 4'b0010,
    LSH = 4'b0011,
    LRSH = 4'b0100,
    ARSH = 4'b0101,
    MAX = 4'b0110,
%if enable_streaming_interface == str(1):
    MIN = 4'b0111,
    DIV = 4'b1000,
    DIVU = 4'b1001,
    ACC = 4'b1010,
    ABS = 4'b1011,
    SGNMUL = 4'b1100
%else:
    MIN = 4'b0111
%endif
  } fu_instr_t;

  typedef enum logic [LOG_N_INPUTS_PE-1:0]{
%if enable_streaming_interface == str(1) and enable_decoupling == str(1):
    MEMLEFT0   = 4'b0000,
    MEMLEFT1   = 4'b0001,
    MEMRIGHT0  = 4'b0010,
    MEMRIGHT1  = 4'b0011,
    STREAM_IN0 = 4'b0100,
    CONSTANT   = 4'b0101,
    SELF       = 4'b0110,
    UP         = 4'b0111,
    LEFT       = 4'b1000,
    RIGHT      = 4'b1001,
    DOWN       = 4'b1010
%elif  enable_streaming_interface == str(1) and enable_decoupling == str(0):
    STREAM_IN0 = 3'b000,
    CONSTANT   = 3'b001,
    SELF       = 3'b010,
    UP         = 3'b011,
    LEFT       = 3'b100,
    RIGHT      = 3'b101,
    DOWN       = 3'b110,
    DELAY_OP   = 3'b111
%elif  enable_streaming_interface == str(0) and enable_decoupling == str(1):
    MEMLEFT0   = 4'b0000,
    MEMLEFT1   = 4'b0001,
    MEMRIGHT0  = 4'b0010,
    MEMRIGHT1  = 4'b0011,
    CONSTANT   = 4'b0100,
    SELF       = 4'b0101,
    UP         = 4'b0110,
    LEFT       = 4'b0111,
    RIGHT      = 4'b1000,
    DOWN       = 4'b1001
%endif
  }pe_mux_sel_t;
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
