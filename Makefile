.PHONY: clean help

PYTHON = python3
FUSESOC = fusesoc

MAGE_CORE = vlsi:polito:mage-dae

REGTOOL_SCRIPT = ./util/regtool.py

REGTOOL_DEST_DIR = ./hw/mage/configuration
REGTOOL_SRC_FILE = ./hw/mage/configuration/mage_regs.hjson
REGTOOL_SW_DEST_DIR = ./sw

KERNEL_LEN = 1

# Address generation engine
N_AGE_TOT = 8
N_AGE_PER_STREAM = 2

# Streaming Interface
IN_STREAM_XBAR = 0
OUT_STREAM_XBAR = 1
ENABLE_STREAMING_INTERFACE = 1
ENABLE_DECOUPLED = 0

N_DMA_CH = 4
N_IN_STREAM = 4
N_DMA_CH_PER_IN_STREAM = 2
N_PEA_DIN_PER_IN_STREAM = 1
N_OUT_STREAM = 4
N_PEA_DOUT_PER_OUT_STREAM = 2
N_DMA_CH_PER_OUT_STREAM = 1

# PEA
N_PEA_ROWS = 4
N_PEA_COLS = 4
N_PE_IN_MEM = 4
N_PE_IN_STREAM = 2
N_NEIGH_PE = 4
#N_PEA_NOC_TYPE = 0

ROW_DIV = 1
ROW_ACC = 0

re-vendor:
	./util/vendor.py ./vendor/lowrisc_opentitan.vendor.hjson -v --update; \
	./util/vendor.py ./vendor/pulp_platform_register_interface.vendor.hjson -v --update; \
	./util/vendor.py ./vendor/pulp_platform_common_cells.vendor.hjson -v --update; \
	./util/vendor.py ./vendor/pulp_platform_tech_cells_generic.vendor.hjson -v --update;

