`timescale 1ns/1ns

module memory_bidi
(
    reset,      // reset memory to zero
    clk,        // clock
    read_write, // high for reading low for writing 
    enable,     // must be high to access the memory 
    address,    // address of the memory to be accessed
    data        // bi-dir connection to the data register
);

// constants
parameter address_size = 16;
parameter memory_size = 2 ** address_size;

// inputs
input wire reset, clk, read_write, enable;
input wire [address_size-1:0] address;                 
inout wire [15:0] data;

// internal
reg [15:0] memory_registers [memory_size-1:0];
reg [15:0] data_out;

always @ (negedge clk)
begin 
    if (!read_write) begin
        if (enable) begin
            memory_registers[address] <= data;
         end
    end 
    else begin
        data_out <= memory_registers[address];
    end
end

assign data = (enable && read_write) ? data_out : {16{1'bz}};

endmodule