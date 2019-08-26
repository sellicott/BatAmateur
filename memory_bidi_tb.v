`timescale 1ns/1ns

module memory_bidi_tb ();

wire reset;
wire clk;
wire read_write;
wire enable;
wire [15:0] address;
wire [15:0] data;

memory_bidi_stim my_stim
(
    .reset(reset),
    .clk(clk),
    .read_write(read_write),
    .enable(enable),
    .address(address),
    .data_in(data),
    .data_out(data)
);

memory_bidi my_memory
(
    .reset(reset),
    .clk(clk),
    .read_write(read_write),
    .enable(enable),
    .address(address),
    .data(data)
);

endmodule
