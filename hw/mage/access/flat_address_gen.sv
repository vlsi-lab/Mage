// Copyright 2025 Politecnico di Torino.
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// File: flat_address_gen.sv
// Author: Alessio Naclerio
// Date: 26/02/2025
// Description: Generate the flat address from the subscripts and the constant

module flat_address_gen
  import mage_pkg::*;
(
    input  logic [  N_SUBSCRIPTS-1:0][NBIT_FLAT_ADDR-1:0] subscripts_i,
    input  logic [ NBIT_IV_CONST-1:0]                     iv_const_i,
    output logic [NBIT_FLAT_ADDR-1:0]                     flat_address_o
);

  always_comb begin
    flat_address_o = subscripts_i[0] + subscripts_i[1] + iv_const_i;
  end

endmodule : flat_address_gen
