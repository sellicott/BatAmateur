`timescale 1ns/1ns

module BatAmateurv2(
	inout wire [15:0] DATA,
	input wire [15:0] ADDRESS,
	input wire RW, RAM_EN, HALT, CLK, RST,
	output wire [15:0] OUT
);

wire [15:0] BUS;
wire [23:0] REGS;
wire [7:0]  ALU_REG;
wire [15:0] INSTR;
wire [8:0]  CTRL_REGS;
wire [5:0]  ALU_CTRL;
wire [15:0] ALU_IN1, ALU_IN2;

BatAmateurController CTRL(
    .CLK(!CLK & !HALT), 
    .RST(RST), 
    .INSTR(INSTR), 
    .PC(CTRL_REGS[2:0]), 
    .MAR(CTRL_REGS[4:3], 
    .RAM(CTRL_REGS[6:5]), 
    .IR(CTRL_REGS[8:7]), 
    .REGS(REGS), 
    .ALU_EN(ALU_CTRL[0]),
    .ALU_OP(ALU_CTRL[5:1])
);

alu ALU(
    .in_1(ALU_IN1), 
    .in_2(ALU_IN2), 
    .select(ALU_CTRL[3:1]), 
    .enable(ALU_CTRL[0]), 
    .bus(BUS), 
    .carry_in(1'b0)
    .carry_out(ALU_REG[1]), 
    .zero_flag(ALU_REG[0])
);

register #(.COUNT_EN(0)) 
MAR_REG (
    .RESET(RST), 
    .CLOCK(CLK), 
    .LOAD(CTRL_REGS[4]), 
    .ENABLE(CTRL_REGS[3] & !HALT),
    .DATA_IN(BUS), 
    .DATA_OUT(ADDRESS),
    .COUNT(1'b0)
);

bidi_register_output A_REG(
    .RESET(RST), 
    .CLOCK(CLK), 
    .RW(REGS[1]), 
    .ENABLE(REGS[0]), 
    .COUNT(REGS[2]),
    .DATA(BUS), 
    .OUTPUT(ALU_IN1)
);

bidi_register_output B_REG(
    .RESET(RST), 
    .CLOCK(CLK), 
    .RW(REGS[4]), 
    .ENABLE(REGS[3]), 
    .COUNT(REGS[5]),
    .DATA(BUS), 
    .OUTPUT(ALU_IN2)
);

bidi_register PC(
    .RESET(RST), 
    .CLOCK(CLK), 
    .RW(CTRL_REGS[1]), 
    .ENABLE(CTRL_REGS[0]), 
    .COUNT(CTRL_REGS[2]),
    .DATA(BUS)
);

bidi_register THREE(
    .RESET(RST), 
    .CLOCK(CLK), 
    .RW(REGS[7]), 
    .ENABLE(REGS[6]), 
    .COUNT(REGS[8]), 
    .DATA(BUS)
);

bidi_register FOUR(
    .RESET(RST), 
    .CLOCK(CLK), 
    .RW(REGS[10]), 
    .ENABLE(REGS[9]), 
    .COUNT(REGS[11]), 
    .DATA(BUS)
);

bidi_register FIVE(
   .RESET(RST), 
   .CLOCK(CLK), 
   .RW(REGS[13]), 
   .ENABLE(REGS[12]), 
   .COUNT(REGS[14]), 
   .DATA(BUS)
);

bidi_register SIX(
    .RESET(RST), 
    .CLOCK(CLK), 
    .RW(REGS[16]), 
    .ENABLE(REGS[15]), 
    .COUNT(REGS[17]), 
    .DATA(BUS)
);

bidi_register SEVEN(
    .RESET(RST), 
    .CLOCK(CLK), 
    .RW(REGS[19]), 
    .ENABLE(REGS[18]), 
    .COUNT(REGS[20]), 
    .DATA(BUS)
);

bidi_register_output OUTREG(
    .RESET(RST), 
    .CLOCK(CLK), 
    .RW(REGS[22]), 
    .ENABLE(REGS[21]), 
    .COUNT(REGS[23]), 
    .DATA(BUS), 
    .OUTPUT(OUT)
);

memory RAM(
    .address(ADDRESS), 
    .clk(CLK), 
    .read_write(CTRL_REGS[6] | RW), 
	.enable(CTRL_REGS[5] | RAM_EN), 
    .reset(!RST), 
    .data(BUS)
);

register_ir #(.COUNT_EN(0)) 
IR_REG(
    .RESET(RST), 
    .CLOCK(CLK), 
    .LOAD(CTRL_REG[8]), 
    .ENABLE(CTRL_REG[7]),
    .DATA_IN(BUS), 
    .DATA_OUT(BUS), 
    .INSTRUCTION_OUT(INSTR),
    .COUNT(1'b0)

);
