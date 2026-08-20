# Simulator configuration
SIM ?= icarus
TOPLEVEL_LANG ?= verilog

# Project paths
PROJECT_ROOT := $(abspath ..)
VENV_ROOT := $(PROJECT_ROOT)/venv
PYTHON_BIN := $(VENV_ROOT)/Scripts/python.exe

# Required for Cocotb's embedded Python on this Windows setup
export VIRTUAL_ENV := $(VENV_ROOT)
export PYGPI_PYTHON_BIN := $(PYTHON_BIN)
export PYTHONPATH := $(VENV_ROOT)/Lib/site-packages

# RTL source files
VERILOG_SOURCES := $(abspath ../sources/Neuromorphic_Lattice/source/impl_1/network_tb.v)
VERILOG_SOURCES += $(abspath ../sources/Neuromorphic_Lattice/source/impl_1/ram.v)
VERILOG_SOURCES += $(abspath ../sources/Neuromorphic_Lattice/source/impl_1/weight_manager_unit.v)
VERILOG_SOURCES += $(abspath ../sources/Neuromorphic_Lattice/source/impl_1/weight_multiply_array.v)
VERILOG_SOURCES += $(abspath ../sources/Neuromorphic_Lattice/source/impl_1/weight_multiply_unit.v)
VERILOG_SOURCES += $(abspath ../sources/Neuromorphic_Lattice/source/impl_1/spike_neuron.v)
VERILOG_SOURCES += $(abspath ../sources/Neuromorphic_Lattice/source/impl_1/spike_array.v)
VERILOG_SOURCES += $(abspath ../sources/Neuromorphic_Lattice/source/impl_1/constants.vh)

# Verilog top-level module
COCOTB_TOPLEVEL := network_tb

# Python test module lattice_tb.py
COCOTB_TEST_MODULES := lattice_tb

# Use Cocotb from this exact virtual environment
COCOTB_CONFIG := $(PYTHON_BIN) -m cocotb_tools.config

include $(shell $(COCOTB_CONFIG) --makefiles)/Makefile.sim