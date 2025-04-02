#ifndef _MAGE_H_
#define _MAGE_H_

#include <stdint.h>

#include "mage_regs.h"

// kernel memory size
#define KMEM_SIZE 1
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

static inline void write_mage_register(uint32_t p_val, uint32_t p_addr, uint32_t p_mask, uint8_t p_sel);


/**
 * @brief Sets the PEA configuration.
 *
 * @param mage_pea_cfg The PEA configuration array that contains the configuration for each PE.
 */
void mage_set_pea_cfg(uint32_t mage_pea_cfg[MAGE_PEA_ROWS][MAGE_PEA_COLS][KMEM_SIZE]);

/**
 * @brief Sets the configuration for a specific PE.
 *
 * @param pe_cfg The PE configuration value.
 * @param pe_row The row index of the PE.
 * @param pe_col The column index of the PE.
 * @param time The time instant for configuration pe_cfg.
 */
void mage_set_pe_cfg(uint32_t pe_cfg, uint8_t pe_row, uint8_t pe_col, uint8_t time);

/**
 * @brief Sets the constants for each PE.
 *
 * @param pea_constants The PEA constants array.
 */
void mage_set_pea_constants(uint32_t pea_constants[MAGE_PEA_ROWS][MAGE_PEA_COLS]);

/**
 * @brief Sets a specific constant for a PE.
 *
 * @param pea_constant The constant value.
 * @param reg The register index.
 */
void mage_set_pe_constant(uint32_t pea_constant, uint8_t row, uint8_t col);

////////////////////////////////////////////////////////////////
//                                                            //
//                       Streaming Mage                       //
//                                                            //
////////////////////////////////////////////////////////////////
/**
 * @brief Sets the selector for the outputs of a column of PEA.
 *
 * @param sel_out The selectors for PEA columns.
 * @param pea_col PEA column.
 */
void mage_set_sel_out_pea_cols(uint8_t sel_out, uint8_t pea_col);

/**
 * @brief Sets the accumulation values for a PE.
 *
 * @param pe_acc_values The accumulation value.
 * @param pe_row PE row.
 * @param pe_col PE col.
 */
void mage_set_pe_acc_values(uint8_t acc_value, uint8_t pe_row, uint8_t pe_col);

/**
 * @brief Sets the selector for the outputs of PEA.
 *
 * @param sel_out The selectors for PEA output.
 */
void mage_set_sel_out_xbar(uint8_t sel_out);

/**
 * @brief Sets the configuration for Mage DMA channel.
 *
 * @param n_dma_ch Number of the DMA channel.
 * @param cfg DMA channel configuration.
 */
void mage_set_dma_cfg(uint8_t n_dma_ch, uint8_t cfg);

#ifdef __cplusplus
}
#endif

#endif // MAGE_H_