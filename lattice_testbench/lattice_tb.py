import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, RisingEdge, ReadOnly
import random
import matplotlib.pyplot as plt
import numpy as np


@cocotb.test(timeout_time=1000, timeout_unit="ns")
async def test_ffn(dut):

    clock = Clock(dut.clk, 2, unit="ns")
    clock.start(start_high=False)

    dut.network_inputs.value = 0B11011

    await RisingEdge(dut.clk)
    await ReadOnly()

    await FallingEdge(dut.clk)

    for i in range(100):
        await RisingEdge(dut.clk)
        await ReadOnly()
        
        await FallingEdge(dut.clk)
        cocotb.log.info("network_outputs is %s", dut.network_outputs)#wmu.weights_out)
        cocotb.log.info("input is %s", dut.network_inputs)