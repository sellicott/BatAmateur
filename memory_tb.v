`timescale 1ns/1ns

module memory_tb ();

wire [15:0] address;
wire clk;
wire read_write;
wire enable;
wire reset;
wire [15:0] data;

memory_stim my_stim
(
    .address(address),
    .clk(clk),
    .read_write(read_write),
    .enable(enable),
    .reset(reset),
    .data_in(data),
    .data_out(data)
);

memory my_memory
(
    .address(address),
    .clk(clk),
    .read_write(read_write),
    .enable(enable),
    .reset(reset),
    .data(data)
);

endmodule
