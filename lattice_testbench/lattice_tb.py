import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, RisingEdge, ReadOnly
import random
import matplotlib.pyplot as plt
import numpy as np


@cocotb.test(timeout_time=10000, timeout_unit="ns")
async def test_ffn(dut):

    clock = Clock(dut.clk, 2, unit="ns")
    clock.start(start_high=False)

    dut.network_inputs.value = 0B11

    await RisingEdge(dut.clk)
    await ReadOnly()

    await FallingEdge(dut.clk)

    for i in range(1000):
        await RisingEdge(dut.clk)
        await ReadOnly()
        
        await FallingEdge(dut.clk)
        cocotb.log.info("___________________________________________________________________")
        cocotb.log.info("inputs are %s, potentials are %s, spike outputs are %s",
                         dut.network_inputs.value, 
                         dut.wma_outputs.value,
                         dut.network_outputs.value,
                         )
        cocotb.log.info("loaded weights are %s", dut.wma.weights_in)
        cocotb.log.info("wma outputs: %s", dut.wma_outputs.value)       
        cocotb.log.info("***** neuron 1 *****")
        cocotb.log.info("neuron 1 input current %s", dut.sa.GEN_NEURONS[0].sn.input_current.value)
        cocotb.log.info("neuron 1 potential current %s", dut.sa.GEN_NEURONS[0].sn.potential.value)
        cocotb.log.info("neuron 1 decayed potential %s", dut.sa.GEN_NEURONS[0].sn.potential_decayed.value)
        cocotb.log.info("***** neuron 2 *****")
        cocotb.log.info("neuron 2 input current %s", dut.sa.GEN_NEURONS[1].sn.input_current.value)
        cocotb.log.info("neuron 2 potential current %s", dut.sa.GEN_NEURONS[1].sn.potential.value)
        cocotb.log.info("neuron 2 decayed potential %s", dut.sa.GEN_NEURONS[1].sn.potential_decayed.value)
        #cocotb.log.info("network_outputs is %s", dut.network_outputs)#wmu.weights_out)
        #cocotb.log.info("input is %s", dut.network_inputs)
        #cocotb.log.info("ram output is %s", dut.ram.data_out)
