// Copyright 2025 Politecnico di Torino.
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// File: accumulation_counter.sv
// Author: Alessio Naclerio
// Date: 26/02/2025
// Description: Accumulation counter

module accumulation_counter
  import pea_pkg::*;
  import mage_pkg::*;
(
    input  logic                          clk_i,
    input  logic                          rst_n_i,
    input  state_t                        state_i,
    input  logic   [N_BITS_START_REG-1:0] reg_start_i,
    input  logic   [   N_BITS_TC_REG-1:0] reg_tc_i,
    input  logic   [         NBIT_II-1:0] reg_II_i,
    output logic                          end_o,
    output logic                          end_d1_o
);

  logic [   N_BITS_TC_REG-1:0] count;
  logic [N_BITS_START_REG-1:0] start_count;
  logic                        count_ii_en;
  logic                        count_en;
  logic [         NBIT_II-1:0] ii_count;
  logic                        cont_start;

  always_ff @(posedge clk_i or negedge rst_n_i) begin
    if (~rst_n_i) begin
      start_count <= '0;
      cont_start  <= 1'b1;
    end else begin
      if (state_i == EXEC) begin
        if (cont_start == 1'b0) begin
          count_ii_en <= 1'b1;
          cont_start  <= 1'b0;
          start_count <= '0;
        end else if (start_count == reg_start_i) begin
          cont_start  <= 1'b0;
          count_ii_en <= 1'b1;
          start_count <= '0;
        end else begin
          start_count <= start_count + 1;
          cont_start  <= 1'b1;
          count_ii_en <= 1'b0;
        end
      end else begin
        start_count <= '0;
        cont_start  <= '0;
        count_ii_en <= '0;
      end
    end
  end

  //II counter
  always_ff @(posedge clk_i, negedge rst_n_i) begin
    if (!rst_n_i) begin
      ii_count <= 0;
      count_en <= 0;
    end else if (count_ii_en) begin
      if (ii_count == reg_II_i) begin
        ii_count <= 0;
        count_en <= 1;
      end else begin
        ii_count <= ii_count + 1;
        count_en <= 0;
      end
    end else begin
      ii_count <= 0;
      count_en <= 0;
    end
  end

  always_ff @(posedge clk_i or negedge rst_n_i) begin
    if (~rst_n_i) begin
      count <= '0;
    end else begin
      if (count_en) begin
        if (count == reg_tc_i) begin
          count <= '0;
        end else begin
          count <= count + 1;
        end
      end else begin
        count <= count;
      end
    end
  end

  assign end_o = (count == reg_tc_i);

  always_ff @(posedge clk_i or negedge rst_n_i) begin
    if (~rst_n_i) begin
      end_d1_o <= '0;
    end else begin
      end_d1_o <= end_o;
    end
  end

endmodule : accumulation_counter
