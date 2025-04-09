#!/usr/bin/env python3

# Copyright 2020 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

#Simplified version of occamygen.py https://github.com/pulp-platform/snitch/blob/master/util/occamygen.py

import argparse
import hjson
import pathlib
import sys
import re
import logging
from subprocess import run
import csv
from jsonref import JsonRef
from mako.template import Template
import collections
from math import log2
import math

# Compile a regex to trim trailing whitespaces on lines.
re_trailws = re.compile(r'[ \t\r]+$', re.MULTILINE)

def string2int(hex_json_string):
    return (hex_json_string.split('x')[1]).split(',')[0]

def write_template(tpl_path, outdir, outfile, **kwargs):
    if tpl_path:
        tpl_path = pathlib.Path(tpl_path).absolute()
        if tpl_path.exists():
            tpl = Template(filename=str(tpl_path))
            if outfile == None:
                filename = outdir / tpl_path.with_suffix("").name
            else:
                filename = outfile
            with open(filename, "w") as file:
                code = tpl.render_unicode(**kwargs)
                code = re_trailws.sub("", code)
                file.write(code)
        else:
            raise FileNotFoundError

def main():

    # has to be [N_IN_STREAM[N_DMA_CH_PER_IN_STREAM]]
    in_stream_dma_ch_placement = [[0, 1, 2, 3]];
    # has to be [N_IN_STREAM[N_PEA_DIN_PER_IN_STREAM]]
    in_stream_pea_din_placement = [[0, 1, 2, 3]];
    # the entry at poition i,j indicates to which pea col the j-th ch of output stream is connected
    # has to be [N_OUT_STREAM[N_PEA_DOUT_PER_OUT_STREAM]]
    out_stream_pea_dout_placement = [[0, 1, 2, 3]];
    # has to be [N_OUT_STREAM[N_DMA_CH_PER_OUT_STREAM]]
    out_stream_dma_ch_placement = [[0, 1, 2, 3]];

    # has to be [N_PEA_COL][N_IN_MEM]?
    pea_in_mem_placement = [[0, 1, 4, 5], [0, 1, 4, 5], [2, 3, 6, 7], [2, 3, 6, 7]];
    # has to be [N_PEA_COL[N_IN_STREAM]]?
    pea_in_stream_placement = [0, 1, 2, 3];

    parser = argparse.ArgumentParser(prog="mage-gen")
    
    parser.add_argument("--config",
                        metavar="file",
                        type=str,
                        required=False,
                        help="X-Heep general configuration")

    parser.add_argument("--outdir",
                        "-of",
                        type=pathlib.Path,
                        required=True,
                        help="Target directory.")

    parser.add_argument("--outfile",
                        "-o",
                        type=pathlib.Path,
                        required=False,
                        help="Target filename, if omitted the template basename is taken.")

    # Parse arguments.
    # pea
    parser.add_argument("--num_words",
                        metavar="",
                        nargs='?',
                        default="1024",
                        help="")
    
    parser.add_argument("--n_pea_rows",
                        metavar="",
                        nargs='?',
                        default="4",
                        help="")
    
    parser.add_argument("--n_pea_cols",
                        metavar="",
                        nargs='?',
                        default="4",
                        help="")
    
    parser.add_argument("--n_pe_in_mem",
                        metavar="",
                        nargs='?',
                        default="2",
                        help="")
    
    parser.add_argument("--n_pe_in_stream",
                        metavar="",
                        nargs='?',
                        default="2",
                        help="")
    
    parser.add_argument("--n_neigh_pe",
                        metavar="",
                        nargs='?',
                        default="4",
                        help="")

    parser.add_argument("--pea_in_mem_placement",
                        metavar="",
                        nargs='?',
                        default=pea_in_mem_placement,
                        help="")

    parser.add_argument("--pea_in_stream_placement",
                        metavar="",
                        nargs='?',
                        default=pea_in_stream_placement,
                        help="")
    
    parser.add_argument("--n_pea_noc_type",
                        metavar="",
                        nargs='?',
                        default="0",
                        help="")
    
    # stream
    parser.add_argument("--enable_decoupling",
                        metavar="",
                        nargs='?',
                        default="0",
                        help="")
    
    parser.add_argument("--enable_streaming_interface",
                        metavar="",
                        nargs='?',
                        default="0",
                        help="")
    
    parser.add_argument("--in_stream_dma_ch_placement",
                        metavar="",
                        nargs='?',
                        default=in_stream_dma_ch_placement,
                        help="")
    
    parser.add_argument("--in_stream_pea_din_placement",
                        metavar="",
                        nargs='?',
                        default=in_stream_pea_din_placement,
                        help="")
    
    parser.add_argument("--out_stream_dma_ch_placement",
                        metavar="",
                        nargs='?',
                        default=out_stream_dma_ch_placement,
                        help="")

    parser.add_argument("--out_stream_pea_dout_placement",
                        metavar="",
                        nargs='?',
                        default=out_stream_pea_dout_placement,
                        help="")
    

    parser.add_argument("--pkg-sv",
                        metavar="PKG_SV",
                        help="Name of top-level package file (output)")

    parser.add_argument("--tpl-sv",
                        metavar="TPL_SV",
                        help="Name of SystemVerilog template for your module (output)")


    parser.add_argument("--n_dma_ch",
                        metavar="from 2 to 16",
                        nargs='?',
                        default="4",
                        help="Number of DMA channels used to stream data into and out of Mage")
    
    parser.add_argument("--n_in_stream",
                        metavar="from 2 to 16",
                        nargs='?',
                        default="4",
                        help="Number of input streams from DMA ")
    
    parser.add_argument("--n_dma_ch_per_in_stream",
                        metavar="from 2 to 16",
                        nargs='?',
                        default="4",
                        help="Number of DMA channels per input stream")
    
    parser.add_argument("--n_pea_din_per_in_stream",
                        metavar="from 2 to 16",
                        nargs='?',
                        default="4",
                        help="Number of inputs to PEAs per input stream")
    
    parser.add_argument("--n_out_stream",
                        metavar="from 2 to 16",
                        nargs='?',
                        default="4",
                        help="Number of output streams to DMA")
    
    parser.add_argument("--n_pea_dout_per_out_stream",
                        metavar="from 2 to 16",
                        nargs='?',
                        default="4",
                        help="Number of outputs from PEAs per output stream")
    
    parser.add_argument("--n_dma_ch_per_out_stream",
                        metavar="from 2 to 16",
                        nargs='?',
                        default="4",
                        help="Number of DMA channels per output stream")
    
    parser.add_argument("--in_stream_xbar",
                        metavar="",
                        nargs='?',
                        default="0",
                        help="Enable input stream crossbar")
    
    parser.add_argument("--out_stream_xbar",
                        metavar="",
                        nargs='?',
                        default="0",
                        help="Enable output stream crossbar")
    
    # ages
    parser.add_argument("--n_age_tot",
                        metavar="",
                        nargs='?',
                        default="4",
                        help="")
    
    parser.add_argument("--n_age_per_stream",
                        metavar="",
                        nargs='?',
                        default="4",
                        help="")
    
    parser.add_argument("--kernel_len",
                        metavar="",
                        nargs='?',
                        default="4",
                        help="")
    
    parser.add_argument("--row_div",
                        metavar="",
                        nargs='?',
                        default="4",
                        help="")
    
    parser.add_argument("--row_acc",
                        metavar="",
                        nargs='?',
                        default="4",
                        help="")
    
    

    args = parser.parse_args()

    if not args.outdir.is_dir():
            exit("Out directory is not a valid path.")

    outdir = args.outdir
    outdir.mkdir(parents=True, exist_ok=True)

    outfile = args.outfile

    if args.enable_streaming_interface != None and args.enable_streaming_interface != '':
        enable_streaming_interface = args.enable_streaming_interface

    if args.enable_decoupling != None and args.enable_decoupling != '':
        enable_decoupling = args.enable_decoupling

    if args.n_dma_ch != None and args.n_dma_ch != '':
        n_dma_ch = int(args.n_dma_ch)

    if args.num_words != None and args.num_words != '':
        num_words = int(args.num_words)
    
    if args.n_in_stream != None and args.n_in_stream != '':
        n_in_stream = int(args.n_in_stream)
    
    if args.n_dma_ch_per_in_stream != None and args.n_dma_ch_per_in_stream != '':
        n_dma_ch_per_in_stream = int(args.n_dma_ch_per_in_stream)
    
    if args.n_pea_din_per_in_stream != None and args.n_pea_din_per_in_stream != '':
        n_pea_din_per_in_stream = int(args.n_pea_din_per_in_stream)
    
    if args.n_out_stream != None and args.n_out_stream != '':
        n_out_stream = int(args.n_out_stream)
    
    if args.n_pea_dout_per_out_stream != None and args.n_pea_dout_per_out_stream != '':
        n_pea_dout_per_out_stream = int(args.n_pea_dout_per_out_stream)
    
    if args.n_dma_ch_per_out_stream != None and args.n_dma_ch_per_out_stream != '':
        n_dma_ch_per_out_stream = int(args.n_dma_ch_per_out_stream)

    if args.in_stream_xbar != None and args.in_stream_xbar != '':
        in_stream_xbar = args.in_stream_xbar

    if args.out_stream_xbar != None and args.out_stream_xbar != '':
        out_stream_xbar = args.out_stream_xbar

    if args.in_stream_dma_ch_placement != None:
        in_stream_dma_ch_placement = args.in_stream_dma_ch_placement

    if args.in_stream_pea_din_placement != None:
        in_stream_pea_din_placement = args.in_stream_pea_din_placement

    if args.out_stream_dma_ch_placement != None:
        out_stream_dma_ch_placement = args.out_stream_dma_ch_placement

    if args.out_stream_pea_dout_placement != None:
        out_stream_pea_dout_placement = args.out_stream_pea_dout_placement

    if args.n_pea_rows != None and args.n_pea_rows != '':
        n_pea_rows = int(args.n_pea_rows)

    if args.n_pea_cols != None and args.n_pea_cols != '':
        n_pea_cols = int(args.n_pea_cols)

    if args.n_pe_in_mem != None and args.n_pe_in_mem != '':
        n_pe_in_mem = int(args.n_pe_in_mem)  

    if args.n_pe_in_stream != None and args.n_pe_in_stream != '':
        n_pe_in_stream = int(args.n_pe_in_stream)

    if args.n_neigh_pe != None and args.n_neigh_pe != '':
        n_neigh_pe = int(args.n_neigh_pe)

    if args.pea_in_mem_placement != None:
        pea_in_mem_placement = args.pea_in_mem_placement

    if args.pea_in_stream_placement != None:
        pea_in_stream_placement = args.pea_in_stream_placement  

    if args.n_pea_noc_type != None and args.n_pea_noc_type != '':
        n_pea_noc_type = args.n_pea_noc_type

    if args.n_age_tot != None and args.n_age_tot != '':
        n_age_tot = int(args.n_age_tot)

    if args.n_age_per_stream != None and args.n_age_per_stream != '':
        n_age_per_stream = int(args.n_age_per_stream)

    if args.kernel_len != None and args.kernel_len != '':
        kernel_len = int(args.kernel_len)

    if args.row_div != None and args.row_div != '':
        row_div = int(args.row_div)

    if args.row_acc != None and args.row_acc != '':
        row_acc = int(args.row_acc)


    kwargs = {
        "num_words"                        : num_words,
        "n_pea_rows"                       : n_pea_rows,
        "n_pea_cols"                       : n_pea_cols,
        "n_pe_in_mem"                      : n_pe_in_mem,
        "n_pe_in_stream"                   : n_pe_in_stream,
        "n_neigh_pe"                       : n_neigh_pe,
        "pea_in_mem_placement"             : pea_in_mem_placement,
        "pea_in_stream_placement"          : pea_in_stream_placement,
        "n_pea_noc_type"                   : n_pea_noc_type,
        "n_dma_ch"                         : n_dma_ch,
        "enable_streaming_interface"       : enable_streaming_interface,
        "enable_decoupling"                : enable_decoupling,
        "n_in_stream"                      : n_in_stream,
        "n_dma_ch_per_in_stream"           : n_dma_ch_per_in_stream,
        "n_pea_din_per_in_stream"          : n_pea_din_per_in_stream,
        "n_out_stream"                     : n_out_stream,
        "n_pea_dout_per_out_stream"        : n_pea_dout_per_out_stream,
        "n_dma_ch_per_out_stream"          : n_dma_ch_per_out_stream,
        "in_stream_xbar"                   : in_stream_xbar,
        "out_stream_xbar"                  : out_stream_xbar,
        "in_stream_dma_ch_placement"       : in_stream_dma_ch_placement,
        "out_stream_dma_ch_placement"      : out_stream_dma_ch_placement,
        "in_stream_pea_din_placement"      : in_stream_pea_din_placement,
        "out_stream_pea_dout_placement"    : out_stream_pea_dout_placement,
        "n_age_tot"                        : n_age_tot,
        "n_age_per_stream"                 : n_age_per_stream,
        "kernel_len"                       : kernel_len,
        "row_div"                          : row_div,
        "row_acc"                          : row_acc
    }

    ###########
    #   TPL   #
    ###########
    #if args.pkg_sv != None:
        #write_template(args.pkg_sv, outdir, outfile, **kwargs)

    if args.tpl_sv != None:
        write_template(args.tpl_sv, outdir, outfile, **kwargs)

if __name__ == "__main__":
    main()
