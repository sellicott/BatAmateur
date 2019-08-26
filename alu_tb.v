`timescale 1ns/1ns

module alu_tb ();

wire [15:0] in_1;
wire [15:0] in_2;
wire carry_in;
wire enable;
wire [2:0] select;
wire [15:0] data;
wire carry_out;
wire zero_flag;

alu alu_test 
(
   .in_1(in_1),
   .in_2(in_2),
   .select(select),
   .enable(enable),
   .carry_in(carry_in),
   .data(data),
   .carry_out(carry_out),
   .zero_flag(zero_flag)
);

alu_stim alu_stimulation
(
   .in_1(in_1),
   .in_2(in_2),
   .select(select),
   .enable(enable),
   .carry_in(carry_in),
   .data(data),
   .carry_out(carry_out),
   .zero_flag(zero_flag)
);

endmodule
