`timescale 1ns/1ns

module memory_tb ();

wire [15:0] address;
wire clk;
wire load;
wire enable;
wire output_en;
wire reset;
wire [15:0] data;

memory_stim my_stim
(
    .address(address),
    .clk(clk),
    .load(load),
    .enable(enable),
    .output_en(output_en),
    .reset(reset),
    .data_in(data),
    .data_out(data)
);

memory my_memory
(
    .address(address),
    .clk(clk),
    .load(load),
    .enable(enable),
    .reset(reset),
    .data_in(data),
    .data_out(data)
);

endmodule
