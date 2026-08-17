import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, RisingEdge, ReadOnly


@cocotb.test(timeout_time=100, timeout_unit="ns")
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

    for i in range(10):
        await FallingEdge(dut.clk)
        
        cocotb.log.info("u1 is %s", dut.u1.value)
        cocotb.log.info("out1 is %s", dut.out1.value)
        cocotb.log.info("u2 is %s", dut.u2.value)
        cocotb.log.info("out2 is %s", dut.out2.value)
            
        await RisingEdge(dut.clk)
        await ReadOnly()
