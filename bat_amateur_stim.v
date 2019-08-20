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

// memory operations
parameter iLDA 16'0000;
parameter iLDB ;
parameter iSTA ;
parameter iSTB ;
parameter iJMP ;
parameter iJZC ;
parameter iJNZ ;
parameter iNOP ;

// register operations
parameter iAND ;
parameter iOR ;
parameter iNOT;
parameter iXOR;
parameter iADD;
parameter iSUB;
parameter iINV;
parameter iINC;
parameter iDEC;
parameter iMOV;

initial begin
    CLK = 1'b0;
    RESET = 1'b0;
    HALT = 1'b1;
    ADDRESS_BUS = {ADDRESS_WIDTH{1'b0}};
    // load in data values
#CLK_PERIOD
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
    DATA_BUS = iLDA | 16'h12;
    // MOV A -> R2
#CLK_PERIOD
    ADDRESS_BUS = 16'h0001;
    DATA_BUS = 4'b0111 | ((5'b11111 << 7) | (3'h3 << 3) | (3'h0 << 0);
// LDA VAL 0
#CLK_PERIOD
    ADDRESS_BUS = 16'h0002;
    DATA_BUS = iLDA | 16'h10;
// LDA VAL 1
#CLK_PERIOD
    ADDRESS_BUS = 16'h0003;
    DATA_BUS = iLDA | 16'h10;
// A+B -> A
#CLK_PERIOD
    ADDRESS_BUS = 16'h0004;
    DATA_BUS = ;
// MOV B -> R1
#CLK_PERIOD
    ADDRESS_BUS = 16'h0005;
    DATA_BUS = ;
// MOV A -> B 
#CLK_PERIOD
    ADDRESS_BUS = 16'h0006;
    DATA_BUS = ;
// MOV R1 -> A 
#CLK_PERIOD
    ADDRESS_BUS = 16'h0007;
    DATA_BUS = ;
// DEC r2
#CLK_PERIOD
    ADDRESS_BUS = 16'h0008;
    DATA_BUS = ;
// JNZ 0x04
#CLK_PERIOD
    ADDRESS_BUS = 16'h0009;
    DATA_BUS = ;
// NOP
#CLK_PERIOD
    ADDRESS_BUS = 16'h000A;
    DATA_BUS = ;
// JMP -1 
#CLK_PERIOD
    ADDRESS_BUS = 16'h000B;
    DATA_BUS = ;

#CLK_PERIOD
  ADDRESS_BUS = 16'h0;
  DATA_BUS = {16{1'bz}};
  HALT = 1'b0;
    
end 

assign #CLK_HALF_PERIOD CLK = !CLK;

endmodule