`timescale 1ns/1ns

module bat_amateur (
	inout wire [15:0] BUS,
	input wire [15:0] ADDRESS,
	input wire EXT_RAM_RW, EXT_RAM_EN, HALT, CLK, RST,
	output wire [15:0] OUT
);

wire FORCE_RAM_RW;
wire FORCE_RAM_EN;
wire [7:0]  ALU_REG;
wire [15:0] INSTR;
wire [15:0] ALU_IN1, ALU_IN2;

wire PC_INC, PC_RW, PC_EN;
wire MAR_LOAD, MAR_EN;
wire RAM_RW, RAM_EN;
wire IR_LOAD, IR_EN;
wire ALU_EN;
wire [4:0] ALU_OP;

wire [7:0] REGS_INC;
wire [7:0] REGS_RW;
wire [7:0] REGS_EN;

BatAmateurController CTRL(
    .CLK(!CLK & !HALT), 
    .ALU_REG(ALU_REG),
    .RST(RST), 
    .INSTR(INSTR), 

	.PC_INC(PC_INC),
	.PC_RW(PC_RW),
	.PC_EN(PC_EN),

    .MAR_LOAD(MAR_LOAD),
	.MAR_EN(MAR_EN),

	.RAM_RW(RAM_RW),
	.RAM_EN(RAM_EN),
	
	.IR_LOAD(IR_LOAD),
	.IR_EN(IR_EN),

	//A, B, 3, 4, 5, 6, 7, OUT (from small to big)
	.REGS_INC(REGS_INC),
	.REGS_RW(REGS_RW),
	.REGS_EN(REGS_EN),

    .ALU_EN(ALU_EN),
    .ALU_OP(ALU_OP)
);

alu ALU(
    .in_1(ALU_IN1), 
    .in_2(ALU_IN2), 
    .select(ALU_OP[3:0]), 
    .enable(ALU_EN), 
    .carry_in(1'b0),
    .data(BUS), 
    .carry_out(ALU_REG[1]), 
    .zero_flag(ALU_REG[0])
);

register #(.COUNT_EN(0)) 
MAR_REG (
    .RESET(RST), 
    .CLOCK(CLK), 
    .LOAD(MAR_LOAD), 
    .ENABLE(MAR_EN & !HALT),
    .DATA_IN(BUS), 
    .DATA_OUT(ADDRESS),
    .COUNT(1'b0)
);

bidi_register PC(
    .RESET(RST), 
    .CLOCK(CLK), 
    .RW(PC_RW), 
    .ENABLE(PC_EN), 
    .COUNT(PC_INC),
    .DATA(BUS)
);

register_ir #(.COUNT_EN(0)) 
IR_REG(
    .RESET(RST), 
    .CLOCK(CLK), 
    .LOAD(IR_LOAD), 
    .ENABLE(IR_EN),
    .DATA_IN(BUS), 
    .DATA_OUT(BUS), 
    .INSTRUCTION_OUT(INSTR),
    .COUNT(1'b0)
);

bidi_register_output A_REG(
    .RESET(RST), 
    .CLOCK(CLK), 
    .RW(REGS_RW[0]), 
    .ENABLE(REGS_EN[0]), 
    .COUNT(REGS_INC[0]),
    .DATA(BUS), 
    .OUTPUT(ALU_IN1)
);

bidi_register_output B_REG(
    .RESET(RST), 
    .CLOCK(CLK), 
    .RW(REGS_RW[1]), 
    .ENABLE(REGS_EN[1]), 
    .COUNT(REGS_INC[1]),
    .DATA(BUS), 
    .OUTPUT(ALU_IN2)
);

bidi_register THREE(
    .RESET(RST), 
    .CLOCK(CLK), 
    .RW(REGS_RW[2]), 
    .ENABLE(REGS_EN[2]), 
    .COUNT(REGS_INC[2]),
    .DATA(BUS)
);

bidi_register FOUR(
    .RESET(RST), 
    .CLOCK(CLK), 
    .RW(REGS_RW[3]), 
    .ENABLE(REGS_EN[3]), 
    .COUNT(REGS_INC[3]),
    .DATA(BUS)
);

bidi_register FIVE(
    .RESET(RST), 
    .CLOCK(CLK), 
    .RW(REGS_RW[4]), 
    .ENABLE(REGS_EN[4]), 
    .COUNT(REGS_INC[4]),
    .DATA(BUS)
);

bidi_register SIX(
    .RESET(RST), 
    .CLOCK(CLK), 
    .RW(REGS_RW[5]), 
    .ENABLE(REGS_EN[5]), 
    .COUNT(REGS_INC[5]),
    .DATA(BUS)
);

bidi_register SEVEN(
    .RESET(RST), 
    .CLOCK(CLK), 
    .RW(REGS_RW[6]), 
    .ENABLE(REGS_EN[6]), 
    .COUNT(REGS_INC[6]),
    .DATA(BUS)
);

bidi_register_output OUTREG(
    .RESET(RST), 
    .CLOCK(CLK), 
    .RW(REGS_RW[7]), 
    .ENABLE(REGS_EN[7]), 
    .COUNT(REGS_INC[7]),
    .DATA(BUS), 
    .OUTPUT(OUT)
);

assign FORCE_RAM_RW = (HALT) ? EXT_RAM_RW : RAM_RW;
assign FORCE_RAM_EN = (HALT) ? EXT_RAM_EN : RAM_EN;
memory_bidi RAM(
    .reset(RST), 
    .clk(CLK), 
    .read_write(FORCE_RAM_RW), 
	.enable(FORCE_RAM_EN), 
    .address(ADDRESS), 
    .data(BUS)
);
endmodule