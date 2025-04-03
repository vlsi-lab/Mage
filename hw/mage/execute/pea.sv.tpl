// Copyright 2025 Politecnico di Torino.
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// File: pea.sv
// Author: Alessio Naclerio
// Date: 26/02/2025
// Description: Processing Element Array

module pea
  import pea_pkg::*;
%if enable_streaming_interface == str(1):
  import stream_intf_pkg::*;
%endif
(
    input  logic                                                  clk_i,
    input  logic                                                  rst_n_i,
%if enable_decoupling == str(1):
    // DAE Interface
    input  logic                                                  start_d_i,
    input  logic                                                  acc_match_i,
    input  logic   [ N_IN_PEA-1:0][N_BITS-1:0]                    pea_data_i,
    input  logic   [N_OUT_PEA-1:0][ LOG_M-1:0]                    sel_output_i,
    output logic   [N_OUT_PEA-1:0][N_BITS-1:0]                    pea_data_o,
    // end DAE Interface
%endif
%if enable_streaming_interface == str(1):
    // Streaming Interface
    input  logic                                                  reg_separate_cols_i,
    input  logic [M-1:0][ LOG_N:0]                              reg_stream_sel_out_pea_i,
    input  logic  [N-1:0][M-1:0][7:0]                             reg_acc_value_i,
    input  logic [ N_STREAM_IN_PEA-1:0]                          stream_valid_i,
    input  logic [ N_STREAM_IN_PEA-1:0][N_BITS-1:0]              stream_data_i,
    output logic [M-1:0]                                          pea_ready_o,
    output logic [M-1:0]                                          stream_valid_o,
    output logic [M-1:0][N_BITS-1:0]                              stream_data_o,
    // end Streaming Interface
%endif
    input  logic   [        N-1:0][     M-1:0][N_CFG_BITS_PE-1:0] ctrl_pea_i,
    input  logic   [        N-1:0][     M-1:0][             31:0] reg_constant_op_i
);

  %for r in range(n_pea_rows):
      %for c in range(n_pea_cols):
  logic [     N_BITS-1:0]             out_data_pe${r}${c};  
      %endfor
  %endfor

  %for r in range(n_pea_rows):
      %for c in range(n_pea_cols):
  logic [N_INPUTS_PE-3:0][N_BITS-1:0] in_data_pe${r}${c};  
      %endfor
  %endfor
  
%if enable_decoupling == str(1):
  ////////////////////////////////////////////////////////////////
  //                 Signals for DAE MAGE PEA                   //
  ////////////////////////////////////////////////////////////////
  logic [   N_IN_PEA-1:0][N_BITS-1:0] in_data_pea;

  %for r in range(n_pea_rows):
  logic [          M-1:0][N_BITS-1:0] out_data_row${r};  
  %endfor
%endif

%if enable_streaming_interface == str(1):
  ////////////////////////////////////////////////////////////////
  //              Signals for Streaming MAGE PEA                //
  ////////////////////////////////////////////////////////////////
  logic [N_STREAM_IN_PEA-1:0][N_BITS-1:0]  stream_data_in_reg;
  logic [N_STREAM_IN_PEA-1:0]              stream_valid_in_reg;
  logic [M-1:0][N-1:0][7:0]                 reg_acc_value_pe;

%for r in range(n_pea_rows):
    %for c in range(n_pea_cols):
  logic [N_INPUTS_PE-3:0] stream_valid_pe_in${r}${c};   
    %endfor
%endfor

%for r in range(n_pea_rows):
    %for c in range(n_pea_cols):
  logic  stream_valid_pe_out${r}${c};   
    %endfor
%endfor

%for r in range(n_pea_rows):
    %for c in range(n_pea_cols):
  logic  stream_ready_pe_out${r}${c};   
    %endfor
%endfor

  logic [M-1:0] ready_in_pe;

%for r in range(n_pea_rows):
    %for c in range(n_pea_cols):
logic [N_NEIGH_PE-1:0][N_BITS-1:0] in_delay_op${r}${c};  
    %endfor
%endfor

%for r in range(n_pea_rows):
    %for c in range(n_pea_cols):
logic [N_BITS-1:0] out_delay_op${r}${c};  
    %endfor
%endfor

%for r in range(n_pea_rows):
    %for c in range(n_pea_cols):
logic [N_NEIGH_PE-1:0] in_delay_op_valid${r}${c};  
    %endfor
%endfor

%for r in range(n_pea_rows):
    %for c in range(n_pea_cols):
logic out_delay_op_valid${r}${c};  
    %endfor
%endfor

  logic  [M*N-1:0] stream_valid_pe_out_arr; 

%for c in range(n_pea_cols):
  logic [          N:0][N_BITS-1:0] out_data_col${c};   
