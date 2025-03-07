// Copyright 2025 Politecnico di Torino.
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// File: ba_gen.sv
// Author: Alessio Naclerio
// Date: 26/02/2025
// Description: This module generates Bank and Address Outputs for a given AGE.


module ba_gen
  import mage_pkg::*;
(
    //NBIT_FLAT_ADDR = 10
    input  logic [    NBIT_FLAT_ADDR-1:0] flat_address_i,
    //NBIT_N_BANKS = 2
    input  logic [      NBIT_N_BANKS-1:0] n_banks_i,
    //NBIT_START_BANK = 3
    input  logic [   NBIT_START_BANK-1:0] start_bank_i,
    //NBIT_BLOCK_SIZE = 2
    input  logic [   NBIT_BLOCK_SIZE-1:0] block_size_i,
    //NBIT_ADDR = 10
    output logic [         NBIT_ADDR-1:0] age_addr_o,
    output logic [N_BANKS_PER_STREAM-1:0] age_bank_o,
    output logic [LOG_N_BANKS_PER_STREAM-1:0] age_bank_ls_stream_o
);

  logic [NBIT_FLAT_ADDR-1:0] x_div_bs;
  logic [NBIT_FLAT_ADDR-1:0] x_rem_bs;
  logic [3-1:0] age_bank_ls_stream;

  always_comb begin
    x_div_bs = (flat_address_i >> block_size_i);
    case(n_banks_i)
      2'b00: age_bank_ls_stream = start_bank_i;
      2'b01: age_bank_ls_stream = {2'b0, x_div_bs[0]} + start_bank_i;
      2'b10: age_bank_ls_stream = {1'b0, x_div_bs[1:0]} + start_bank_i;
      2'b11: age_bank_ls_stream = x_div_bs[2:0] + start_bank_i;
    endcase

    age_bank_o = 1 << age_bank_ls_stream;

    case(block_size_i)
      2'b00: x_rem_bs = '0;
      2'b01: x_rem_bs = {{NBIT_FLAT_ADDR-1{1'b0}},flat_address_i[0]};
      2'b10: x_rem_bs = {{NBIT_FLAT_ADDR-2{1'b0}},flat_address_i[1:0]};
      2'b11: x_rem_bs = {{NBIT_FLAT_ADDR-3{1'b0}},flat_address_i[2:0]};
    endcase

    age_addr_o = ((flat_address_i >> (block_size_i + n_banks_i)) << (block_size_i)) + x_rem_bs;

% if n_age_per_stream == 4:
    age_bank_ls_stream_o = age_bank_ls_stream[1:0];
% elif n_age_per_stream == 2:
    age_bank_ls_stream_o = age_bank_ls_stream[0];
% elif n_age_per_stream == 8:
    age_bank_ls_stream_o = age_bank_ls_stream[3:0];
% endif
  end

endmodule : ba_gen
