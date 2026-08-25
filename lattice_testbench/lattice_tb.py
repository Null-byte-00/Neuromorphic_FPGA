import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, RisingEdge, ReadOnly


def unpack_signed_words(bus_value, count, width=16):

    raw = int(bus_value)
    mask = (1 << width) - 1
    sign_bit = 1 << (width - 1)

    values = []

    for index in range(count):
        word = (raw >> (index * width)) & mask

        if word & sign_bit:
            word -= 1 << width

        values.append(word)

    return values


@cocotb.test(timeout_time=10000, timeout_unit="ns")
async def test_ffn(dut):

    Clock(dut.clk, 2, unit="ns").start(start_high=False)

    dut.reset.value = 1
    dut.network_inputs.value = 0

    for _ in range(3):
        await RisingEdge(dut.clk)

    dut.reset.value = 0

    while True:
        await RisingEdge(dut.clk)
        await ReadOnly()

        if int(dut.weights_loaded.value) == 1:
            break

    assert int(dut.weights_loaded.value) == 1

    cocotb.log.info("Weights loaded")

    await FallingEdge(dut.clk)
    dut.network_inputs.value = 0b10000

    hidden_size = 20

    for cycle in range(300):
        await RisingEdge(dut.clk)
        await ReadOnly()


        cocotb.log.info("_________________________________________________________________")
        layer1_values = unpack_signed_words(
            dut.layer1_currents.value,
            count=hidden_size,
            width=16,
        )

        cocotb.log.info(
            "cycle=%d layer1 currents=%s",
            cycle,
            layer1_values,
        )

        cocotb.log.info(
            "cycle=%d hidden spikes=%s output spikes=%s",
            cycle,
            dut.hidden_spikes.value,
            dut.network_outputs.value,
        )

        layer2_values = unpack_signed_words(
        dut.layer2_currents.value,
        count=5,
        width=16,
        )

        cocotb.log.info("layer2 currents=%s", layer2_values)