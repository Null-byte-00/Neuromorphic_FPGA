import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, RisingEdge, ReadOnly
import random
import matplotlib.pyplot as plt
import numpy as np

random_spike_train_in1 = random.choices([0, 1], weights=[0.7, 0.3], k=100)

@cocotb.test(timeout_time=1000, timeout_unit="ns")
async def test_ffn(dut):
    u1_potentials = []
    in_spikes = []
    out_spikes = []

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
        u1_potentials.append(int(dut.u1.value))
        await FallingEdge(dut.clk)

        dut.in1.value = random_spike_train_in1[i]
        cocotb.log.info("u1 is %s", dut.u1.value)
        cocotb.log.info("out1 is %s", dut.out1.value)
        cocotb.log.info("u2 is %s", dut.u2.value)
        cocotb.log.info("out2 is %s", dut.out2.value)
            
        await RisingEdge(dut.clk)
        await ReadOnly()

        in_spikes.append(int(dut.in1))
        out_spikes.append(int(dut.out1))


    x_axis = np.array(range(len(u1_potentials)))
    y_axis = np.array(u1_potentials)


    fig, ax = plt.subplots(figsize=(8, 5))

    ax.plot(x_axis, y_axis, label='Membrane potential', color='royalblue', linewidth=2, linestyle='-')
    #ax.plot(x_axis, np.array(in_spikes) + 80, label='input spikes', color='red', linewidth=2, linestyle='-')
    #ax.plot(x_axis, np.array(out_spikes) - 10, label='output spikes', color='green', linewidth=2, linestyle='-')
    in_spikes = np.array(in_spikes)
    out_spikes = np.array(out_spikes)

    in_mask = (in_spikes == 1)
    out_mask = (out_spikes == 1)

    plt.scatter(x_axis[in_mask], in_spikes[in_mask] + 80)
    plt.scatter(x_axis[out_mask], out_spikes[out_mask] - 10)


    plt.show()