// Copyright 2025 Politecnico di Torino.
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// File: fu_wrapper.sv
// Author: Alessio Naclerio
// Date: 26/02/2025
// Description: wrapper for functional unit

module fu_wrapper
  import pea_pkg::*;
(
    input  logic                   clk_i,
    input  logic                   rst_n_i,
    input  logic      [N_BITS-1:0] a_i,
    input  logic      [N_BITS-1:0] b_i,
    input  fu_instr_t              instr_i,
%if enable_streaming_interface == str(1):
    input  logic                   delay_sign_i,
    input  logic      [N_BITS-1:0] const_i,
    input  logic                   ops_valid_i,
    input  logic                   pea_ready_i,
    input  logic     [       15:0] reg_acc_value_i,
    output logic                   acc_loopback_o,
    output logic                   valid_o,
    output logic                   ready_o,
%endif
%if enable_decoupling == str(1):
    input  logic      [       1:0] vec_mode_i,
%endif
    output logic      [N_BITS-1:0] res_o
);

  // Internal signed versions of the inputs
  logic signed [N_BITS-1:0] a_signed;
  logic signed [N_BITS-1:0] b_signed;

  assign a_signed = $signed(a_i);
  assign b_signed = $signed(b_i); 

%if enable_streaming_interface == str(1):
  ////////////////////////////////////////////////////////////////
  //                    Ready-Valid Handling                    //
  ////////////////////////////////////////////////////////////////

  // acuumulation ready-valid
  logic [N_BITS-1:0]  acc_cnt;
  logic               acc_ready;
  logic               acc_valid;
  // ready-valid
  logic               valid;
  logic               ready;
  logic               valid_mo_instr;
  logic               mo_instr;
  // +1 adder
  logic [N_BITS-1:0]  add_one_op1;
  logic [N_BITS-1:0]  add_one_op2;
  logic [N_BITS-1:0]  add_one_res; 