mage-gen:
	$(PYTHON) util/mage-gen.py  --outdir hw/mage/stream --tpl-sv hw/mage/stream/streaming_interface.sv.tpl \
	--n_dma_ch $(N_DMA_CH) \
	--n_in_stream $(N_IN_STREAM) \
	--n_dma_ch_per_in_stream $(N_DMA_CH_PER_IN_STREAM) \
	--n_pea_din_per_in_stream $(N_PEA_DIN_PER_IN_STREAM) \
	--n_out_stream $(N_OUT_STREAM) \
	--n_pea_dout_per_out_stream $(N_PEA_DOUT_PER_OUT_STREAM) \
	--n_dma_ch_per_out_stream $(N_DMA_CH_PER_OUT_STREAM) \
	--in_stream_xbar $(IN_STREAM_XBAR) \
	--out_stream_xbar $(OUT_STREAM_XBAR)
	$(PYTHON) util/mage-gen.py  --outdir hw/mage/packages --tpl-sv hw/mage/packages/stream_intf_pkg.sv.tpl \
	--n_dma_ch $(N_DMA_CH) \
	--n_in_stream $(N_IN_STREAM) \
	--n_dma_ch_per_in_stream $(N_DMA_CH_PER_IN_STREAM) \
	--n_pea_din_per_in_stream $(N_PEA_DIN_PER_IN_STREAM) \
	--n_out_stream $(N_OUT_STREAM) \
	--n_pea_dout_per_out_stream $(N_PEA_DOUT_PER_OUT_STREAM) \
	--n_dma_ch_per_out_stream $(N_DMA_CH_PER_OUT_STREAM) \
	--in_stream_xbar $(IN_STREAM_XBAR) \
	--out_stream_xbar $(OUT_STREAM_XBAR)
	$(PYTHON) util/mage-gen.py  --outdir hw/mage/execute/pe/fu --tpl-sv hw/mage/execute/pe/fu/fu_wrapper.sv.tpl \
	--enable_streaming_interface $(ENABLE_STREAMING_INTERFACE) \
	--enable_decoupling $(ENABLE_DECOUPLED)
	$(PYTHON) util/mage-gen.py  --outdir hw/mage/execute/pe/fu --tpl-sv hw/mage/execute/pe/fu/fu_wrapper_div.sv.tpl \
	--enable_streaming_interface $(ENABLE_STREAMING_INTERFACE) \
	--enable_decoupling $(ENABLE_DECOUPLED)
	$(PYTHON) util/mage-gen.py  --outdir hw/mage/execute --tpl-sv hw/mage/execute/pea.sv.tpl \
	--n_pea_rows $(N_PEA_ROWS) \
	--n_pea_cols $(N_PEA_COLS) \
	--row_div $(ROW_DIV) \
	--row_acc $(ROW_ACC) \
	--n_pe_in_mem $(N_PE_IN_MEM) \
	--n_pe_in_stream $(N_PE_IN_STREAM) \
	--n_neigh_pe $(N_NEIGH_PE) \
	--enable_streaming_interface $(ENABLE_STREAMING_INTERFACE) \
	--enable_decoupling $(ENABLE_DECOUPLED)
	$(PYTHON) util/mage-gen.py  --outdir hw/mage/packages --tpl-sv hw/mage/packages/mage_pkg.sv.tpl \
	--kernel_len $(KERNEL_LEN) \
	--n_age_tot $(N_AGE_TOT) \
	--n_age_per_stream $(N_AGE_PER_STREAM) 
	$(PYTHON) util/mage-gen.py  --outdir hw/mage/packages --tpl-sv hw/mage/packages/xbar_pkg.sv.tpl \
	--n_age_tot $(N_AGE_TOT) \
	--n_age_per_stream $(N_AGE_PER_STREAM) \
	--kernel_len $(KERNEL_LEN)
	$(PYTHON) util/mage-gen.py  --outdir hw/mage/access --tpl-sv hw/mage/access/ba_gen.sv.tpl \
	--n_age_per_stream $(N_AGE_PER_STREAM) 
	$(PYTHON) util/mage-gen.py  --outdir hw/mage/packages --tpl-sv hw/mage/packages/pea_pkg.sv.tpl \
	--n_pea_rows $(N_PEA_ROWS) \
	--n_pea_cols $(N_PEA_COLS) \
	--kernel_len $(KERNEL_LEN) \
	--enable_decoupling $(ENABLE_DECOUPLED) \
	--enable_streaming_interface $(ENABLE_STREAMING_INTERFACE) \
	--n_pe_in_mem $(N_PE_IN_MEM) \
	--n_pe_in_stream $(N_PE_IN_STREAM) \
	--n_neigh_pe $(N_NEIGH_PE)
	$(PYTHON) util/mage-gen.py  --outdir hw/mage/configuration --tpl-sv hw/mage/configuration/peripheral_regs.sv.tpl \
	--n_dma_ch $(N_DMA_CH) \
	--kernel_len $(KERNEL_LEN) \
	--n_pea_cols $(N_PEA_COLS) \
	--n_pea_rows $(N_PEA_ROWS) \
	--n_age_tot $(N_AGE_TOT) \
	--out_stream_xbar $(OUT_STREAM_XBAR) \
	--in_stream_xbar $(IN_STREAM_XBAR) \
	--n_age_per_stream $(N_AGE_PER_STREAM) \
	--enable_decoupling $(ENABLE_DECOUPLED) \
	--enable_streaming_interface $(ENABLE_STREAMING_INTERFACE) \
	--n_in_stream $(N_IN_STREAM) \
	--n_dma_ch_per_in_stream $(N_DMA_CH_PER_IN_STREAM) \
	--n_pea_din_per_in_stream $(N_PEA_DIN_PER_IN_STREAM) \
	--n_out_stream $(N_OUT_STREAM) \
	--n_pea_dout_per_out_stream $(N_PEA_DOUT_PER_OUT_STREAM) \
	--n_dma_ch_per_out_stream $(N_DMA_CH_PER_OUT_STREAM)
	$(PYTHON) util/mage-gen.py  --outdir hw/mage --tpl-sv hw/mage/mage_top.sv.tpl \
	--kernel_len $(KERNEL_LEN) \
	--enable_streaming_interface $(ENABLE_STREAMING_INTERFACE) \
	--enable_decoupling $(ENABLE_DECOUPLED) \
	--out_stream_xbar $(OUT_STREAM_XBAR) \
	--in_stream_xbar $(IN_STREAM_XBAR)
	$(PYTHON) util/mage-gen.py  --outdir hw/mage --tpl-sv hw/mage/mage_wrapper.sv.tpl \
	--enable_streaming_interface $(ENABLE_STREAMING_INTERFACE) \
	--enable_decoupling $(ENABLE_DECOUPLED)
	$(PYTHON) util/mage-gen.py  --outdir hw/mage/configuration --tpl-sv hw/mage/configuration/mage_regs.hjson.tpl \
	--n_dma_ch $(N_DMA_CH) \
	--kernel_len $(KERNEL_LEN) \
	--n_age_tot $(N_AGE_TOT) \
	--n_pea_cols $(N_PEA_COLS) \
	--n_pea_rows $(N_PEA_ROWS) \
	--enable_decoupling $(ENABLE_DECOUPLED) \
	--enable_streaming_interface $(ENABLE_STREAMING_INTERFACE) \
	--n_age_per_stream $(N_AGE_PER_STREAM) \
	--in_stream_xbar $(IN_STREAM_XBAR) \
	--out_stream_xbar $(OUT_STREAM_XBAR) \
	--n_in_stream $(N_IN_STREAM) \
	--n_dma_ch_per_in_stream $(N_DMA_CH_PER_IN_STREAM) \
	--n_pea_din_per_in_stream $(N_PEA_DIN_PER_IN_STREAM) \
	--n_out_stream $(N_OUT_STREAM) \
	--n_pea_dout_per_out_stream $(N_PEA_DOUT_PER_OUT_STREAM) \
	--n_dma_ch_per_out_stream $(N_DMA_CH_PER_OUT_STREAM) 
	$(PYTHON) util/mage-gen.py  --outdir hw/mage/configuration --tpl-sv hw/mage/configuration/cfg_regs_ls_stream_sel.sv.tpl \
	--kernel_len $(KERNEL_LEN) 
	$(PYTHON) util/mage-gen.py  --outdir hw/mage/configuration --tpl-sv hw/mage/configuration/cfg_regs_out_pea.sv.tpl \
	--kernel_len $(KERNEL_LEN) 
	$(PYTHON) util/mage-gen.py  --outdir hw/mage/configuration --tpl-sv hw/mage/configuration/cfg_regs_pea.sv.tpl \
	--kernel_len $(KERNEL_LEN) \
	--enable_streaming_interface $(ENABLE_STREAMING_INTERFACE) 
	$(PYTHON) util/mage-gen.py  --outdir hw/mage/access --tpl-sv hw/mage/access/mage.sv.tpl \
	--kernel_len $(KERNEL_LEN) 
	$(PYTHON) util/mage-gen.py  --outdir hw/mage/access --tpl-sv hw/mage/access/cfg_dispatcher.sv.tpl \
	--kernel_len $(KERNEL_LEN) 
	$(PYTHON) util/mage-gen.py  --outdir hw/mage/access --tpl-sv hw/mage/access/k_controller.sv.tpl \
	--kernel_len $(KERNEL_LEN) 
	$(PYTHON) util/mage-gen.py --num_words 1024 \
	  --outdir hw/fpga/scripts/ --tpl-sv hw/fpga/scripts/generate_sram.tcl.tpl
	$(PYTHON) util/mage-gen.py  --outdir sw/ --tpl-sv sw/mage.h.tpl \
	--kernel_len $(KERNEL_LEN) \
	--n_pea_cols $(N_PEA_COLS) \
	--n_pea_rows $(N_PEA_ROWS) \
	--n_age_tot $(N_AGE_TOT) \
	--n_age_per_stream $(N_AGE_PER_STREAM) \
	--enable_decoupling $(ENABLE_DECOUPLED) \
	--enable_streaming_interface $(ENABLE_STREAMING_INTERFACE)
	$(PYTHON) util/mage-gen.py  --outdir sw/ --tpl-sv sw/mage.c.tpl \
	--kernel_len $(KERNEL_LEN) \
	--n_pea_cols $(N_PEA_COLS) \
	--n_pea_rows $(N_PEA_ROWS) \
	--n_age_tot $(N_AGE_TOT) \
	--n_age_per_stream $(N_AGE_PER_STREAM) \
	--enable_decoupling $(ENABLE_DECOUPLED) \
	--in_stream_xbar $(IN_STREAM_XBAR) \
	--out_stream_xbar $(OUT_STREAM_XBAR) \
	--enable_streaming_interface $(ENABLE_STREAMING_INTERFACE)
	util/format-verible;
	$(PYTHON) util/mage-gen.py  --outdir sw/ --tpl-sv sw/mage_x_heep.h.tpl \
	--kernel_len $(KERNEL_LEN) \
	--n_pea_cols $(N_PEA_COLS) \
	--n_pea_rows $(N_PEA_ROWS) \
	--n_age_tot $(N_AGE_TOT) \
	--n_age_per_stream $(N_AGE_PER_STREAM) \
	--enable_decoupling $(ENABLE_DECOUPLED) \
	--in_stream_xbar $(IN_STREAM_XBAR) \
	--out_stream_xbar $(OUT_STREAM_XBAR) \
	--enable_streaming_interface $(ENABLE_STREAMING_INTERFACE)
	$(PYTHON) $(REGTOOL_SCRIPT) -r -t $(REGTOOL_DEST_DIR) $(REGTOOL_SRC_FILE)
	$(PYTHON) $(REGTOOL_SCRIPT) -D $(REGTOOL_SRC_FILE) > $(REGTOOL_SW_DEST_DIR)/mage_regs.h

	util/format-verible;

