`timescale 1ns/1ns

module bat_amateur_tb ();
parameter ADDRESS_WIDTH = 16;

wire CLK;
wire RESET;
wire HALT;
wire RAM_RW;
wire [15:0] DATA_BUS;
wire [ADDRESS_WIDTH-1:0] ADDRESS_BUS;
wire [15:0] OUTPUT_BUS;

bat_amateur my_bat_amateur (
    .DATA(DATA_BUS),
    .ADDRESS(ADDRESS_BUS),
    .EXT_RAM_RW(RAM_RW),
    .EXT_RAM_EN(HALT),
    .HALT(HALT),
    .CLK(CLK),
    .RST(RESET),
    .OUT(OUTPUT_BUS)
);

bat_amateur_stim my_bat_amateur_stim (
    .HALT(HALT),
    .CLK(CLK),
    .RESET(RESET),
    .RAM_RW(RAM_RW),
    .RAM_EN(RAM_EN),
    .DATA_BUS(DATA_BUS),
    .ADDRESS_BUS(ADDRESS_BUS),
    .OUTPUT_BUS(OUTPUT_BUS)
);

endmodule