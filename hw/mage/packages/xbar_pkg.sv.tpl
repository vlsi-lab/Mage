// Copyright 2025 Politecnico di Torino.
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// File: xbar_pkg.sv
// Author: Alessio Naclerio
// Date: 26/02/2025
// Description: Package for crossbars

package xbar_pkg;
  import mage_pkg::*;
  import pea_pkg::*;

%if n_age_tot * n_age_per_stream > 32:
  localparam unsigned N_CFG_REGS_32_SEL_L_STREAM = 2;
  localparam unsigned N_CFG_REGS_32_SEL_S_STREAM = 2;
%else:
  localparam unsigned N_CFG_REGS_32_SEL_L_STREAM = 1;
  localparam unsigned N_CFG_REGS_32_SEL_S_STREAM = 1;
%endif

  // Number of 32-bit configuration registers for storing output pea selectors: (N_ROWS * log2(N_COLS))/32
  localparam unsigned N_CFG_REGS_32_SEL_OUT_PEA = 2;

  // These define the modularity of the xbar.
  // If set to 2, the xbar will have 2-to-1 muxes.
  // If set to 4, the xbar will have 4-to-1 muxes.
  localparam unsigned N_BANKS_PER_BB = 4;
  localparam unsigned N_PE_PER_BB = 4;
  // Log2 of number of banks per basic block
  localparam unsigned LOG_N_BANKS_PER_BB = $clog2(N_BANKS_PER_BB);
  // Log2 of number of PEs per basic block
  localparam unsigned LOG_N_PE_PER_BB = $clog2(N_PE_PER_BB);
  // Number of pipeline stages in banks <-> pea xbar
  // N_BANKS_PER_STREAM = N_PE_PER_GROUP and N_BANKS_PER_BB = N_PE_PER_BB
  localparam unsigned N_PIPE_STAGE_BANKS_PEA = $clog2(N_BANKS_PER_STREAM) / $clog2(N_BANKS_PER_BB);
  // Number of xbar basic blocks for each stage
  localparam unsigned N_BB_BANKS_PEA_STG_0 = N_BANKS_PER_STREAM / N_BANKS_PER_BB;
  localparam unsigned N_BB_BANKS_PEA_STG_1 = N_BANKS_PER_STREAM / (2 * N_BANKS_PER_BB);
  localparam unsigned N_BB_BANKS_PEA_STG_2 = N_BANKS_PER_STREAM / (4 * N_BANKS_PER_BB);

  // N_BANKS_PER_STREAM = N_AGE_PER_STREAM
  // This define the modularity of the xbar.
  // If set to 2, the xbar will have 2-to-1 muxes.
  // If set to 4, the xbar will have 4-to-1 muxes.
  localparam unsigned N_AGE_PER_BB = 2;
  // Number of pipeline stages in age -> banks xbar
  localparam unsigned N_PIPE_STAGE_AGE_BANKS = $clog2(N_BANKS_PER_STREAM) / $clog2(N_BANKS_PER_BB);
  // Number of xbar basic blocks for each stage
  localparam unsigned N_BB_AGE_BANKS_STG_0 = N_BANKS_PER_STREAM / N_AGE_PER_BB;
  localparam unsigned N_BB_AGE_BANKS_STG_1 = N_BANKS_PER_STREAM / (N_AGE_PER_BB * 2);
  localparam unsigned N_BB_AGE_BANKS_STG_2 = N_BANKS_PER_STREAM / (N_AGE_PER_BB * 4);


endpackage
