`timescale 1ns/1ns

module memory_stim (
    address,
    clk,
    read_write,
    enable,
    reset,
    data_in,
    data_out
);

output reg address;
output reg clk;
output reg read_write;
output reg enable;
output reg reset;
output reg data_out;
input wire data_in;


initial begin
    clk <= 0'b0;
    reset <= 0'b0;
    enable <= 0'b0;
    read_write <= 0'b1;
    address <= 16'h0000;
#10
    address <= 16'h0000;
    read_write = 0'b0;
    enable = 1'b1;
    data_out = 16'h5A5A;

#10
    address <= 16'h0010;
    read_write = 0'b0;
    enable = 1'b1;
    data_out = 16'hA5A5;
// read data
#10
    data_out = 16'hzzzz;
    address <= 16'h0000;
    read_write = 0'b1;
    enable = 1'b1;

#10
    address <= 16'h0010;
    read_write = 0'b1;
    enable = 1'b1;
end

always #5 clk <= ~clk;

endmodule
