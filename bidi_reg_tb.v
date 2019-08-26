`timescale 1ns/1ns

module bidi_reg_tb();

wire RESET;
wire CLOCK;
wire RW;
wire ENABLE;
wire COUNT;
wire [15:0] DATA;

bidi_reg_stim my_stim
(
    .RESET(RESET),
    .CLOCK(CLOCK),
    .RW(RW),
    .ENABLE(ENABLE),
    .COUNT(COUNT),
    .DATA_OUT(DATA),
    .DATA_IN(DATA)
);

bidi_register my_register
(
    .RESET(RESET),
    .CLOCK(CLOCK),
    .RW(RW),
    .ENABLE(ENABLE),
    .COUNT(COUNT),
    .DATA(DATA)
);

endmodule
