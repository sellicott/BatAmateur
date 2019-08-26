`timescale 1ns/1ns

module memory_tb ();

wire [15:0] address;
wire clk;
wire load;
wire out_en;
wire reset;
wire [15:0] data;

memory_stim my_stim
(
    .address(address),
    .clk(clk),
    .load(load),
    .out_en(out_en),
    .reset(reset),
    .data_in(data),
    .data_out(data)
);

memory my_memory
(
    .address(address),
    .clk(clk),
    .load(load),
    .out_en(out_en),
    .reset(reset),
    .data_in(data),
    .data_out(data)
);

endmodule