verible:
	util/format-verible;

verilator-sim:
	$(FUSESOC) --cores-root . run --no-export --target=sim --tool=verilator $(FUSESOC_FLAGS) --setup --build $(MAGE_CORE)  2>&1 | tee buildsim.log

questasim-sim:
	$(FUSESOC) --cores-root . run --no-export --target=sim --tool=modelsim $(FUSESOC_FLAGS) --setup --build $(MAGE_CORE) 2>&1 | tee buildsim.log

synthesis:
	$(FUSESOC) --cores-root . run --no-export --target=syn $(FUSESOC_FLAGS_SYN) --setup $(MAGE_CORE) ${FUSESOC_PARAM} 2>&1 | tee builddesigncompiler.log

regtool:
	$(PYTHON) $(REGTOOL_SCRIPT) -r -t $(REGTOOL_DEST_DIR) $(REGTOOL_SRC_FILE)
	$(PYTHON) $(REGTOOL_SCRIPT) -D $(REGTOOL_SRC_FILE) > $(REGTOOL_SW_DEST_DIR)/mage_regs.h

run-verilator:
	cd ./build/vlsi_polito_mage/sim-verilator;\
	make Vmage_wrapper;\
	./Vmage_wrapper;\

run-synthesis:
	cd ./build/vlsi_polito_mage/syn-design_compiler;\
	make -f Makefile;\

run-power-analysis:
	cd ./build/vlsi_polito_mage/power-analysis;\
	pt_shell -file  ../../../scripts/power_analysis/pwr_script.tcl\

waves:
	gtkwave ./build/vlsi_polito_mage/sim-verilator/waveform.vcd

clean-build:
	rm -rf build buildsim.log builddesigncompiler.log

clean-synthesis:
	rm -rf build/vlsi_polito_mage/syn-design_compiler buildsim.log builddesigncompiler.log
