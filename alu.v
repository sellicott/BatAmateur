module alu
(
   input wire [15:0] in_1, in_2, 
   input wire [2:0] select,
   input wire enable,
   output wire [15:0] bus,
   output reg carry_out, zero_flag
);

parameter carry_bit = 16;
reg [16:0] result;

always @(*)
begin
    case (select)
        0: result = in_1 + in_2; // addition
        1: result = in_1 - in_2; // subtraction
        2: result = in_1 & in_2; // and operator
        3: result = in_1 | in_2; // or operator
        4: result = in_1 ^ in_2; // xor operator
        5: result = ~in_1;       // inversion
        6: result = in_1 + 1;    // increment
        7: result = in_1 - 1;    // decrement
        default: $display("Invalid instruction to ALU")
    endcase

    // save the carry out bit 
    carry_out <= result[carry_bit];

    // set flag for a zero result
    if (result == 0)
    begin
        zero_flag <= 1;
    end

    // connect the output to the bus if enabled
    bus <= (enable) ? result[15:0] : 16'bz;
end

endmodule
