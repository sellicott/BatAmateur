`timescale 1ns/1ns

// to standardize the registers,
//if the bus is 2 wide, it's r/w, then en
//if three, it's inc, then  r/w, then en

module bat_amatuer_controller(
	input wire CLK, RST,
	input wire [7:0] ALU_REG,
	input wire [15:0] INSTR,

	output wire PC_INC,
	output wire PC_RW,
	output wire PC_EN,

	output wire MAR_LOAD,
	output wire MAR_EN,

	output wire RAM_RW,
	output wire RAM_EN,
	
	output wire IR_LOAD,
	output wire IR_EN,

	//A, B, 3, 4, 5, 6, 7, OUT (from small to big)
	output wire [7:0] REGS_INC,
	output wire [7:0] REGS_RW,
	output wire [7:0] REGS_EN,

	output wire ALU_EN,
	output wire [4:0] ALU_OP
);

reg [2:0] uOP;
reg ZERO_FLAG;
reg C_OUT;

wire reset_counter;

// make a counter for the ROM
//negedge to avoid causing race conditions
always @(negedge CLK or negedge RST) 
begin
    if(!RST)
    begin
        uOP <= 3'b111;
        ZERO_FLAG <= 1'b0;
        C_OUT <= 1'b0;
    end
    else if (reset_counter)
        uOP <= 3'b111;
    else
    begin
        //increment the uOP
        //reset state for uOP is 3, then
        uOP <= uOP + 4'd1;
    end
end

endmodule
