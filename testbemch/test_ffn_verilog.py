import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, RisingEdge, ReadOnly
import random
import matplotlib.pyplot as plt
import numpy as np

random_spike_train_in1 = [random.randint(0, 1) for _ in range(100)]
u1_potentials = []
in_spikes = []
out_spikes = []

@cocotb.test(timeout_time=1000, timeout_unit="ns")
async def test_ffn(dut):
    dut.in1.value = 0
    dut.in2.value = 0
    #dut.reset.value = 1

    clock = Clock(dut.clk, 2, unit="ns")
    clock.start(start_high=False)

    #dut.reset.value = 1

    await RisingEdge(dut.clk)
    await ReadOnly()

    cocotb.log.info("Initial out1 is %s", dut.out1.value)
    cocotb.log.info("Initial out2 is %s", dut.out2.value)

    await FallingEdge(dut.clk)
    #dut.reset.value = 0

    dut.in1.value = 1
    dut.in2.value = 1

    await RisingEdge(dut.clk)
    await ReadOnly()

    for i in range(100):
        await FallingEdge(dut.clk)

        dut.in1.value = random_spike_train_in1[i]
        cocotb.log.info("u1 is %s", dut.u1.value)
        cocotb.log.info("out1 is %s", dut.out1.value)
        cocotb.log.info("u2 is %s", dut.u2.value)
        cocotb.log.info("out2 is %s", dut.out2.value)
            
        await RisingEdge(dut.clk)
        await ReadOnly()

        u1_potentials.append(int(dut.u1.value))
        in_spikes.append(int(dut.in1))
        out_spikes.append(int(dut.out1))


    x_axis = np.array(range(len(u1_potentials)))
    y_axis = np.array(u1_potentials)


    fig, ax = plt.subplots(figsize=(8, 5))

    ax.plot(x_axis, y_axis, label='Membrane potential', color='royalblue', linewidth=2, linestyle='-')
    ax.plot(x_axis, in_spikes, label='input spikes', color='red', linewidth=2, linestyle='-')
    ax.plot(x_axis, out_spikes, label='output spikes', color='green', linewidth=2, linestyle='-')

    plt.show()