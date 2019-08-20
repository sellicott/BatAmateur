`timescale 1ns/1ns

module bat_amateur_stim (
    HALT
    CLK,
    RESET,
    DATA_BUS,
    ADDRESS_BUS,
    OUTPUT_BUS
);
parameter CLK_HALF_PERIOD = 5;
parameter CLK_PERIOD = 2*CLK_HALF_PERIOD;
parameter ADDRESS_WIDTH = 16;

output reg HALT;
output reg CLK;
output reg RESET;
inout  wire DATA_BUS;
output wire ADDRESS_BUS;
input  wire OUTPUT_BUS;

initial begin
    CLK = 1'b0;
    RESET = 1'b1;
    HALT = 1'b1;
    ADDRESS_BUS = {ADDRESS_WIDTH{1'b0}};
    // load in data values
#CLK_PERIOD
    RESET = 1'b0;
    ADDRESS_BUS = 16'h0010;
    DATA_BUS = 16'd0;
#CLK_PERIOD
    ADDRESS_BUS = 16'h0011;
    DATA_BUS = 16'd1;
#CLK_PERIOD
    ADDRESS_BUS = 16'h0012;
    DATA_BUS = 16'd5;

    // load the instructions
    // LDA <value 5>
#CLK_PERIOD
    ADDRESS_BUS = 16'h0000;
    DATA_BUS = 16'h0012;
    // MOV A -> R3
#CLK_PERIOD
    ADDRESS_BUS = 16'h0001;
    DATA_BUS = (4'b0111 << 12) | ((5'b11111 << 7) | (3'h3 << 3) | (3'h0 << 0);
// LDA VAL 0
#CLK_PERIOD
    ADDRESS_BUS = 16'h0002;
    DATA_BUS = 16'h0010;
// LDA VAL 1
#CLK_PERIOD
    ADDRESS_BUS = 16'h0003;
    DATA_BUS = 16'h0011;
// A+B -> A
#CLK_PERIOD
    ADDRESS_BUS = 16'h0004;
    DATA_BUS = (4'b0111 << 12) | ((5'b00000 << 7) | (1'b0 << 7) | (3'h0 << 3) | (3'h1 << 0);
// MOV B -> R2
#CLK_PERIOD
    ADDRESS_BUS = 16'h0005;
    DATA_BUS = (4'b0111 << 12) | ((5'b11111 << 7) | (3'h2 << 3) | (3'h1 << 0);
// MOV A -> B 
#CLK_PERIOD
    ADDRESS_BUS = 16'h0006;
    DATA_BUS = (4'b0111 << 12) | ((5'b11111 << 7) | (3'h1 << 3) | (3'h0 << 0);
// MOV R2 -> A 
#CLK_PERIOD
    ADDRESS_BUS = 16'h0007;
    DATA_BUS = (4'b0111 << 12) | ((5'b11111 << 7) | (3'h0 << 3) | (3'h2 << 0);
// DEC r3
#CLK_PERIOD
    ADDRESS_BUS = 16'h0008;
    DATA_BUS = 16'h73E1;
// JNZ 0x04
#CLK_PERIOD
    ADDRESS_BUS = 16'h0009;
    DATA_BUS = 16'h6FFA;
// NOP
#CLK_PERIOD
    ADDRESS_BUS = 16'h000A;
    DATA_BUS = 16'hF000;
// JMP -1 
#CLK_PERIOD
    ADDRESS_BUS = 16'h000B;
    DATA_BUS = 16'h4FFF;

#CLK_PERIOD
  ADDRESS_BUS = 16'h0;
  DATA_BUS = {16{1'bz}};
  HALT = 1'b0;
end 

assign #CLK_HALF_PERIOD CLK = !CLK;

endmodule