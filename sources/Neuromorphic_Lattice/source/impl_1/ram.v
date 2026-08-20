// Parameterized Single-Port Synchronous RAM with File Initialization
module single_port_ram #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
)(
    input                      clk,
    input                      write_enable,
    input     [ADDR_WIDTH-1:0] address,
    input     [DATA_WIDTH-1:0] data_in,
    output reg [DATA_WIDTH-1:0] data_out
);

    // Declare the memory array
    reg [DATA_WIDTH-1:0] memory [0:(1<<ADDR_WIDTH)-1];

    // File Initialization Block
    initial begin
        // Use $readmemb for binary file data instead
        $readmemh("memory_init.txt", memory); 
    end

    // Synchronous Write and Read Logic
    always @(posedge clk) begin
        if (write_enable) begin
            memory[address] <= data_in;
        end
        data_out <= memory[address];     
    end

endmodule