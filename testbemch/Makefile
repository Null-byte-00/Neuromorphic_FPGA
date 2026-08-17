# Simulator configuration
SIM ?= icarus
TOPLEVEL_LANG ?= verilog

# Project paths
PROJECT_ROOT := $(abspath ..)

# Force cocotb to use this project's virtual environment
PYTHON_BIN := $(PROJECT_ROOT)/venv/Scripts/python.exe

export PYGPI_PYTHON_BIN := $(PYTHON_BIN)
export PYTHONPATH := $(PROJECT_ROOT)/venv/Lib/site-packages

# RTL source files
VERILOG_SOURCES := $(abspath ../sources/Neuromorphic_FPGA/src/ffn_network.v)

# Exact name of the top-level Verilog module
COCOTB_TOPLEVEL := ffn_22_netwok

# Python file: test_ffn_verilog.py
COCOTB_TEST_MODULES := test_ffn_verilog

# cocotb simulator rules
include $(shell cocotb-config --makefiles)/Makefile.sim