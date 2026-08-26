import random

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


@cocotb.test(timeout_time=20000, timeout_unit="ns")
async def test_ffn(dut):

    # Start clock
    clock = Clock(dut.clk, 2, unit="ns")
    clock.start(start_high=False)

    input_width = len(dut.network_inputs)
    hidden_size = len(dut.hidden_spikes)
    output_size = len(dut.network_outputs)

    # Reset
    dut.reset.value = 1
    dut.network_inputs.value = 0

    for _ in range(3):
        await RisingEdge(dut.clk)

    dut.reset.value = 0

    # Wait for RAM weights to be distributed to both layers
    while True:
        await RisingEdge(dut.clk)
        await ReadOnly()

        if int(dut.weights_loaded.value) == 1:
            break

    cocotb.log.info("Weights loaded")

    current_input = 0

    for cycle in range(1000):

        await FallingEdge(dut.clk)

        # Change the input only when layer 1 is about to latch
        # a new input vector.
        if int(dut.layer1_start.value) == 1:
            current_input = random.randrange(1 << input_width)
            dut.network_inputs.value = current_input

            cocotb.log.info(
                "New input vector: %s",
                f"{current_input:0{input_width}b}",
            )

        await RisingEdge(dut.clk)
        await ReadOnly()

        layer1_values = unpack_signed_words(
            dut.layer1_currents.value,
            count=hidden_size,
            width=16,
        )

        layer2_values = unpack_signed_words(
            dut.layer2_currents.value,
            count=output_size,
            width=16,
        )

        cocotb.log.info(
            "cycle=%d L1 busy=%d done=%d L2 busy=%d done=%d",
            cycle,
            int(dut.layer1_busy.value),
            int(dut.layer1_done.value),
            int(dut.layer2_busy.value),
            int(dut.layer2_done.value),
        )

        if int(dut.layer1_done.value) == 1:
            cocotb.log.info(
                "Final layer1 currents for input %s: %s",
                f"{current_input:0{input_width}b}",
                layer1_values,
            )

            cocotb.log.info(
                "Hidden spikes: %s",
                dut.hidden_spikes.value,
            )

        if int(dut.layer2_done.value) == 1:
            cocotb.log.info(
                "Final layer2 currents: %s",
                layer2_values,
            )

        cocotb.log.info(
            "Output spikes: %s",
            dut.network_outputs.value,
        )