%endfor
%for c in range(n_pea_cols): 
  logic [          N:0]             out_valid_col${c};  
%endfor
%endif

  //Input Registers
  always_ff @(posedge clk_i, negedge rst_n_i) begin
    if (!rst_n_i) begin
%if enable_decoupling == str(1):
      in_data_pea <= '0;
%endif
%if enable_streaming_interface == str(1):
      stream_data_in_reg <= '0;
      stream_valid_in_reg <= '0;
%endif
    end else begin
%if enable_streaming_interface == str(1):
  %for i in range(4):
      if(ready_in_pe[${i}]) begin
        stream_data_in_reg[${i}]  <= stream_data_i[${i}];
        stream_valid_in_reg[${i}] <= stream_valid_i[${i}];
      end else begin
        stream_data_in_reg[${i}]  <= stream_data_in_reg[${i}];
        stream_valid_in_reg[${i}] <= stream_valid_in_reg[${i}];
      end
  %endfor
%endif
%if enable_decoupling == str(1):
      if (start_d_i == 1'b1) begin
        in_data_pea <= pea_data_i;
      end
%endif
    end
  end

  // Output muxes
%if enable_decoupling == str(1):
  %for r in range(n_pea_rows):
      %for c in range(n_pea_cols):
  assign out_data_row${r}[${c}] = out_data_pe${r}${c}; 
      %endfor
  %endfor
%endif
%if enable_streaming_interface == str(1):
  %for c in range(n_pea_cols):
      %for r in range(n_pea_rows):
  assign out_data_col${c}[${r}] = out_data_pe${r}${c};  
      %endfor
  assign out_data_col${c}[${n_pea_rows}] = '0;
  %endfor
  %for c in range(n_pea_cols):
      %for r in range(n_pea_rows): 
  assign out_valid_col${c}[${r}] = stream_valid_pe_out${r}${c}; 
      %endfor
  assign out_valid_col${c}[${n_pea_rows}] = 1'b0;
  %endfor
%endif

%if enable_decoupling == str(1):
  %for r in range(2*n_pea_rows):
  assign pea_data_o[${r}] = out_data_row${int(r/2)}[sel_output_i[${r}]]; 
  %endfor
%endif
%if enable_streaming_interface == str(1):
  %for c in range(n_pea_cols):
  assign stream_data_o[${c}] = out_data_col${c}[reg_stream_sel_out_pea_i[${c}]];
  assign stream_valid_o[${c}] = out_valid_col${c}[reg_stream_sel_out_pea_i[${c}]]; 
  %endfor
%endif

  ////////////////////////////////////////////////////////////////
  //               Assignments for PEs Din/Dout                 //
  ////////////////////////////////////////////////////////////////

%if enable_streaming_interface == str(1) and enable_decoupling == str(1):

  %for r in range(n_pea_rows):
    %for c in range(n_pea_cols):
      %for n in range(n_pe_in_mem):
        %for i in range(len(pea_in_mem_placement)):
          %for j in range(len(pea_in_mem_placement[i])):
            % if i == r and j == n:
              %if pea_in_mem_placement[i][j] != None:
  assign in_data_pe${r}${c}[${j}] = in_data_pea[${pea_in_mem_placement[i][j]}];
              %else:
  assign in_data_pe${r}${c}[${j}] = '0;
              %endif        
            %endif
          %endfor
        %endfor
      %endfor
      % for i in range(len(pea_in_stream_placement)):
        % if i == c:
          %if pea_in_stream_placement[i] != None:
  assign in_data_pe${r}${c}[${n_pe_in_mem}] = stream_data_in_reg[${pea_in_stream_placement[i]}];
          %else:
  assign in_data_pe${r}${c}[${n_pe_in_mem}] = '0;
          %endif
        %endif
      %endfor
  assign in_data_pe${r}${c}[${n_pe_in_mem+n_pe_in_stream}] = reg_constant_op_i[${r}][${c}];<% k = 0%> 
      %for r1 in range(r-1,r+2,1):  
        %for c1 in range(c-1,c+2,1):
          %if (r1 == r or c1 == c) and (not(r1 == r and c1 == c)): #this defines noc
            %if r1 < 0 or c1 < 0 or r1 >= n_pea_rows or c1 >= n_pea_cols:
  assign in_data_pe${r}${c}[${n_pe_in_mem+n_pe_in_stream+1+k}] = '0; <% k = k + 1 %>
            %else:
  assign in_data_pe${r}${c}[${n_pe_in_mem+n_pe_in_stream+1+k}] = out_data_pe${r1}${c1}; <% k = k + 1 %>                  
            %endif
          %endif
        %endfor
      %endfor

    %endfor
  %endfor

%elif  enable_streaming_interface == str(1) and enable_decoupling == str(0):

  %for r in range(n_pea_rows):
    %for c in range(n_pea_cols):
      % for i in range(len(pea_in_stream_placement)):
        % if i == c:
          %if pea_in_stream_placement[i] != None:
  assign in_data_pe${r}${c}[0] = stream_data_in_reg[${pea_in_stream_placement[i]}];
          %else:
  assign in_data_pe${r}${c}[0] = '0;
          %endif
        %endif
      %endfor   
  assign in_data_pe${r}${c}[${n_pe_in_stream}] = reg_constant_op_i[${r}][${c}];<% k = 0 %> 
      %for r1 in range(r-1,r+2,1):
        %for c1 in range(c-1,c+2,1):
          %if (r1 == r or c1 == c) and (not(r1 == r and c1 == c)): #this defines noc
            %if r1 < 0 or c1 < 0 or r1 >= n_pea_rows or c1 >= n_pea_cols:
  assign in_data_pe${r}${c}[${n_pe_in_stream+1+k}] = '0; <% k = k + 1 %>
            %else:
  assign in_data_pe${r}${c}[${n_pe_in_stream+1+k}] = out_data_pe${r1}${c1}; <% k = k + 1 %>                  
            %endif
          %endif
        %endfor
      %endfor

    %endfor
  %endfor

%elif  enable_streaming_interface == str(0) and enable_decoupling == str(1):

  %for r in range(n_pea_rows):
    %for c in range(n_pea_cols):
      %for n in range(n_pe_in_mem):
        %for i in range(len(pea_in_mem_placement)):
          %for j in range(len(pea_in_mem_placement[i])):
            % if i == r and j == n:
              %if pea_in_mem_placement[i][j] != None:
  assign in_data_pe${r}${c}[${j}] = in_data_pea[${pea_in_mem_placement[i][j]}];
              %else:
  assign in_data_pe${r}${c}[${j}] = '0;
              %endif       
            %endif
          %endfor
        %endfor
      %endfor       
  assign in_data_pe${r}${c}[${n_pe_in_mem}] = reg_constant_op_i[${r}][${c}];
  assign in_data_pe${r}${c}[${1+n_pe_in_mem}] = out_data_pe${r}${c}; <% k = 0 %> 
      %for r1 in range(r-1,r+2,1):
        %for c1 in range(c-1,c+2,1):
          %if (r1 == r or c1 == c) and (not(r1 == r and c1 == c)): #this defines noc
            %if r1 < 0 or c1 < 0 or r1 >= n_pea_rows or c1 >= n_pea_cols:
  assign in_data_pe${r}${c}[${n_pe_in_mem+1+k}] = '0; <% k = k + 1 %>
            %else:
  assign in_data_pe${r}${c}[${n_pe_in_mem+1+k}] = out_data_pe${r1}${c1}; <% k = k + 1 %>                  
            %endif
          %endif
        %endfor
      %endfor

    %endfor
  %endfor

%endif
%if enable_streaming_interface == str(1):
  <% k = 0 %>
  %for r in range(n_pea_rows):
    %for c in range(n_pea_cols): 
      %for r1 in range(r-1,r+2,1):
        %for c1 in range(c-1,c+2,1):
          %if (r1 == r or c1 == c) and (not(r1 == r and c1 == c)): #this defines noc
            %if r1 < 0 or c1 < 0 or r1 >= n_pea_rows or c1 >= n_pea_cols:
              %if r1 == -1 and c1 == c:
                % for i in range(len(pea_in_stream_placement)):
                  % if i == c:
                    %if pea_in_stream_placement[i] != None:
  assign in_delay_op${r}${c}[${k}] = stream_data_in_reg[${pea_in_stream_placement[i]}]; <% k = k + 1 %>
                    %else:
  assign in_delay_op${r}${c}[${k}] = '0; <% k = k + 1 %>
                    %endif
                  %endif
                %endfor
              %else:
  assign in_delay_op${r}${c}[${k}] = '0; <% k = k + 1 %>
              %endif
            %else:
  assign in_delay_op${r}${c}[${k}] = out_delay_op${r1}${c1}; <% k = k + 1 %>                  
            %endif
          %endif
        %endfor
      %endfor
    <% k = 0 %>
    %endfor
  %endfor
  <% k = 0 %>
  %for r in range(n_pea_rows):
    %for c in range(n_pea_cols): 
      %for r1 in range(r-1,r+2,1):
        %for c1 in range(c-1,c+2,1):
          %if (r1 == r or c1 == c) and (not(r1 == r and c1 == c)): #this defines noc
            %if r1 < 0 or c1 < 0 or r1 >= n_pea_rows or c1 >= n_pea_cols:
              %if r1 == -1 and c1 == c:
                % for i in range(len(pea_in_stream_placement)):
                  % if i == c:
                    %if pea_in_stream_placement[i] != None:
  assign in_delay_op_valid${r}${c}[${k}] = stream_valid_in_reg[${pea_in_stream_placement[i]}]; <% k = k + 1 %>
                    %else:
  assign in_delay_op_valid${r}${c}[${k}] = '0; <% k = k + 1 %>
                    %endif
                  %endif
                %endfor
              %else:
  assign in_delay_op_valid${r}${c}[${k}] = '0; <% k = k + 1 %>
              %endif
            %else:
  assign in_delay_op_valid${r}${c}[${k}] = out_delay_op_valid${r1}${c1}; <% k = k + 1 %>                  
            %endif
          %endif
        %endfor
      %endfor
    <% k = 0 %>
    %endfor
  %endfor
%endif
%if enable_streaming_interface == str(1):
////////////////////////////////////////////////////////////////
//               Assignments for PEs Valid I/O                //
////////////////////////////////////////////////////////////////
  %for r in range(n_pea_rows):
    %for c in range(n_pea_cols):
      <% k = 1 %>       
      % for i in range(len(pea_in_stream_placement)):
        % if i == c:
          %if pea_in_stream_placement[i] != None:
  assign stream_valid_pe_in${r}${c}[0] = stream_valid_in_reg[${pea_in_stream_placement[i]}];
          %else:
  assign stream_valid_pe_in${r}${c}[0] = 1'b1;
          %endif
        %endif
      %endfor
  assign stream_valid_pe_in${r}${c}[${k}] = 1'b1; <% k = k + 1 %>
      %for r1 in range(r-1,r+2,1):
        %for c1 in range(c-1,c+2,1):
          %if (r1 == r or c1 == c) and (not(r1 == r and c1 == c)): #this defines noc
            %if r1 < 0 or c1 < 0 or r1 >= n_pea_rows or c1 >= n_pea_cols:
  assign stream_valid_pe_in${r}${c}[${k}] = 1'b1; <% k = k + 1 %>        
            %else:
  assign stream_valid_pe_in${r}${c}[${k}] = stream_valid_pe_out${r1}${c1}; <% k = k + 1 %>                  
            %endif
          %endif
        %endfor
      %endfor
    %endfor
  %endfor
%endif

%if enable_streaming_interface == str(1):
  always_comb begin
    for(int i=0; i<N; i++) begin
        for(int j=0; j<M; j++) begin
            reg_acc_value_pe[i][j] = reg_acc_value_i[i][j];
        end
    end
  end
%endif

%for r in range(n_pea_rows):
    %for c in range(n_pea_cols):
  pe pe_inst_${r}${c} (
      .clk_i(clk_i),
      .rst_n_i(rst_n_i),
      .neigh_pe_op_i(in_data_pe${r}${c}),
%if enable_decoupling == str(1):
      .acc_match_i(acc_match_i),
%endif
%if enable_streaming_interface == str(1):
      .reg_acc_value_i(reg_acc_value_pe[${r}][${c}]),
      .pea_ready_i(ready_in_pe[${c}]),
      .neigh_pe_op_valid_i(stream_valid_pe_in${r}${c}),
      .neigh_delay_op_i(in_delay_op${r}${c}),
      .neigh_delay_op_valid_i(in_delay_op_valid${r}${c}),
      .valid_o(stream_valid_pe_out${r}${c}),
      .ready_o(stream_ready_pe_out${r}${c}),
      .delay_op_valid_o(out_delay_op_valid${r}${c}),
      .delay_op_o(out_delay_op${r}${c}),
%endif
      .ctrl_pe_i(ctrl_pea_i[${r}][${c}]),
      .pe_res_o(out_data_pe${r}${c})
  ); 
    %endfor
%endfor

  assign stream_valid_pe_out_arr = {
%for r in range(n_pea_rows): 
  %for c in range(n_pea_cols): 
    %if r == n_pea_rows-1 and c == n_pea_cols-1:
    stream_ready_pe_out${r}${c}
    %else:
    stream_ready_pe_out${r}${c},
    %endif
  %endfor 
%endfor
  };

  always_comb begin
    if(reg_separate_cols_i) begin

%for c in range(n_pea_cols):
      ready_in_pe[${c}] = 
  %for r in range(n_pea_rows): 
    %if r == n_pea_rows-1:
      stream_ready_pe_out${r}${c};
    %else:
      stream_ready_pe_out${r}${c} &
    %endif
  %endfor 
%endfor
%for c in range(n_pea_cols):
      pea_ready_o[${c}] = ready_in_pe[${c}];
%endfor
    end else begin
%for c in range(n_pea_cols):
      ready_in_pe[${c}] = &stream_valid_pe_out_arr;
      pea_ready_o[${c}] = ready_in_pe[${c}];
%endfor
    end
  end

endmodule
