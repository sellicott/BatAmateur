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
integer k;


always @ (posedge clk or reset)
begin 
    if (!reset) begin
        for (k = 0; k < memory_size; k = k + 1)
        begin 
            memory_registers[k] <= {16{1'b0}};
        end
    end
    else if (enable && read_write == 0) begin
        memory_registers[address] <= data;
    end
end

assign data = (enable && read_write == 1) ? memory_registers[address] : {16{1'bz}};

endmodule
