`timescale 1ns/1ns

module alu_stim 
(
   output reg [15:0] in_1,
   output reg [15:0] in_2,
   output reg carry_in,
   output reg enable,
   output reg [2:0] select,
   input wire [15:0] data,
   input wire carry_out,
   input wire zero_flag 
);  

parameter T = 10;

initial 
begin

    // all inputs are zero 
    carry_in = 0;
    select = 0;
    in_1 = 16'b0;
    in_2 = 16'b0;
    enable = 0;
    #T

    if ((data == 16'bz) && (carry_out == 1'bz) && (zero_flag == 1'bz))
    begin
        $display("test 1 passed");
    end else
    begin 
        $display("test 1 failed");
    end

    // first input is all ones and we invert it
    carry_in = 0;
    select = 3'd5; 
    in_1 = 16'hffff;
    in_2 = 16'h0000;
    enable = 1;
    #T

    if ((data == 16'b0) && (carry_out == 1) && (zero_flag == 1))
    begin
        $display("test 2 passed");
    end else
    begin 
        $display("test 2 failed");
    end

    carry_in = 0;
    select = 0;
    in_1 = 16'b0;
    in_2 = 16'b0;
    enable = 0;
    #T

    // add 5 plus 3
    carry_in = 0;
    select = 0;
    in_1 = 16'd5;
    in_2 = 16'd3;
    enable = 1;
    #T

    if ((data == 16'd8) && (carry_out == 0) && (zero_flag == 0))
    begin
        $display("test 3 passed");
    end else
    begin 
        $display("test 3 failed");
    end

    carry_in = 0;
    select = 0;
    in_1 = 16'b0;
    in_2 = 16'b0;
    enable = 0;
    #T

    // subtract 6035 and 3127
    carry_in = 0;
    select = 1;
    in_1 = 16'd6035;
    in_2 = 16'd3127;
    enable = 1;
    #T

    if ((data == 16'd2908) && (carry_out == 0) && (zero_flag == 0))
    begin
        $display("test 4 passed");
    end else
    begin 
        $display("test 4 failed");
    end

    carry_in = 0;
    select = 0;
    in_1 = 16'b0;
    in_2 = 16'b0;
    enable = 0;
    #T

    // add with carry in 
    carry_in = 1;
    select = 0;
    in_1 = 16'd4941;
    in_2 = 16'd1259;
    enable = 1;
    #T

    if ((data == 16'd6201) && (carry_out == 0) && (zero_flag == 0))
    begin
        $display("test 5 passed");
    end else
    begin 
        $display("test 5 failed");
    end

    carry_in = 0;
    select = 0;
    in_1 = 16'b0;
    in_2 = 16'b0;
    enable = 0;
    #T

    // add with carry in 
    carry_in = 0;
    select = 7;
    in_1 = 16'd1;
    in_2 = 16'd0;
    enable = 1;
    #T

    if ((data == 16'd0) && (carry_out == 0) && (zero_flag == 1))
    begin
        $display("test 6 passed");
    end else
    begin 
        $display("test 6 failed");
    end

end

endmodule
