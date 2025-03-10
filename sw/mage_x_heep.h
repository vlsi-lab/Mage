#ifndef _MAGE_X_HEEP_
#define _MAGE_X_HEEP_

#ifdef __cplusplus
extern "C"
{
#endif // __cplusplus

//#include "core_v_mini_mcu.h"
#include "mage_regs.h"

#define EXT_XBAR_NMASTER 4
#define EXT_XBAR_NSLAVE 1


#define MAGE_PERIPH_START_ADDRESS (EXT_PERIPHERAL_START_ADDRESS + 0x0000000)
#define MAGE_PERIPH_SIZE 0x0001000
#define MAGE_PERIPH_END_ADDRESS (MAGE_PERIPH_START_ADDRESS + MAGE_PERIPH_SIZE)

// Processing Elements configuration
#define MAGE_PEA_CFG_START_ADDR (MAGE_PERIPH_START_ADDRESS + MAGE_CFG_PE_00_REG_OFFSET)
// Processing Elements constants
#define MAGE_PEA_CONSTANTS_START_ADDR (MAGE_PERIPH_START_ADDRESS + MAGE_PEA_CONSTANTS_0_REG_OFFSET)

////////////////////////////////////////////////////////////////
//                                                            //
//                       Streaming Mage                       //
//                                                            //
////////////////////////////////////////////////////////////////
// DMA configuration
#define MAGE_DMA_CFG_START_ADDR (MAGE_PERIPH_START_ADDRESS + MAGE_STREAM_DMA_CFG_REG_OFFSET)
// Column Result selection
#define MAGE_COL_RES_SEL_START_ADDR (MAGE_PERIPH_START_ADDRESS + MAGE_SEL_OUT_COL_PEA_REG_OFFSET)
// Accumulation values
#define MAGE_ACC_VALUE_START_ADDR (MAGE_PERIPH_START_ADDRESS + MAGE_ACC_VALUE_0_REG_OFFSET)


#ifdef __cplusplus
} // extern "C"
#endif // __cplusplus

#endif // _MAGE_X_HEEP_
