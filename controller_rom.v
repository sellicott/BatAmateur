`timescale 1ns/1ns

// to standardize the registers,
//if the bus is 2 wide, it's r/w, then en
//if three, it's inc, then  r/w, then en

module controller_rom(
  input wire [15:0] INSTR, // instruction high
  input wire [2:0]  uOP,   // microoperation

  input wire ZERO_FLAG,
  input wire COUT_FLAG,

  output reg RESET_uOP,
  output reg READ_FLAGS,

	output reg PC_INC,
	output reg PC_RW,
	output reg PC_EN,

	output reg MAR_LOAD,
	output reg MAR_EN,

	output reg RAM_RW,
	output reg RAM_EN,
	
	output reg IR_LOAD,
	output reg IR_EN,

	//A, B, 3, 4, 5, 6, 7, OUT (from small to big)
	output reg [7:0] REGS_INC,
	output reg [7:0] REGS_RW,
	output reg [7:0] REGS_EN,

	output reg ALU_EN,
	output reg [4:0] ALU_OP
);

reg [2:0] uOP;
reg ZERO_FLAG;
reg C_OUT;

wire [3:0] instr_h;
wire [4:0] instr_l;
wire acc_a_b;
wire [2:0] op1;
wire [2:0] op2;

wire jmp_cond;

// select the connections for each of the bits
assign instr_h = INSTR[15:12];
assign instr_l = INSTR[11:7];
assign acc_a_b = INSTR[6];
assign op1     = INSTR[5:3];
assign op2     = INSTR[2:0];

// condition for a jump 
assign jump_cond = (
  instr_h[1:0] == 2'b00 |                 // unconditional jump
  (instr_h[1:0] == 2'b01 &&  ZERO_FLAG) | // branch if zero
  (instr_h[1:0] == 2'b10 && !ZERO_FLAG)   // branch if not zero
);

always @(INSTR or uOP)
begin
  casez ({instr_h, instr_l, uOP})
    // fetch 
    12'b?????????000: begin
      // MAR <- PC 
      PC_INC <= 1'b0; PC_RW <= 1'b1; PC_EN <= 1'b1;
      MAR_LOAD <= 1'b1; MAR_EN <= 1'b1;
      RAM_RW <= 1'b1; RAM_EN <= 1'b0;
      IR_LOAD <= 1'b0; IR_EN <= 1'b0;
      REGS_INC <= 8'h00; REGS_RW <= 8'hFF; REGS_EN <= 8'h00;
      ALU_EN <= 0; ALU_OP <= 0;
    end

    // decode
    12'b?????????001: begin
      // PC <= PC + 1, IR <= RAM[MAR]
      PC_INC <= 1'b01 PC_RW <= 1'b0; PC_EN <= 1'b0;
      MAR_LOAD <= 1'b0; MAR_EN <= 1'b1;
      RAM_RW <= 1'b1; RAM_EN <= 1'b1;
      IR_LOAD <= 1'b1; IR_EN <= 1'b0;
      REGS_INC <= 8'h00; REGS_RW <= 8'hFF; REGS_EN <= 8'h00;
      ALU_EN <= 1'b0; ALU_OP <= 0;
    end

    // reset
    12'b?????????111: begin
      // default state 
      PC_INC <= 1'b0; PC_RW <= 1'b1; PC_EN <= 1'b0;
      MAR_LOAD <= 1'b0; MAR_EN <= 1'b1;
      RAM_RW <= 1'b1; RAM_EN <= 1'b0;
      IR_LOAD <= 1'b0; IR_EN <= 1'b0;
      REGS_INC <= 8'h00; REGS_RW <= 8'hFF; REGS_EN <= 8'h00;
      ALU_EN <= 1'b0; ALU_OP <= 0;

      RESET_uOP <= 1'b0;
      READ_FLAGS <= 1'b0;
    end 

    // for LDA, LDB, STA, STB
    // direct and indirect uOP 2
    // MAR <= IR[11:0]
    12'b?0???????010: begin // uOP 2
      PC_INC <= 1'b0; PC_RW <= 1'b1; PC_EN <= 1'b0;
      MAR_LOAD <= 1'b1; MAR_EN <= 1'b1;
      RAM_RW <= 1'b1; RAM_EN <= 1'b0;
      IR_LOAD <= 1'b0; IR_EN <= 1'b1;
      REGS_INC <= 8'h00; REGS_RW <= 8'hFF; REGS_EN <= 8'h00;
      ALU_EN <= 0; ALU_OP <= 0;
    end

    // for LDA, LDB, STA, STB 
    // indirect uOP 3
    // MAR <= RAM[MAR]
    12'b10???????010: begin // uOP 3
      PC_INC <= 1'b0; PC_RW <= 1'b1; PC_EN <= 1'b0;
      MAR_LOAD <= 1'b1; MAR_EN <= 1'b1;
      RAM_RW <= 1'b1; RAM_EN <= 1'b1;
      IR_LOAD <= 1'b0; IR_EN <= 1'b1;
      REGS_INC <= 8'h00; REGS_RW <= 8'hFF; REGS_EN <= 8'h00;
      ALU_EN <= 0; ALU_OP <= 0;
    end

    // LDA, LDB (direct or indirect)
    // A or B <= RAM[MAR]
    12'b000??????011, // direct
    12'b100??????100: // indirect
    begin
      // read from the ram
      PC_INC <= 1'b0; PC_RW <= 1'b1; PC_EN <= 1'b0;
      MAR_LOAD <= 1'b0; MAR_EN <= 1'b1;
      RAM_RW <= 1'b1; RAM_EN <= 1'b1;
      IR_LOAD <= 1'b0; IR_EN <= 1'b0;
      REGS_INC[7:0] <= 8'h00; REGS_RW <= 8'h00; REGS_EN[7:2] <= 6'h00;
      ALU_EN <= 1'b0; ALU_OP <= 0;

      // all of the registers are set to write mode
      // select to enable either A or B
      // 0 in instr_h[0] is A, 1 is B
      REGS_EN[0] <= ~instr_h[0];
      REGS_EN[1] <= instr_h[0];

      RESET_uOP <= 1'b1;
    end 

    // STA, STB (direct or indirect)
    // RAM[MAR] <= A or B
    12'b001??????011, // direct
    12'b101??????100: // indirect
    begin
      // write to the ram
      PC_INC <= 1'b0; PC_RW <= 1'b1; PC_EN <= 1'b0;
      MAR_LOAD <= 1'b0; MAR_EN <= 1'b1;
      RAM_RW <= 1'b0; RAM_EN <= 1'b1;
      IR_LOAD <= 1'b0; IR_EN <= 1'b0;
      REGS_INC[7:0] <= 8'h00; REGS_RW <= 8'hFF; REGS_EN[7:2] <= 6'h00;
      ALU_EN <= 1'b0; ALU_OP <= 1'b0;

      // all of the registers are set to read mode
      // select to enable either A or B
      // 0 in instr_h[0] is A, 1 is B
      REGS_EN[0] <= ~instr_h[0];
      REGS_EN[1] <= instr_h[0];

      RESET_uOP <= 1'b1;
    end 

    // JMP (indirect) uOP 2
    // MAR <= IR[11:0]
    12'b1100?????010,
    12'b1101?????010,
    12'b1110?????010: begin // uOP 2
      PC_INC <= 1'b0; PC_RW <= 1'b1; PC_EN <= 1'b0;
      MAR_LOAD <= 1'b1; MAR_EN <= 1'b1;
      RAM_RW <= 1'b1; RAM_EN <= 1'b0;
      IR_LOAD <= 1'b0; IR_EN <= 1'b1;
      REGS_INC <= 8'h00; REGS_RW <= 8'hFF; REGS_EN <= 8'h00;
      ALU_EN <= 0; ALU_OP <= 0;
    end

    // JMP (direct) uOP 2
    12'b0100?????010,
    12'b0101?????010,
    12'b0110?????010,
    // JMP (indirect) uOP 3
    12'b1100?????011,
    12'b1101?????011,
    12'b1110?????011:
    // PC <- IR[11:0]
    begin
      // write PC from IR 
      PC_INC <= 1'b0; PC_RW <= 1'b0;
      MAR_LOAD <= 1'b0; MAR_EN <= 1'b1;
      RAM_RW <= 1'b1; RAM_EN <= 1'b0;
      IR_LOAD <= 1'b0; 
      REGS_INC <= 8'h00; REGS_RW <= 8'hFF; REGS_EN <= 8'h00;
      ALU_EN <= 1'b0; ALU_OP <= 0;

      // only allow the move if the jump condition is satisfied
      IR_EN <= (jump_cond) ? 1'b1 : 1'b0;
      PC_EN <=  (jump_cond) ? 1'b1 : 1'b0;

      RESET_uOP <= 1'b1;
    end 

    // register
    // ALU
    // A <= r[op1]
    12'b011100???010: // uOP 2
    begin 
      // everything else off 
      PC_INC <= 1'b0; PC_RW <= 1'b1; PC_EN <= 1'b0;
      MAR_LOAD <= 1'b0; MAR_EN <= 1'b1;
      RAM_RW <= 1'b1; RAM_EN <= 1'b0;
      IR_LOAD <= 1'b0; IR_EN <= 1'b0;
      ALU_EN <= 1'b0; ALU_OP <= 0;

      REGS_INC <= 8'h00;
      // read from op1
      REGS_RW <= (1 << op1);
      // enable A and op1 
      REGS_EN <= 8'h01 | (1 << op1); 
    end

    // B <= r[op2]
    12'b011100???011: // uOP 3 
    begin
      // everything else off 
      PC_INC <= 1'b0; PC_RW <= 1'b1; PC_EN <= 1'b0;
      MAR_LOAD <= 1'b0; MAR_EN <= 1'b1;
      RAM_RW <= 1'b1; RAM_EN <= 1'b0;
      IR_LOAD <= 1'b0; IR_EN <= 1'b0;
      ALU_EN <= 1'b0; ALU_OP <= 0;

      REGS_INC <= 8'h00;
      // read from op2
      REGS_RW <= (1 << op2);
      // enable B and op2 
      REGS_EN <= 8'h02 | (1 << op2); 
    end

    // A or B <= ALU
    12'b011100???100: 
    begin
      // disable everything else
      PC_INC <= 1'b0; PC_RW <= 1'b1; PC_EN <= 1'b0;
      MAR_LOAD <= 1'b0; MAR_EN <= 1'b1;
      RAM_RW <= 1'b1; RAM_EN <= 1'b0;
      IR_LOAD <= 1'b0; IR_EN <= 1'b0;
      REGS_INC[7:0] <= 8'h00; REGS_RW <= 8'h00; REGS_EN[7:2] <= 6'h00;

      // enable the ALU
      ALU_EN <= 1'b1; 
      ALU_OP <= instr_l;

      // all of the registers are set to write mode
      // select to enable either A or B
      // 0 in instr_h[0] is A, 1 is B
      REGS_EN[0] <= ~acc_a_b;
      REGS_EN[1] <= acc_a_b;

      READ_FLAGS <= 1'b1;
    end

    // read flags (wait for them to have stabilized)
    12'b011100???101: 
    begin
      // disable everything else
      PC_INC <= 1'b0; PC_RW <= 1'b1; PC_EN <= 1'b0;
      MAR_LOAD <= 1'b0; MAR_EN <= 1'b1;
      RAM_RW <= 1'b1; RAM_EN <= 1'b0;
      IR_LOAD <= 1'b0; IR_EN <= 1'b0;
      REGS_INC[7:0] <= 8'h00; REGS_RW <= 8'h00; REGS_EN[7:0] <= 8'h00;

      // enable the ALU
      ALU_EN <= 1'b1; 
      ALU_OP <= instr_l;

      RESET_uOP <= 1'b1;
      READ_FLAGS <= 1'b1;
    end

    // MOV
    12'b011111111010: begin
      // everything else off 
      PC_INC <= 1'b0; PC_RW <= 1'b1; PC_EN <= 1'b0;
      MAR_LOAD <= 1'b0; MAR_EN <= 1'b1;
      RAM_RW <= 1'b1; RAM_EN <= 1'b0;
      IR_LOAD <= 1'b0; IR_EN <= 1'b0;
      ALU_EN <= 1'b0; ALU_OP <= 1'b0;

      REGS_INC <= 8'h00;
      // make the register we need to read from in read mode
      REGS_RW <= (1 << op2);
      // enable both registers
      REGS_EN <= (1 << op1) | (1 << op2); 

      RESET_uOP <= 1'b1;
    end

    // NOP
    12'b1111?????010:
    begin
      // default state 
      PC_INC <= 1'b0; PC_RW <= 1'b1; PC_EN <= 1'b0;
      MAR_LOAD <= 1'b0; MAR_EN <= 1'b1;
      RAM_RW <= 1'b1; RAM_EN <= 1'b0;
      IR_LOAD <= 1'b0; IR_EN <= 1'b0;
      REGS_INC <= 8'h00; REGS_RW <= 8'hFF; REGS_EN <= 8'h00;
      ALU_EN <= 1'b0; ALU_OP <= 0;

      RESET_uOP;
    end
    default:
    begin
      // default state 
      PC_INC <= 1'b0; PC_RW <= 1'b1; PC_EN <= 1'b0;
      MAR_LOAD <= 1'b0; MAR_EN <= 1'b1;
      RAM_RW <= 1'b1; RAM_EN <= 1'b0;
      IR_LOAD <= 1'b0; IR_EN <= 1'b0;
      REGS_INC <= 8'h00; REGS_RW <= 8'hFF; REGS_EN <= 8'h00;
      ALU_EN <= 1'b0; ALU_OP <= 0;

      RESET_uOP;
    end
  endcase
end
endmodule