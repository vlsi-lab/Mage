// Generated register defines for mage

#ifndef _MAGE_REG_DEFS_
#define _MAGE_REG_DEFS_

#ifdef __cplusplus
extern "C" {
#endif
// Register width
#define MAGE_PARAM_REG_WIDTH 32

// MAGE-CGRA status
#define MAGE_STATUS_REG_OFFSET 0x0
#define MAGE_STATUS_START_BIT 0
#define MAGE_STATUS_DONE_BIT 1

// General Configuration Bits
#define MAGE_GEN_CFG_REG_OFFSET 0x4
#define MAGE_GEN_CFG_II_MASK 0xf
#define MAGE_GEN_CFG_II_OFFSET 0
#define MAGE_GEN_CFG_II_FIELD \
  ((bitfield_field32_t) { .mask = MAGE_GEN_CFG_II_MASK, .index = MAGE_GEN_CFG_II_OFFSET })
#define MAGE_GEN_CFG_S_N_T_MAGE_BIT 4
#define MAGE_GEN_CFG_S_N_T_MAGE_PEA_BIT 5
#define MAGE_GEN_CFG_S_N_T_MAGE_PEA_OUT_REGS_BIT 6
#define MAGE_GEN_CFG_S_N_T_MAGE_XBAR_BIT 7
#define MAGE_GEN_CFG_ACC_VEC_MODE_MASK 0xf
#define MAGE_GEN_CFG_ACC_VEC_MODE_OFFSET 8
#define MAGE_GEN_CFG_ACC_VEC_MODE_FIELD \
  ((bitfield_field32_t) { .mask = MAGE_GEN_CFG_ACC_VEC_MODE_MASK, .index = MAGE_GEN_CFG_ACC_VEC_MODE_OFFSET })
#define MAGE_GEN_CFG_BLOCKSIZE_MASK 0xf
#define MAGE_GEN_CFG_BLOCKSIZE_OFFSET 12
#define MAGE_GEN_CFG_BLOCKSIZE_FIELD \
  ((bitfield_field32_t) { .mask = MAGE_GEN_CFG_BLOCKSIZE_MASK, .index = MAGE_GEN_CFG_BLOCKSIZE_OFFSET })

// Initial Loop Bounds for Hardware Loops
#define MAGE_ILB_HWL_REG_OFFSET 0x8
#define MAGE_ILB_HWL_ILB_0_MASK 0xff
#define MAGE_ILB_HWL_ILB_0_OFFSET 0
#define MAGE_ILB_HWL_ILB_0_FIELD \
  ((bitfield_field32_t) { .mask = MAGE_ILB_HWL_ILB_0_MASK, .index = MAGE_ILB_HWL_ILB_0_OFFSET })
#define MAGE_ILB_HWL_ILB_1_MASK 0xff
#define MAGE_ILB_HWL_ILB_1_OFFSET 8
#define MAGE_ILB_HWL_ILB_1_FIELD \
  ((bitfield_field32_t) { .mask = MAGE_ILB_HWL_ILB_1_MASK, .index = MAGE_ILB_HWL_ILB_1_OFFSET })
#define MAGE_ILB_HWL_ILB_2_MASK 0xff
#define MAGE_ILB_HWL_ILB_2_OFFSET 16
#define MAGE_ILB_HWL_ILB_2_FIELD \
  ((bitfield_field32_t) { .mask = MAGE_ILB_HWL_ILB_2_MASK, .index = MAGE_ILB_HWL_ILB_2_OFFSET })
#define MAGE_ILB_HWL_ILB_3_MASK 0xff
#define MAGE_ILB_HWL_ILB_3_OFFSET 24
#define MAGE_ILB_HWL_ILB_3_FIELD \
  ((bitfield_field32_t) { .mask = MAGE_ILB_HWL_ILB_3_MASK, .index = MAGE_ILB_HWL_ILB_3_OFFSET })

// Final Loop Bounds for Hardware Loops
#define MAGE_FLB_HWL_REG_OFFSET 0xc
#define MAGE_FLB_HWL_FLB_0_MASK 0xff
#define MAGE_FLB_HWL_FLB_0_OFFSET 0
#define MAGE_FLB_HWL_FLB_0_FIELD \
  ((bitfield_field32_t) { .mask = MAGE_FLB_HWL_FLB_0_MASK, .index = MAGE_FLB_HWL_FLB_0_OFFSET })
#define MAGE_FLB_HWL_FLB_1_MASK 0xff
#define MAGE_FLB_HWL_FLB_1_OFFSET 8
#define MAGE_FLB_HWL_FLB_1_FIELD \
  ((bitfield_field32_t) { .mask = MAGE_FLB_HWL_FLB_1_MASK, .index = MAGE_FLB_HWL_FLB_1_OFFSET })
#define MAGE_FLB_HWL_FLB_2_MASK 0xff
#define MAGE_FLB_HWL_FLB_2_OFFSET 16
#define MAGE_FLB_HWL_FLB_2_FIELD \
  ((bitfield_field32_t) { .mask = MAGE_FLB_HWL_FLB_2_MASK, .index = MAGE_FLB_HWL_FLB_2_OFFSET })
#define MAGE_FLB_HWL_FLB_3_MASK 0xff
#define MAGE_FLB_HWL_FLB_3_OFFSET 24
#define MAGE_FLB_HWL_FLB_3_FIELD \
  ((bitfield_field32_t) { .mask = MAGE_FLB_HWL_FLB_3_MASK, .index = MAGE_FLB_HWL_FLB_3_OFFSET })

// Increments for Hardware Loops
#define MAGE_INC_HWL_REG_OFFSET 0x10
#define MAGE_INC_HWL_INC_0_MASK 0xff
#define MAGE_INC_HWL_INC_0_OFFSET 0
#define MAGE_INC_HWL_INC_0_FIELD \
  ((bitfield_field32_t) { .mask = MAGE_INC_HWL_INC_0_MASK, .index = MAGE_INC_HWL_INC_0_OFFSET })
#define MAGE_INC_HWL_INC_1_MASK 0xff
#define MAGE_INC_HWL_INC_1_OFFSET 8
#define MAGE_INC_HWL_INC_1_FIELD \
  ((bitfield_field32_t) { .mask = MAGE_INC_HWL_INC_1_MASK, .index = MAGE_INC_HWL_INC_1_OFFSET })
#define MAGE_INC_HWL_INC_2_MASK 0xff
#define MAGE_INC_HWL_INC_2_OFFSET 16
#define MAGE_INC_HWL_INC_2_FIELD \
  ((bitfield_field32_t) { .mask = MAGE_INC_HWL_INC_2_MASK, .index = MAGE_INC_HWL_INC_2_OFFSET })
#define MAGE_INC_HWL_INC_3_MASK 0xff
#define MAGE_INC_HWL_INC_3_OFFSET 24
#define MAGE_INC_HWL_INC_3_FIELD \
  ((bitfield_field32_t) { .mask = MAGE_INC_HWL_INC_3_MASK, .index = MAGE_INC_HWL_INC_3_OFFSET })

// Configuration for AGEs strides (common parameters)
// Configuration for AGEs strides
#define MAGE_STRIDES_0_REG_OFFSET 0x14
#define MAGE_STRIDES_0_S0_0_MASK 0xff
#define MAGE_STRIDES_0_S0_0_OFFSET 0
#define MAGE_STRIDES_0_S0_0_FIELD \
  ((bitfield_field32_t) { .mask = MAGE_STRIDES_0_S0_0_MASK, .index = MAGE_STRIDES_0_S0_0_OFFSET })
#define MAGE_STRIDES_0_S1_0_MASK 0xff
#define MAGE_STRIDES_0_S1_0_OFFSET 8
#define MAGE_STRIDES_0_S1_0_FIELD \
  ((bitfield_field32_t) { .mask = MAGE_STRIDES_0_S1_0_MASK, .index = MAGE_STRIDES_0_S1_0_OFFSET })
#define MAGE_STRIDES_0_S2_0_MASK 0xff
#define MAGE_STRIDES_0_S2_0_OFFSET 16
#define MAGE_STRIDES_0_S2_0_FIELD \
  ((bitfield_field32_t) { .mask = MAGE_STRIDES_0_S2_0_MASK, .index = MAGE_STRIDES_0_S2_0_OFFSET })
#define MAGE_STRIDES_0_S3_0_MASK 0xff
#define MAGE_STRIDES_0_S3_0_OFFSET 24
#define MAGE_STRIDES_0_S3_0_FIELD \
  ((bitfield_field32_t) { .mask = MAGE_STRIDES_0_S3_0_MASK, .index = MAGE_STRIDES_0_S3_0_OFFSET })

// Configuration for AGEs strides
#define MAGE_STRIDES_1_REG_OFFSET 0x18
#define MAGE_STRIDES_1_S0_1_MASK 0xff
#define MAGE_STRIDES_1_S0_1_OFFSET 0
#define MAGE_STRIDES_1_S0_1_FIELD \
  ((bitfield_field32_t) { .mask = MAGE_STRIDES_1_S0_1_MASK, .index = MAGE_STRIDES_1_S0_1_OFFSET })
#define MAGE_STRIDES_1_S1_1_MASK 0xff
#define MAGE_STRIDES_1_S1_1_OFFSET 8
#define MAGE_STRIDES_1_S1_1_FIELD \
  ((bitfield_field32_t) { .mask = MAGE_STRIDES_1_S1_1_MASK, .index = MAGE_STRIDES_1_S1_1_OFFSET })
#define MAGE_STRIDES_1_S2_1_MASK 0xff
#define MAGE_STRIDES_1_S2_1_OFFSET 16
#define MAGE_STRIDES_1_S2_1_FIELD \
  ((bitfield_field32_t) { .mask = MAGE_STRIDES_1_S2_1_MASK, .index = MAGE_STRIDES_1_S2_1_OFFSET })
#define MAGE_STRIDES_1_S3_1_MASK 0xff
#define MAGE_STRIDES_1_S3_1_OFFSET 24
#define MAGE_STRIDES_1_S3_1_FIELD \
  ((bitfield_field32_t) { .mask = MAGE_STRIDES_1_S3_1_MASK, .index = MAGE_STRIDES_1_S3_1_OFFSET })

// Configuration for AGEs strides
#define MAGE_STRIDES_2_REG_OFFSET 0x1c
#define MAGE_STRIDES_2_S0_2_MASK 0xff
#define MAGE_STRIDES_2_S0_2_OFFSET 0
#define MAGE_STRIDES_2_S0_2_FIELD \
  ((bitfield_field32_t) { .mask = MAGE_STRIDES_2_S0_2_MASK, .index = MAGE_STRIDES_2_S0_2_OFFSET })
#define MAGE_STRIDES_2_S1_2_MASK 0xff
#define MAGE_STRIDES_2_S1_2_OFFSET 8
#define MAGE_STRIDES_2_S1_2_FIELD \
  ((bitfield_field32_t) { .mask = MAGE_STRIDES_2_S1_2_MASK, .index = MAGE_STRIDES_2_S1_2_OFFSET })
#define MAGE_STRIDES_2_S2_2_MASK 0xff
#define MAGE_STRIDES_2_S2_2_OFFSET 16
#define MAGE_STRIDES_2_S2_2_FIELD \
  ((bitfield_field32_t) { .mask = MAGE_STRIDES_2_S2_2_MASK, .index = MAGE_STRIDES_2_S2_2_OFFSET })
#define MAGE_STRIDES_2_S3_2_MASK 0xff
#define MAGE_STRIDES_2_S3_2_OFFSET 24
#define MAGE_STRIDES_2_S3_2_FIELD \
  ((bitfield_field32_t) { .mask = MAGE_STRIDES_2_S3_2_MASK, .index = MAGE_STRIDES_2_S3_2_OFFSET })

// Configuration for AGEs strides
#define MAGE_STRIDES_3_REG_OFFSET 0x20
#define MAGE_STRIDES_3_S0_3_MASK 0xff
#define MAGE_STRIDES_3_S0_3_OFFSET 0
#define MAGE_STRIDES_3_S0_3_FIELD \
  ((bitfield_field32_t) { .mask = MAGE_STRIDES_3_S0_3_MASK, .index = MAGE_STRIDES_3_S0_3_OFFSET })
#define MAGE_STRIDES_3_S1_3_MASK 0xff
#define MAGE_STRIDES_3_S1_3_OFFSET 8
#define MAGE_STRIDES_3_S1_3_FIELD \
  ((bitfield_field32_t) { .mask = MAGE_STRIDES_3_S1_3_MASK, .index = MAGE_STRIDES_3_S1_3_OFFSET })
#define MAGE_STRIDES_3_S2_3_MASK 0xff
#define MAGE_STRIDES_3_S2_3_OFFSET 16
#define MAGE_STRIDES_3_S2_3_FIELD \
  ((bitfield_field32_t) { .mask = MAGE_STRIDES_3_S2_3_MASK, .index = MAGE_STRIDES_3_S2_3_OFFSET })
#define MAGE_STRIDES_3_S3_3_MASK 0xff
#define MAGE_STRIDES_3_S3_3_OFFSET 24
#define MAGE_STRIDES_3_S3_3_FIELD \
  ((bitfield_field32_t) { .mask = MAGE_STRIDES_3_S3_3_MASK, .index = MAGE_STRIDES_3_S3_3_OFFSET })

// Configuration for AGEs strides
#define MAGE_STRIDES_4_REG_OFFSET 0x24
#define MAGE_STRIDES_4_S0_4_MASK 0xff
#define MAGE_STRIDES_4_S0_4_OFFSET 0
#define MAGE_STRIDES_4_S0_4_FIELD \
  ((bitfield_field32_t) { .mask = MAGE_STRIDES_4_S0_4_MASK, .index = MAGE_STRIDES_4_S0_4_OFFSET })
#define MAGE_STRIDES_4_S1_4_MASK 0xff
#define MAGE_STRIDES_4_S1_4_OFFSET 8
#define MAGE_STRIDES_4_S1_4_FIELD \
  ((bitfield_field32_t) { .mask = MAGE_STRIDES_4_S1_4_MASK, .index = MAGE_STRIDES_4_S1_4_OFFSET })
#define MAGE_STRIDES_4_S2_4_MASK 0xff
#define MAGE_STRIDES_4_S2_4_OFFSET 16
#define MAGE_STRIDES_4_S2_4_FIELD \
  ((bitfield_field32_t) { .mask = MAGE_STRIDES_4_S2_4_MASK, .index = MAGE_STRIDES_4_S2_4_OFFSET })
#define MAGE_STRIDES_4_S3_4_MASK 0xff
#define MAGE_STRIDES_4_S3_4_OFFSET 24
#define MAGE_STRIDES_4_S3_4_FIELD \
  ((bitfield_field32_t) { .mask = MAGE_STRIDES_4_S3_4_MASK, .index = MAGE_STRIDES_4_S3_4_OFFSET })

// Configuration for AGEs strides
#define MAGE_STRIDES_5_REG_OFFSET 0x28
#define MAGE_STRIDES_5_S0_5_MASK 0xff
#define MAGE_STRIDES_5_S0_5_OFFSET 0
#define MAGE_STRIDES_5_S0_5_FIELD \
  ((bitfield_field32_t) { .mask = MAGE_STRIDES_5_S0_5_MASK, .index = MAGE_STRIDES_5_S0_5_OFFSET })
#define MAGE_STRIDES_5_S1_5_MASK 0xff
#define MAGE_STRIDES_5_S1_5_OFFSET 8
#define MAGE_STRIDES_5_S1_5_FIELD \
  ((bitfield_field32_t) { .mask = MAGE_STRIDES_5_S1_5_MASK, .index = MAGE_STRIDES_5_S1_5_OFFSET })
#define MAGE_STRIDES_5_S2_5_MASK 0xff
#define MAGE_STRIDES_5_S2_5_OFFSET 16
#define MAGE_STRIDES_5_S2_5_FIELD \
  ((bitfield_field32_t) { .mask = MAGE_STRIDES_5_S2_5_MASK, .index = MAGE_STRIDES_5_S2_5_OFFSET })
#define MAGE_STRIDES_5_S3_5_MASK 0xff
#define MAGE_STRIDES_5_S3_5_OFFSET 24
#define MAGE_STRIDES_5_S3_5_FIELD \
  ((bitfield_field32_t) { .mask = MAGE_STRIDES_5_S3_5_MASK, .index = MAGE_STRIDES_5_S3_5_OFFSET })

// Configuration for AGEs strides
#define MAGE_STRIDES_6_REG_OFFSET 0x2c
#define MAGE_STRIDES_6_S0_6_MASK 0xff
#define MAGE_STRIDES_6_S0_6_OFFSET 0
#define MAGE_STRIDES_6_S0_6_FIELD \
  ((bitfield_field32_t) { .mask = MAGE_STRIDES_6_S0_6_MASK, .index = MAGE_STRIDES_6_S0_6_OFFSET })
#define MAGE_STRIDES_6_S1_6_MASK 0xff
#define MAGE_STRIDES_6_S1_6_OFFSET 8
#define MAGE_STRIDES_6_S1_6_FIELD \
  ((bitfield_field32_t) { .mask = MAGE_STRIDES_6_S1_6_MASK, .index = MAGE_STRIDES_6_S1_6_OFFSET })
#define MAGE_STRIDES_6_S2_6_MASK 0xff
#define MAGE_STRIDES_6_S2_6_OFFSET 16
#define MAGE_STRIDES_6_S2_6_FIELD \
  ((bitfield_field32_t) { .mask = MAGE_STRIDES_6_S2_6_MASK, .index = MAGE_STRIDES_6_S2_6_OFFSET })
#define MAGE_STRIDES_6_S3_6_MASK 0xff
#define MAGE_STRIDES_6_S3_6_OFFSET 24
#define MAGE_STRIDES_6_S3_6_FIELD \
  ((bitfield_field32_t) { .mask = MAGE_STRIDES_6_S3_6_MASK, .index = MAGE_STRIDES_6_S3_6_OFFSET })

// Configuration for AGEs strides
#define MAGE_STRIDES_7_REG_OFFSET 0x30
#define MAGE_STRIDES_7_S0_7_MASK 0xff
#define MAGE_STRIDES_7_S0_7_OFFSET 0
#define MAGE_STRIDES_7_S0_7_FIELD \
  ((bitfield_field32_t) { .mask = MAGE_STRIDES_7_S0_7_MASK, .index = MAGE_STRIDES_7_S0_7_OFFSET })
#define MAGE_STRIDES_7_S1_7_MASK 0xff
#define MAGE_STRIDES_7_S1_7_OFFSET 8
#define MAGE_STRIDES_7_S1_7_FIELD \
  ((bitfield_field32_t) { .mask = MAGE_STRIDES_7_S1_7_MASK, .index = MAGE_STRIDES_7_S1_7_OFFSET })
#define MAGE_STRIDES_7_S2_7_MASK 0xff
#define MAGE_STRIDES_7_S2_7_OFFSET 16
#define MAGE_STRIDES_7_S2_7_FIELD \
  ((bitfield_field32_t) { .mask = MAGE_STRIDES_7_S2_7_MASK, .index = MAGE_STRIDES_7_S2_7_OFFSET })
#define MAGE_STRIDES_7_S3_7_MASK 0xff
#define MAGE_STRIDES_7_S3_7_OFFSET 24
#define MAGE_STRIDES_7_S3_7_FIELD \
  ((bitfield_field32_t) { .mask = MAGE_STRIDES_7_S3_7_MASK, .index = MAGE_STRIDES_7_S3_7_OFFSET })

// Configuration for PE 00 (common parameters)
#define MAGE_CFG_PE_00_CFG_PE_00_FIELD_WIDTH 32
#define MAGE_CFG_PE_00_CFG_PE_00_FIELDS_PER_REG 1
#define MAGE_CFG_PE_00_MULTIREG_COUNT 1

// Configuration for PE 00
#define MAGE_CFG_PE_00_REG_OFFSET 0x34

// Configuration for PE 01 (common parameters)
#define MAGE_CFG_PE_01_CFG_PE_01_FIELD_WIDTH 32
#define MAGE_CFG_PE_01_CFG_PE_01_FIELDS_PER_REG 1
#define MAGE_CFG_PE_01_MULTIREG_COUNT 1

// Configuration for PE 01
#define MAGE_CFG_PE_01_REG_OFFSET 0x38

// Configuration for PE 02 (common parameters)
#define MAGE_CFG_PE_02_CFG_PE_02_FIELD_WIDTH 32
#define MAGE_CFG_PE_02_CFG_PE_02_FIELDS_PER_REG 1
#define MAGE_CFG_PE_02_MULTIREG_COUNT 1

// Configuration for PE 02
#define MAGE_CFG_PE_02_REG_OFFSET 0x3c

// Configuration for PE 03 (common parameters)
#define MAGE_CFG_PE_03_CFG_PE_03_FIELD_WIDTH 32
#define MAGE_CFG_PE_03_CFG_PE_03_FIELDS_PER_REG 1
#define MAGE_CFG_PE_03_MULTIREG_COUNT 1

// Configuration for PE 03
#define MAGE_CFG_PE_03_REG_OFFSET 0x40

// Configuration for PE 10 (common parameters)
#define MAGE_CFG_PE_10_CFG_PE_10_FIELD_WIDTH 32
#define MAGE_CFG_PE_10_CFG_PE_10_FIELDS_PER_REG 1
#define MAGE_CFG_PE_10_MULTIREG_COUNT 1

// Configuration for PE 10
#define MAGE_CFG_PE_10_REG_OFFSET 0x44

// Configuration for PE 11 (common parameters)
#define MAGE_CFG_PE_11_CFG_PE_11_FIELD_WIDTH 32
#define MAGE_CFG_PE_11_CFG_PE_11_FIELDS_PER_REG 1
#define MAGE_CFG_PE_11_MULTIREG_COUNT 1

// Configuration for PE 11
#define MAGE_CFG_PE_11_REG_OFFSET 0x48

// Configuration for PE 12 (common parameters)
#define MAGE_CFG_PE_12_CFG_PE_12_FIELD_WIDTH 32
#define MAGE_CFG_PE_12_CFG_PE_12_FIELDS_PER_REG 1
#define MAGE_CFG_PE_12_MULTIREG_COUNT 1

// Configuration for PE 12
#define MAGE_CFG_PE_12_REG_OFFSET 0x4c

// Configuration for PE 13 (common parameters)
#define MAGE_CFG_PE_13_CFG_PE_13_FIELD_WIDTH 32
#define MAGE_CFG_PE_13_CFG_PE_13_FIELDS_PER_REG 1
#define MAGE_CFG_PE_13_MULTIREG_COUNT 1

// Configuration for PE 13
#define MAGE_CFG_PE_13_REG_OFFSET 0x50

// Configuration for PE 20 (common parameters)
#define MAGE_CFG_PE_20_CFG_PE_20_FIELD_WIDTH 32
#define MAGE_CFG_PE_20_CFG_PE_20_FIELDS_PER_REG 1
#define MAGE_CFG_PE_20_MULTIREG_COUNT 1

// Configuration for PE 20
#define MAGE_CFG_PE_20_REG_OFFSET 0x54

// Configuration for PE 21 (common parameters)
#define MAGE_CFG_PE_21_CFG_PE_21_FIELD_WIDTH 32
#define MAGE_CFG_PE_21_CFG_PE_21_FIELDS_PER_REG 1
#define MAGE_CFG_PE_21_MULTIREG_COUNT 1

// Configuration for PE 21
#define MAGE_CFG_PE_21_REG_OFFSET 0x58

// Configuration for PE 22 (common parameters)
#define MAGE_CFG_PE_22_CFG_PE_22_FIELD_WIDTH 32
#define MAGE_CFG_PE_22_CFG_PE_22_FIELDS_PER_REG 1
#define MAGE_CFG_PE_22_MULTIREG_COUNT 1

// Configuration for PE 22
#define MAGE_CFG_PE_22_REG_OFFSET 0x5c

// Configuration for PE 23 (common parameters)
#define MAGE_CFG_PE_23_CFG_PE_23_FIELD_WIDTH 32
#define MAGE_CFG_PE_23_CFG_PE_23_FIELDS_PER_REG 1
#define MAGE_CFG_PE_23_MULTIREG_COUNT 1

// Configuration for PE 23
#define MAGE_CFG_PE_23_REG_OFFSET 0x60

// Configuration for PE 30 (common parameters)
#define MAGE_CFG_PE_30_CFG_PE_30_FIELD_WIDTH 32
#define MAGE_CFG_PE_30_CFG_PE_30_FIELDS_PER_REG 1
#define MAGE_CFG_PE_30_MULTIREG_COUNT 1

// Configuration for PE 30
#define MAGE_CFG_PE_30_REG_OFFSET 0x64

// Configuration for PE 31 (common parameters)
#define MAGE_CFG_PE_31_CFG_PE_31_FIELD_WIDTH 32
#define MAGE_CFG_PE_31_CFG_PE_31_FIELDS_PER_REG 1
#define MAGE_CFG_PE_31_MULTIREG_COUNT 1

// Configuration for PE 31
#define MAGE_CFG_PE_31_REG_OFFSET 0x68

// Configuration for PE 32 (common parameters)
#define MAGE_CFG_PE_32_CFG_PE_32_FIELD_WIDTH 32
#define MAGE_CFG_PE_32_CFG_PE_32_FIELDS_PER_REG 1
#define MAGE_CFG_PE_32_MULTIREG_COUNT 1

// Configuration for PE 32
#define MAGE_CFG_PE_32_REG_OFFSET 0x6c

// Configuration for PE 33 (common parameters)
#define MAGE_CFG_PE_33_CFG_PE_33_FIELD_WIDTH 32
#define MAGE_CFG_PE_33_CFG_PE_33_FIELDS_PER_REG 1
#define MAGE_CFG_PE_33_MULTIREG_COUNT 1

// Configuration for PE 33
#define MAGE_CFG_PE_33_REG_OFFSET 0x70

// Selection signals for output of PEA rows (common parameters)
#define MAGE_SEL_OUT_PEA_ROW_0_0_SEL_OUT_PEA_ROW_0_0_FIELD_WIDTH 2
#define MAGE_SEL_OUT_PEA_ROW_0_0_SEL_OUT_PEA_ROW_0_0_FIELDS_PER_REG 16
#define MAGE_SEL_OUT_PEA_ROW_0_0_MULTIREG_COUNT 1

// Selection signals for output of PEA rows
#define MAGE_SEL_OUT_PEA_ROW_0_0_REG_OFFSET 0x74
#define MAGE_SEL_OUT_PEA_ROW_0_0_SEL_OUT_PEA_ROW_0_0_0_MASK 0x3
#define MAGE_SEL_OUT_PEA_ROW_0_0_SEL_OUT_PEA_ROW_0_0_0_OFFSET 0
#define MAGE_SEL_OUT_PEA_ROW_0_0_SEL_OUT_PEA_ROW_0_0_0_FIELD \
  ((bitfield_field32_t) { .mask = MAGE_SEL_OUT_PEA_ROW_0_0_SEL_OUT_PEA_ROW_0_0_0_MASK, .index = MAGE_SEL_OUT_PEA_ROW_0_0_SEL_OUT_PEA_ROW_0_0_0_OFFSET })

// Selection signals for output of PEA rows (common parameters)
#define MAGE_SEL_OUT_PEA_ROW_0_1_SEL_OUT_PEA_ROW_0_1_FIELD_WIDTH 2
#define MAGE_SEL_OUT_PEA_ROW_0_1_SEL_OUT_PEA_ROW_0_1_FIELDS_PER_REG 16
#define MAGE_SEL_OUT_PEA_ROW_0_1_MULTIREG_COUNT 1

// Selection signals for output of PEA rows
#define MAGE_SEL_OUT_PEA_ROW_0_1_REG_OFFSET 0x78
#define MAGE_SEL_OUT_PEA_ROW_0_1_SEL_OUT_PEA_ROW_0_1_0_MASK 0x3
#define MAGE_SEL_OUT_PEA_ROW_0_1_SEL_OUT_PEA_ROW_0_1_0_OFFSET 0
#define MAGE_SEL_OUT_PEA_ROW_0_1_SEL_OUT_PEA_ROW_0_1_0_FIELD \
  ((bitfield_field32_t) { .mask = MAGE_SEL_OUT_PEA_ROW_0_1_SEL_OUT_PEA_ROW_0_1_0_MASK, .index = MAGE_SEL_OUT_PEA_ROW_0_1_SEL_OUT_PEA_ROW_0_1_0_OFFSET })

// Selection signals for output of PEA rows (common parameters)
#define MAGE_SEL_OUT_PEA_ROW_1_0_SEL_OUT_PEA_ROW_1_0_FIELD_WIDTH 2
#define MAGE_SEL_OUT_PEA_ROW_1_0_SEL_OUT_PEA_ROW_1_0_FIELDS_PER_REG 16
#define MAGE_SEL_OUT_PEA_ROW_1_0_MULTIREG_COUNT 1

// Selection signals for output of PEA rows
#define MAGE_SEL_OUT_PEA_ROW_1_0_REG_OFFSET 0x7c
#define MAGE_SEL_OUT_PEA_ROW_1_0_SEL_OUT_PEA_ROW_1_0_0_MASK 0x3
#define MAGE_SEL_OUT_PEA_ROW_1_0_SEL_OUT_PEA_ROW_1_0_0_OFFSET 0
#define MAGE_SEL_OUT_PEA_ROW_1_0_SEL_OUT_PEA_ROW_1_0_0_FIELD \
  ((bitfield_field32_t) { .mask = MAGE_SEL_OUT_PEA_ROW_1_0_SEL_OUT_PEA_ROW_1_0_0_MASK, .index = MAGE_SEL_OUT_PEA_ROW_1_0_SEL_OUT_PEA_ROW_1_0_0_OFFSET })

// Selection signals for output of PEA rows (common parameters)
#define MAGE_SEL_OUT_PEA_ROW_1_1_SEL_OUT_PEA_ROW_1_1_FIELD_WIDTH 2
#define MAGE_SEL_OUT_PEA_ROW_1_1_SEL_OUT_PEA_ROW_1_1_FIELDS_PER_REG 16
#define MAGE_SEL_OUT_PEA_ROW_1_1_MULTIREG_COUNT 1

// Selection signals for output of PEA rows
#define MAGE_SEL_OUT_PEA_ROW_1_1_REG_OFFSET 0x80
#define MAGE_SEL_OUT_PEA_ROW_1_1_SEL_OUT_PEA_ROW_1_1_0_MASK 0x3
#define MAGE_SEL_OUT_PEA_ROW_1_1_SEL_OUT_PEA_ROW_1_1_0_OFFSET 0
#define MAGE_SEL_OUT_PEA_ROW_1_1_SEL_OUT_PEA_ROW_1_1_0_FIELD \
  ((bitfield_field32_t) { .mask = MAGE_SEL_OUT_PEA_ROW_1_1_SEL_OUT_PEA_ROW_1_1_0_MASK, .index = MAGE_SEL_OUT_PEA_ROW_1_1_SEL_OUT_PEA_ROW_1_1_0_OFFSET })

// Selection signals for output of PEA rows (common parameters)
#define MAGE_SEL_OUT_PEA_ROW_2_0_SEL_OUT_PEA_ROW_2_0_FIELD_WIDTH 2
#define MAGE_SEL_OUT_PEA_ROW_2_0_SEL_OUT_PEA_ROW_2_0_FIELDS_PER_REG 16
#define MAGE_SEL_OUT_PEA_ROW_2_0_MULTIREG_COUNT 1

// Selection signals for output of PEA rows
#define MAGE_SEL_OUT_PEA_ROW_2_0_REG_OFFSET 0x84
#define MAGE_SEL_OUT_PEA_ROW_2_0_SEL_OUT_PEA_ROW_2_0_0_MASK 0x3
#define MAGE_SEL_OUT_PEA_ROW_2_0_SEL_OUT_PEA_ROW_2_0_0_OFFSET 0
#define MAGE_SEL_OUT_PEA_ROW_2_0_SEL_OUT_PEA_ROW_2_0_0_FIELD \
  ((bitfield_field32_t) { .mask = MAGE_SEL_OUT_PEA_ROW_2_0_SEL_OUT_PEA_ROW_2_0_0_MASK, .index = MAGE_SEL_OUT_PEA_ROW_2_0_SEL_OUT_PEA_ROW_2_0_0_OFFSET })

// Selection signals for output of PEA rows (common parameters)
#define MAGE_SEL_OUT_PEA_ROW_2_1_SEL_OUT_PEA_ROW_2_1_FIELD_WIDTH 2
#define MAGE_SEL_OUT_PEA_ROW_2_1_SEL_OUT_PEA_ROW_2_1_FIELDS_PER_REG 16
#define MAGE_SEL_OUT_PEA_ROW_2_1_MULTIREG_COUNT 1

// Selection signals for output of PEA rows
#define MAGE_SEL_OUT_PEA_ROW_2_1_REG_OFFSET 0x88
#define MAGE_SEL_OUT_PEA_ROW_2_1_SEL_OUT_PEA_ROW_2_1_0_MASK 0x3
#define MAGE_SEL_OUT_PEA_ROW_2_1_SEL_OUT_PEA_ROW_2_1_0_OFFSET 0
#define MAGE_SEL_OUT_PEA_ROW_2_1_SEL_OUT_PEA_ROW_2_1_0_FIELD \
  ((bitfield_field32_t) { .mask = MAGE_SEL_OUT_PEA_ROW_2_1_SEL_OUT_PEA_ROW_2_1_0_MASK, .index = MAGE_SEL_OUT_PEA_ROW_2_1_SEL_OUT_PEA_ROW_2_1_0_OFFSET })

// Selection signals for output of PEA rows (common parameters)
#define MAGE_SEL_OUT_PEA_ROW_3_0_SEL_OUT_PEA_ROW_3_0_FIELD_WIDTH 2
#define MAGE_SEL_OUT_PEA_ROW_3_0_SEL_OUT_PEA_ROW_3_0_FIELDS_PER_REG 16
#define MAGE_SEL_OUT_PEA_ROW_3_0_MULTIREG_COUNT 1

// Selection signals for output of PEA rows
#define MAGE_SEL_OUT_PEA_ROW_3_0_REG_OFFSET 0x8c
#define MAGE_SEL_OUT_PEA_ROW_3_0_SEL_OUT_PEA_ROW_3_0_0_MASK 0x3
#define MAGE_SEL_OUT_PEA_ROW_3_0_SEL_OUT_PEA_ROW_3_0_0_OFFSET 0
#define MAGE_SEL_OUT_PEA_ROW_3_0_SEL_OUT_PEA_ROW_3_0_0_FIELD \
  ((bitfield_field32_t) { .mask = MAGE_SEL_OUT_PEA_ROW_3_0_SEL_OUT_PEA_ROW_3_0_0_MASK, .index = MAGE_SEL_OUT_PEA_ROW_3_0_SEL_OUT_PEA_ROW_3_0_0_OFFSET })

// Selection signals for output of PEA rows (common parameters)
#define MAGE_SEL_OUT_PEA_ROW_3_1_SEL_OUT_PEA_ROW_3_1_FIELD_WIDTH 2
#define MAGE_SEL_OUT_PEA_ROW_3_1_SEL_OUT_PEA_ROW_3_1_FIELDS_PER_REG 16
#define MAGE_SEL_OUT_PEA_ROW_3_1_MULTIREG_COUNT 1

// Selection signals for output of PEA rows
#define MAGE_SEL_OUT_PEA_ROW_3_1_REG_OFFSET 0x90
#define MAGE_SEL_OUT_PEA_ROW_3_1_SEL_OUT_PEA_ROW_3_1_0_MASK 0x3
#define MAGE_SEL_OUT_PEA_ROW_3_1_SEL_OUT_PEA_ROW_3_1_0_OFFSET 0
#define MAGE_SEL_OUT_PEA_ROW_3_1_SEL_OUT_PEA_ROW_3_1_0_FIELD \
  ((bitfield_field32_t) { .mask = MAGE_SEL_OUT_PEA_ROW_3_1_SEL_OUT_PEA_ROW_3_1_0_MASK, .index = MAGE_SEL_OUT_PEA_ROW_3_1_SEL_OUT_PEA_ROW_3_1_0_OFFSET })

// Selection signals for load streams of AGE 00 (common parameters)
#define MAGE_SEL_LOAD_STREAM_AGE_0_0_SEL_LOAD_STREAM_AGE_0_0_FIELD_WIDTH 1
#define MAGE_SEL_LOAD_STREAM_AGE_0_0_SEL_LOAD_STREAM_AGE_0_0_FIELDS_PER_REG 32
#define MAGE_SEL_LOAD_STREAM_AGE_0_0_MULTIREG_COUNT 1

// Selection signals for load streams of AGE 00
#define MAGE_SEL_LOAD_STREAM_AGE_0_0_REG_OFFSET 0x94
#define MAGE_SEL_LOAD_STREAM_AGE_0_0_SEL_LOAD_STREAM_AGE_0_0_0_BIT 0

// Selection signals for load streams of AGE 01 (common parameters)
#define MAGE_SEL_LOAD_STREAM_AGE_0_1_SEL_LOAD_STREAM_AGE_0_1_FIELD_WIDTH 1
#define MAGE_SEL_LOAD_STREAM_AGE_0_1_SEL_LOAD_STREAM_AGE_0_1_FIELDS_PER_REG 32
#define MAGE_SEL_LOAD_STREAM_AGE_0_1_MULTIREG_COUNT 1

// Selection signals for load streams of AGE 01
#define MAGE_SEL_LOAD_STREAM_AGE_0_1_REG_OFFSET 0x98
#define MAGE_SEL_LOAD_STREAM_AGE_0_1_SEL_LOAD_STREAM_AGE_0_1_0_BIT 0

// Selection signals for load streams of AGE 10 (common parameters)
#define MAGE_SEL_LOAD_STREAM_AGE_1_0_SEL_LOAD_STREAM_AGE_1_0_FIELD_WIDTH 1
#define MAGE_SEL_LOAD_STREAM_AGE_1_0_SEL_LOAD_STREAM_AGE_1_0_FIELDS_PER_REG 32
#define MAGE_SEL_LOAD_STREAM_AGE_1_0_MULTIREG_COUNT 1

// Selection signals for load streams of AGE 10
#define MAGE_SEL_LOAD_STREAM_AGE_1_0_REG_OFFSET 0x9c
#define MAGE_SEL_LOAD_STREAM_AGE_1_0_SEL_LOAD_STREAM_AGE_1_0_0_BIT 0

// Selection signals for load streams of AGE 11 (common parameters)
#define MAGE_SEL_LOAD_STREAM_AGE_1_1_SEL_LOAD_STREAM_AGE_1_1_FIELD_WIDTH 1
#define MAGE_SEL_LOAD_STREAM_AGE_1_1_SEL_LOAD_STREAM_AGE_1_1_FIELDS_PER_REG 32
#define MAGE_SEL_LOAD_STREAM_AGE_1_1_MULTIREG_COUNT 1

// Selection signals for load streams of AGE 11
#define MAGE_SEL_LOAD_STREAM_AGE_1_1_REG_OFFSET 0xa0
#define MAGE_SEL_LOAD_STREAM_AGE_1_1_SEL_LOAD_STREAM_AGE_1_1_0_BIT 0

// Selection signals for load streams of AGE 20 (common parameters)
#define MAGE_SEL_LOAD_STREAM_AGE_2_0_SEL_LOAD_STREAM_AGE_2_0_FIELD_WIDTH 1
#define MAGE_SEL_LOAD_STREAM_AGE_2_0_SEL_LOAD_STREAM_AGE_2_0_FIELDS_PER_REG 32
#define MAGE_SEL_LOAD_STREAM_AGE_2_0_MULTIREG_COUNT 1

// Selection signals for load streams of AGE 20
#define MAGE_SEL_LOAD_STREAM_AGE_2_0_REG_OFFSET 0xa4
#define MAGE_SEL_LOAD_STREAM_AGE_2_0_SEL_LOAD_STREAM_AGE_2_0_0_BIT 0

// Selection signals for load streams of AGE 21 (common parameters)
#define MAGE_SEL_LOAD_STREAM_AGE_2_1_SEL_LOAD_STREAM_AGE_2_1_FIELD_WIDTH 1
#define MAGE_SEL_LOAD_STREAM_AGE_2_1_SEL_LOAD_STREAM_AGE_2_1_FIELDS_PER_REG 32
#define MAGE_SEL_LOAD_STREAM_AGE_2_1_MULTIREG_COUNT 1

// Selection signals for load streams of AGE 21
#define MAGE_SEL_LOAD_STREAM_AGE_2_1_REG_OFFSET 0xa8
#define MAGE_SEL_LOAD_STREAM_AGE_2_1_SEL_LOAD_STREAM_AGE_2_1_0_BIT 0

// Selection signals for load streams of AGE 30 (common parameters)
#define MAGE_SEL_LOAD_STREAM_AGE_3_0_SEL_LOAD_STREAM_AGE_3_0_FIELD_WIDTH 1
#define MAGE_SEL_LOAD_STREAM_AGE_3_0_SEL_LOAD_STREAM_AGE_3_0_FIELDS_PER_REG 32
#define MAGE_SEL_LOAD_STREAM_AGE_3_0_MULTIREG_COUNT 1

// Selection signals for load streams of AGE 30
#define MAGE_SEL_LOAD_STREAM_AGE_3_0_REG_OFFSET 0xac
#define MAGE_SEL_LOAD_STREAM_AGE_3_0_SEL_LOAD_STREAM_AGE_3_0_0_BIT 0

// Selection signals for load streams of AGE 31 (common parameters)
#define MAGE_SEL_LOAD_STREAM_AGE_3_1_SEL_LOAD_STREAM_AGE_3_1_FIELD_WIDTH 1
#define MAGE_SEL_LOAD_STREAM_AGE_3_1_SEL_LOAD_STREAM_AGE_3_1_FIELDS_PER_REG 32
#define MAGE_SEL_LOAD_STREAM_AGE_3_1_MULTIREG_COUNT 1

// Selection signals for load streams of AGE 31
#define MAGE_SEL_LOAD_STREAM_AGE_3_1_REG_OFFSET 0xb0
#define MAGE_SEL_LOAD_STREAM_AGE_3_1_SEL_LOAD_STREAM_AGE_3_1_0_BIT 0

// Selection signals for store streams of AGE 00 (common parameters)
#define MAGE_SEL_STORE_STREAM_AGE_0_0_SEL_STORE_STREAM_AGE_0_0_FIELD_WIDTH 1
#define MAGE_SEL_STORE_STREAM_AGE_0_0_SEL_STORE_STREAM_AGE_0_0_FIELDS_PER_REG 32
#define MAGE_SEL_STORE_STREAM_AGE_0_0_MULTIREG_COUNT 1

// Selection signals for store streams of AGE 00
#define MAGE_SEL_STORE_STREAM_AGE_0_0_REG_OFFSET 0xb4
#define MAGE_SEL_STORE_STREAM_AGE_0_0_SEL_STORE_STREAM_AGE_0_0_0_BIT 0

// Selection signals for store streams of AGE 01 (common parameters)
#define MAGE_SEL_STORE_STREAM_AGE_0_1_SEL_STORE_STREAM_AGE_0_1_FIELD_WIDTH 1
#define MAGE_SEL_STORE_STREAM_AGE_0_1_SEL_STORE_STREAM_AGE_0_1_FIELDS_PER_REG 32
#define MAGE_SEL_STORE_STREAM_AGE_0_1_MULTIREG_COUNT 1

// Selection signals for store streams of AGE 01
#define MAGE_SEL_STORE_STREAM_AGE_0_1_REG_OFFSET 0xb8
#define MAGE_SEL_STORE_STREAM_AGE_0_1_SEL_STORE_STREAM_AGE_0_1_0_BIT 0

// Selection signals for store streams of AGE 10 (common parameters)
#define MAGE_SEL_STORE_STREAM_AGE_1_0_SEL_STORE_STREAM_AGE_1_0_FIELD_WIDTH 1
#define MAGE_SEL_STORE_STREAM_AGE_1_0_SEL_STORE_STREAM_AGE_1_0_FIELDS_PER_REG 32
#define MAGE_SEL_STORE_STREAM_AGE_1_0_MULTIREG_COUNT 1

// Selection signals for store streams of AGE 10
#define MAGE_SEL_STORE_STREAM_AGE_1_0_REG_OFFSET 0xbc
#define MAGE_SEL_STORE_STREAM_AGE_1_0_SEL_STORE_STREAM_AGE_1_0_0_BIT 0

// Selection signals for store streams of AGE 11 (common parameters)
#define MAGE_SEL_STORE_STREAM_AGE_1_1_SEL_STORE_STREAM_AGE_1_1_FIELD_WIDTH 1
#define MAGE_SEL_STORE_STREAM_AGE_1_1_SEL_STORE_STREAM_AGE_1_1_FIELDS_PER_REG 32
#define MAGE_SEL_STORE_STREAM_AGE_1_1_MULTIREG_COUNT 1

// Selection signals for store streams of AGE 11
#define MAGE_SEL_STORE_STREAM_AGE_1_1_REG_OFFSET 0xc0
#define MAGE_SEL_STORE_STREAM_AGE_1_1_SEL_STORE_STREAM_AGE_1_1_0_BIT 0

// Selection signals for store streams of AGE 20 (common parameters)
#define MAGE_SEL_STORE_STREAM_AGE_2_0_SEL_STORE_STREAM_AGE_2_0_FIELD_WIDTH 1
#define MAGE_SEL_STORE_STREAM_AGE_2_0_SEL_STORE_STREAM_AGE_2_0_FIELDS_PER_REG 32
#define MAGE_SEL_STORE_STREAM_AGE_2_0_MULTIREG_COUNT 1

// Selection signals for store streams of AGE 20
#define MAGE_SEL_STORE_STREAM_AGE_2_0_REG_OFFSET 0xc4
#define MAGE_SEL_STORE_STREAM_AGE_2_0_SEL_STORE_STREAM_AGE_2_0_0_BIT 0

// Selection signals for store streams of AGE 21 (common parameters)
#define MAGE_SEL_STORE_STREAM_AGE_2_1_SEL_STORE_STREAM_AGE_2_1_FIELD_WIDTH 1
#define MAGE_SEL_STORE_STREAM_AGE_2_1_SEL_STORE_STREAM_AGE_2_1_FIELDS_PER_REG 32
#define MAGE_SEL_STORE_STREAM_AGE_2_1_MULTIREG_COUNT 1

// Selection signals for store streams of AGE 21
#define MAGE_SEL_STORE_STREAM_AGE_2_1_REG_OFFSET 0xc8
#define MAGE_SEL_STORE_STREAM_AGE_2_1_SEL_STORE_STREAM_AGE_2_1_0_BIT 0

// Selection signals for store streams of AGE 30 (common parameters)
#define MAGE_SEL_STORE_STREAM_AGE_3_0_SEL_STORE_STREAM_AGE_3_0_FIELD_WIDTH 1
#define MAGE_SEL_STORE_STREAM_AGE_3_0_SEL_STORE_STREAM_AGE_3_0_FIELDS_PER_REG 32
#define MAGE_SEL_STORE_STREAM_AGE_3_0_MULTIREG_COUNT 1

// Selection signals for store streams of AGE 30
#define MAGE_SEL_STORE_STREAM_AGE_3_0_REG_OFFSET 0xcc
#define MAGE_SEL_STORE_STREAM_AGE_3_0_SEL_STORE_STREAM_AGE_3_0_0_BIT 0

// Selection signals for store streams of AGE 31 (common parameters)
#define MAGE_SEL_STORE_STREAM_AGE_3_1_SEL_STORE_STREAM_AGE_3_1_FIELD_WIDTH 1
#define MAGE_SEL_STORE_STREAM_AGE_3_1_SEL_STORE_STREAM_AGE_3_1_FIELDS_PER_REG 32
#define MAGE_SEL_STORE_STREAM_AGE_3_1_MULTIREG_COUNT 1

// Selection signals for store streams of AGE 31
#define MAGE_SEL_STORE_STREAM_AGE_3_1_REG_OFFSET 0xd0
#define MAGE_SEL_STORE_STREAM_AGE_3_1_SEL_STORE_STREAM_AGE_3_1_0_BIT 0

// Configuration for AGE 0 of Stream 0 (common parameters)
#define MAGE_CFG_MAGE_S0_AGE0_AGE_INST_FIELD_WIDTH 32
#define MAGE_CFG_MAGE_S0_AGE0_AGE_INST_FIELDS_PER_REG 1
#define MAGE_CFG_MAGE_S0_AGE0_MULTIREG_COUNT 1

// Configuration for AGE 0 of Stream 0
#define MAGE_CFG_MAGE_S0_AGE0_REG_OFFSET 0xd4

// Configuration for AGE 1 of Stream 0 (common parameters)
#define MAGE_CFG_MAGE_S0_AGE1_AGE_INST_FIELD_WIDTH 32
#define MAGE_CFG_MAGE_S0_AGE1_AGE_INST_FIELDS_PER_REG 1
#define MAGE_CFG_MAGE_S0_AGE1_MULTIREG_COUNT 1

// Configuration for AGE 1 of Stream 0
#define MAGE_CFG_MAGE_S0_AGE1_REG_OFFSET 0xd8

// Configuration for AGE 0 of Stream 1 (common parameters)
#define MAGE_CFG_MAGE_S1_AGE0_AGE_INST_FIELD_WIDTH 32
#define MAGE_CFG_MAGE_S1_AGE0_AGE_INST_FIELDS_PER_REG 1
#define MAGE_CFG_MAGE_S1_AGE0_MULTIREG_COUNT 1

// Configuration for AGE 0 of Stream 1
#define MAGE_CFG_MAGE_S1_AGE0_REG_OFFSET 0xdc

// Configuration for AGE 1 of Stream 1 (common parameters)
#define MAGE_CFG_MAGE_S1_AGE1_AGE_INST_FIELD_WIDTH 32
#define MAGE_CFG_MAGE_S1_AGE1_AGE_INST_FIELDS_PER_REG 1
#define MAGE_CFG_MAGE_S1_AGE1_MULTIREG_COUNT 1

// Configuration for AGE 1 of Stream 1
#define MAGE_CFG_MAGE_S1_AGE1_REG_OFFSET 0xe0

// Configuration for AGE 0 of Stream 2 (common parameters)
#define MAGE_CFG_MAGE_S2_AGE0_AGE_INST_FIELD_WIDTH 32
#define MAGE_CFG_MAGE_S2_AGE0_AGE_INST_FIELDS_PER_REG 1
#define MAGE_CFG_MAGE_S2_AGE0_MULTIREG_COUNT 1

// Configuration for AGE 0 of Stream 2
#define MAGE_CFG_MAGE_S2_AGE0_REG_OFFSET 0xe4

// Configuration for AGE 1 of Stream 2 (common parameters)
#define MAGE_CFG_MAGE_S2_AGE1_AGE_INST_FIELD_WIDTH 32
#define MAGE_CFG_MAGE_S2_AGE1_AGE_INST_FIELDS_PER_REG 1
#define MAGE_CFG_MAGE_S2_AGE1_MULTIREG_COUNT 1

// Configuration for AGE 1 of Stream 2
#define MAGE_CFG_MAGE_S2_AGE1_REG_OFFSET 0xe8

// Configuration for AGE 0 of Stream 3 (common parameters)
#define MAGE_CFG_MAGE_S3_AGE0_AGE_INST_FIELD_WIDTH 32
#define MAGE_CFG_MAGE_S3_AGE0_AGE_INST_FIELDS_PER_REG 1
#define MAGE_CFG_MAGE_S3_AGE0_MULTIREG_COUNT 1

// Configuration for AGE 0 of Stream 3
#define MAGE_CFG_MAGE_S3_AGE0_REG_OFFSET 0xec

// Configuration for AGE 1 of Stream 3 (common parameters)
#define MAGE_CFG_MAGE_S3_AGE1_AGE_INST_FIELD_WIDTH 32
#define MAGE_CFG_MAGE_S3_AGE1_AGE_INST_FIELDS_PER_REG 1
#define MAGE_CFG_MAGE_S3_AGE1_MULTIREG_COUNT 1

// Configuration for AGE 1 of Stream 3
#define MAGE_CFG_MAGE_S3_AGE1_REG_OFFSET 0xf0

// PEs constants (common parameters)
#define MAGE_PEA_CONSTANTS_CONSTANT_FIELD_WIDTH 32
#define MAGE_PEA_CONSTANTS_CONSTANT_FIELDS_PER_REG 1
#define MAGE_PEA_CONSTANTS_MULTIREG_COUNT 16

// PEs constants
#define MAGE_PEA_CONSTANTS_0_REG_OFFSET 0xf4

// PEs constants
#define MAGE_PEA_CONSTANTS_1_REG_OFFSET 0xf8

// PEs constants
#define MAGE_PEA_CONSTANTS_2_REG_OFFSET 0xfc

// PEs constants
#define MAGE_PEA_CONSTANTS_3_REG_OFFSET 0x100

// PEs constants
#define MAGE_PEA_CONSTANTS_4_REG_OFFSET 0x104

// PEs constants
#define MAGE_PEA_CONSTANTS_5_REG_OFFSET 0x108

// PEs constants
#define MAGE_PEA_CONSTANTS_6_REG_OFFSET 0x10c

// PEs constants
#define MAGE_PEA_CONSTANTS_7_REG_OFFSET 0x110

// PEs constants
#define MAGE_PEA_CONSTANTS_8_REG_OFFSET 0x114

// PEs constants
#define MAGE_PEA_CONSTANTS_9_REG_OFFSET 0x118

// PEs constants
#define MAGE_PEA_CONSTANTS_10_REG_OFFSET 0x11c

// PEs constants
#define MAGE_PEA_CONSTANTS_11_REG_OFFSET 0x120

// PEs constants
#define MAGE_PEA_CONSTANTS_12_REG_OFFSET 0x124

// PEs constants
#define MAGE_PEA_CONSTANTS_13_REG_OFFSET 0x128

// PEs constants
#define MAGE_PEA_CONSTANTS_14_REG_OFFSET 0x12c

// PEs constants
#define MAGE_PEA_CONSTANTS_15_REG_OFFSET 0x130

// PEs RF (common parameters)
#define MAGE_PEA_RF_CONSTANT_FIELD_WIDTH 32
#define MAGE_PEA_RF_CONSTANT_FIELDS_PER_REG 1
#define MAGE_PEA_RF_MULTIREG_COUNT 16

// PEs RF
#define MAGE_PEA_RF_0_REG_OFFSET 0x134

// PEs RF
#define MAGE_PEA_RF_1_REG_OFFSET 0x138

// PEs RF
#define MAGE_PEA_RF_2_REG_OFFSET 0x13c

// PEs RF
#define MAGE_PEA_RF_3_REG_OFFSET 0x140

// PEs RF
#define MAGE_PEA_RF_4_REG_OFFSET 0x144

// PEs RF
#define MAGE_PEA_RF_5_REG_OFFSET 0x148

// PEs RF
#define MAGE_PEA_RF_6_REG_OFFSET 0x14c

// PEs RF
#define MAGE_PEA_RF_7_REG_OFFSET 0x150

// PEs RF
#define MAGE_PEA_RF_8_REG_OFFSET 0x154

// PEs RF
#define MAGE_PEA_RF_9_REG_OFFSET 0x158

// PEs RF
#define MAGE_PEA_RF_10_REG_OFFSET 0x15c

// PEs RF
#define MAGE_PEA_RF_11_REG_OFFSET 0x160

// PEs RF
#define MAGE_PEA_RF_12_REG_OFFSET 0x164

// PEs RF
#define MAGE_PEA_RF_13_REG_OFFSET 0x168

// PEs RF
#define MAGE_PEA_RF_14_REG_OFFSET 0x16c

// PEs RF
#define MAGE_PEA_RF_15_REG_OFFSET 0x170

// Configuration for AGE IV constraints (common parameters)
// Configuration for AGE IV constraints
#define MAGE_AGE_IV_CONSTRAINTS_0_REG_OFFSET 0x174
#define MAGE_AGE_IV_CONSTRAINTS_0_C0_0_MASK 0xff
#define MAGE_AGE_IV_CONSTRAINTS_0_C0_0_OFFSET 0
#define MAGE_AGE_IV_CONSTRAINTS_0_C0_0_FIELD \
  ((bitfield_field32_t) { .mask = MAGE_AGE_IV_CONSTRAINTS_0_C0_0_MASK, .index = MAGE_AGE_IV_CONSTRAINTS_0_C0_0_OFFSET })
#define MAGE_AGE_IV_CONSTRAINTS_0_C1_0_MASK 0xff
#define MAGE_AGE_IV_CONSTRAINTS_0_C1_0_OFFSET 8
#define MAGE_AGE_IV_CONSTRAINTS_0_C1_0_FIELD \
  ((bitfield_field32_t) { .mask = MAGE_AGE_IV_CONSTRAINTS_0_C1_0_MASK, .index = MAGE_AGE_IV_CONSTRAINTS_0_C1_0_OFFSET })
#define MAGE_AGE_IV_CONSTRAINTS_0_C2_0_MASK 0xff
#define MAGE_AGE_IV_CONSTRAINTS_0_C2_0_OFFSET 16
#define MAGE_AGE_IV_CONSTRAINTS_0_C2_0_FIELD \
  ((bitfield_field32_t) { .mask = MAGE_AGE_IV_CONSTRAINTS_0_C2_0_MASK, .index = MAGE_AGE_IV_CONSTRAINTS_0_C2_0_OFFSET })
#define MAGE_AGE_IV_CONSTRAINTS_0_C3_0_MASK 0xff
#define MAGE_AGE_IV_CONSTRAINTS_0_C3_0_OFFSET 24
#define MAGE_AGE_IV_CONSTRAINTS_0_C3_0_FIELD \
  ((bitfield_field32_t) { .mask = MAGE_AGE_IV_CONSTRAINTS_0_C3_0_MASK, .index = MAGE_AGE_IV_CONSTRAINTS_0_C3_0_OFFSET })

// Configuration for AGE IV constraints
#define MAGE_AGE_IV_CONSTRAINTS_1_REG_OFFSET 0x178
#define MAGE_AGE_IV_CONSTRAINTS_1_C0_1_MASK 0xff
#define MAGE_AGE_IV_CONSTRAINTS_1_C0_1_OFFSET 0
#define MAGE_AGE_IV_CONSTRAINTS_1_C0_1_FIELD \
  ((bitfield_field32_t) { .mask = MAGE_AGE_IV_CONSTRAINTS_1_C0_1_MASK, .index = MAGE_AGE_IV_CONSTRAINTS_1_C0_1_OFFSET })
#define MAGE_AGE_IV_CONSTRAINTS_1_C1_1_MASK 0xff
#define MAGE_AGE_IV_CONSTRAINTS_1_C1_1_OFFSET 8
#define MAGE_AGE_IV_CONSTRAINTS_1_C1_1_FIELD \
  ((bitfield_field32_t) { .mask = MAGE_AGE_IV_CONSTRAINTS_1_C1_1_MASK, .index = MAGE_AGE_IV_CONSTRAINTS_1_C1_1_OFFSET })
#define MAGE_AGE_IV_CONSTRAINTS_1_C2_1_MASK 0xff
#define MAGE_AGE_IV_CONSTRAINTS_1_C2_1_OFFSET 16
#define MAGE_AGE_IV_CONSTRAINTS_1_C2_1_FIELD \
  ((bitfield_field32_t) { .mask = MAGE_AGE_IV_CONSTRAINTS_1_C2_1_MASK, .index = MAGE_AGE_IV_CONSTRAINTS_1_C2_1_OFFSET })
#define MAGE_AGE_IV_CONSTRAINTS_1_C3_1_MASK 0xff
#define MAGE_AGE_IV_CONSTRAINTS_1_C3_1_OFFSET 24
#define MAGE_AGE_IV_CONSTRAINTS_1_C3_1_FIELD \
  ((bitfield_field32_t) { .mask = MAGE_AGE_IV_CONSTRAINTS_1_C3_1_MASK, .index = MAGE_AGE_IV_CONSTRAINTS_1_C3_1_OFFSET })

#ifdef __cplusplus
}  // extern "C"
#endif
#endif  // _MAGE_REG_DEFS_
// End generated register defines for mage