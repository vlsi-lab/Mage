
// Copyright 2025 Politecnico di Torino.
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// File: fu_partitioned.sv
// Author: Alessio Naclerio
// Date: 26/02/2025
// Description:  This module is a functional unit that can perform the following operations:
//               - 8-bit, 16-bit, and 32-bit Addition
//               - 8-bit, 16-bit, and 32-bit Multiplication
//               - 8-bit, 16-bit, and 32-bit Subtraction

module fu_partitioned
  import pea_pkg::*;
(
    input  logic             clk_i,
    input  logic             rst_n_i,
    input  logic      [31:0] a_i,
    input  logic      [31:0] b_i,
    input  logic             stream_valid_a_i,
    input  logic             stream_valid_b_i,
    output logic             stream_valid_o,
    input  logic      [ 1:0] vec_mode_i,
    input  fu_instr_t        instr_i,
    output logic      [31:0] res_o
);

  // Multipliers Inputs
  logic [7:0] mul_op_8_a;
  logic [7:0] mul_op_8_b;
  logic [15:0] mul_op_16_1_a;
  logic [15:0] mul_op_16_1_b;
  logic [15:0] mul_op_16_2_a;
  logic [15:0] mul_op_16_2_b;
  logic [15:0] mul_op_16_3_a;
  logic [15:0] mul_op_16_3_b;

  // Multipliers Outputs
  logic [7:0] mul_result_8;
  logic [31:0] mul_result_16_1;
  logic [15:0] mul_result_16_2;
  logic [15:0] mul_result_16_3;
  logic [31:0] mul_result_16_1_d;
  logic [15:0] mul_result_16_2_d;
  logic [15:0] mul_result_16_3_d;

  // Vector Modes
  logic vec_mode_8;
  logic vec_mode_16;
  logic no_vec_mode;

  always_comb begin
    vec_mode_8  = vec_mode_i == 2'b01;
    vec_mode_16 = vec_mode_i == 2'b10;
    no_vec_mode = vec_mode_i == 2'b00;
  end

  logic valid;

  always_comb begin
    case (instr_i)
      DIV || DIVU: begin
        valid = div_ready;
      end
      default: valid = 1;
    endcase
  end

  always_ff @(posedge clk_i, negedge rst_n_i) begin
    if (!rst_n_i) begin
      stream_valid_o <= '0;
    end else begin
      stream_valid_o <= valid;
    end
  end

  ////////////////////////////////////////////////////////////////
  //                                                            //
  //               Partitioned Integer Multiplier               //
  //                                                            //
  ////////////////////////////////////////////////////////////////

  always_comb begin

    // default case is mul32
    mul_op_16_1_a = a_i[15:0];  //A_low
    mul_op_16_1_b = b_i[15:0];  //B_low
    mul_op_16_2_a = a_i[15:0];  //A_low
    mul_op_16_2_b = b_i[31:16];  //B_high
    mul_op_16_3_a = a_i[31:16];  //A_high
    mul_op_16_3_b = b_i[15:0];  //B_low
    mul_op_8_a = '0;
    mul_op_8_b = '0;

    if (instr_i == MUL) begin
      // mul8
      if (vec_mode_8) begin
        mul_op_8_a = a_i[7:0];
        mul_op_8_b = b_i[7:0];
        mul_op_16_1_a[7:0] = a_i[15:8];
        mul_op_16_1_b[7:0] = b_i[15:8];
        mul_op_16_2_a[7:0] = a_i[23:16];
        mul_op_16_2_b[7:0] = b_i[23:16];
        mul_op_16_3_a[7:0] = a_i[31:24];
        mul_op_16_3_b[7:0] = b_i[31:24];
        //mul16
      end else if (vec_mode_16) begin
        mul_op_16_1_a = a_i[15:0];
        mul_op_16_1_b = b_i[15:0];
        mul_op_16_2_a = a_i[31:16];
        mul_op_16_2_b = b_i[31:16];
        mul_op_16_3_a = '0;
        mul_op_16_3_b = '0;
      end
    end
  end

  // Multipliers outputs

  always_comb begin
    mul_result_8 = mul_op_8_a * mul_op_8_b;
    mul_result_16_1 = mul_op_16_1_a * mul_op_16_1_b;
    mul_result_16_2 = mul_op_16_2_a * mul_op_16_2_b;
    mul_result_16_3 = mul_op_16_3_a * mul_op_16_3_b;
  end

  // 32-bit mul case
  always_ff @(posedge clk_i, negedge rst_n_i) begin
    if (!rst_n_i) begin
      mul_result_16_1_d <= '0;
      mul_result_16_2_d <= '0;
      mul_result_16_3_d <= '0;
    end else begin
      if (instr_i == MUL && no_vec_mode) begin
        mul_result_16_1_d <= mul_result_16_1;
        mul_result_16_2_d <= mul_result_16_2;
        mul_result_16_3_d <= mul_result_16_3;
      end else begin
        mul_result_16_1_d <= '0;
        mul_result_16_2_d <= '0;
        mul_result_16_3_d <= '0;
      end
    end
  end


  ////////////////////////////////////////////////////////////////
  //                                                            //
  // Partitioned Integer Adder/Subtractor (based on RI5CY ALU)  //
  //                                                            //
  ////////////////////////////////////////////////////////////////

  // Adder
  logic adder_op_b_negate;
  logic [15:0]
      adder_op_a_low,
      adder_op_b_low,
      adder_op_a_high,
      adder_op_b_high,
      operand_b_neg_low,
      operand_b_neg_high;
  logic [17:0] adder_in_a_low, adder_in_b_low, adder_in_a_high, adder_in_b_high;
  logic [31:0] adder_result;
  logic [18:0] adder_result_expanded_low, adder_result_expanded_high;

  assign adder_op_b_negate = (instr_i == SUB);

  // prepare operand a
  assign adder_op_a_low = a_i[15:0];
  assign adder_op_a_high = a_i[31:16];

  assign operand_b_neg_low = ~b_i[15:0];
  assign operand_b_neg_high = ~b_i[31:16];

  // prepare operand b
  assign adder_op_b_low = adder_op_b_negate ? operand_b_neg_low : b_i[15:0];
  assign adder_op_b_high = adder_op_b_negate ? operand_b_neg_high : b_i[31:16];

  // prepare carry
  always_comb begin
    // default is the 32-bit addition case
    adder_in_a_low[0]      = 1'b1;
    adder_in_a_low[8:1]    = adder_op_a_low[7:0];
    adder_in_a_low[9]      = 1'b1;
    adder_in_a_low[17:10]  = adder_op_a_low[15:8];
    adder_in_a_high[0]     = adder_result_expanded_low[18];
    adder_in_a_high[8:1]   = adder_op_a_high[7:0];
    adder_in_a_high[9]     = 1'b1;
    adder_in_a_high[17:10] = adder_op_a_high[15:8];

    adder_in_b_low[0]      = 1'b0;
    adder_in_b_low[8:1]    = adder_op_b_low[7:0];
    adder_in_b_low[9]      = 1'b0;
    adder_in_b_low[17:10]  = adder_op_b_low[15:8];
    adder_in_b_high[0]     = 1'b0;
    adder_in_b_high[8:1]   = adder_op_b_high[7:0];
    adder_in_b_high[9]     = 1'b0;
    adder_in_b_high[17:10] = adder_op_b_high[15:8];

    if (adder_op_b_negate) begin
      // special case for subtractions and absolute number calculations
      adder_in_b_low[0] = 1'b1;

      if (vec_mode_16) begin
        adder_in_a_high[0] = 1'b0;
        adder_in_b_high[0] = 1'b1;
      end else if (vec_mode_8) begin
        adder_in_a_high[0] = 1'b0;
        adder_in_b_low[9]  = 1'b1;
        adder_in_b_high[0] = 1'b1;
        adder_in_b_high[9] = 1'b1;
      end

    end else if (instr_i == ADD) begin
      // take care of partitioning the adder for the addition case
      if (vec_mode_16) begin
        adder_in_a_high[0] = 1'b0;
      end else if (vec_mode_8) begin
        adder_in_a_low[9]  = 1'b0;
        adder_in_a_high[0] = 1'b0;
        adder_in_a_high[9] = 1'b0;
      end
    end else if (instr_i == MUL && no_vec_mode) begin
      adder_in_a_low[8:1] = mul_result_16_2_d[7:0];
      adder_in_a_low[17:10] = mul_result_16_2_d[15:8];
      adder_in_b_low[8:1] = mul_result_16_3_d[7:0];
      adder_in_b_low[17:10] = mul_result_16_3_d[15:8];

      adder_in_a_high[8:1] = mul_result_16_1_d[23:16];
      adder_in_a_high[17:10] = mul_result_16_1_d[31:24];
      adder_in_b_high[8:1] = adder_result_expanded_low[8:1];
      adder_in_b_high[17:10] = adder_result_expanded_low[17:10];
    end
  end

  // actual adder
  assign adder_result_expanded_low = $signed(adder_in_a_low) + $signed(adder_in_b_low);
  assign adder_result_expanded_high = $signed(adder_in_a_high) + $signed(adder_in_b_high);
  assign adder_result = {
    adder_result_expanded_high[17:10],
    adder_result_expanded_high[8:1],
    adder_result_expanded_low[17:10],
    adder_result_expanded_low[8:1]
  };

  ////////////////////////////////////////////////////////////////
  //                                                            //
  //                  Partitioned Shifter                       //
  //                                                            //
  ////////////////////////////////////////////////////////////////

  logic        shift_left;  // should we shift left
  logic        shift_arithmetic;

  logic [31:0] operand_a_rev;
  logic [31:0] operand_a_neg;
  logic [31:0] operand_a_neg_rev;

  logic [31:0] shift_amt_left;  // amount of shift, if to the left
  logic [31:0] shift_amt;  // amount of shift, to the right
  logic [31:0] shift_amt_int;  // amount of shift, used for the actual shifters
  logic [31:0] shift_op_a;  // input of the shifter
  logic [31:0] shift_result;
  logic [31:0] shift_right_result;
  logic [31:0] shift_left_result;

  assign shift_amt = b_i;

  assign operand_a_neg = ~a_i;
  // bit reverse operand_a_neg for left shifts and bit counting
  generate
    genvar m;
    for (m = 0; m < 32; m++) begin : gen_operand_a_neg_rev
      assign operand_a_neg_rev[m] = operand_a_neg[31-m];
    end
  endgenerate

  // bit reverse operand_a for left shifts
  generate
    genvar k;
    for (k = 0; k < 32; k++) begin : gen_operand_a_rev
      assign operand_a_rev[k] = a_i[31-k];
    end
  endgenerate

  // by reversing the bits of the input, we also have to reverse the order of shift amounts
  always_comb begin
    case (vec_mode_i)
      2'b01: begin
        shift_amt_left[15:0]  = shift_amt[31:16];
        shift_amt_left[31:16] = shift_amt[15:0];
      end

      2'b10: begin
        shift_amt_left[7:0]   = shift_amt[31:24];
        shift_amt_left[15:8]  = shift_amt[23:16];
        shift_amt_left[23:16] = shift_amt[15:8];
        shift_amt_left[31:24] = shift_amt[7:0];
      end

      default: // VEC_MODE32
      begin
        shift_amt_left[31:0] = shift_amt[31:0];
      end
    endcase
  end

  // ALU_FL1 and ALU_CBL are used for the bit counting ops later
  assign shift_left = (instr_i == ALHS) || (instr_i == LSH);

  assign shift_arithmetic = (instr_i == ARSH)  || (instr_i == ALHS);

  // choose the bit reversed or the normal input for shift operand a
  assign shift_op_a    = shift_left ? operand_a_rev : a_i;
  assign shift_amt_int = shift_left ? shift_amt_left : shift_amt;

  // right shifts, we let the synthesizer optimize this
  logic [63:0] shift_op_a_32;

  assign shift_op_a_32 = $signed({{32{shift_arithmetic & shift_op_a[31]}}, shift_op_a});

  always_comb begin
    case (vec_mode_i)
      2'b01: begin
        shift_right_result[31:16] = $signed({shift_arithmetic & shift_op_a[31],
                                             shift_op_a[31:16]}) >>> shift_amt_int[19:16];
        shift_right_result[15:0] =
            $signed({shift_arithmetic & shift_op_a[15], shift_op_a[15:0]}) >>> shift_amt_int[3:0];
      end

      2'b10: begin
        shift_right_result[31:24] = $signed({shift_arithmetic & shift_op_a[31],
                                             shift_op_a[31:24]}) >>> shift_amt_int[26:24];
        shift_right_result[23:16] = $signed({shift_arithmetic & shift_op_a[23],
                                             shift_op_a[23:16]}) >>> shift_amt_int[18:16];
        shift_right_result[15:8] =
            $signed({shift_arithmetic & shift_op_a[15], shift_op_a[15:8]}) >>> shift_amt_int[10:8];
        shift_right_result[7:0] = $signed({shift_arithmetic & shift_op_a[7], shift_op_a[7:0]}) >>>
            shift_amt_int[2:0];
      end

      default: // VEC_MODE32
      begin
        shift_right_result = shift_op_a_32 >> shift_amt_int[4:0];
      end
    endcase
    ;  // case (vec_mode_i)
  end

  // bit reverse the shift_right_result for left shifts
  genvar j;
  generate
    for (j = 0; j < 32; j++) begin : gen_shift_left_result
      assign shift_left_result[j] = shift_right_result[31-j];
    end
  endgenerate

  assign shift_result = shift_left ? shift_left_result : shift_right_result;

  /////////////////////////////////////////////////////////////////////
  //   ____  _ _      ____                  _      ___               //
  //  | __ )(_) |_   / ___|___  _   _ _ __ | |_   / _ \ _ __  ___    //
  //  |  _ \| | __| | |   / _ \| | | | '_ \| __| | | | | '_ \/ __|   //
  //  | |_) | | |_  | |__| (_) | |_| | | | | |_  | |_| | |_) \__ \_  //
  //  |____/|_|\__|  \____\___/ \__,_|_| |_|\__|  \___/| .__/|___(_) //
  //                                                   |_|           //
  /////////////////////////////////////////////////////////////////////

  logic [31:0] ff_input;  // either op_a_i or its bit reversed version
  logic [ 5:0] clb_result;  // count leading bits
  logic [ 4:0] ff1_result;  // holds the index of the first '1'
  logic        ff_no_one;  // if no ones are found

  cv32e40p_popcnt popcnt_i (
      .in_i    (operand_a_i),
      .result_o(cnt_result)
  );

  always_comb begin
    ff_input = '0;

    case (instr_i)
      DIVU: ff_input = operand_a_rev;

      DIV: begin
        if (operand_a_i[31]) ff_input = operand_a_neg_rev;
        else ff_input = operand_a_rev;
      end
    endcase
  end

  cv32e40p_ff_one ff_one_i (
      .in_i       (ff_input),
      .first_one_o(ff1_result),
      .no_ones_o  (ff_no_one)
  );

  assign clb_result = ff1_result - 5'd1;


  ////////////////////////////////////////////////////
  //  ____ _____     __     __  ____  _____ __  __  //
  // |  _ \_ _\ \   / /    / / |  _ \| ____|  \/  | //
  // | | | | | \ \ / /    / /  | |_) |  _| | |\/| | //
  // | |_| | |  \ V /    / /   |  _ <| |___| |  | | //
  // |____/___|  \_/    /_/    |_| \_\_____|_|  |_| //
  //                                                //
  ////////////////////////////////////////////////////

  logic [31:0] result_div;
  logic        div_ready;
  logic        div_signed;
  logic        div_op_a_signed;
  logic [ 5:0] div_shift_int;

  assign div_signed = (instr_i == DIV);

  assign div_op_a_signed = a_i[31] & div_signed;

  assign div_shift_int = ff_no_one ? 6'd31 : clb_result;
  assign div_shift = div_shift_int + (div_op_a_signed ? 6'd0 : 6'd1);

  assign div_valid = (stream_valid_a_i & stream_valid_b_i) & ((instr_i == DIV) || (instr_i == DIVU));

  // inputs A and B are swapped
  cv32e40p_alu_div alu_div_i (
      .Clk_CI (clk),
      .Rst_RBI(rst_n),

      // input IF
      .OpA_DI      (b_i),
      .OpB_DI      (shift_left_result),
      .OpBShift_DI (div_shift),
      .OpBIsZero_SI((a_i == 0)),

      .OpBSign_SI(div_op_a_signed),
      .OpCode_SI (operator_i[1:0]),

      .Res_DO(result_div),

      // Hand-Shake
      .InVld_SI (div_valid),
      .OutRdy_SI(div_valid),  //TO BE CHECKED
      .OutVld_SO(div_ready)
  );

  ////////////////////////////////////////////////////////////////
  //                                                            //
  //                        Comparator                          //
  //                                                            //
  ////////////////////////////////////////////////////////////////

  logic comparator_res;
  logic [31:0] comp_inst_res;
  assign comparator_res = ($signed(a_i) > $signed(b_i)) ? 1'b1 : 1'b0;
  always_comb begin
    case (instr_i)
      MAX: comp_inst_res = comparator_res ? a_i : b_i;
      MIN: comp_inst_res = comparator_res ? b_i : a_i;
      default: comp_inst_res = 0;
    endcase
  end

  ////////////////////////////////////////////////////////////////
  //                                                            //
  //                  Result Selection Stage                    //
  //                                                            //
  ////////////////////////////////////////////////////////////////

  always_comb begin
    case (instr_i)
      MUL: begin
        if (vec_mode_8) begin
          res_o = {mul_result_16_3[7:0], mul_result_16_2[7:0], mul_result_16_1[7:0], mul_result_8};
        end else if (vec_mode_16) begin
          res_o = {mul_result_16_2[15:0], mul_result_16_1[15:0]};
        end else begin
          res_o = {adder_result[15:0], mul_result_16_1_d[15:0]};
        end
      end

      ADD: begin
        res_o = adder_result;
      end

      SUB: begin
        res_o = adder_result;
      end

      ALHS: begin
        res_o = shift_result;
      end

      LSH: begin
        res_o = shift_result;
      end

      ARSH: begin
        res_o = shift_result;
      end

      LRSH: begin
        res_o = shift_result;
      end

      AND: res_o = a_i & b_i;

      OR: res_o = a_i | b_i;

      XOR: res_o = a_i ^ b_i;

      MAX: res_o = comp_inst_res;

      MIN: res_o = comp_inst_res;

      DIV: res_o = result_div;

      DIVU: res_o = result_div;

      default: res_o = 0;
    endcase
  end

endmodule
