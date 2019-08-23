`timescale 1ns/1ns

module memory
(
    address,    // address of the memory to be accessed
    clk,        // clock
    read_write, // high for reading low for writing 
    enable,     // must be high to access the memory 
    output_en,  // output enable
    reset,      // reset memory to zero
    data_in,        // bi-dir connection to the data register
    data_out,
);

// constants
parameter address_size = 16;
parameter memory_size = 2 ** address_size;

// inputs
input wire [address_size-1:0] address;                 
input wire clk, read_write, enable, reset, output_en;
input wire [15:0] data_in;

// output
output reg [15:0] data_out;

// internal
reg [15:0] memory_registers [memory_size-1:0];
reg [15:0] mdr;
integer k;

assign data_out = (enable && read_write && output_en) ? mdr : 16'bz; 

always @ (posedge clk or reset)
begin 
    if (reset == 1'b0)
    begin
        mdr <= {16{1'b0}};

        for (k = 0; k < memory_size; k = k + 1)
        begin 
            memory_registers[k] <= {16{1'b0}};
        end
    end
    else
    begin
        if (enable) 
        begin 
            if (read_write && output_en) 
            begin
               mdr <= memory_registers[address];    
            end else begin 
               memory_registers[address] <= data_in; 
            end
        end     
    end
end

endmodule
