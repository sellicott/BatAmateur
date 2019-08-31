`timescale 1ns/1ns

// to standardize the registers,
//if the bus is 2 wide, it's r/w, then en
//if three, it's inc, then  r/w, then en

module bat_amateur_controller ( 
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
wire read_alu_flags;

controller_rom my_rom (
    .INSTR(INSTR),
    .uOP(uOP),
    .ZERO_FLAG(ZERO_FLAG),
    .COUT_FLAG(C_OUT),
    .RESET_uOP(reset_counter),
    .READ_FLAGS(read_alu_flags),

    .PC_INC(PC_INC), .PC_RW(PC_RW), .PC_EN(PC_EN),
    .MAR_LOAD(MAR_LOAD), .MAR_EN(MAR_EN),
    .RAM_RW(RAM_RW), .RAM_EN(RAM_EN),
    .IR_LOAD(IR_LOAD), .IR_EN(IR_EN),
    .REGS_INC(REGS_INC), .REGS_RW(REGS_RW), .REGS_EN(REGS_EN),
    .ALU_EN(ALU_EN), .ALU_OP(ALU_OP)
);

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
    else 
    begin
        if (reset_counter)
            uOP <= 3'b111;
        else
        begin
            //increment the uOP
            //reset state for uOP is 3, then
            uOP <= uOP + 4'd1;
        end

        // read the flags
        if (read_alu_flags)
        begin
            ZERO_FLAG <= ALU_REG[0];
            C_OUT <= ALU_REG[1];
        end
    end
end

endmodule
