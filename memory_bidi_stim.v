`timescale 1ns/1ns

module memory_bidi_stim (
    reset,
    clk,
    read_write,
    enable,
    address,
    data_in,
    data_out
);

output reg reset;
output reg clk;
output reg read_write;
output reg enable;
output reg [15:0] address;
output reg [15:0] data_out;
input wire [15:0] data_in;


initial begin
    reset = 1'b0;
    clk = 1'b0;
    read_write = 1'b1;
    enable = 1'b0;
    address = 16'h0000;
    data_out = {16{1'hz}};

#10
    reset = 1'b1;
    // write some data
    read_write = 1'b0; // write
    enable = 1'b1;
    address = 16'h0000;
    data_out = 16'h5A5A;

#10
    read_write = 1'b0; // write
    enable = 1'b1;
    address = 16'h0010;
    data_out = 16'hA5A5;

#10
    // blank space 
    read_write = 1'b1;
    enable = 1'b0;
    address = 16'h0000;
    data_out = {16{1'hz}};

#10
    // read data
    read_write = 1'b1; // read
    enable = 1'b1;
    address = 16'h0000;
    $display(data_in);

#10
    read_write = 1'b1; // read
    enable = 1'b1;
    address = 16'h0010;
    $display(data_in);
end

always #5 clk <= ~clk;

endmodule
