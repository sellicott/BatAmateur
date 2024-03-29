/* This is a register for the Bat Amateur processor it has 
 * both an input and output port
 *
 * Signal priorities:
 * 1) reset (set internal data to 0)
 * 2) data read (read in data from the bus if enable is high)
 * 3) count (incriment) data in the internal register
 *
 * Writing data to the output will happen if enable is high 
 *
 * Rev 1.0
 * Author: Sam Ellicott
 * Date: 8-18-19
 */

`timescale 1ns/1ns

module register_ir (
RESET,   // syncronous reset (active low)
CLOCK,   // clock
LOAD,    // high for read, low for write
ENABLE,  // enable bus access (active high)
COUNT,   // incriment register (active high)

DATA_IN,        // data bus connection
DATA_OUT,       // data bus connection
INSTRUCTION_OUT // direct access to the internal register value
);
// PARAMETERS
parameter BUS_WIDTH = 16;
parameter COUNT_EN = 1;
// INPUTS
input wire RESET;
input wire CLOCK;
input wire LOAD;
input wire ENABLE;
input wire COUNT;
// OUTPUT
input  wire [BUS_WIDTH-1:0] DATA_IN;
output wire [BUS_WIDTH-1:0] DATA_OUT;
output wire [BUS_WIDTH-1:0] INSTRUCTION_OUT;

reg [BUS_WIDTH-1:0] INTERNAL_DATA;

always @(posedge CLOCK) begin
    if (!RESET) begin
        // set the internal bus to 0
        INTERNAL_DATA <= {BUS_WIDTH{1'b0}};
    end
    // load is second priority
    else if (LOAD) begin
        INTERNAL_DATA <= DATA_IN;
    end
    // only increment if the functionality is enabled and we are not reading
    // in data from the bus and the count operation is specified
    else if (COUNT_EN && COUNT) begin
        INTERNAL_DATA <= INTERNAL_DATA + 1;
    end
end

// The enable signal is independent of reset and count, except for data read
assign DATA_OUT = ENABLE ? {4'b0, INTERNAL_DATA[11:0]} : {BUS_WIDTH{1'bz}};
assign INSTRUCTION_OUT = INTERNAL_DATA;
endmodule
