`timescale 1ns/1ns

module memory
(
    address,    // address of the memory to be accessed
    clk,        // clock
    load,       // high for reading low for writing 
    out_en,     // must be high to access the memory 
    reset,      // reset memory to zero
    data_in,    // bi-dir connection to the data register
    data_out
);

// constants
parameter address_size = 16;
parameter memory_size = 2 ** address_size;

// inputs
input wire [address_size-1:0] address;                 
input wire clk, load, out_en, reset;
input wire [15:0] data_in;

// output
output reg [15:0] data_out;

// internal
reg [15:0] memory_registers [memory_size-1:0];
integer k;


always @ (posedge clk)
begin 
    if (out_en) 
    begin 
        data_out <= memory_registers[address];
    end     
    else begin
        data_out <= {16{1'bz}};
    end

    if (load) 
    begin
        memory_registers[address] <= data_in;
    end
end

endmodule
