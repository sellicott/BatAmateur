`timescale 1ns/1ns

module bat_amateur_stim (
HALT,
CLK,
RESET,
RAM_RW,
RAM_EN,
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
output reg RAM_RW;
output reg RAM_EN;
output reg [15:0] DATA_BUS;
output reg [15:0] ADDRESS_BUS;
input  wire [15:0] OUTPUT_BUS;

initial begin
    CLK = 1'b0;
    RESET = 1'b0;
    HALT = 1'b1;
    RAM_EN = 1'b0;
    RAM_RW = 1'b0; // write ram
    ADDRESS_BUS = {ADDRESS_WIDTH{1'b0}};
    DATA_BUS = {16{1'b0}};
    // load in data values
#CLK_PERIOD
    RESET = 1'b1;
    RAM_EN = 1'b1;
    RAM_RW = 1'b0; // write ram
    ADDRESS_BUS = 16'h0010;
    DATA_BUS = 16'd5;
#CLK_PERIOD
    ADDRESS_BUS = 16'h0011;
    DATA_BUS = 16'd0;
#CLK_PERIOD
    ADDRESS_BUS = 16'h0012;
    DATA_BUS = 16'd1;

    // load the instructions
    // LDA <value 5>
#CLK_PERIOD
    ADDRESS_BUS = 16'h0000;
    DATA_BUS = 16'h0010;
    // MOV R3 <- A
#CLK_PERIOD
    ADDRESS_BUS = 16'h0001;
    DATA_BUS = 16'h7F98;
// LDB VAL 0
#CLK_PERIOD
    ADDRESS_BUS = 16'h0002;
    DATA_BUS = 16'h1011;
// LDA VAL 1
#CLK_PERIOD
    ADDRESS_BUS = 16'h0003;
    DATA_BUS = 16'h0012;
// MOV R2 <- A 
#CLK_PERIOD
    ADDRESS_BUS = 16'h0004;
    DATA_BUS = 16'h7FA0;
// MOV R7 <- R2 
#CLK_PERIOD
    ADDRESS_BUS = 16'h0005;
    DATA_BUS = 16'h7FFA;
// B <- R2 + B 
#CLK_PERIOD
    ADDRESS_BUS = 16'h0006;
    DATA_BUS = 16'h7F51;
// MOV A <- R2 
#CLK_PERIOD
    ADDRESS_BUS = 16'h0007;
    DATA_BUS = 16'h7F82;
// MOV R2 <- B
#CLK_PERIOD
    ADDRESS_BUS = 16'h0008;
    DATA_BUS = 16'h7F88;
// MOV B <- A
#CLK_PERIOD
    ADDRESS_BUS = 16'h0009;
    DATA_BUS = 16'h7FFA;
// MOV R7 <- R2
#CLK_PERIOD
    ADDRESS_BUS = 16'h000A;
    DATA_BUS = 16'h7FFA;
// DEC r3
#CLK_PERIOD
    ADDRESS_BUS = 16'h000B;
    DATA_BUS = 16'h7399;
// MOV R3 <- A 
#CLK_PERIOD
    ADDRESS_BUS = 16'h000C;
    DATA_BUS = 16'h7F98;
// JNZ 0x0006
#CLK_PERIOD
    ADDRESS_BUS = 16'h000D;
    DATA_BUS = 16'h5006;
// JMP 0x000E 
#CLK_PERIOD
    ADDRESS_BUS = 16'h000E;
    DATA_BUS = 16'h400E;

#CLK_PERIOD
  ADDRESS_BUS = {16{1'bz}};
  DATA_BUS = {16{1'bz}};
  RAM_EN = 1'b0;
  RAM_RW = 1'b1;
  HALT = 1'b0;
end 

always #CLK_HALF_PERIOD CLK = !CLK;

endmodule