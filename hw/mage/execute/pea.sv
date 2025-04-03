// Copyright 2025 Politecnico di Torino.
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// File: pea.sv
// Author: Alessio Naclerio
// Date: 26/02/2025
// Description: Processing Element Array

module pea
  import pea_pkg::*;
  import stream_intf_pkg::*;
(
    input  logic                                                      clk_i,
    input  logic                                                      rst_n_i,
    // Streaming Interface
    input  logic                                                      reg_separate_cols_i,
    input  logic [              M-1:0][   LOG_N:0]                    reg_stream_sel_out_pea_i,
    input  logic [              N-1:0][     M-1:0][              7:0] reg_acc_value_i,
    input  logic [N_STREAM_IN_PEA-1:0]                                stream_valid_i,
    input  logic [N_STREAM_IN_PEA-1:0][N_BITS-1:0]                    stream_data_i,
    output logic [              M-1:0]                                pea_ready_o,
    output logic [              M-1:0]                                stream_valid_o,
    output logic [              M-1:0][N_BITS-1:0]                    stream_data_o,
    // end Streaming Interface
    input  logic [              N-1:0][     M-1:0][N_CFG_BITS_PE-1:0] ctrl_pea_i,
    input  logic [              N-1:0][     M-1:0][             31:0] reg_constant_op_i
);

  logic [         N_BITS-1:0]                  out_data_pe00;
  logic [         N_BITS-1:0]                  out_data_pe01;
  logic [         N_BITS-1:0]                  out_data_pe02;
  logic [         N_BITS-1:0]                  out_data_pe03;
  logic [         N_BITS-1:0]                  out_data_pe10;
  logic [         N_BITS-1:0]                  out_data_pe11;
  logic [         N_BITS-1:0]                  out_data_pe12;
  logic [         N_BITS-1:0]                  out_data_pe13;
  logic [         N_BITS-1:0]                  out_data_pe20;
  logic [         N_BITS-1:0]                  out_data_pe21;
  logic [         N_BITS-1:0]                  out_data_pe22;
  logic [         N_BITS-1:0]                  out_data_pe23;
  logic [         N_BITS-1:0]                  out_data_pe30;
  logic [         N_BITS-1:0]                  out_data_pe31;
  logic [         N_BITS-1:0]                  out_data_pe32;
  logic [         N_BITS-1:0]                  out_data_pe33;

  logic [    N_INPUTS_PE-3:0][N_BITS-1:0]      in_data_pe00;
  logic [    N_INPUTS_PE-3:0][N_BITS-1:0]      in_data_pe01;
  logic [    N_INPUTS_PE-3:0][N_BITS-1:0]      in_data_pe02;
  logic [    N_INPUTS_PE-3:0][N_BITS-1:0]      in_data_pe03;
  logic [    N_INPUTS_PE-3:0][N_BITS-1:0]      in_data_pe10;
  logic [    N_INPUTS_PE-3:0][N_BITS-1:0]      in_data_pe11;
  logic [    N_INPUTS_PE-3:0][N_BITS-1:0]      in_data_pe12;
  logic [    N_INPUTS_PE-3:0][N_BITS-1:0]      in_data_pe13;
  logic [    N_INPUTS_PE-3:0][N_BITS-1:0]      in_data_pe20;
  logic [    N_INPUTS_PE-3:0][N_BITS-1:0]      in_data_pe21;
  logic [    N_INPUTS_PE-3:0][N_BITS-1:0]      in_data_pe22;
  logic [    N_INPUTS_PE-3:0][N_BITS-1:0]      in_data_pe23;
  logic [    N_INPUTS_PE-3:0][N_BITS-1:0]      in_data_pe30;
  logic [    N_INPUTS_PE-3:0][N_BITS-1:0]      in_data_pe31;
  logic [    N_INPUTS_PE-3:0][N_BITS-1:0]      in_data_pe32;
  logic [    N_INPUTS_PE-3:0][N_BITS-1:0]      in_data_pe33;


  ////////////////////////////////////////////////////////////////
  //              Signals for Streaming MAGE PEA                //
  ////////////////////////////////////////////////////////////////
  logic [N_STREAM_IN_PEA-1:0][N_BITS-1:0]      stream_data_in_reg;
  logic [N_STREAM_IN_PEA-1:0]                  stream_valid_in_reg;
  logic [              M-1:0][     N-1:0][7:0] reg_acc_value_pe;

  logic [    N_INPUTS_PE-3:0]                  stream_valid_pe_in00;
  logic [    N_INPUTS_PE-3:0]                  stream_valid_pe_in01;
  logic [    N_INPUTS_PE-3:0]                  stream_valid_pe_in02;
  logic [    N_INPUTS_PE-3:0]                  stream_valid_pe_in03;
  logic [    N_INPUTS_PE-3:0]                  stream_valid_pe_in10;
  logic [    N_INPUTS_PE-3:0]                  stream_valid_pe_in11;
  logic [    N_INPUTS_PE-3:0]                  stream_valid_pe_in12;
  logic [    N_INPUTS_PE-3:0]                  stream_valid_pe_in13;
  logic [    N_INPUTS_PE-3:0]                  stream_valid_pe_in20;
  logic [    N_INPUTS_PE-3:0]                  stream_valid_pe_in21;
  logic [    N_INPUTS_PE-3:0]                  stream_valid_pe_in22;
  logic [    N_INPUTS_PE-3:0]                  stream_valid_pe_in23;
  logic [    N_INPUTS_PE-3:0]                  stream_valid_pe_in30;
  logic [    N_INPUTS_PE-3:0]                  stream_valid_pe_in31;
  logic [    N_INPUTS_PE-3:0]                  stream_valid_pe_in32;
  logic [    N_INPUTS_PE-3:0]                  stream_valid_pe_in33;

  logic                                        stream_valid_pe_out00;
  logic                                        stream_valid_pe_out01;
  logic                                        stream_valid_pe_out02;
  logic                                        stream_valid_pe_out03;
  logic                                        stream_valid_pe_out10;
  logic                                        stream_valid_pe_out11;
  logic                                        stream_valid_pe_out12;
  logic                                        stream_valid_pe_out13;
  logic                                        stream_valid_pe_out20;
  logic                                        stream_valid_pe_out21;
  logic                                        stream_valid_pe_out22;
  logic                                        stream_valid_pe_out23;
  logic                                        stream_valid_pe_out30;
  logic                                        stream_valid_pe_out31;
  logic                                        stream_valid_pe_out32;
  logic                                        stream_valid_pe_out33;

  logic                                        stream_ready_pe_out00;
  logic                                        stream_ready_pe_out01;
  logic                                        stream_ready_pe_out02;
  logic                                        stream_ready_pe_out03;
  logic                                        stream_ready_pe_out10;
  logic                                        stream_ready_pe_out11;
  logic                                        stream_ready_pe_out12;
  logic                                        stream_ready_pe_out13;
  logic                                        stream_ready_pe_out20;
  logic                                        stream_ready_pe_out21;
  logic                                        stream_ready_pe_out22;
  logic                                        stream_ready_pe_out23;
  logic                                        stream_ready_pe_out30;
  logic                                        stream_ready_pe_out31;
  logic                                        stream_ready_pe_out32;
  logic                                        stream_ready_pe_out33;

  logic [              M-1:0]                  ready_in_pe;

  logic [     N_NEIGH_PE-1:0][N_BITS-1:0]      in_delay_op00;
  logic [     N_NEIGH_PE-1:0][N_BITS-1:0]      in_delay_op01;
  logic [     N_NEIGH_PE-1:0][N_BITS-1:0]      in_delay_op02;
  logic [     N_NEIGH_PE-1:0][N_BITS-1:0]      in_delay_op03;
  logic [     N_NEIGH_PE-1:0][N_BITS-1:0]      in_delay_op10;
  logic [     N_NEIGH_PE-1:0][N_BITS-1:0]      in_delay_op11;
  logic [     N_NEIGH_PE-1:0][N_BITS-1:0]      in_delay_op12;
  logic [     N_NEIGH_PE-1:0][N_BITS-1:0]      in_delay_op13;
  logic [     N_NEIGH_PE-1:0][N_BITS-1:0]      in_delay_op20;
  logic [     N_NEIGH_PE-1:0][N_BITS-1:0]      in_delay_op21;
  logic [     N_NEIGH_PE-1:0][N_BITS-1:0]      in_delay_op22;
  logic [     N_NEIGH_PE-1:0][N_BITS-1:0]      in_delay_op23;
  logic [     N_NEIGH_PE-1:0][N_BITS-1:0]      in_delay_op30;
  logic [     N_NEIGH_PE-1:0][N_BITS-1:0]      in_delay_op31;
  logic [     N_NEIGH_PE-1:0][N_BITS-1:0]      in_delay_op32;
  logic [     N_NEIGH_PE-1:0][N_BITS-1:0]      in_delay_op33;

  logic [         N_BITS-1:0]                  out_delay_op00;
  logic [         N_BITS-1:0]                  out_delay_op01;
  logic [         N_BITS-1:0]                  out_delay_op02;
  logic [         N_BITS-1:0]                  out_delay_op03;
  logic [         N_BITS-1:0]                  out_delay_op10;
  logic [         N_BITS-1:0]                  out_delay_op11;
  logic [         N_BITS-1:0]                  out_delay_op12;
  logic [         N_BITS-1:0]                  out_delay_op13;
  logic [         N_BITS-1:0]                  out_delay_op20;
  logic [         N_BITS-1:0]                  out_delay_op21;
  logic [         N_BITS-1:0]                  out_delay_op22;
  logic [         N_BITS-1:0]                  out_delay_op23;
  logic [         N_BITS-1:0]                  out_delay_op30;
  logic [         N_BITS-1:0]                  out_delay_op31;
  logic [         N_BITS-1:0]                  out_delay_op32;
  logic [         N_BITS-1:0]                  out_delay_op33;

  logic [     N_NEIGH_PE-1:0]                  in_delay_op_valid00;
  logic [     N_NEIGH_PE-1:0]                  in_delay_op_valid01;
  logic [     N_NEIGH_PE-1:0]                  in_delay_op_valid02;
  logic [     N_NEIGH_PE-1:0]                  in_delay_op_valid03;
  logic [     N_NEIGH_PE-1:0]                  in_delay_op_valid10;
  logic [     N_NEIGH_PE-1:0]                  in_delay_op_valid11;
  logic [     N_NEIGH_PE-1:0]                  in_delay_op_valid12;
  logic [     N_NEIGH_PE-1:0]                  in_delay_op_valid13;
  logic [     N_NEIGH_PE-1:0]                  in_delay_op_valid20;
  logic [     N_NEIGH_PE-1:0]                  in_delay_op_valid21;
  logic [     N_NEIGH_PE-1:0]                  in_delay_op_valid22;
  logic [     N_NEIGH_PE-1:0]                  in_delay_op_valid23;
  logic [     N_NEIGH_PE-1:0]                  in_delay_op_valid30;
  logic [     N_NEIGH_PE-1:0]                  in_delay_op_valid31;
  logic [     N_NEIGH_PE-1:0]                  in_delay_op_valid32;
  logic [     N_NEIGH_PE-1:0]                  in_delay_op_valid33;

  logic                                        out_delay_op_valid00;
  logic                                        out_delay_op_valid01;
  logic                                        out_delay_op_valid02;
  logic                                        out_delay_op_valid03;
  logic                                        out_delay_op_valid10;
  logic                                        out_delay_op_valid11;
  logic                                        out_delay_op_valid12;
  logic                                        out_delay_op_valid13;
  logic                                        out_delay_op_valid20;
  logic                                        out_delay_op_valid21;
  logic                                        out_delay_op_valid22;
  logic                                        out_delay_op_valid23;
  logic                                        out_delay_op_valid30;
  logic                                        out_delay_op_valid31;
  logic                                        out_delay_op_valid32;
  logic                                        out_delay_op_valid33;

  logic [            M*N-1:0]                  stream_valid_pe_out_arr;

  logic [                N:0][N_BITS-1:0]      out_data_col0;
  logic [                N:0][N_BITS-1:0]      out_data_col1;
  logic [                N:0][N_BITS-1:0]      out_data_col2;
  logic [                N:0][N_BITS-1:0]      out_data_col3;
  logic [                N:0]                  out_valid_col0;
  logic [                N:0]                  out_valid_col1;
  logic [                N:0]                  out_valid_col2;
  logic [                N:0]                  out_valid_col3;

  //Input Registers
  always_ff @(posedge clk_i, negedge rst_n_i) begin
    if (!rst_n_i) begin
      stream_data_in_reg  <= '0;
      stream_valid_in_reg <= '0;
    end else begin
      if (ready_in_pe[0]) begin
        stream_data_in_reg[0]  <= stream_data_i[0];
        stream_valid_in_reg[0] <= stream_valid_i[0];
      end else begin
        stream_data_in_reg[0]  <= stream_data_in_reg[0];
        stream_valid_in_reg[0] <= stream_valid_in_reg[0];
      end
      if (ready_in_pe[1]) begin
        stream_data_in_reg[1]  <= stream_data_i[1];
        stream_valid_in_reg[1] <= stream_valid_i[1];
      end else begin
        stream_data_in_reg[1]  <= stream_data_in_reg[1];
        stream_valid_in_reg[1] <= stream_valid_in_reg[1];
      end
      if (ready_in_pe[2]) begin
        stream_data_in_reg[2]  <= stream_data_i[2];
        stream_valid_in_reg[2] <= stream_valid_i[2];
      end else begin
        stream_data_in_reg[2]  <= stream_data_in_reg[2];
        stream_valid_in_reg[2] <= stream_valid_in_reg[2];
      end
      if (ready_in_pe[3]) begin
        stream_data_in_reg[3]  <= stream_data_i[3];
        stream_valid_in_reg[3] <= stream_valid_i[3];
      end else begin
        stream_data_in_reg[3]  <= stream_data_in_reg[3];
        stream_valid_in_reg[3] <= stream_valid_in_reg[3];
      end
    end
  end

  // Output muxes
  assign out_data_col0[0] = out_data_pe00;
  assign out_data_col0[1] = out_data_pe10;
  assign out_data_col0[2] = out_data_pe20;
  assign out_data_col0[3] = out_data_pe30;
  assign out_data_col0[4] = '0;
  assign out_data_col1[0] = out_data_pe01;
  assign out_data_col1[1] = out_data_pe11;
  assign out_data_col1[2] = out_data_pe21;
  assign out_data_col1[3] = out_data_pe31;
  assign out_data_col1[4] = '0;
  assign out_data_col2[0] = out_data_pe02;
  assign out_data_col2[1] = out_data_pe12;
  assign out_data_col2[2] = out_data_pe22;
  assign out_data_col2[3] = out_data_pe32;
  assign out_data_col2[4] = '0;
  assign out_data_col3[0] = out_data_pe03;
  assign out_data_col3[1] = out_data_pe13;
  assign out_data_col3[2] = out_data_pe23;
  assign out_data_col3[3] = out_data_pe33;
  assign out_data_col3[4] = '0;
  assign out_valid_col0[0] = stream_valid_pe_out00;
  assign out_valid_col0[1] = stream_valid_pe_out10;
  assign out_valid_col0[2] = stream_valid_pe_out20;
  assign out_valid_col0[3] = stream_valid_pe_out30;
  assign out_valid_col0[4] = 1'b0;
  assign out_valid_col1[0] = stream_valid_pe_out01;
  assign out_valid_col1[1] = stream_valid_pe_out11;
  assign out_valid_col1[2] = stream_valid_pe_out21;
  assign out_valid_col1[3] = stream_valid_pe_out31;
  assign out_valid_col1[4] = 1'b0;
  assign out_valid_col2[0] = stream_valid_pe_out02;
  assign out_valid_col2[1] = stream_valid_pe_out12;
  assign out_valid_col2[2] = stream_valid_pe_out22;
  assign out_valid_col2[3] = stream_valid_pe_out32;
  assign out_valid_col2[4] = 1'b0;
  assign out_valid_col3[0] = stream_valid_pe_out03;
  assign out_valid_col3[1] = stream_valid_pe_out13;
  assign out_valid_col3[2] = stream_valid_pe_out23;
  assign out_valid_col3[3] = stream_valid_pe_out33;
  assign out_valid_col3[4] = 1'b0;

  assign stream_data_o[0] = out_data_col0[reg_stream_sel_out_pea_i[0]];
  assign stream_valid_o[0] = out_valid_col0[reg_stream_sel_out_pea_i[0]];
  assign stream_data_o[1] = out_data_col1[reg_stream_sel_out_pea_i[1]];
  assign stream_valid_o[1] = out_valid_col1[reg_stream_sel_out_pea_i[1]];
  assign stream_data_o[2] = out_data_col2[reg_stream_sel_out_pea_i[2]];
  assign stream_valid_o[2] = out_valid_col2[reg_stream_sel_out_pea_i[2]];
  assign stream_data_o[3] = out_data_col3[reg_stream_sel_out_pea_i[3]];
  assign stream_valid_o[3] = out_valid_col3[reg_stream_sel_out_pea_i[3]];

  ////////////////////////////////////////////////////////////////
  //               Assignments for PEs Din/Dout                 //
  ////////////////////////////////////////////////////////////////


  assign in_data_pe00[0] = stream_data_in_reg[0];
  assign in_data_pe00[1] = reg_constant_op_i[0][0];
  assign in_data_pe00[2] = '0;
  assign in_data_pe00[3] = '0;
  assign in_data_pe00[4] = out_data_pe01;
  assign in_data_pe00[5] = out_data_pe10;

  assign in_data_pe01[0] = stream_data_in_reg[1];
  assign in_data_pe01[1] = reg_constant_op_i[0][1];
  assign in_data_pe01[2] = '0;
  assign in_data_pe01[3] = out_data_pe00;
  assign in_data_pe01[4] = out_data_pe02;
  assign in_data_pe01[5] = out_data_pe11;

  assign in_data_pe02[0] = stream_data_in_reg[2];
  assign in_data_pe02[1] = reg_constant_op_i[0][2];
  assign in_data_pe02[2] = '0;
  assign in_data_pe02[3] = out_data_pe01;
  assign in_data_pe02[4] = out_data_pe03;
  assign in_data_pe02[5] = out_data_pe12;

  assign in_data_pe03[0] = stream_data_in_reg[3];
  assign in_data_pe03[1] = reg_constant_op_i[0][3];
  assign in_data_pe03[2] = '0;
  assign in_data_pe03[3] = out_data_pe02;
  assign in_data_pe03[4] = '0;
  assign in_data_pe03[5] = out_data_pe13;

  assign in_data_pe10[0] = stream_data_in_reg[0];
  assign in_data_pe10[1] = reg_constant_op_i[1][0];
  assign in_data_pe10[2] = out_data_pe00;
  assign in_data_pe10[3] = '0;
  assign in_data_pe10[4] = out_data_pe11;
  assign in_data_pe10[5] = out_data_pe20;

  assign in_data_pe11[0] = stream_data_in_reg[1];
  assign in_data_pe11[1] = reg_constant_op_i[1][1];
  assign in_data_pe11[2] = out_data_pe01;
  assign in_data_pe11[3] = out_data_pe10;
  assign in_data_pe11[4] = out_data_pe12;
  assign in_data_pe11[5] = out_data_pe21;

  assign in_data_pe12[0] = stream_data_in_reg[2];
  assign in_data_pe12[1] = reg_constant_op_i[1][2];
  assign in_data_pe12[2] = out_data_pe02;
  assign in_data_pe12[3] = out_data_pe11;
  assign in_data_pe12[4] = out_data_pe13;
  assign in_data_pe12[5] = out_data_pe22;

  assign in_data_pe13[0] = stream_data_in_reg[3];
  assign in_data_pe13[1] = reg_constant_op_i[1][3];
  assign in_data_pe13[2] = out_data_pe03;
  assign in_data_pe13[3] = out_data_pe12;
  assign in_data_pe13[4] = '0;
  assign in_data_pe13[5] = out_data_pe23;

  assign in_data_pe20[0] = stream_data_in_reg[0];
  assign in_data_pe20[1] = reg_constant_op_i[2][0];
  assign in_data_pe20[2] = out_data_pe10;
  assign in_data_pe20[3] = '0;
  assign in_data_pe20[4] = out_data_pe21;
  assign in_data_pe20[5] = out_data_pe30;

  assign in_data_pe21[0] = stream_data_in_reg[1];
  assign in_data_pe21[1] = reg_constant_op_i[2][1];
  assign in_data_pe21[2] = out_data_pe11;
  assign in_data_pe21[3] = out_data_pe20;
  assign in_data_pe21[4] = out_data_pe22;
  assign in_data_pe21[5] = out_data_pe31;

  assign in_data_pe22[0] = stream_data_in_reg[2];
  assign in_data_pe22[1] = reg_constant_op_i[2][2];
  assign in_data_pe22[2] = out_data_pe12;
  assign in_data_pe22[3] = out_data_pe21;
  assign in_data_pe22[4] = out_data_pe23;
  assign in_data_pe22[5] = out_data_pe32;

  assign in_data_pe23[0] = stream_data_in_reg[3];
  assign in_data_pe23[1] = reg_constant_op_i[2][3];
  assign in_data_pe23[2] = out_data_pe13;
  assign in_data_pe23[3] = out_data_pe22;
  assign in_data_pe23[4] = '0;
  assign in_data_pe23[5] = out_data_pe33;

  assign in_data_pe30[0] = stream_data_in_reg[0];
  assign in_data_pe30[1] = reg_constant_op_i[3][0];
  assign in_data_pe30[2] = out_data_pe20;
  assign in_data_pe30[3] = '0;
  assign in_data_pe30[4] = out_data_pe31;
  assign in_data_pe30[5] = '0;

  assign in_data_pe31[0] = stream_data_in_reg[1];
  assign in_data_pe31[1] = reg_constant_op_i[3][1];
  assign in_data_pe31[2] = out_data_pe21;
  assign in_data_pe31[3] = out_data_pe30;
  assign in_data_pe31[4] = out_data_pe32;
  assign in_data_pe31[5] = '0;

  assign in_data_pe32[0] = stream_data_in_reg[2];
  assign in_data_pe32[1] = reg_constant_op_i[3][2];
  assign in_data_pe32[2] = out_data_pe22;
  assign in_data_pe32[3] = out_data_pe31;
  assign in_data_pe32[4] = out_data_pe33;
  assign in_data_pe32[5] = '0;

  assign in_data_pe33[0] = stream_data_in_reg[3];
  assign in_data_pe33[1] = reg_constant_op_i[3][3];
  assign in_data_pe33[2] = out_data_pe23;
  assign in_data_pe33[3] = out_data_pe32;
  assign in_data_pe33[4] = '0;
  assign in_data_pe33[5] = '0;



  assign in_delay_op00[0] = stream_data_in_reg[0];
  assign in_delay_op00[1] = '0;
  assign in_delay_op00[2] = out_delay_op01;
  assign in_delay_op00[3] = out_delay_op10;

  assign in_delay_op01[0] = stream_data_in_reg[1];
  assign in_delay_op01[1] = out_delay_op00;
  assign in_delay_op01[2] = out_delay_op02;
  assign in_delay_op01[3] = out_delay_op11;

  assign in_delay_op02[0] = stream_data_in_reg[2];
  assign in_delay_op02[1] = out_delay_op01;
  assign in_delay_op02[2] = out_delay_op03;
  assign in_delay_op02[3] = out_delay_op12;

  assign in_delay_op03[0] = stream_data_in_reg[3];
  assign in_delay_op03[1] = out_delay_op02;
  assign in_delay_op03[2] = '0;
  assign in_delay_op03[3] = out_delay_op13;

  assign in_delay_op10[0] = out_delay_op00;
  assign in_delay_op10[1] = '0;
  assign in_delay_op10[2] = out_delay_op11;
  assign in_delay_op10[3] = out_delay_op20;

  assign in_delay_op11[0] = out_delay_op01;
  assign in_delay_op11[1] = out_delay_op10;
  assign in_delay_op11[2] = out_delay_op12;
  assign in_delay_op11[3] = out_delay_op21;

  assign in_delay_op12[0] = out_delay_op02;
  assign in_delay_op12[1] = out_delay_op11;
  assign in_delay_op12[2] = out_delay_op13;
  assign in_delay_op12[3] = out_delay_op22;

  assign in_delay_op13[0] = out_delay_op03;
  assign in_delay_op13[1] = out_delay_op12;
  assign in_delay_op13[2] = '0;
  assign in_delay_op13[3] = out_delay_op23;

  assign in_delay_op20[0] = out_delay_op10;
  assign in_delay_op20[1] = '0;
  assign in_delay_op20[2] = out_delay_op21;
  assign in_delay_op20[3] = out_delay_op30;

  assign in_delay_op21[0] = out_delay_op11;
  assign in_delay_op21[1] = out_delay_op20;
  assign in_delay_op21[2] = out_delay_op22;
  assign in_delay_op21[3] = out_delay_op31;

  assign in_delay_op22[0] = out_delay_op12;
  assign in_delay_op22[1] = out_delay_op21;
  assign in_delay_op22[2] = out_delay_op23;
  assign in_delay_op22[3] = out_delay_op32;

  assign in_delay_op23[0] = out_delay_op13;
  assign in_delay_op23[1] = out_delay_op22;
  assign in_delay_op23[2] = '0;
  assign in_delay_op23[3] = out_delay_op33;

  assign in_delay_op30[0] = out_delay_op20;
  assign in_delay_op30[1] = '0;
  assign in_delay_op30[2] = out_delay_op31;
  assign in_delay_op30[3] = '0;

  assign in_delay_op31[0] = out_delay_op21;
  assign in_delay_op31[1] = out_delay_op30;
  assign in_delay_op31[2] = out_delay_op32;
  assign in_delay_op31[3] = '0;

  assign in_delay_op32[0] = out_delay_op22;
  assign in_delay_op32[1] = out_delay_op31;
  assign in_delay_op32[2] = out_delay_op33;
  assign in_delay_op32[3] = '0;

  assign in_delay_op33[0] = out_delay_op23;
  assign in_delay_op33[1] = out_delay_op32;
  assign in_delay_op33[2] = '0;
  assign in_delay_op33[3] = '0;


  assign in_delay_op_valid00[0] = stream_valid_in_reg[0];
  assign in_delay_op_valid00[1] = '0;
  assign in_delay_op_valid00[2] = out_delay_op_valid01;
  assign in_delay_op_valid00[3] = out_delay_op_valid10;

  assign in_delay_op_valid01[0] = stream_valid_in_reg[1];
  assign in_delay_op_valid01[1] = out_delay_op_valid00;
  assign in_delay_op_valid01[2] = out_delay_op_valid02;
  assign in_delay_op_valid01[3] = out_delay_op_valid11;

  assign in_delay_op_valid02[0] = stream_valid_in_reg[2];
  assign in_delay_op_valid02[1] = out_delay_op_valid01;
  assign in_delay_op_valid02[2] = out_delay_op_valid03;
  assign in_delay_op_valid02[3] = out_delay_op_valid12;

  assign in_delay_op_valid03[0] = stream_valid_in_reg[3];
  assign in_delay_op_valid03[1] = out_delay_op_valid02;
  assign in_delay_op_valid03[2] = '0;
  assign in_delay_op_valid03[3] = out_delay_op_valid13;

  assign in_delay_op_valid10[0] = out_delay_op_valid00;
  assign in_delay_op_valid10[1] = '0;
  assign in_delay_op_valid10[2] = out_delay_op_valid11;
  assign in_delay_op_valid10[3] = out_delay_op_valid20;

  assign in_delay_op_valid11[0] = out_delay_op_valid01;
  assign in_delay_op_valid11[1] = out_delay_op_valid10;
  assign in_delay_op_valid11[2] = out_delay_op_valid12;
  assign in_delay_op_valid11[3] = out_delay_op_valid21;

  assign in_delay_op_valid12[0] = out_delay_op_valid02;
  assign in_delay_op_valid12[1] = out_delay_op_valid11;
  assign in_delay_op_valid12[2] = out_delay_op_valid13;
  assign in_delay_op_valid12[3] = out_delay_op_valid22;

  assign in_delay_op_valid13[0] = out_delay_op_valid03;
  assign in_delay_op_valid13[1] = out_delay_op_valid12;
  assign in_delay_op_valid13[2] = '0;
  assign in_delay_op_valid13[3] = out_delay_op_valid23;

  assign in_delay_op_valid20[0] = out_delay_op_valid10;
  assign in_delay_op_valid20[1] = '0;
  assign in_delay_op_valid20[2] = out_delay_op_valid21;
  assign in_delay_op_valid20[3] = out_delay_op_valid30;

  assign in_delay_op_valid21[0] = out_delay_op_valid11;
  assign in_delay_op_valid21[1] = out_delay_op_valid20;
  assign in_delay_op_valid21[2] = out_delay_op_valid22;
  assign in_delay_op_valid21[3] = out_delay_op_valid31;

  assign in_delay_op_valid22[0] = out_delay_op_valid12;
  assign in_delay_op_valid22[1] = out_delay_op_valid21;
  assign in_delay_op_valid22[2] = out_delay_op_valid23;
  assign in_delay_op_valid22[3] = out_delay_op_valid32;

  assign in_delay_op_valid23[0] = out_delay_op_valid13;
  assign in_delay_op_valid23[1] = out_delay_op_valid22;
  assign in_delay_op_valid23[2] = '0;
  assign in_delay_op_valid23[3] = out_delay_op_valid33;

  assign in_delay_op_valid30[0] = out_delay_op_valid20;
  assign in_delay_op_valid30[1] = '0;
  assign in_delay_op_valid30[2] = out_delay_op_valid31;
  assign in_delay_op_valid30[3] = '0;

  assign in_delay_op_valid31[0] = out_delay_op_valid21;
  assign in_delay_op_valid31[1] = out_delay_op_valid30;
  assign in_delay_op_valid31[2] = out_delay_op_valid32;
  assign in_delay_op_valid31[3] = '0;

  assign in_delay_op_valid32[0] = out_delay_op_valid22;
  assign in_delay_op_valid32[1] = out_delay_op_valid31;
  assign in_delay_op_valid32[2] = out_delay_op_valid33;
  assign in_delay_op_valid32[3] = '0;

  assign in_delay_op_valid33[0] = out_delay_op_valid23;
  assign in_delay_op_valid33[1] = out_delay_op_valid32;
  assign in_delay_op_valid33[2] = '0;
  assign in_delay_op_valid33[3] = '0;

  ////////////////////////////////////////////////////////////////
  //               Assignments for PEs Valid I/O                //
  ////////////////////////////////////////////////////////////////

  assign stream_valid_pe_in00[0] = stream_valid_in_reg[0];
  assign stream_valid_pe_in00[1] = 1'b1;
  assign stream_valid_pe_in00[2] = 1'b1;
  assign stream_valid_pe_in00[3] = 1'b1;
  assign stream_valid_pe_in00[4] = stream_valid_pe_out01;
  assign stream_valid_pe_in00[5] = stream_valid_pe_out10;

  assign stream_valid_pe_in01[0] = stream_valid_in_reg[1];
  assign stream_valid_pe_in01[1] = 1'b1;
  assign stream_valid_pe_in01[2] = 1'b1;
  assign stream_valid_pe_in01[3] = stream_valid_pe_out00;
  assign stream_valid_pe_in01[4] = stream_valid_pe_out02;
  assign stream_valid_pe_in01[5] = stream_valid_pe_out11;

  assign stream_valid_pe_in02[0] = stream_valid_in_reg[2];
  assign stream_valid_pe_in02[1] = 1'b1;
  assign stream_valid_pe_in02[2] = 1'b1;
  assign stream_valid_pe_in02[3] = stream_valid_pe_out01;
  assign stream_valid_pe_in02[4] = stream_valid_pe_out03;
  assign stream_valid_pe_in02[5] = stream_valid_pe_out12;

  assign stream_valid_pe_in03[0] = stream_valid_in_reg[3];
  assign stream_valid_pe_in03[1] = 1'b1;
  assign stream_valid_pe_in03[2] = 1'b1;
  assign stream_valid_pe_in03[3] = stream_valid_pe_out02;
  assign stream_valid_pe_in03[4] = 1'b1;
  assign stream_valid_pe_in03[5] = stream_valid_pe_out13;

  assign stream_valid_pe_in10[0] = stream_valid_in_reg[0];
  assign stream_valid_pe_in10[1] = 1'b1;
  assign stream_valid_pe_in10[2] = stream_valid_pe_out00;
  assign stream_valid_pe_in10[3] = 1'b1;
  assign stream_valid_pe_in10[4] = stream_valid_pe_out11;
  assign stream_valid_pe_in10[5] = stream_valid_pe_out20;

  assign stream_valid_pe_in11[0] = stream_valid_in_reg[1];
  assign stream_valid_pe_in11[1] = 1'b1;
  assign stream_valid_pe_in11[2] = stream_valid_pe_out01;
  assign stream_valid_pe_in11[3] = stream_valid_pe_out10;
  assign stream_valid_pe_in11[4] = stream_valid_pe_out12;
  assign stream_valid_pe_in11[5] = stream_valid_pe_out21;

  assign stream_valid_pe_in12[0] = stream_valid_in_reg[2];
  assign stream_valid_pe_in12[1] = 1'b1;
  assign stream_valid_pe_in12[2] = stream_valid_pe_out02;
  assign stream_valid_pe_in12[3] = stream_valid_pe_out11;
  assign stream_valid_pe_in12[4] = stream_valid_pe_out13;
  assign stream_valid_pe_in12[5] = stream_valid_pe_out22;

  assign stream_valid_pe_in13[0] = stream_valid_in_reg[3];
  assign stream_valid_pe_in13[1] = 1'b1;
  assign stream_valid_pe_in13[2] = stream_valid_pe_out03;
  assign stream_valid_pe_in13[3] = stream_valid_pe_out12;
  assign stream_valid_pe_in13[4] = 1'b1;
  assign stream_valid_pe_in13[5] = stream_valid_pe_out23;

  assign stream_valid_pe_in20[0] = stream_valid_in_reg[0];
  assign stream_valid_pe_in20[1] = 1'b1;
  assign stream_valid_pe_in20[2] = stream_valid_pe_out10;
  assign stream_valid_pe_in20[3] = 1'b1;
  assign stream_valid_pe_in20[4] = stream_valid_pe_out21;
  assign stream_valid_pe_in20[5] = stream_valid_pe_out30;

  assign stream_valid_pe_in21[0] = stream_valid_in_reg[1];
  assign stream_valid_pe_in21[1] = 1'b1;
  assign stream_valid_pe_in21[2] = stream_valid_pe_out11;
  assign stream_valid_pe_in21[3] = stream_valid_pe_out20;
  assign stream_valid_pe_in21[4] = stream_valid_pe_out22;
  assign stream_valid_pe_in21[5] = stream_valid_pe_out31;

  assign stream_valid_pe_in22[0] = stream_valid_in_reg[2];
  assign stream_valid_pe_in22[1] = 1'b1;
  assign stream_valid_pe_in22[2] = stream_valid_pe_out12;
  assign stream_valid_pe_in22[3] = stream_valid_pe_out21;
  assign stream_valid_pe_in22[4] = stream_valid_pe_out23;
  assign stream_valid_pe_in22[5] = stream_valid_pe_out32;

  assign stream_valid_pe_in23[0] = stream_valid_in_reg[3];
  assign stream_valid_pe_in23[1] = 1'b1;
  assign stream_valid_pe_in23[2] = stream_valid_pe_out13;
  assign stream_valid_pe_in23[3] = stream_valid_pe_out22;
  assign stream_valid_pe_in23[4] = 1'b1;
  assign stream_valid_pe_in23[5] = stream_valid_pe_out33;

  assign stream_valid_pe_in30[0] = stream_valid_in_reg[0];
  assign stream_valid_pe_in30[1] = 1'b1;
  assign stream_valid_pe_in30[2] = stream_valid_pe_out20;
  assign stream_valid_pe_in30[3] = 1'b1;
  assign stream_valid_pe_in30[4] = stream_valid_pe_out31;
  assign stream_valid_pe_in30[5] = 1'b1;

  assign stream_valid_pe_in31[0] = stream_valid_in_reg[1];
  assign stream_valid_pe_in31[1] = 1'b1;
  assign stream_valid_pe_in31[2] = stream_valid_pe_out21;
  assign stream_valid_pe_in31[3] = stream_valid_pe_out30;
  assign stream_valid_pe_in31[4] = stream_valid_pe_out32;
  assign stream_valid_pe_in31[5] = 1'b1;

  assign stream_valid_pe_in32[0] = stream_valid_in_reg[2];
  assign stream_valid_pe_in32[1] = 1'b1;
  assign stream_valid_pe_in32[2] = stream_valid_pe_out22;
  assign stream_valid_pe_in32[3] = stream_valid_pe_out31;
  assign stream_valid_pe_in32[4] = stream_valid_pe_out33;
  assign stream_valid_pe_in32[5] = 1'b1;

  assign stream_valid_pe_in33[0] = stream_valid_in_reg[3];
  assign stream_valid_pe_in33[1] = 1'b1;
  assign stream_valid_pe_in33[2] = stream_valid_pe_out23;
  assign stream_valid_pe_in33[3] = stream_valid_pe_out32;
  assign stream_valid_pe_in33[4] = 1'b1;
  assign stream_valid_pe_in33[5] = 1'b1;

  always_comb begin
    for (int i = 0; i < N; i++) begin
      for (int j = 0; j < M; j++) begin
        reg_acc_value_pe[i][j] = reg_acc_value_i[i][j];
      end
    end
  end

  pe pe_inst_00 (
      .clk_i(clk_i),
      .rst_n_i(rst_n_i),
      .neigh_pe_op_i(in_data_pe00),
      .reg_acc_value_i(reg_acc_value_pe[0][0]),
      .pea_ready_i(ready_in_pe[0]),
      .neigh_pe_op_valid_i(stream_valid_pe_in00),
      .neigh_delay_op_i(in_delay_op00),
      .neigh_delay_op_valid_i(in_delay_op_valid00),
      .valid_o(stream_valid_pe_out00),
      .ready_o(stream_ready_pe_out00),
      .delay_op_valid_o(out_delay_op_valid00),
      .delay_op_o(out_delay_op00),
      .ctrl_pe_i(ctrl_pea_i[0][0]),
      .pe_res_o(out_data_pe00)
  );
  pe pe_inst_01 (
      .clk_i(clk_i),
      .rst_n_i(rst_n_i),
      .neigh_pe_op_i(in_data_pe01),
      .reg_acc_value_i(reg_acc_value_pe[0][1]),
      .pea_ready_i(ready_in_pe[1]),
      .neigh_pe_op_valid_i(stream_valid_pe_in01),
      .neigh_delay_op_i(in_delay_op01),
      .neigh_delay_op_valid_i(in_delay_op_valid01),
      .valid_o(stream_valid_pe_out01),
      .ready_o(stream_ready_pe_out01),
      .delay_op_valid_o(out_delay_op_valid01),
      .delay_op_o(out_delay_op01),
      .ctrl_pe_i(ctrl_pea_i[0][1]),
      .pe_res_o(out_data_pe01)
  );
  pe pe_inst_02 (
      .clk_i(clk_i),
      .rst_n_i(rst_n_i),
      .neigh_pe_op_i(in_data_pe02),
      .reg_acc_value_i(reg_acc_value_pe[0][2]),
      .pea_ready_i(ready_in_pe[2]),
      .neigh_pe_op_valid_i(stream_valid_pe_in02),
      .neigh_delay_op_i(in_delay_op02),
      .neigh_delay_op_valid_i(in_delay_op_valid02),
      .valid_o(stream_valid_pe_out02),
      .ready_o(stream_ready_pe_out02),
      .delay_op_valid_o(out_delay_op_valid02),
      .delay_op_o(out_delay_op02),
      .ctrl_pe_i(ctrl_pea_i[0][2]),
      .pe_res_o(out_data_pe02)
  );
  pe pe_inst_03 (
      .clk_i(clk_i),
      .rst_n_i(rst_n_i),
      .neigh_pe_op_i(in_data_pe03),
      .reg_acc_value_i(reg_acc_value_pe[0][3]),
      .pea_ready_i(ready_in_pe[3]),
      .neigh_pe_op_valid_i(stream_valid_pe_in03),
      .neigh_delay_op_i(in_delay_op03),
      .neigh_delay_op_valid_i(in_delay_op_valid03),
      .valid_o(stream_valid_pe_out03),
      .ready_o(stream_ready_pe_out03),
      .delay_op_valid_o(out_delay_op_valid03),
      .delay_op_o(out_delay_op03),
      .ctrl_pe_i(ctrl_pea_i[0][3]),
      .pe_res_o(out_data_pe03)
  );
  pe pe_inst_10 (
      .clk_i(clk_i),
      .rst_n_i(rst_n_i),
      .neigh_pe_op_i(in_data_pe10),
      .reg_acc_value_i(reg_acc_value_pe[1][0]),
      .pea_ready_i(ready_in_pe[0]),
      .neigh_pe_op_valid_i(stream_valid_pe_in10),
      .neigh_delay_op_i(in_delay_op10),
      .neigh_delay_op_valid_i(in_delay_op_valid10),
      .valid_o(stream_valid_pe_out10),
      .ready_o(stream_ready_pe_out10),
      .delay_op_valid_o(out_delay_op_valid10),
      .delay_op_o(out_delay_op10),
      .ctrl_pe_i(ctrl_pea_i[1][0]),
      .pe_res_o(out_data_pe10)
  );
  pe pe_inst_11 (
      .clk_i(clk_i),
      .rst_n_i(rst_n_i),
      .neigh_pe_op_i(in_data_pe11),
      .reg_acc_value_i(reg_acc_value_pe[1][1]),
      .pea_ready_i(ready_in_pe[1]),
      .neigh_pe_op_valid_i(stream_valid_pe_in11),
      .neigh_delay_op_i(in_delay_op11),
      .neigh_delay_op_valid_i(in_delay_op_valid11),
      .valid_o(stream_valid_pe_out11),
      .ready_o(stream_ready_pe_out11),
      .delay_op_valid_o(out_delay_op_valid11),
      .delay_op_o(out_delay_op11),
      .ctrl_pe_i(ctrl_pea_i[1][1]),
      .pe_res_o(out_data_pe11)
  );
  pe pe_inst_12 (
      .clk_i(clk_i),
      .rst_n_i(rst_n_i),
      .neigh_pe_op_i(in_data_pe12),
      .reg_acc_value_i(reg_acc_value_pe[1][2]),
      .pea_ready_i(ready_in_pe[2]),
      .neigh_pe_op_valid_i(stream_valid_pe_in12),
      .neigh_delay_op_i(in_delay_op12),
      .neigh_delay_op_valid_i(in_delay_op_valid12),
      .valid_o(stream_valid_pe_out12),
      .ready_o(stream_ready_pe_out12),
      .delay_op_valid_o(out_delay_op_valid12),
      .delay_op_o(out_delay_op12),
      .ctrl_pe_i(ctrl_pea_i[1][2]),
      .pe_res_o(out_data_pe12)
  );
  pe pe_inst_13 (
      .clk_i(clk_i),
      .rst_n_i(rst_n_i),
      .neigh_pe_op_i(in_data_pe13),
      .reg_acc_value_i(reg_acc_value_pe[1][3]),
      .pea_ready_i(ready_in_pe[3]),
      .neigh_pe_op_valid_i(stream_valid_pe_in13),
      .neigh_delay_op_i(in_delay_op13),
      .neigh_delay_op_valid_i(in_delay_op_valid13),
      .valid_o(stream_valid_pe_out13),
      .ready_o(stream_ready_pe_out13),
      .delay_op_valid_o(out_delay_op_valid13),
      .delay_op_o(out_delay_op13),
      .ctrl_pe_i(ctrl_pea_i[1][3]),
      .pe_res_o(out_data_pe13)
  );
  pe pe_inst_20 (
      .clk_i(clk_i),
      .rst_n_i(rst_n_i),
      .neigh_pe_op_i(in_data_pe20),
      .reg_acc_value_i(reg_acc_value_pe[2][0]),
      .pea_ready_i(ready_in_pe[0]),
      .neigh_pe_op_valid_i(stream_valid_pe_in20),
      .neigh_delay_op_i(in_delay_op20),
      .neigh_delay_op_valid_i(in_delay_op_valid20),
      .valid_o(stream_valid_pe_out20),
      .ready_o(stream_ready_pe_out20),
      .delay_op_valid_o(out_delay_op_valid20),
      .delay_op_o(out_delay_op20),
      .ctrl_pe_i(ctrl_pea_i[2][0]),
      .pe_res_o(out_data_pe20)
  );
  pe pe_inst_21 (
      .clk_i(clk_i),
      .rst_n_i(rst_n_i),
      .neigh_pe_op_i(in_data_pe21),
      .reg_acc_value_i(reg_acc_value_pe[2][1]),
      .pea_ready_i(ready_in_pe[1]),
      .neigh_pe_op_valid_i(stream_valid_pe_in21),
      .neigh_delay_op_i(in_delay_op21),
      .neigh_delay_op_valid_i(in_delay_op_valid21),
      .valid_o(stream_valid_pe_out21),
      .ready_o(stream_ready_pe_out21),
      .delay_op_valid_o(out_delay_op_valid21),
      .delay_op_o(out_delay_op21),
      .ctrl_pe_i(ctrl_pea_i[2][1]),
      .pe_res_o(out_data_pe21)
  );
  pe pe_inst_22 (
      .clk_i(clk_i),
      .rst_n_i(rst_n_i),
      .neigh_pe_op_i(in_data_pe22),
      .reg_acc_value_i(reg_acc_value_pe[2][2]),
      .pea_ready_i(ready_in_pe[2]),
      .neigh_pe_op_valid_i(stream_valid_pe_in22),
      .neigh_delay_op_i(in_delay_op22),
      .neigh_delay_op_valid_i(in_delay_op_valid22),
      .valid_o(stream_valid_pe_out22),
      .ready_o(stream_ready_pe_out22),
      .delay_op_valid_o(out_delay_op_valid22),
      .delay_op_o(out_delay_op22),
      .ctrl_pe_i(ctrl_pea_i[2][2]),
      .pe_res_o(out_data_pe22)
  );
  pe pe_inst_23 (
      .clk_i(clk_i),
      .rst_n_i(rst_n_i),
      .neigh_pe_op_i(in_data_pe23),
      .reg_acc_value_i(reg_acc_value_pe[2][3]),
      .pea_ready_i(ready_in_pe[3]),
      .neigh_pe_op_valid_i(stream_valid_pe_in23),
      .neigh_delay_op_i(in_delay_op23),
      .neigh_delay_op_valid_i(in_delay_op_valid23),
      .valid_o(stream_valid_pe_out23),
      .ready_o(stream_ready_pe_out23),
      .delay_op_valid_o(out_delay_op_valid23),
      .delay_op_o(out_delay_op23),
      .ctrl_pe_i(ctrl_pea_i[2][3]),
      .pe_res_o(out_data_pe23)
  );
  pe pe_inst_30 (
      .clk_i(clk_i),
      .rst_n_i(rst_n_i),
      .neigh_pe_op_i(in_data_pe30),
      .reg_acc_value_i(reg_acc_value_pe[3][0]),
      .pea_ready_i(ready_in_pe[0]),
      .neigh_pe_op_valid_i(stream_valid_pe_in30),
      .neigh_delay_op_i(in_delay_op30),
      .neigh_delay_op_valid_i(in_delay_op_valid30),
      .valid_o(stream_valid_pe_out30),
      .ready_o(stream_ready_pe_out30),
      .delay_op_valid_o(out_delay_op_valid30),
      .delay_op_o(out_delay_op30),
      .ctrl_pe_i(ctrl_pea_i[3][0]),
      .pe_res_o(out_data_pe30)
  );
  pe pe_inst_31 (
      .clk_i(clk_i),
      .rst_n_i(rst_n_i),
      .neigh_pe_op_i(in_data_pe31),
      .reg_acc_value_i(reg_acc_value_pe[3][1]),
      .pea_ready_i(ready_in_pe[1]),
      .neigh_pe_op_valid_i(stream_valid_pe_in31),
      .neigh_delay_op_i(in_delay_op31),
      .neigh_delay_op_valid_i(in_delay_op_valid31),
      .valid_o(stream_valid_pe_out31),
      .ready_o(stream_ready_pe_out31),
      .delay_op_valid_o(out_delay_op_valid31),
      .delay_op_o(out_delay_op31),
      .ctrl_pe_i(ctrl_pea_i[3][1]),
      .pe_res_o(out_data_pe31)
  );
  pe pe_inst_32 (
      .clk_i(clk_i),
      .rst_n_i(rst_n_i),
      .neigh_pe_op_i(in_data_pe32),
      .reg_acc_value_i(reg_acc_value_pe[3][2]),
      .pea_ready_i(ready_in_pe[2]),
      .neigh_pe_op_valid_i(stream_valid_pe_in32),
      .neigh_delay_op_i(in_delay_op32),
      .neigh_delay_op_valid_i(in_delay_op_valid32),
      .valid_o(stream_valid_pe_out32),
      .ready_o(stream_ready_pe_out32),
      .delay_op_valid_o(out_delay_op_valid32),
      .delay_op_o(out_delay_op32),
      .ctrl_pe_i(ctrl_pea_i[3][2]),
      .pe_res_o(out_data_pe32)
  );
  pe pe_inst_33 (
      .clk_i(clk_i),
      .rst_n_i(rst_n_i),
      .neigh_pe_op_i(in_data_pe33),
      .reg_acc_value_i(reg_acc_value_pe[3][3]),
      .pea_ready_i(ready_in_pe[3]),
      .neigh_pe_op_valid_i(stream_valid_pe_in33),
      .neigh_delay_op_i(in_delay_op33),
      .neigh_delay_op_valid_i(in_delay_op_valid33),
      .valid_o(stream_valid_pe_out33),
      .ready_o(stream_ready_pe_out33),
      .delay_op_valid_o(out_delay_op_valid33),
      .delay_op_o(out_delay_op33),
      .ctrl_pe_i(ctrl_pea_i[3][3]),
      .pe_res_o(out_data_pe33)
  );

  assign stream_valid_pe_out_arr = {
    stream_ready_pe_out00,
    stream_ready_pe_out01,
    stream_ready_pe_out02,
    stream_ready_pe_out03,
    stream_ready_pe_out10,
    stream_ready_pe_out11,
    stream_ready_pe_out12,
    stream_ready_pe_out13,
    stream_ready_pe_out20,
    stream_ready_pe_out21,
    stream_ready_pe_out22,
    stream_ready_pe_out23,
    stream_ready_pe_out30,
    stream_ready_pe_out31,
    stream_ready_pe_out32,
    stream_ready_pe_out33
  };

  always_comb begin
    if (reg_separate_cols_i) begin

      ready_in_pe[0] =
      stream_ready_pe_out00 &
      stream_ready_pe_out10 &
      stream_ready_pe_out20 &
      stream_ready_pe_out30;
      ready_in_pe[1] =
      stream_ready_pe_out01 &
      stream_ready_pe_out11 &
      stream_ready_pe_out21 &
      stream_ready_pe_out31;
      ready_in_pe[2] =
      stream_ready_pe_out02 &
      stream_ready_pe_out12 &
      stream_ready_pe_out22 &
      stream_ready_pe_out32;
      ready_in_pe[3] =
      stream_ready_pe_out03 &
      stream_ready_pe_out13 &
      stream_ready_pe_out23 &
      stream_ready_pe_out33;
      pea_ready_o[0] = ready_in_pe[0];
      pea_ready_o[1] = ready_in_pe[1];
      pea_ready_o[2] = ready_in_pe[2];
      pea_ready_o[3] = ready_in_pe[3];
    end else begin
      ready_in_pe[0] = &stream_valid_pe_out_arr;
      pea_ready_o[0] = ready_in_pe[0];
      ready_in_pe[1] = &stream_valid_pe_out_arr;
      pea_ready_o[1] = ready_in_pe[1];
      ready_in_pe[2] = &stream_valid_pe_out_arr;
      pea_ready_o[2] = ready_in_pe[2];
      ready_in_pe[3] = &stream_valid_pe_out_arr;
      pea_ready_o[3] = ready_in_pe[3];
    end
  end

endmodule
