#ifndef _MAGE_X_HEEP_
#define _MAGE_X_HEEP_

#ifdef __cplusplus
extern "C"
{
#endif // __cplusplus

#include "core_v_mini_mcu.h"
#include "mage_regs.h"

#define EXT_XBAR_NMASTER 4
#define EXT_XBAR_NSLAVE 1

%if enable_decoupling == str(1):
#define MAGE_START_ADDRESS (EXT_SLAVE_START_ADDRESS + 0x000000)
#define MAGE_SIZE 0x100000
#define MAGE_END_ADDRESS (MAGE_START_ADDRESS + MAGE_SIZE)
%endif

#define MAGE_PERIPH_START_ADDRESS (EXT_PERIPHERAL_START_ADDRESS + 0x0000000)
#define MAGE_PERIPH_SIZE 0x0001000
#define MAGE_PERIPH_END_ADDRESS (MAGE_PERIPH_START_ADDRESS + MAGE_PERIPH_SIZE)

// Processing Elements configuration
#define MAGE_PEA_CFG_START_ADDR (MAGE_PERIPH_START_ADDRESS + MAGE_CFG_PE_00_REG_OFFSET)
// Processing Elements constants
#define MAGE_PEA_CONSTANTS_START_ADDR (MAGE_PERIPH_START_ADDRESS + MAGE_PEA_CONSTANTS_0_REG_OFFSET)

%if enable_decoupling == str(1):
////////////////////////////////////////////////////////////////
//                                                            //
//                          DAE Mage                          //
//                                                            //
////////////////////////////////////////////////////////////////
#define MAGE_STATUS_START_ADDR (MAGE_PERIPH_START_ADDRESS + MAGE_STATUS_REG_OFFSET)
#define MAGE_GEN_CFG_START_ADDR (MAGE_PERIPH_START_ADDRESS + MAGE_GEN_CFG_REG_OFFSET)
#define MAGE_ILB_HWL_START_ADDR (MAGE_PERIPH_START_ADDRESS + MAGE_ILB_HWL_REG_OFFSET)
#define MAGE_FLB_HWL_START_ADDR (MAGE_PERIPH_START_ADDRESS + MAGE_FLB_HWL_REG_OFFSET)
#define MAGE_LI_HWL_START_ADDR (MAGE_PERIPH_START_ADDRESS + MAGE_INC_HWL_REG_OFFSET)
#define MAGE_STRIDES_START_ADDR (MAGE_PERIPH_START_ADDRESS + MAGE_STRIDES_0_REG_OFFSET)
#define MAGE_PKE_START_ADDR (MAGE_PERIPH_START_ADDRESS + MAGE_PKE_REG_OFFSET)
#define MAGE_PEA_CONTROL_SNT_ADDR (MAGE_PERIPH_START_ADDRESS + MAGE_PEA_CONTROL_SNT_REG_OFFSET)
#define MAGE_SEL_OUT_PEA_START_ADDR (MAGE_PERIPH_START_ADDRESS + MAGE_SEL_OUT_PEA_REG_OFFSET)
#define MAGE_LOAD_STREAM_START_ADDR (MAGE_PERIPH_START_ADDRESS + MAGE_L_STREAM_SEL_AGE_REG_OFFSET)
#define MAGE_STORE_STREAM_START_ADDR (MAGE_PERIPH_START_ADDRESS + MAGE_S_STREAM_SEL_AGE_REG_OFFSET)
#define MAGE_CFG_START_ADDR (MAGE_PERIPH_START_ADDRESS + MAGE_CFG_MAGE_S0_AGE0_REG_OFFSET)
#define MAGE_IV_CONSTRAINTS_START_ADDR (MAGE_PERIPH_START_ADDRESS + MAGE_AGE_IV_CONSTRAINTS_0_REG_OFFSET)

#define START_MAGE_BANK_0 MAGE_START_ADDRESS
#define START_MAGE_BANK_1 MAGE_START_ADDRESS + 0x1000
#define START_MAGE_BANK_2 MAGE_START_ADDRESS + 0x2000
#define START_MAGE_BANK_3 MAGE_START_ADDRESS + 0x3000
#define START_MAGE_BANK_4 MAGE_START_ADDRESS + 0x4000
#define START_MAGE_BANK_5 MAGE_START_ADDRESS + 0x5000
#define START_MAGE_BANK_6 MAGE_START_ADDRESS + 0x6000
#define START_MAGE_BANK_7 MAGE_START_ADDRESS + 0x7000

%endif
%if enable_streaming_interface == str(1):
////////////////////////////////////////////////////////////////
//                                                            //
//                       Streaming Mage                       //
//                                                            //
////////////////////////////////////////////////////////////////
// Column Result selection
#define MAGE_COL_RES_SEL_START_ADDR (HEEPATIA_MAGE_START_ADDRESS + MAGE_SEL_OUT_COL_PEA_REG_OFFSET)
// Accumulation values
#define MAGE_ACC_VALUES_START_ADDR (HEEPATIA_MAGE_START_ADDRESS + MAGE_ACC_VALUE_0_REG_OFFSET)
// Separate column management
#define MAGE_SEPARATE_COLS_START_ADDR (HEEPATIA_MAGE_START_ADDRESS + MAGE_SEPARATE_COLS_REG_OFFSET)
// Synch DMAs
#define MAGE_SYNCH_DMA_START_ADDR (HEEPATIA_MAGE_START_ADDRESS + MAGE_SYNCH_DMA_CH_REG_OFFSET)        
// Trans size DMA 0
#define MAGE_TRANS_SIZE_0_START_ADDR (HEEPATIA_MAGE_START_ADDRESS + MAGE_TRANS_SIZE_0_REG_OFFSET)       
// Trans size DMA 1
#define MAGE_TRANS_SIZE_1_START_ADDR (HEEPATIA_MAGE_START_ADDRESS + MAGE_TRANS_SIZE_1_REG_OFFSET)     
// Trans size DMA 2
#define MAGE_TRANS_SIZE_2_START_ADDR (HEEPATIA_MAGE_START_ADDRESS + MAGE_TRANS_SIZE_2_REG_OFFSET)     
// Trans size DMA 3
#define MAGE_TRANS_SIZE_3_START_ADDR (HEEPATIA_MAGE_START_ADDRESS + MAGE_TRANS_SIZE_3_REG_OFFSET)                                           
%if out_stream_xbar == str(1):
// Output xbar
#define MAGE_OUT_XBAR_START_ADDR (MAGE_PERIPH_START_ADDRESS + MAGE_STREAM_OUT_XBAR_SEL_REG_OFFSET)
%endif
%if in_stream_xbar == str(1):
// Output xbar
#define MAGE_IN_XBAR_START_ADDR (MAGE_PERIPH_START_ADDRESS + MAGE_STREAM_IN_XBAR_SEL_REG_OFFSET)
%endif
%endif

#ifdef __cplusplus
} // extern "C"
#endif // __cplusplus

#endif // _MAGE_X_HEEP_
