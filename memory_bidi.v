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
parameter memory_size = 256;

// inputs
input wire reset, clk, read_write, enable;
input wire [address_size-1:0] address;                 
inout wire [15:0] data;

wire [15:0] small_address;

// internal
reg [15:0] memory_registers [memory_size-1:0];

always @ (posedge clk)
begin 
    if (enable && !read_write) begin
        memory_registers[small_address] <= data;
    end
end

assign small_address = { {8{1'b0}}, address[7:0] };

assign data = (enable && read_write) ? memory_registers[small_address] : {16{1'bz}};

endmodule
