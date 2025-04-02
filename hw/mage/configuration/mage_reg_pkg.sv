// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Register Package auto-generated by `reggen` containing data structure

package mage_reg_pkg;

  // Address widths within the block
  parameter int BlockAw = 8;

  ////////////////////////////
  // Typedefs for registers //
  ////////////////////////////

  typedef struct packed {logic [31:0] q;} mage_reg2hw_cfg_pe_00_mreg_t;

  typedef struct packed {logic [31:0] q;} mage_reg2hw_cfg_pe_01_mreg_t;

  typedef struct packed {logic [31:0] q;} mage_reg2hw_cfg_pe_02_mreg_t;

  typedef struct packed {logic [31:0] q;} mage_reg2hw_cfg_pe_03_mreg_t;

  typedef struct packed {logic [31:0] q;} mage_reg2hw_cfg_pe_10_mreg_t;

  typedef struct packed {logic [31:0] q;} mage_reg2hw_cfg_pe_11_mreg_t;

  typedef struct packed {logic [31:0] q;} mage_reg2hw_cfg_pe_12_mreg_t;

  typedef struct packed {logic [31:0] q;} mage_reg2hw_cfg_pe_13_mreg_t;

  typedef struct packed {logic [31:0] q;} mage_reg2hw_cfg_pe_20_mreg_t;

  typedef struct packed {logic [31:0] q;} mage_reg2hw_cfg_pe_21_mreg_t;

  typedef struct packed {logic [31:0] q;} mage_reg2hw_cfg_pe_22_mreg_t;

  typedef struct packed {logic [31:0] q;} mage_reg2hw_cfg_pe_23_mreg_t;

  typedef struct packed {logic [31:0] q;} mage_reg2hw_cfg_pe_30_mreg_t;

  typedef struct packed {logic [31:0] q;} mage_reg2hw_cfg_pe_31_mreg_t;

  typedef struct packed {logic [31:0] q;} mage_reg2hw_cfg_pe_32_mreg_t;

  typedef struct packed {logic [31:0] q;} mage_reg2hw_cfg_pe_33_mreg_t;

  typedef struct packed {logic [31:0] q;} mage_reg2hw_pea_constants_mreg_t;

  typedef struct packed {logic [3:0] q;} mage_reg2hw_stream_dma_cfg_reg_t;

  typedef struct packed {logic q;} mage_reg2hw_separate_cols_reg_t;

  typedef struct packed {
    struct packed {logic [1:0] q;} sel_in_xbar_0;
    struct packed {logic [1:0] q;} sel_in_xbar_1;
    struct packed {logic [1:0] q;} sel_in_xbar_2;
    struct packed {logic [1:0] q;} sel_in_xbar_3;
  } mage_reg2hw_stream_in_xbar_sel_reg_t;

  typedef struct packed {
    struct packed {logic [1:0] q;} sel_out_xbar_0;
    struct packed {logic [1:0] q;} sel_out_xbar_1;
    struct packed {logic [1:0] q;} sel_out_xbar_2;
    struct packed {logic [1:0] q;} sel_out_xbar_3;
  } mage_reg2hw_stream_out_xbar_sel_reg_t;

  typedef struct packed {
    struct packed {logic [7:0] q;} sel_col_0;
    struct packed {logic [7:0] q;} sel_col_1;
    struct packed {logic [7:0] q;} sel_col_2;
    struct packed {logic [7:0] q;} sel_col_3;
  } mage_reg2hw_sel_out_col_pea_mreg_t;

  typedef struct packed {
    struct packed {logic [7:0] q;} pe_0;
    struct packed {logic [7:0] q;} pe_1;
    struct packed {logic [7:0] q;} pe_2;
    struct packed {logic [7:0] q;} pe_3;
  } mage_reg2hw_acc_value_mreg_t;

  // Register -> HW type
  typedef struct packed {
    mage_reg2hw_cfg_pe_00_mreg_t [0:0] cfg_pe_00;  // [1204:1173]
    mage_reg2hw_cfg_pe_01_mreg_t [0:0] cfg_pe_01;  // [1172:1141]
    mage_reg2hw_cfg_pe_02_mreg_t [0:0] cfg_pe_02;  // [1140:1109]
    mage_reg2hw_cfg_pe_03_mreg_t [0:0] cfg_pe_03;  // [1108:1077]
    mage_reg2hw_cfg_pe_10_mreg_t [0:0] cfg_pe_10;  // [1076:1045]
    mage_reg2hw_cfg_pe_11_mreg_t [0:0] cfg_pe_11;  // [1044:1013]
    mage_reg2hw_cfg_pe_12_mreg_t [0:0] cfg_pe_12;  // [1012:981]
    mage_reg2hw_cfg_pe_13_mreg_t [0:0] cfg_pe_13;  // [980:949]
    mage_reg2hw_cfg_pe_20_mreg_t [0:0] cfg_pe_20;  // [948:917]
    mage_reg2hw_cfg_pe_21_mreg_t [0:0] cfg_pe_21;  // [916:885]
    mage_reg2hw_cfg_pe_22_mreg_t [0:0] cfg_pe_22;  // [884:853]
    mage_reg2hw_cfg_pe_23_mreg_t [0:0] cfg_pe_23;  // [852:821]
    mage_reg2hw_cfg_pe_30_mreg_t [0:0] cfg_pe_30;  // [820:789]
    mage_reg2hw_cfg_pe_31_mreg_t [0:0] cfg_pe_31;  // [788:757]
    mage_reg2hw_cfg_pe_32_mreg_t [0:0] cfg_pe_32;  // [756:725]
    mage_reg2hw_cfg_pe_33_mreg_t [0:0] cfg_pe_33;  // [724:693]
    mage_reg2hw_pea_constants_mreg_t [15:0] pea_constants;  // [692:181]
    mage_reg2hw_stream_dma_cfg_reg_t stream_dma_cfg;  // [180:177]
    mage_reg2hw_separate_cols_reg_t separate_cols;  // [176:176]
    mage_reg2hw_stream_in_xbar_sel_reg_t stream_in_xbar_sel;  // [175:168]
    mage_reg2hw_stream_out_xbar_sel_reg_t stream_out_xbar_sel;  // [167:160]
    mage_reg2hw_sel_out_col_pea_mreg_t [0:0] sel_out_col_pea;  // [159:128]
    mage_reg2hw_acc_value_mreg_t [3:0] acc_value;  // [127:0]
  } mage_reg2hw_t;

  // Register offsets
  parameter logic [BlockAw-1:0] MAGE_CFG_PE_00_OFFSET = 8'h0;
  parameter logic [BlockAw-1:0] MAGE_CFG_PE_01_OFFSET = 8'h4;
  parameter logic [BlockAw-1:0] MAGE_CFG_PE_02_OFFSET = 8'h8;
  parameter logic [BlockAw-1:0] MAGE_CFG_PE_03_OFFSET = 8'hc;
  parameter logic [BlockAw-1:0] MAGE_CFG_PE_10_OFFSET = 8'h10;
  parameter logic [BlockAw-1:0] MAGE_CFG_PE_11_OFFSET = 8'h14;
  parameter logic [BlockAw-1:0] MAGE_CFG_PE_12_OFFSET = 8'h18;
  parameter logic [BlockAw-1:0] MAGE_CFG_PE_13_OFFSET = 8'h1c;
  parameter logic [BlockAw-1:0] MAGE_CFG_PE_20_OFFSET = 8'h20;
  parameter logic [BlockAw-1:0] MAGE_CFG_PE_21_OFFSET = 8'h24;
  parameter logic [BlockAw-1:0] MAGE_CFG_PE_22_OFFSET = 8'h28;
  parameter logic [BlockAw-1:0] MAGE_CFG_PE_23_OFFSET = 8'h2c;
  parameter logic [BlockAw-1:0] MAGE_CFG_PE_30_OFFSET = 8'h30;
  parameter logic [BlockAw-1:0] MAGE_CFG_PE_31_OFFSET = 8'h34;
  parameter logic [BlockAw-1:0] MAGE_CFG_PE_32_OFFSET = 8'h38;
  parameter logic [BlockAw-1:0] MAGE_CFG_PE_33_OFFSET = 8'h3c;
  parameter logic [BlockAw-1:0] MAGE_PEA_CONSTANTS_0_OFFSET = 8'h40;
  parameter logic [BlockAw-1:0] MAGE_PEA_CONSTANTS_1_OFFSET = 8'h44;
  parameter logic [BlockAw-1:0] MAGE_PEA_CONSTANTS_2_OFFSET = 8'h48;
  parameter logic [BlockAw-1:0] MAGE_PEA_CONSTANTS_3_OFFSET = 8'h4c;
  parameter logic [BlockAw-1:0] MAGE_PEA_CONSTANTS_4_OFFSET = 8'h50;
  parameter logic [BlockAw-1:0] MAGE_PEA_CONSTANTS_5_OFFSET = 8'h54;
  parameter logic [BlockAw-1:0] MAGE_PEA_CONSTANTS_6_OFFSET = 8'h58;
  parameter logic [BlockAw-1:0] MAGE_PEA_CONSTANTS_7_OFFSET = 8'h5c;
  parameter logic [BlockAw-1:0] MAGE_PEA_CONSTANTS_8_OFFSET = 8'h60;
  parameter logic [BlockAw-1:0] MAGE_PEA_CONSTANTS_9_OFFSET = 8'h64;
  parameter logic [BlockAw-1:0] MAGE_PEA_CONSTANTS_10_OFFSET = 8'h68;
  parameter logic [BlockAw-1:0] MAGE_PEA_CONSTANTS_11_OFFSET = 8'h6c;
  parameter logic [BlockAw-1:0] MAGE_PEA_CONSTANTS_12_OFFSET = 8'h70;
  parameter logic [BlockAw-1:0] MAGE_PEA_CONSTANTS_13_OFFSET = 8'h74;
  parameter logic [BlockAw-1:0] MAGE_PEA_CONSTANTS_14_OFFSET = 8'h78;
  parameter logic [BlockAw-1:0] MAGE_PEA_CONSTANTS_15_OFFSET = 8'h7c;
  parameter logic [BlockAw-1:0] MAGE_STREAM_DMA_CFG_OFFSET = 8'h80;
  parameter logic [BlockAw-1:0] MAGE_SEPARATE_COLS_OFFSET = 8'h84;
  parameter logic [BlockAw-1:0] MAGE_STREAM_IN_XBAR_SEL_OFFSET = 8'h88;
  parameter logic [BlockAw-1:0] MAGE_STREAM_OUT_XBAR_SEL_OFFSET = 8'h8c;
  parameter logic [BlockAw-1:0] MAGE_SEL_OUT_COL_PEA_OFFSET = 8'h90;
  parameter logic [BlockAw-1:0] MAGE_ACC_VALUE_0_OFFSET = 8'h94;
  parameter logic [BlockAw-1:0] MAGE_ACC_VALUE_1_OFFSET = 8'h98;
  parameter logic [BlockAw-1:0] MAGE_ACC_VALUE_2_OFFSET = 8'h9c;
  parameter logic [BlockAw-1:0] MAGE_ACC_VALUE_3_OFFSET = 8'ha0;

  // Register index
  typedef enum int {
    MAGE_CFG_PE_00,
    MAGE_CFG_PE_01,
    MAGE_CFG_PE_02,
    MAGE_CFG_PE_03,
    MAGE_CFG_PE_10,
    MAGE_CFG_PE_11,
    MAGE_CFG_PE_12,
    MAGE_CFG_PE_13,
    MAGE_CFG_PE_20,
    MAGE_CFG_PE_21,
    MAGE_CFG_PE_22,
    MAGE_CFG_PE_23,
    MAGE_CFG_PE_30,
    MAGE_CFG_PE_31,
    MAGE_CFG_PE_32,
    MAGE_CFG_PE_33,
    MAGE_PEA_CONSTANTS_0,
    MAGE_PEA_CONSTANTS_1,
    MAGE_PEA_CONSTANTS_2,
    MAGE_PEA_CONSTANTS_3,
    MAGE_PEA_CONSTANTS_4,
    MAGE_PEA_CONSTANTS_5,
    MAGE_PEA_CONSTANTS_6,
    MAGE_PEA_CONSTANTS_7,
    MAGE_PEA_CONSTANTS_8,
    MAGE_PEA_CONSTANTS_9,
    MAGE_PEA_CONSTANTS_10,
    MAGE_PEA_CONSTANTS_11,
    MAGE_PEA_CONSTANTS_12,
    MAGE_PEA_CONSTANTS_13,
    MAGE_PEA_CONSTANTS_14,
    MAGE_PEA_CONSTANTS_15,
    MAGE_STREAM_DMA_CFG,
    MAGE_SEPARATE_COLS,
    MAGE_STREAM_IN_XBAR_SEL,
    MAGE_STREAM_OUT_XBAR_SEL,
    MAGE_SEL_OUT_COL_PEA,
    MAGE_ACC_VALUE_0,
    MAGE_ACC_VALUE_1,
    MAGE_ACC_VALUE_2,
    MAGE_ACC_VALUE_3
  } mage_id_e;

  // Register width information to check illegal writes
  parameter logic [3:0] MAGE_PERMIT[41] = '{
      4'b1111,  // index[ 0] MAGE_CFG_PE_00
      4'b1111,  // index[ 1] MAGE_CFG_PE_01
      4'b1111,  // index[ 2] MAGE_CFG_PE_02
      4'b1111,  // index[ 3] MAGE_CFG_PE_03
      4'b1111,  // index[ 4] MAGE_CFG_PE_10
      4'b1111,  // index[ 5] MAGE_CFG_PE_11
      4'b1111,  // index[ 6] MAGE_CFG_PE_12
      4'b1111,  // index[ 7] MAGE_CFG_PE_13
      4'b1111,  // index[ 8] MAGE_CFG_PE_20
      4'b1111,  // index[ 9] MAGE_CFG_PE_21
      4'b1111,  // index[10] MAGE_CFG_PE_22
      4'b1111,  // index[11] MAGE_CFG_PE_23
      4'b1111,  // index[12] MAGE_CFG_PE_30
      4'b1111,  // index[13] MAGE_CFG_PE_31
      4'b1111,  // index[14] MAGE_CFG_PE_32
      4'b1111,  // index[15] MAGE_CFG_PE_33
      4'b1111,  // index[16] MAGE_PEA_CONSTANTS_0
      4'b1111,  // index[17] MAGE_PEA_CONSTANTS_1
      4'b1111,  // index[18] MAGE_PEA_CONSTANTS_2
      4'b1111,  // index[19] MAGE_PEA_CONSTANTS_3
      4'b1111,  // index[20] MAGE_PEA_CONSTANTS_4
      4'b1111,  // index[21] MAGE_PEA_CONSTANTS_5
      4'b1111,  // index[22] MAGE_PEA_CONSTANTS_6
      4'b1111,  // index[23] MAGE_PEA_CONSTANTS_7
      4'b1111,  // index[24] MAGE_PEA_CONSTANTS_8
      4'b1111,  // index[25] MAGE_PEA_CONSTANTS_9
      4'b1111,  // index[26] MAGE_PEA_CONSTANTS_10
      4'b1111,  // index[27] MAGE_PEA_CONSTANTS_11
      4'b1111,  // index[28] MAGE_PEA_CONSTANTS_12
      4'b1111,  // index[29] MAGE_PEA_CONSTANTS_13
      4'b1111,  // index[30] MAGE_PEA_CONSTANTS_14
      4'b1111,  // index[31] MAGE_PEA_CONSTANTS_15
      4'b0001,  // index[32] MAGE_STREAM_DMA_CFG
      4'b0001,  // index[33] MAGE_SEPARATE_COLS
      4'b0001,  // index[34] MAGE_STREAM_IN_XBAR_SEL
      4'b0001,  // index[35] MAGE_STREAM_OUT_XBAR_SEL
      4'b1111,  // index[36] MAGE_SEL_OUT_COL_PEA
      4'b1111,  // index[37] MAGE_ACC_VALUE_0
      4'b1111,  // index[38] MAGE_ACC_VALUE_1
      4'b1111,  // index[39] MAGE_ACC_VALUE_2
      4'b1111  // index[40] MAGE_ACC_VALUE_3
  };

endpackage

