#ifndef _MAGE_H_
#define _MAGE_H_

#include <stdint.h>

#include "mage_regs.h"

// kernel memory size
#define MAGE_KMEM_SIZE 1
// number of rows and columns of the PEA array
#define MAGE_PEA_ROWS 4
#define MAGE_PEA_COLS 4


////////////////////////////////////////////////////////////////
//                                                            //
//                       Streaming Mage                       //
//                                                            //
////////////////////////////////////////////////////////////////
// number of 32-bit registers used to store PE accumulation values
#define PEA_ACC_VALUES_SIZE 4

#ifdef __cplusplus
extern "C"
{
#endif
/**
 * @brief Sets the constants for each PE.
 *
 * @param pea_constants The PEA constants array.
 */
void mage_set_pea_constants(uint8_t pea_constants[MAGE_PEA_ROWS][MAGE_PEA_COLS]);

/**
 * @brief Sets a specific constant for a PE.
 *
 * @param pea_constant The constant value.
 * @param reg The register index.
 */
void mage_set_pe_constant(uint8_t pea_constant, uint8_t row, uint8_t col);

/**
 * @brief Sets the PEA configuration.
 *
 * @param mage_pea_cfg The PEA configuration array that contains the configuration for each PE.
 */
void mage_set_pea_cfg(uint32_t mage_pea_cfg[MAGE_PEA_ROWS][MAGE_PEA_COLS][MAGE_KMEM_SIZE]);

/**
 * @brief Sets the configuration for a specific PE.
 *
 * @param pe_cfg The PE configuration value.
 * @param pe_row The row index of the PE.
 * @param pe_col The column index of the PE.
 * @param n_reg The configuration register index.
 */
void mage_set_pe_cfg(uint32_t pe_cfg, uint32_t pe_row, uint32_t pe_col, uint32_t n_reg);

////////////////////////////////////////////////////////////////
//                                                            //
//                       Streaming Mage                       //
//                                                            //
////////////////////////////////////////////////////////////////
/**
 * @brief Sets the selectors for the outputs of PEA columns.
 *
 * @param sel_out_pea_cols The selectors for PEA columns.
 */
void mage_set_sel_out_pea_cols(uint32_t sel_out_pea_cols);

/**
 * @brief Sets the accumulation values for PEs.
 *
 * @param acc_values The accumulation values.
 */
void mage_set_acc_values(uint32_t acc_values[PEA_ACC_VALUES_SIZE]);

#ifdef __cplusplus
}
#endif

#endif // MAGE_CGRA_H_