%endif
%if enable_streaming_interface == str(1):

  /*
    +1 adder shared between:
      -> the ACC counter
      -> the ABS operation in ABSMIN
      -> the ABS operation in SGNCSUB
  */
  always_comb begin
    add_one_op1 = '0;
    add_one_op2[N_BITS-1:1] = '0;
    if(instr_i == ACC || instr_i == MAX) begin
      add_one_op1 = acc_cnt;
      add_one_op2[0] = 1'b1;
    end else if (instr_i == ABSMIN) begin
      add_one_op1 = sign_op1 ? op1_neg : a_signed;
      add_one_op2[0] = sign_op1 ? 1'b1 : 1'b0;
    end  else if (instr_i == SGNCSUB) begin
      add_one_op1 = sign_op1_d ? temp_res_neg : temp_res;
      add_one_op2[0] = sign_op1_d ? 1'b1 : 1'b0;
    end
  end

  always_comb begin
    add_one_res = add_one_op1 + add_one_op2;
  end

  ////////////////////////////////////////////////////////////////
  //                        Accumulation                        //
  ////////////////////////////////////////////////////////////////

  /*
    ACC counter: counts up to reg_acc_value_i, it is used to know how many elements to accumulate
    in the ACC instruction. It is also used to know when to stop the max search in the MAX instruction.
    acc_loopback_o is used to loop back the result of the operation to the input of the PE.
  */
  always_ff @(posedge clk_i, negedge rst_n_i) begin
    if (!rst_n_i) begin
      acc_cnt <= '0;
      acc_loopback_o <= 1'b0;
    end else begin
      if (instr_i == ACC || instr_i == MAX) begin
        if (acc_cnt == reg_acc_value_i && ops_valid_i && pea_ready_i) begin
          acc_cnt <= '0;
          acc_loopback_o <= 1'b0;
        end else if (ops_valid_i && pea_ready_i) begin
          acc_cnt <= add_one_res;
          acc_loopback_o <= 1'b1;
        end
      end else begin
        acc_cnt <= '0;
        acc_loopback_o <= 1'b0;
      end
    end
  end

  assign acc_ready = 1'b1;
  assign acc_valid = (acc_cnt == reg_acc_value_i && acc_cnt != '0 && ops_valid_i);

  ////////////////////////////////////////////////////////////////
  //                   Ready-Valid Assignment                   //
  ////////////////////////////////////////////////////////////////

  assign mo_instr = instr_i == ABSMIN || instr_i[4] == 1'b1; 

  always_comb begin
    valid = ops_valid_i;
    ready = 1'b1; 
    if(!mo_instr) begin
      case (instr_i)
        ACC: begin
          valid = acc_valid;
          ready = acc_ready;
        end
        MAX: begin
          valid = (reg_acc_value_i == '0) ? ops_valid_i : acc_valid;
          ready = 1'b1;
        end
        default: begin
          valid = ops_valid_i;
          ready = 1'b1;
        end
      endcase
    end else begin
      valid = valid_mo_instr;
      ready = 1'b1;
    end
  end

  assign valid_o = valid;
  assign ready_o = ready;
  %endif

  %if enable_streaming_interface == str(1) and enable_decoupling == str(0):
  ////////////////////////////////////////////////////////////////
  //                FU Input/Output Assignments                 //
  ////////////////////////////////////////////////////////////////

  logic [N_BITS:0] add_res;
  logic [N_BITS-1:0] mul_res;
  logic [N_BITS-1:0] shift_res;
  logic [N_BITS-1:0] lsh_res;

  logic [N_BITS-1:0] mul_op1;
  logic [N_BITS-1:0] mul_op2;

  logic [N_BITS-1:0] lsh_op1_rev;
  logic [2*N_BITS-1:0] shift_op1;
  logic [N_BITS-1:0] shift_op2;

  logic [N_BITS:0] add_op1;
  logic [N_BITS:0] add_op2;

  logic [N_BITS-1:0] op1_neg;
  logic [N_BITS-1:0] op2_neg;
  logic [N_BITS-1:0] op2_neg_d1;
  
  logic sign_op1;
  logic sign_op1_d;

  logic [N_BITS-1:0] temp_res;
  logic [N_BITS-1:0] temp_res_neg;
  logic [N_BITS-1:0] temp_op_reg;

  assign op1_neg = ~a_signed;
  assign op2_neg = ~b_signed;
  assign op2_neg_d1 = ~temp_op_reg;

  assign add_res = add_op1 + add_op2;
  assign mul_res = mul_op1 * mul_op2;
  assign shift_res = shift_op1 >>> shift_op2;
  generate
    genvar m;
    for (m = 0; m < 32; m++) begin
      assign lsh_res[31-m] = shift_res[m];
    end
  endgenerate

  assign sign_op1 = a_signed[N_BITS-1];

  always_ff @(posedge clk_i, negedge rst_n_i) begin
    if (!rst_n_i) begin
      sign_op1_d <= 1'b0;
    end else begin
      if(pea_ready_i && instr_i == SGNCSUB) begin
        sign_op1_d <= sign_op1;
      end
    end
  end

  generate
    genvar n;
    for (n = 0; n < 32; n++) begin
      assign lsh_op1_rev[n] = a_signed[31-n];
    end
  endgenerate

  always_ff @(posedge clk_i, negedge rst_n_i) begin
    if (!rst_n_i) begin
      valid_mo_instr <= 1'b0;
    end else begin
      if(mo_instr && pea_ready_i) begin
        valid_mo_instr <= ops_valid_i;
      end
    end
  end

  always_ff @(posedge clk_i, negedge rst_n_i) begin
    if (!rst_n_i) begin
      temp_res <= '0;
    end else begin
      if (pea_ready_i) begin
        if(ops_valid_i) begin
          if (instr_i == ADDPOW) begin
            temp_res <= add_res[N_BITS:1];
          end else if (instr_i == CADDMUL) begin
            temp_res <= add_res[N_BITS:1];
          end else if (instr_i == CMULADD) begin
            temp_res <= mul_res;
          end else if (instr_i == ADDCMUL) begin
            temp_res <= add_res[N_BITS:1];
          end else if (instr_i == MULCARSH) begin
            temp_res <= mul_res;
          end else if (instr_i == ABSMIN) begin
            temp_res <= add_one_res;
          end else if (instr_i == SGNCSUB) begin
            temp_res <= add_res[N_BITS:1];
          end else if (instr_i == SUBPOW) begin
            temp_res <= add_res[N_BITS:1];
          end else if (instr_i == CLSHSUB) begin
            temp_res <= lsh_res;
          end
        end
      end
    end
  end

  assign temp_res_neg = ~temp_res;

  always_ff @(posedge clk_i, negedge rst_n_i) begin
    if (!rst_n_i) begin
      temp_op_reg <= '0;
    end else begin
      if(pea_ready_i) begin
        if (instr_i == CADDMUL || instr_i == CMULADD || instr_i == ABSMIN || instr_i == CLSHSUB) begin
          temp_op_reg <= b_signed;
        end else if (instr_i == SGNCSUB) begin
          temp_op_reg <= a_signed;
        end
      end
    end
  end

  always_comb begin

    add_op1 = {a_signed, 1'b0};
    add_op2 = {b_signed, 1'b0};
    mul_op1 = a_signed;
    mul_op2 = b_signed;
    shift_op1 = a_signed;
    shift_op2 = b_signed;

    case(instr_i)
      NOP: begin
        add_op1   = '0;
        add_op2   = '0;
        mul_op1   = '0;
        mul_op2   = '0;
        shift_op1 = '0;
        shift_op2 = '0;
      end

      ABS: begin
        add_op1 = {op1_neg, 1'b0};
        add_op2 = {32'd1, 1'b0};
      end

      SUB: begin
        add_op1 = {a_signed, 1'b1};
        add_op2 = {op2_neg, 1'b1};
      end

      MIN: begin
        add_op1 = {a_signed, 1'b1};
        add_op2 = {op2_neg, 1'b1};
      end

      MAX: begin
        add_op1 = {a_signed, 1'b1};
        add_op2 = {op2_neg, 1'b1};
      end

      ARSH: begin 
        shift_op1 = {{32{a_signed[N_BITS-1]}}, a_signed};
        shift_op2 = b_signed;
      end

      LRSH: begin 
        shift_op1 = {32'd0, a_signed};
      end

      LSH: begin 
        shift_op1 = {32'd0, lsh_op1_rev};
      end

      ADDPOW: begin
        mul_op1 = temp_res;
        mul_op2 = temp_res;
      end
      
      SUBPOW: begin
        add_op1 = {a_signed, 1'b1};
        add_op2 = {op2_neg, 1'b1};
        mul_op1 = temp_res;
        mul_op2 = temp_res;
      end
      
      ADDCMUL: begin
        mul_op1 = temp_res;
        mul_op2 = const_i;
      end

      CADDMUL: begin
        add_op2 = {const_i, 1'b0};
        mul_op1 = temp_res;
        mul_op2 = temp_op_reg;
      end

      CMULADD: begin
        add_op1 = {temp_res, 1'b0};
        add_op2 = {temp_op_reg, 1'b0};
        mul_op2 = const_i;
      end

      MULCARSH: begin
        shift_op1 = {{32{temp_res[N_BITS-1]}}, temp_res};
        shift_op2 = const_i;
      end

      CLSHSUB: begin
        shift_op1 = {32'd0, lsh_op1_rev};
        shift_op2 = const_i;
        add_op1 = {temp_res, 1'b1};
        add_op2 = {op2_neg_d1, 1'b1};
      end

      ABSMIN: begin
        add_op1 = {temp_res, 1'b1};
        add_op2 = {op2_neg_d1, 1'b1};
      end

      SGNCSUB: begin
        add_op1 = {const_i, 1'b1};
        add_op2 = {op2_neg, 1'b1};
      end

      default: begin
        add_op1   = {a_signed, 1'b0};
        add_op2   = {b_signed, 1'b0};
        mul_op1   = a_signed;
        mul_op2   = b_signed;
        shift_op1 = a_signed;
        shift_op2 = b_signed;
      end
      
    endcase
  end
  

  always_comb begin
    case (instr_i)
      NOP: res_o = 0;
      ADD: res_o = add_res[N_BITS:1];
      ACC: res_o = add_res[N_BITS:1];
      MUL: res_o = mul_res;
      SUB: res_o = add_res[N_BITS:1];
      LSH: res_o = lsh_res;
      ARSH: res_o = shift_res;
      LRSH: res_o = shift_res;
      MAX: res_o = (add_res[N_BITS-1]) ? b_signed : a_signed;
      MIN: res_o = (add_res[N_BITS-1]) ? a_signed : b_signed;
      ABS: res_o = sign_op1 ? add_res[N_BITS:1] : a_signed;
      ADDPOW: res_o = mul_res;
      SUBPOW: res_o = mul_res;
      CADDMUL: res_o = mul_res;
      ADDCMUL: res_o = mul_res;
      CMULADD: res_o = add_res[N_BITS:1];
      CLSHSUB: res_o = add_res[N_BITS:1];
      MULCARSH: res_o = shift_res;
      ABSMIN: res_o = (add_res[N_BITS-1]) ? temp_res : temp_op_reg;
      SGNCSUB: res_o = (|temp_op_reg == 1'b0) ? '0: add_one_res;
      SGNSEL: res_o = delay_sign_i ? b_i : a_i;
      default: res_o = 0;
    endcase
  end

  %elif enable_streaming_interface == str(0) and enable_decoupling == str(1):
  fu_partitioned fu_partitioned_i (
    .clk_i,
    .rst_n_i,
    .a_i,
    .b_i,
    .instr_i,
    .vec_mode_i;
    .res_o,
  )
  %elif enable_streaming_interface == str(1) and enable_decoupling == str(1):
  %endif

endmodule
