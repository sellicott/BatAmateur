`timescale 1ns/1ns

module memory_stim (
    address,
    clk,
    load,
    enable,
    output_en,
    reset,
    data_in,
    data_out
);

output reg [15:0] address;
output reg clk;
output reg read_write;
output reg enable;
output reg output_en;
output reg reset;
output reg [15:0] data_out;
input wire [15:0] data_in;


initial begin
    clk = 1'b0;
    reset = 1'b0;
    enable = 1'b0;
    output_en = 1'b0;
    load = 1'b1;
    address = 16'h0000;
#10
    reset = 1'b1;
    address = 16'h0000;
    load = 1'b1;
    enable = 1'b1;
    data_out = 16'h5A5A;

#10
    address = 16'h0010;
    load = 1'b1;
    enable = 1'b1;
    data_out = 16'hA5A5;
// read data
#10
    data_out = 16'hzzzz;
    address = 16'h0000;
    load = 1'b0;
    enable = 1'b1;
    output_en = 1'b0;
#10
    data_out = 16'hzzzz;
    address = 16'h0000;
    load = 1'b0;
    enable = 1'b1;
    output_en = 1'b1;

#10
    address = 16'h0010;
    load = 1'b0;
    enable = 1'b1;
    output_en = 1'b1;
end

always #5 clk <= ~clk;

endmodule
