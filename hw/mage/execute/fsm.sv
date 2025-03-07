// Copyright 2025 Politecnico di Torino.
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// File: fsm.sv
// Author: Alessio Naclerio
// Date: 26/02/2025
// Description: This module is a simple FSM that transitions between IDLE, EXEC, and DONE states

module fsm
  import pea_pkg::*;
(
    input  logic   clk_i,
    input  logic   rst_n_i,
    input  logic   start_i,
    input  logic   end_i,
    //output interrupt signal
    output logic   intr_o,
    //output state
    output state_t state_o
);

  // Define the state register
  state_t next_state;
  state_t state;
  logic   intr;

  always_ff @(posedge clk_i, negedge rst_n_i) begin : state_transition_fsm_ff
    if (!rst_n_i) begin
      state <= IDLE;
    end else begin
      state <= next_state;
    end
  end

  always_comb begin : states_transitions_fsm_comb
    case (state)

      IDLE: begin
        intr = 1'b0;
        if (start_i) begin
          next_state = EXEC;
        end else begin
          next_state = IDLE;
        end
      end

      EXEC: begin
        if (end_i == 1'b1) begin
          next_state = DONE;
          intr = 1'b0;
        end else begin
          next_state = EXEC;
          intr = 1'b0;
        end
      end

      DONE: begin
        intr = 1'b1;
        next_state = IDLE;
      end

      default: begin
        next_state = IDLE;
        intr = 1'b0;
      end

    endcase
  end

  assign intr_o  = intr;
  assign state_o = state;

endmodule
