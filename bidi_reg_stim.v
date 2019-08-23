`timescale 1ns/1ns

module bidi_reg_stim (
RESET,   // syncronous reset (active low)
CLOCK,   // clock
RW,      // high for read, low for write
ENABLE,  // enable bus access (active high)
COUNT,   // incriment register (active high)

DATA_OUT,    // data bus connection
DATA_IN      // data bus connection
);

output reg RESET;
output reg CLOCK;
output reg RW;
output reg ENABLE;
output reg COUNT;
output reg [15:0] DATA_OUT;
input wire [15:0] DATA_IN;


initial begin
    RESET = 1'b0;
    CLOCK = 1'b0;
    RW = 1'b1;
    ENABLE = 1'b0;
    COUNT = 1'b0;
    DATA_OUT = {16{1'bz}};

#10
    RESET = 1'b1;
    // load some data and read it out
    DATA_OUT = 16'hA5A5;
    RW = 1'b0; // write
    ENABLE = 1'b1;
    COUNT = 1'b0;

#10
    // try and read out the data
    DATA_OUT = {16{1'bz}};
    RW = 1'b1; // read
    ENABLE = 1'b1;
    COUNT = 1'b0;
    $display(DATA_IN);

#10 
    // incriment the data
    DATA_OUT = {16{1'bz}};
    RW = 1'b1; // read
    ENABLE = 1'b1;
    COUNT = 1'b1;
    $display(DATA_IN);

end

always #5 CLOCK <= ~CLOCK;

endmodule
