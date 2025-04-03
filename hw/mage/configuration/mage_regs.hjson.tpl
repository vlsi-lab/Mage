{ name: "mage",
  clock_primary: "clk_i",
  bus_interfaces: [
    { protocol: "reg_iface", direction: "device" }
  ],
  registers: [
%if enable_decoupling == str(1):
    { name:     "STATUS",
      desc:     "MAGE-CGRA status",
      swaccess: "rw",
      hwaccess: "hrw",
      resval:   0,
      fields: [
        { bits: "0", 
          name: "START",
          desc: "Start for computation" 
        },
        { bits: "1", 
          name: "DONE",
          desc: "It signals that the computation is finished" 
        },
      ]
    },
    { name:     "GEN_CFG",
      desc:     "General Configuration Bits",
      swaccess: "rw",
      hwaccess: "hro",
      resval:   0,
      fields: [
        { bits: "3:0", 
          name: "II",
          desc: "Initiation interval" 
        },
        { bits: "4:4", 
          name: "S_N_T_MAGE",
          desc: "Static/Time-Multiplexed configuration for MAGE" 
        },
        { bits: "5:5", 
          name: "S_N_T_mage_PEA",
          desc: "Static/Time-Multiplexed configuration for MAGE-CGRA" 
        },
        { bits: "6:6", 
          name: "S_N_T_mage_PEA_OUT_REGS",
          desc: "Static/Time-Multiplexed configuration for MAGE-CGRA" 
        },
        { bits: "7:7", 
          name: "S_N_T_mage_XBAR",
          desc: "Static/Time-Multiplexed configuration for MAGE-CGRA" 
        },
        { bits: "11:8", 
          name: "ACC_VEC_MODE",
          desc: "Vector mode for accumulation" 
        },
        { bits: "15:12", 
          name: "BLOCKSIZE",
          desc: "Blocksize for dmem decoder" 
        }
      ]
    },
    { name:     "ILB_HWL",
      desc:     "Initial Loop Bounds for Hardware Loops",
      swaccess: "rw",
      hwaccess: "hro",
      resval:   0,
      fields: [
        { bits: "7:0", 
          name: "ILB_0",
          desc: "Initial Loop Bound for loop 0" 
        },
        { bits: "15:8", 
          name: "ILB_1",
          desc: "Initial Loop Bound for loop 1" 
        },
        { bits: "23:16", 
          name: "ILB_2",
          desc: "Initial Loop Bound for loop 2" 
        },
        { bits: "31:24", 
          name: "ILB_3",
          desc: "Initial Loop Bound for loop 3" 
        },
      ]
    },
    { name:     "FLB_HWL",
      desc:     "Final Loop Bounds for Hardware Loops",
      swaccess: "rw",
      hwaccess: "hro",
      resval:   0,
      fields: [
        { bits: "7:0", 
          name: "FLB_0",
          desc: "Final Loop Bound for loop 0" 
        },
        { bits: "15:8", 
          name: "FLB_1",
          desc: "Final Loop Bound for loop 1" 
        },
        { bits: "23:16", 
          name: "FLB_2",
          desc: "Final Loop Bound for loop 2" 
        },
        { bits: "31:24", 
          name: "FLB_3",
          desc: "Final Loop Bound for loop 3" 
        },
      ]
    },
    { name:     "INC_HWL",
      desc:     "Increments for Hardware Loops",
      swaccess: "rw",
      hwaccess: "hro",
      resval:   0,
      fields: [
        { bits: "7:0", 
          name: "INC_0",
          desc: "Increment for loop 0" 
        },
        { bits: "15:8", 
          name: "INC_1",
          desc: "Increment for loop 1" 
        },
        { bits: "23:16", 
          name: "INC_2",
          desc: "Increment for loop 2" 
        },
        { bits: "31:24", 
          name: "INC_3",
          desc: "Increment for loop 3" 
        },
      ]
    },
    { name:     "PEA_CONTROL_SNT",
      desc:     "Each bit controls the control mode of each pe, static or time-multiplexed",
      swaccess: "rw",
      hwaccess: "hro",
      resval:   0,
      fields: [
        { bits: "31:0"
        }
      ]
    },
    { multireg:
        { name: "STRIDES",
        desc: "Configuration for AGEs strides",
        count : "${n_age_tot}",
        cname: "STRIDES",
        swaccess: "rw",
        hwaccess: "hro",
        fields: [
        { bits: "7:0", 
          name: "S0",
          desc: "Stride 0" 
        },
        { bits: "15:8", 
          name: "S1",
          desc: "Stride 1" 
        },
        { bits: "23:16", 
          name: "S2",
          desc: "Stride 2" 
        },
        { bits: "31:24", 
          name: "S3",
          desc: "Stride 3" 
        },
        ],
        }
    },
    { name:     "PKE",
      desc:     "Length of Prologue, Kernel and Epilogue execution stage, and number of times for Kernel to be repeated",
      swaccess: "rw",
      hwaccess: "hro",
      resval:   0,
      fields: [
        { bits: "3:0", 
          name: "LEN_P",
          desc: "Length of Prologue execution stage" 
        },
        { bits: "7:4", 
          name: "LEN_K",
          desc: "Length of Kernel execution stage" 
        },
        { bits: "11:8", 
          name: "LEN_E",
          desc: "Length of Epilogue execution stage" 
        },
        { bits: "15:12", 
          name: "LEN_DFG",
          desc: "Lenght of DFG" 
        }
      ]
    },
%endif
  <%import math as m%>
%for r in range(n_pea_rows):
    %for c in range(n_pea_cols):
    { multireg:
        { name: "CFG_PE_${r}${c}",
        desc: "Configuration for MAGE-CGRA PE 00",
        count : "${m.ceil(kernel_len)}",
        cname: "PE_${r}${c}",
        swaccess: "rw",
        hwaccess: "hro",
        fields: [
        { bits: "31:0"
        }
        ],
        }
    },
    %endfor
%endfor
%if enable_decoupling == str(1):
<%import math as m%>
    { multireg:
        { name: "SEL_OUT_PEA",
        desc: "Selection signals for output of MAGE-CGRA PEA",
        count: "${m.ceil(((2*n_pea_rows*m.log2(n_pea_cols))*kernel_len)/32)}",
        cname: "ISOP",
        swaccess: "rw",
        hwaccess: "hro",
        fields: [
        { bits: "31:0"
        }
        ],
        }
    }, 
    { multireg:
        { name: "L_STREAM_SEL_AGE",
        desc: "Selection signals for load streams",
        count: "${int(m.ceil(((n_age_tot*m.log2(n_age_per_stream))*kernel_len)/32))}",
        cname: "SSS",
        swaccess: "rw",
        hwaccess: "hro",
        fields: [
        { bits: "31:0"
        }
        ],
        }
    },
    { multireg:
        { name: "S_STREAM_SEL_AGE",
        desc: "Selection signals for store streams",
        count: "${int(m.ceil(((n_age_tot*m.log2(n_age_per_stream))*kernel_len)/32))}",
        cname: "LSS",
        swaccess: "rw",
        hwaccess: "hro",
        fields: [
        { bits: "31:0"
        }
        ],
        }
    },
  %for s in range(int(n_age_tot/n_age_per_stream)):
    %for a in range(n_age_per_stream):
    { multireg:
        { name: "CFG_MAGE_S${s}_AGE${a}",
        desc: "Configuration for AGE ${a} of Stream ${s}",
        count : "${kernel_len}",
        cname: "IM",
        swaccess: "rw",
        hwaccess: "hro",
        fields: [
        { bits: "31:0", 
          name: "AGE_INST",
          desc: "Instruction for AGE ${a} of Stream ${s}" 
        },
        ],
        }
    },
    %endfor
  %endfor
%endif
    { multireg:
        { name: "PEA_CONSTANTS",
        desc: "Configuration for PEs constants",
        count : "${n_pea_rows*n_pea_cols}",
        cname: "PEA_CONSTANTS",
        swaccess: "rw",
        hwaccess: "hro",
        fields: [
        { bits: "31:0", 
          name: "CONSTANT",
          desc: "Constant for PE" 
        },
        ],
        }
    },
%if enable_decoupling == str(1):
    { multireg:
        { name: "AGE_IV_CONSTRAINTS",
        desc: "Configuration for AGE IV constraints",
        count : "${int(n_age_tot/4)}",
        cname: "AGE_IV_CONSTRAINTS",
        swaccess: "rw",
        hwaccess: "hro",
        fields: [
        { bits: "7:0", 
          name: "C0",
          desc: "Constraint 0" 
        },
        { bits: "15:8", 
          name: "C1",
          desc: "Constraint 1" 
        },
        { bits: "23:16", 
          name: "C2",
          desc: "Constraint 2" 
        },
        { bits: "31:24", 
          name: "C3",
          desc: "Constraint 3" 
        },
        ],
        }
    },
%endif
%if enable_streaming_interface == str(1):
    { name: "STREAM_DMA_CFG",
      desc: "Selection signals for output of MAGE-CGRA PEA",
      swaccess: "rw",
      hwaccess: "hro",
      fields: [
      { bits: "3:0", 
        name: "DMA_CH_CFG",
        desc: "Configuration for DMA channels (r or r/w)" 
      },
      ],
    },
    { name: "SEPARATE_COLS",
      desc: "If set to 1, each column of Mage works in streaming separately from all the other. If 0, all columns work together. If 2, columns are grouped in 2 groups of 2 each",
      swaccess: "rw",
      hwaccess: "hro",
      fields: [
      { bits: "1:0",
        name: "SEP_COLS",
        desc: "Configuration for separate Mage columns in streaming"
      },
      ],
    },
  %if in_stream_xbar == str(1):
    { name: "STREAM_IN_XBAR_SEL",
      desc: "Selection signals for input stream crossbars",
      swaccess: "rw",
      hwaccess: "hro",
      fields: [
    %for i in range(int(n_in_stream*n_dma_ch_per_in_stream)):
      { bits: "${2*i+1}:${2*i}", 
        name: "SEL_IN_XBAR_${i}",
        desc: "Selection signals for output stream crossbar" 
      },
    %endfor
      ],
    },
  %endif
  %if out_stream_xbar == str(1):
    { name: "STREAM_OUT_XBAR_SEL",
      desc: "Selection signals for output stream crossbars",
      swaccess: "rw",
      hwaccess: "hro",
      fields: [
    %for i in range(int(n_out_stream*n_dma_ch_per_out_stream)):
      { bits: "${2*i+1}:${2*i}", 
        name: "SEL_OUT_XBAR_${i}",
        desc: "Selection signals for output stream crossbar" 
      },
    %endfor
      ],
    },
  %endif
    { multireg:
      { name: "SEL_OUT_COL_PEA",
      desc: "Selection signals for output of MAGE-CGRA PEA",
      count : "${m.ceil((int(m.ceil(m.log2(n_pea_cols)))*n_pea_rows)/32)}",
      cname: "SEL_OUT_COL_PEA",
      swaccess: "rw",
      hwaccess: "hro",
      fields: [
      { bits: "7:0", 
        name: "SEL_COL_0",
        desc: "Selector for column 0" 
      },
      { bits: "15:8", 
        name: "SEL_COL_1",
        desc: "Selector for column 1"
      },
      { bits: "23:16", 
        name: "SEL_COL_2",
        desc: "Selector for column 2"
      },
      { bits: "31:24", 
        name: "SEL_COL_3",
        desc: "Selector for column 3"
      },
      ],
      }
    },
    { multireg:
      { name: "ACC_VALUE",
      desc: "Accumulation Value for PEs",
      count : "${m.ceil((n_pea_cols*n_pea_rows*8)/32)}",
      cname: "ACC_VALUE_PE",
      swaccess: "rw",
      hwaccess: "hro",
      fields: [
      { bits: "7:0", 
        name: "PE_0",
        desc: "Selector for column 0" 
      },
      { bits: "15:8", 
        name: "PE_1",
        desc: "Selector for column 1"
      },
      { bits: "23:16", 
        name: "PE_2",
        desc: "Selector for column 2"
      },
      { bits: "31:24", 
        name: "PE_3",
        desc: "Selector for column 3"
      },
      ],
      }
    },
%endif   
  ]
}