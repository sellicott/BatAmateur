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
RESET,   // syncronous reset
CLOCK,   // clock
RW,      // low for read, high for write
ENABLE,  // enable bus access
COUNT,   // if high, the register will incriment

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
inout wire [BUS_WIDTH-1:0] DATA;

reg [BUS_WIDTH-1:0] INTERNAL_DATA;

always @(posedge CLOCK) begin
    if (RESET) begin
        // set the internal bus to 0
        INTERNAL_DATA <= {BUS_WIDTH{1'b0}};
    end
    // only increment if the functionality is enabled and we are not reading
    // in data from the bus and the count operation is specified
    else if (COUNT_EN && RW != 0 && COUNT) begin
        INTERNAL_DATA <= INTERNAL_DATA + 1;
    end

    // The enable signal is independent of reset and count, except for data read
    if (ENABLE) begin
        case (RW)
            // read data from the bus, if the reset condition is not specified
            0: INTERNAL_DATA <= (!RESET) ? DATA : ;
            // write the data to the bus
            1: DATA <= INTERNAL_DATA; 
            // if no valid RW signal, hold current data, output high impedence
            default: DATA <= {BUS_WIDTH{1'bx}}
        endcase
    end 
    else begin
        // not enabled, set the output bus to high impedence
        DATA <= {BUS_WIDTH{1'bz}}
    end
end
endmodule