/* This is a bidirectional register for the Bat Amateur processor
 *
 * Signal priorities:
 * 1) reset (set internal data to 0)
 * 2) data read (read in data from the bus if enable is high)
 * 3) count (incriment) data in the internal register
 *
 * Writing data to the output will happen if enable is high for the 
 * reset and count cases above if enable is high and write is high.
 *
 * Rev 1.0
 * Author: Sam Ellicott
 * Date: 8-16-19
 */

`timescale 1ns/1ns

module bidi_register (
RESET,   // syncronous reset (active low)
CLOCK,   // clock
RW,      // high for read, low for write
ENABLE,  // enable bus access (active high)
COUNT,   // incriment register (active high)

DATA     // data bus connection
);
// PARAMETERS
parameter BUS_WIDTH = 16;
parameter COUNT_EN = 1;
// INPUTS
input wire RESET;
input wire CLOCK;
input wire RW;
input wire ENABLE;
input wire COUNT;
// OUTPUT
inout reg [BUS_WIDTH-1:0] DATA;

reg [BUS_WIDTH-1:0] INTERNAL_DATA;

always @(posedge CLOCK) begin
    if (!RESET) begin
        // set the internal bus to 0
        INTERNAL_DATA <= {BUS_WIDTH{1'b0}};
    end
    // only increment if the functionality is enabled and we are not reading
    // in data from the bus and the count operation is specified
    else if (ENABLE && RW == 0) begin
        INTERNAL_DATA <= DATA;
    end 
    else if (COUNT_EN && RW != 0 && COUNT) begin
        INTERNAL_DATA <= INTERNAL_DATA + 1;
    end
end

assign DATA = (ENABLE && RW == 1) ? INTERNAL_DATA : {BUS_WIDTH{1'bz}};

endmodule
