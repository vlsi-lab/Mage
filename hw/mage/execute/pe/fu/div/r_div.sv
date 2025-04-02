// Copyright 2025 Politecnico di Torino.
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// File: r_div.sv
// Author: Alessio Naclerio
// Date: 26/02/2025
// Description: Restoring Multicycle Divider

module r_div
  import pea_pkg::*;
(
    input  logic              rst_n_i,
    input  logic              clk_i,
    input  logic              en_i,
    input  logic [N_BITS-1:0] n_i,
    input  logic [N_BITS-1:0] d_i,
    output logic [N_BITS-1:0] r_o,
    output logic [N_BITS-1:0] q_o,
    output logic              valid_o
);

  typedef enum logic [1:0] {
    IDLE,
    EXEC,
    FINISH
  } div_fsm_t;

  // i/o div signals
  logic [N_BITS-1:0] r_out_stage_in_reg;
  logic [N_BITS-1:0] r_out_stage_out_reg;
  logic [N_BITS-1:0] r_in_stage;
  logic [$clog2(N_RADIX)-1:0] q_out_stage;
  logic [N_BITS-1:0] q_out;
  logic [N_BITS-1:0] n_in_stage;
  logic [N_BITS-1:0] n_in;
  // fsm-realted signals
  logic [$clog2(N_DIV_STAGE)-1:0] cnt;
  div_fsm_t div_state_n;
  div_fsm_t div_state_c;

  r_div_stage r_div_stage_inst (
      .n_i(n_in[N_BITS-1:N_BITS-$clog2(N_RADIX)]),
      .d_i(d_i),
      .r_i(r_in_stage),
      .r_o(r_out_stage_in_reg),
      .q_o(q_out_stage)
  );

  always_ff @(posedge clk_i, negedge rst_n_i) begin
    if (!rst_n_i) begin
      div_state_c <= IDLE;
    end else begin
      div_state_c <= div_state_n;
    end
  end

  always_ff @(posedge clk_i, negedge rst_n_i) begin
    if (!rst_n_i) begin
      cnt <= '0;
    end else begin
      if (en_i) begin
        cnt <= cnt + 1;
      end
    end
  end

  always_comb begin
    case (div_state_c)
      IDLE: begin
        if (en_i) begin
          div_state_n = EXEC;
        end else begin
          div_state_n = IDLE;
        end
      end
      EXEC: begin
        if (cnt == N_DIV_STAGE - 2) begin
          div_state_n = FINISH;
        end
      end
      FINISH: begin
        if (en_i) begin
          div_state_n = EXEC;
        end else begin
          div_state_n = IDLE;
        end
      end
      default: begin
        div_state_n = IDLE;
      end
    endcase
  end

  always_comb begin
    case (cnt)
      0: begin
        r_in_stage = '0;
      end
      default: begin
        r_in_stage = r_out_stage_out_reg;
      end
    endcase
  end

  always_ff @(posedge clk_i, negedge rst_n_i) begin
    if (!rst_n_i) begin
      r_out_stage_out_reg <= '0;
    end else begin
      r_out_stage_out_reg <= r_out_stage_in_reg;
    end
  end

  assign valid_o = (div_state_c == FINISH);
  assign r_o = r_out_stage_out_reg;

  always_ff @(posedge clk_i, negedge rst_n_i) begin
    if (!rst_n_i) begin
      q_out <= '0;
    end else begin
      if (div_state_c == EXEC || div_state_c == IDLE) begin
        q_out <= (q_out << $clog2(N_RADIX)) | q_out_stage;
      end else begin
        q_out <= '0;
      end
    end
  end

  always_comb begin
    q_o = {q_out[N_BITS-1-$clog2(N_RADIX):0], q_out_stage[$clog2(N_RADIX)-1:0]};
  end

  always_ff @(posedge clk_i, negedge rst_n_i) begin
    if (!rst_n_i) begin
      n_in_stage <= '0;
    end else begin
      if (en_i) begin
        n_in_stage <= (n_in << $clog2(N_RADIX));
      end else begin
        n_in_stage <= '0;
      end
    end
  end

  assign n_in = (cnt == 0) ? n_i : n_in_stage;

endmodule
