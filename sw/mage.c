#include <stddef.h>
#include <stdint.h>

#include "mage_regs.h"
#include "mage_x_heep.h"
#include "mage.h"

static inline void write_mage_register(uint32_t p_val, uint32_t p_addr, uint32_t p_mask, uint8_t p_sel){
  /*
   * An intermediate variable "value" is used to prevent writing twice into
   * the register.
   */
  uint32_t value = *((uint32_t *)p_addr);
  value &= ~(p_mask << p_sel);
  value |= (p_val & p_mask) << p_sel;
  *((uint32_t *)p_addr) = value;
}

/**
 * @brief Sets the PEA configuration.
 *
 * @param mage_pea_cfg The PEA configuration array that contains the configuration for each PE.
 */
void mage_set_pea_cfg(uint32_t mage_pea_cfg[MAGE_PEA_ROWS][MAGE_PEA_COLS][KMEM_SIZE]){
  int32_t *mage_pea_cfg_idx = (int32_t *)(MAGE_PEA_CFG_START_ADDR);
  for(uint8_t i = 0; i < MAGE_PEA_ROWS; i++){
    for(uint8_t j = 0; j < MAGE_PEA_COLS; j++){
      for(uint8_t k = 0; k < KMEM_SIZE; k++){
        mage_set_pe_cfg(mage_pea_cfg[i][j][k], i, j, k);
      }
    }
  }
}

/**
 * @brief Sets the configuration for a specific PE.
 *
 * @param pe_cfg The PE configuration value.
 * @param pe_row The row index of the PE.
 * @param pe_col The column index of the PE.
 * @param time The time instant for configuration pe_cfg.
 */
void mage_set_pe_cfg(uint32_t pe_cfg, uint8_t pe_row, uint8_t pe_col, uint8_t time){
  int32_t *mage_pe_cfg = ((int32_t *)(MAGE_PEA_CFG_START_ADDR)) + pe_row * MAGE_PEA_COLS + pe_col;
  write_mage_register(pe_cfg, mage_pe_cfg, 0xFFFFFFFF, 0);
}

/**
 * @brief Set the PEA constants.
 *
 * @param pea_constants PEA constants array.
 */
void mage_set_pea_constants(uint32_t pea_constants[MAGE_PEA_ROWS][MAGE_PEA_COLS]){
  int32_t *mage_pea_constants_idx = (int32_t *)(MAGE_PEA_CONSTANTS_START_ADDR);
  for(int i = 0; i < MAGE_PEA_COLS; i++){
    for(int j = 0; j < MAGE_PEA_ROWS; j++){
      mage_set_pe_constant(pea_constants[j][i], j, i);
    }
  }
}

/**
 * @brief Sets a specific constant for a PE.
 *
 * @param pea_constant The constant value.
 * @param reg The register index.
 */
void mage_set_pe_constant(uint32_t pe_constant, uint8_t pe_row, uint8_t pe_col){
  int32_t *mage_pea_constants = (int32_t *)(MAGE_PEA_CONSTANTS_START_ADDR);
  mage_pea_constants += pe_row * MAGE_PEA_COLS + pe_col;
  write_mage_register(pe_constant, mage_pea_constants, 0xFFFFFFFF, 0);
}


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
void mage_set_sel_out_pea_cols(uint8_t sel_out, uint8_t pea_col){
  int32_t *mage_sel_out_pea = (int32_t *)(MAGE_COL_RES_SEL_START_ADDR);
  write_mage_register(sel_out, mage_sel_out_pea, 0xFF, pea_col << 3);
}

/**
 * @brief Sets the accumulation values for a PE.
 *
 * @param pe_acc_values The accumulation value.
 * @param pe_row PE row.
 * @param pe_col PE col.
 */
void mage_set_pe_acc_values(uint8_t acc_value, uint8_t pe_row, uint8_t pe_col){
  int32_t *mage_acc_values_addr = (int32_t *)(MAGE_ACC_VALUES_START_ADDR);
  mage_acc_values_addr += pe_row;
  write_mage_register(acc_value, mage_acc_values_addr, 0xFF, pe_col << 3);
}

/**
 * @brief Sets the selector for the outputs of PEA.
 *
 * @param sel_out The selectors for PEA output.
 */
void mage_set_sel_out_xbar(uint8_t sel_out){
  int32_t *mage_sel_out_xbar = (int32_t *)(MAGE_OUT_XBAR_START_ADDR);
  *mage_sel_out_xbar = sel_out;
}

/**
 * @brief Sets the configuration for Mage DMA channel.
 *
 * @param n_dma_ch Number of the DMA channel.
 * @param cfg DMA channel configuration.
 */
void mage_set_dma_cfg(uint8_t n_dma_ch, uint8_t cfg){
  int32_t *mage_dma_cfg = (int32_t *)(MAGE_DMA_CFG_START_ADDR);
  write_mage_register(cfg, mage_dma_cfg, 0xFF, n_dma_ch << 3);
}

