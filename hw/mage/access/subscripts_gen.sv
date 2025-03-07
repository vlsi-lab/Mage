// Copyright 2025 Politecnico di Torino.
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// File: subscripts_gen.sv
// Author: Alessio Naclerio
// Date: 26/02/2025
// Description: This module generates the subscripts from the IVs and the strides


module subscripts_gen
  import mage_pkg::*;
(
    input  logic [N_SUBSCRIPTS-1:0][N_IV_PER_SUBSCRIPT-1:0][NBIT_LP_IV-1:0] iv_i,
    input  logic [N_SUBSCRIPTS-1:0][N_IV_PER_SUBSCRIPT-1:0][NBIT_LP_IV-1:0] reg_strides_i,
    output logic [N_SUBSCRIPTS-1:0][    NBIT_FLAT_ADDR-1:0]                 subscripts_o
);

  logic [N_SUBSCRIPTS-1:0][N_IV_PER_SUBSCRIPT-1:0][NBIT_FLAT_ADDR-1:0] mult_ivs;

  /*
  always_comb begin
    subscripts_o = '0;
    for (int i = 0; i < N_SUBSCRIPTS; i = i + 1) begin
      for (int j = 0; j < N_IV_PER_SUBSCRIPT; j = j + 1) begin
        subscripts_o[i] = subscripts_o[i] + iv_i[i][j];
      end
      subscripts_o[i] = subscripts_o[i] + iv_const_i[i];
    end
  end */

  always_comb begin
    for (int i = 0; i < N_SUBSCRIPTS; i = i + 1) begin
      for (int j = 0; j < N_IV_PER_SUBSCRIPT; j = j + 1) begin
        mult_ivs[i][j] = iv_i[i][j] * reg_strides_i[i][j];
      end
    end
  end

  //sum mult_ivs two by two
  /* always_comb begin
    for (int i = 0; i < N_SUBSCRIPTS; i = i + 1) begin
      for (int j = 0; j < (N_IV_PER_SUBSCRIPT/2) - 1; j = j + 1) begin
        subscripts_o[i] = mult_ivs[i][j] + mult_ivs[i][j+1];
      end
    end
  end */
  assign subscripts_o[0] = mult_ivs[0][0] + mult_ivs[0][1];
  assign subscripts_o[1] = mult_ivs[1][0] + mult_ivs[1][1];

endmodule : subscripts_gen
