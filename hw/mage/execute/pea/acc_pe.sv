// Copyright 2025 Politecnico di Torino.
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// File: acc_pe.sv
// Author: Alessio Naclerio
// Date: 26/02/2025
// Description: This is a standard PE with functionalities to support accumulation, also for vector mode operations (8 and 16 bits)

module acc_pe
  import pea_pkg::*;
(
    input  logic                                 clk_i,
    input  logic                                 rst_n_i,
    input  logic [  N_INPUTS_PE-1:0][N_BITS-1:0] pe_op_i,
    input  logic [N_CFG_BITS_PE-1:0]             ctrl_pe_i,
    input  logic [  N_INPUTS_PE-1:0]             stream_valid_i,
    output logic                                 stream_valid_o,
    output logic [       N_BITS-1:0]             pe_res_o
);
  //output of input muxes
  logic      [         N_BITS-1:0] mux1_out;
  logic      [         N_BITS-1:0] mux2_out;
  logic      [         N_BITS-1:0] pe_res;
  logic      [         N_BITS-1:0] tmp_pe_res;
  logic      [LOG_N_INPUTS_PE-1:0] mux1_sel;
  logic      [LOG_N_INPUTS_PE-1:0] mux2_sel;
  logic      [                1:0] vec_mode;
  logic                            acc_counter_sel;

  //fu signals
  logic      [         N_BITS-1:0] fu_out;
  logic      [         N_BITS-1:0] fu_out_d;
  fu_instr_t                       fu_sel;

  //Accumulation signals
  logic                            vec_mode_8;
  logic                            vec_mode_16;
  logic                            no_vec_mode;
  logic      [                4:0] output_ready_ff;
  logic                            output_ready;
  logic      [               17:0] adder_res_16_part;
  logic      [               17:0] adder_16_part_in_a;
  logic      [               17:0] adder_16_part_in_b;
  logic      [                7:0] adder_8_res;

  ////////////////////////////////////////////////////////////////
  //                                                            //
  //                      PE Control Word                       //
  //                                                            //
  ////////////////////////////////////////////////////////////////
  assign mux1_sel = ctrl_pe_i[LOG_N_INPUTS_PE-1 : 0];
  assign mux2_sel = ctrl_pe_i[LOG_N_INPUTS_PE+LOG_N_INPUTS_PE-1 : LOG_N_INPUTS_PE];
  assign fu_sel = fu_instr_t'(ctrl_pe_i[LOG_N_INPUTS_PE+LOG_N_INPUTS_PE+LOG_N_OPERATIONS-1 : LOG_N_INPUTS_PE+LOG_N_INPUTS_PE]);
  assign acc_counter_sel = ctrl_pe_i[LOG_N_INPUTS_PE+LOG_N_INPUTS_PE+LOG_N_OPERATIONS];
  assign vec_mode = ctrl_pe_i[LOG_N_INPUTS_PE+LOG_N_INPUTS_PE+LOG_N_OPERATIONS+2 : LOG_N_INPUTS_PE+LOG_N_INPUTS_PE+LOG_N_OPERATIONS+1];

  // First accumulation match
  // The first accumulation must be ignored, it only serves for giving the right first input to acc PE
  /* always_ff @(posedge clk_i or negedge rst_n_i) begin
    if (~rst_n_i) begin
      first_acc_match <= 1'b0;
    end else begin
      if(acc_match_i == 1'b1) begin
        first_acc_match <= 1'b1;
      end else begin
        first_acc_match <= first_acc_match;
      end
    end
  end */

  /* Accumulation match signal to be asserted if
    1. The PE is in accumulation mode
    2. It is not the first accumulation match signal from accumulation controller
    3. The accumulation match signal is currently asserted from the accumulation controller
  */
  assign acc_match = (acc_counter_sel == 1'b1) ? acc_match_i : 1'b0;  //&& first_acc_match == 1'b1

  //ATTENTION: The feedback operand for the accumulation is ALWAYS on the first operands input to the FU
  /*
    Management of PE actual inputs
    They are always equal to the output of the input muxes,
    except when the PE is in accumulation mode. In this case, as long as the accumulation match signal is not asserted
    the output of the FU is fed back to the input of the FU. When asserted, the output of the mux1 is fed to the input of the FU
  */
  always_comb begin
    if (acc_counter_sel) begin
      if (!acc_match_i) begin
        mux1_out = fu_out_d;  //pe_op_i[4'b0110];
        mux2_out = pe_op_i[mux2_sel];
      end else begin
        mux1_out = pe_op_i[mux1_sel];
        mux2_out = pe_op_i[mux2_sel];
      end
    end else begin
      mux1_out = pe_op_i[mux1_sel];
      mux2_out = pe_op_i[mux2_sel];
    end
  end

  ////////////////////////////////////////////////////////////////
  //                                                            //
  //                Partitioned Functional Unit                 //
  //                                                            //
  ////////////////////////////////////////////////////////////////
  fu_partitioned int_fu (
      .clk_i(clk_i),
      .rst_n_i(rst_n_i),
      .a_i(mux1_out),
      .b_i(mux2_out),
      .instr_i(fu_sel),
      .vec_mode_i(vec_mode),
      .res_o(fu_out)
  );

  // register holding the output of the FU to be fed back to it for the accumulation case
  always_ff @(posedge clk_i or negedge rst_n_i) begin
    if (~rst_n_i) begin
      fu_out_d <= 0;
    end else begin
      fu_out_d <= fu_out;
    end
  end

  ////////////////////////////////////////////////////////////////
  //                                                            //
  // 16-bit and 8-bit Adders for Vector Mode Final Accumulation //
  //                                                            //
  ////////////////////////////////////////////////////////////////

  //PE temporary output register holding the operand to consider for vecmode 8 and 16 accumulation final stage
  always_ff @(posedge clk_i, negedge rst_n_i) begin
    if (!rst_n_i) begin
      tmp_pe_res <= 0;
    end else begin
      if (acc_match) begin
        tmp_pe_res <= fu_out_d;
      end else begin
        tmp_pe_res <= tmp_pe_res;
      end
    end
  end

  //Vector mode detection
  always_comb begin
    vec_mode_8  = vec_mode == 2'b01;
    vec_mode_16 = vec_mode == 2'b10;
    no_vec_mode = vec_mode == 2'b00;
  end

  // delay acc_match to create the signal that is asserted when the output is ready
  always_ff @(posedge clk_i or negedge rst_n_i) begin
    if (~rst_n_i) begin
      output_ready_ff <= 0;
    end else begin
      output_ready_ff[0] <= acc_match;
      output_ready_ff[1] <= output_ready_ff[0];
      output_ready_ff[2] <= output_ready_ff[1];
      output_ready_ff[3] <= output_ready_ff[2];
      output_ready_ff[4] <= output_ready_ff[3];
    end
  end

  // Depending on the vector mode, the actual output ready signal differs
  always_comb begin
    if (vec_mode_8) begin
      output_ready = output_ready_ff[2];
    end else if (vec_mode_16) begin
      output_ready = output_ready_ff[1];
    end else begin
      output_ready = acc_match;
    end
  end

  // partitioned 16-bit adder for:
  // vec16 mode final addition in the accumulation process
  // first vec8 addtion in the accumulation process
  always_comb begin
    adder_16_part_in_a[0]     = 1'b1;
    adder_16_part_in_a[8:1]   = tmp_pe_res[7:0];
    adder_16_part_in_a[9]     = 1'b1;
    adder_16_part_in_a[17:10] = tmp_pe_res[15:8];

    adder_16_part_in_b[0]     = 1'b0;
    adder_16_part_in_b[8:1]   = tmp_pe_res[23:16];
    adder_16_part_in_b[9]     = 1'b0;
    adder_16_part_in_b[17:10] = tmp_pe_res[31:24];

    if (vec_mode_8) begin
      adder_16_part_in_a[9] = 1'b0;
    end
  end

  // adder and register
  always_ff @(posedge clk_i or negedge rst_n_i) begin
    if (~rst_n_i) begin
      adder_res_16_part <= 0;
    end else begin
      adder_res_16_part <= $signed(adder_16_part_in_a) + $signed(adder_16_part_in_b);
    end
  end

  // 8-bit adder and register (Final vec8 addition)
  always_ff @(posedge clk_i or negedge rst_n_i) begin
    if (~rst_n_i) begin
      adder_8_res <= 0;
    end else begin
      adder_8_res <= $signed(adder_res_16_part[8:1]) + $signed(adder_res_16_part[17:10]);
    end
  end

  //PE output register
  always_ff @(posedge clk_i, negedge rst_n_i) begin
    if (!rst_n_i) begin
      pe_res_o <= 0;
    end else begin
      if (output_ready && vec_mode_8) begin
        pe_res_o <= {{24{adder_8_res[7]}}, adder_8_res};
      end else if (output_ready && vec_mode_16) begin
        pe_res_o <= {{16{adder_res_16_part[17]}}, adder_res_16_part[17:10], adder_res_16_part[8:1]};
      end else begin
        pe_res_o <= fu_out;
      end
    end
  end

endmodule
