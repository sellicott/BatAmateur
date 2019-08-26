`timescale 1ns/1ns

module alu
(
   input wire [15:0] in_1, in_2,   // inputs for the calculation
   input wire [3:0] select,        // selects which operation
   input wire enable,              // enables bus access
   input wire carry_in,            // carry in flag
   output wire [15:0] data,        // connection to the bus
   output wire carry_out,          // carry out flag 
   output wire zero_flag
);

parameter carry_bit = 16; // carry out bit of the resulting operation

// internal
reg [16:0] result;

// save the carry out bit 
assign carry_out = (!enable) ? 1'bz : result[carry_bit];
assign zero_flag = (!enable) ? 1'bz   
                 : (result[15:0] == 16'b0) ? 1'b1
                 : 1'b0;  

// connect the output to the bus if enabled
assign data = (enable) ? result[15:0] : 16'bz;

always @ (enable) 
begin
    if (enable == 1)
    begin
        case (select)
            0: result = in_1 + in_2 + carry_in; // addition
            1: result = in_1 - in_2;            // subtraction
            2: result = in_1 & in_2;            // and operator
            3: result = in_1 | in_2;            // or operator
            4: result = in_1 ^ in_2;            // xor operator
            5: result = ~in_1;                  // inversion
            6: result = in_1 + 1;               // increment
            7: result = in_1 - 1;               // decrement
            default: $display("Invalid instruction to ALU");
        endcase
    end
end


endmodule
