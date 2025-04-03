// Copyright 2025 Politecnico di Torino.
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// File: pea_pkg.sv
// Author: Alessio Naclerio
// Date: 26/02/2025
// Description: Package for the execute part of Mage

package pea_pkg;
  import stream_intf_pkg::*;

  ////////////////////////////////////////////////////////////////
  //             Configuration Registers Parameters             //
  ////////////////////////////////////////////////////////////////
  localparam unsigned N_CFG_BITS_PE = 32;
  localparam unsigned N_CFG_REGS_PE = 1;

  ////////////////////////////////////////////////////////////////
  //         Processing Element Array (PEA) Parameters          //
  ////////////////////////////////////////////////////////////////
  localparam unsigned N_BITS = 32;

  localparam unsigned M = 4;
  localparam unsigned N = 4;
  localparam unsigned LOG_M = $clog2(M);
  localparam unsigned LOG_N = $clog2(N);


  localparam unsigned N_RADIX = 16;
  localparam unsigned N_DIV_STAGE = 8;

  localparam unsigned N_OPERATIONS = 16;
  localparam unsigned N_NEIGH_PE = 4;
  localparam unsigned N_INPUTS_PE = 9;
  localparam unsigned LOG_N_OPERATIONS = (N_OPERATIONS == 1) ? 1 : $clog2(N_OPERATIONS);
  localparam unsigned LOG_N_INPUTS_PE = (N_INPUTS_PE == 1) ? 1 : $clog2(N_INPUTS_PE);
  ////////////////////////////////////////////////////////////////
  //         PE Instructions and Interconnections Types         //
  ////////////////////////////////////////////////////////////////
  typedef enum logic [3:0] {
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
    ADD = 4'b1010,
    DIV = 4'b1011,
    DIVU = 4'b1100,
    ACC = 4'b1101,
    REM = 4'b1110,
    ADDPOW = 4'b1111
  } fu_instr_t;

  typedef enum logic [LOG_N_INPUTS_PE-1:0] {
    STREAM_IN0 = 4'b0000,
    CONSTANT   = 4'b0001,
    UP         = 4'b0010,
    LEFT       = 4'b0011,
    RIGHT      = 4'b0100,
    DOWN       = 4'b0101,
    SELF       = 4'b0110,
    RF         = 4'b0111,
    DELAY_OP   = 4'b1000
  } pe_mux_sel_t;

  typedef enum logic [LOG_N_INPUTS_PE-2:0] {
    D_UP      = 4'b000,
    D_LEFT    = 4'b001,
    D_RIGHT   = 4'b010,
    D_DOWN    = 4'b011,
    D_PE_RES  = 4'b100,
    D_PE_OP_A = 4'b101,
    D_PE_OP_B = 4'b110
  } delay_pe_mux_sel_t;
endpackage : pea_pkg
