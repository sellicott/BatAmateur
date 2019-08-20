`timescale 1ns/1ns

module memory
(
    address,    // address of the memory to be accessed
    clk,        // clock
    read_write, // high for reading low for writing 
    enable,     // must be high to access the memory 
    reset,      // reset memory to zero
    data        // bi-dir connection to the data register
);

// constants
parameter address_size = 16;
parameter memory_size = 2 ** address_size;

// inputs
input wire [address_size-1:0] address;                 
input wire clk, read_write, enable, reset;

// output
inout wire [15:0] data;

// internal
reg [15:0] memory_registers [memory_size-1:0];
reg [15:0] mdr;
integer k;

always @ (posedge clk or reset)
begin 
    if (!reset)
    begin
        mdr = 0;

        for (k = 0; k < memory_size; k = k + 1)
        begin 
            memory[k] = 0;
        end
    end
    else
    begin
        if (enable) 
        begin 
            if (read_write) 
            begin
               mdr = memory[address];    
               data = mdr;
            end else
            begin 
               mdr = data;
               memory[address] = mdr; 
            end
        end else 
        begin
            data = 'bz;
        end
    end
end

endmodule
