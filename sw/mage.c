#include <stddef.h>
#include <stdint.h>

#include "mage_regs.h"
#include "mage_x_heep.h"
#include "mage.h"

/**
 * @brief Sets the PEA configuration.
 *
 * @param mage_pea_cfg The PEA configuration array that contains the configuration for each PE.
 */
void mage_set_pea_cfg(uint32_t mage_pea_cfg[MAGE_PEA_ROWS][MAGE_PEA_COLS][MAGE_KMEM_SIZE]){
  int32_t *mage_pea_cfg_idx = (int32_t *)(MAGE_PEA_CFG_START_ADDR);
  for(int i = 0; i < MAGE_PEA_ROWS; i++){
    for(int j = 0; j < MAGE_PEA_COLS; j++){
      for(int k = 0; k < MAGE_KMEM_SIZE; k++){
        *mage_pea_cfg_idx = mage_pea_cfg[i][j][k];
        mage_pea_cfg_idx++;
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
 * @param n_reg The configuration register index.
 */
void mage_set_pe_cfg(uint32_t pe_cfg, uint32_t pe_row, uint32_t pe_col, uint32_t n_reg){
  int32_t *mage_pe_cfg = (int32_t *)(MAGE_PEA_CFG_START_ADDR);
  mage_pe_cfg += (pe_row * MAGE_PEA_COLS + pe_col) * MAGE_KMEM_SIZE + n_reg;
  *mage_pe_cfg = pe_cfg;
}

// TODO: remake this function
/**
 * @brief Set the PEA constants.
 *
 * @param pea_constants PEA constants array.
 */
void mage_set_pea_constants(uint8_t pea_constants[MAGE_PEA_ROWS][MAGE_PEA_COLS]){
  int32_t *mage_pea_constants_idx = (int32_t *)(MAGE_PEA_CONSTANTS_START_ADDR);
  for(int i = 0; i < MAGE_PEA_COLS; i++){
    for(int j = 0; j < MAGE_PEA_ROWS; j++){
      write_mage_register(pea_constants[i][j], mage_pea_constants_idx, 0xFF, 8*j);
    }
    mage_pea_constants_idx++;
  }
}

// TODO: remake this function
/**
 * @brief Sets a specific constant for a PE.
 *
 * @param pea_constant The constant value.
 * @param reg The register index.
 */
void mage_set_pe_constant(uint8_t pea_constant, uint8_t pe_row, uint8_t pe_col){
  int8_t *mage_pea_constants = (int8_t *)(MAGE_PEA_CONSTANTS_START_ADDR);
  mage_pea_constants += (pe_row * MAGE_PEA_COLS + pe_col) / 4;
  uint32_t offset = ((pe_row * MAGE_PEA_COLS + pe_col) % 4) * 8;

  write_mage_register(pea_constant, mage_set_pea_constants, 0xFF, offset);
}



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
void mage_set_sel_out_pea_cols(uint32_t sel_out_pea_cols){
  int32_t *mage_sel_out_pea = (int32_t *)(MAGE_COL_RES_SEL_START_ADDR);
  *mage_sel_out_pea = sel_out_pea;
}

/**
 * @brief Sets the accumulation values for PEs.
 *
 * @param acc_values The accumulation values.
 */
void mage_set_acc_values(uint32_t acc_values[PEA_ACC_VALUES_SIZE]){
  int32_t *mage_acc_values_idx = (int32_t *)(MAGE_ACC_VALUES_START_ADDR);
  for(int i = 0; i < PEA_ACC_VALUES_SIZE; i++){
    *mage_acc_values_idx = acc_values[i];
    mage_acc_values_idx++;
  }
}

