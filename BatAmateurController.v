`timescale 1ns/1ns

// to standardize the registers,
//if the bus is 2 wide, it's r/w, then en
//if three, it's inc, then  r/w, then en

module BatAmateurController(
	input wire CLK, RST,
	input wire [7:0] ALU_REG,
	input wire [15:0] INSTR,

	output reg [2:0] PC,
	output reg [1:0] MAR,
	output reg [1:0] RAM,
	output reg [1:0] IR,
	//A, B, 3, 4, 5, 6, 7, OUT (from small to big)
	output reg [23:0] REGS,
	output reg ALU_EN,
	output reg [4:0] ALU_OP
);

reg [2:0] uOP;

always @(negedge CLK) //negedge to avoid causing race conditions
begin
	//increment the uOP
	//reset state for uOP is 3, then
	uOP = uOP + 1;
	//we also need to clear all of the output controls
	//to definitively avoid crosstalk
	PC = 0;
	MAR = 0;
	RAM = 0;
	IR = 0;
	REGS = 0;
	ALU_EN = 0;
	ALU_OP = 0;
	
	if(RST = 1'b0)
	begin
		uOP = 3'b111;
	end
	else
	begin
	//now we configure the signals correctly
	case(uOP)
	
		0: //initial retrieval
			begin
			PC = 3'b011;
			MAR = 2'b01;
			end

		1: //load from memory into IR
			begin
			PC = 3'b110; 
			MAR = 2'b11;
			RAM = 2'b11;
			IR = 2'b01;
			end
	
		2: //and he, upon, look'd his creation,
		   //wept, for it was to be ugly and dumb
		   //yet, he worked on, as if to be unfazed
		   //he'd finish if it cost him ARM and THUMB
			begin
				if(INSTR[15:12] == 4'b0111)
				begin
					//this is the pit of ALU
					//tread lightly, and with a big 
					
					//check MOV
					if(INSTR[11:7] == 5'b11111)
					begin
						//r1 enable
						REGS[INSTR[5:3]*3] = 1'b1;
						//r2 enable and read out
						REGS[INSTR[2:0]*3+1] = 1'b1;
						REGS[INSTR[2:0]*3] = 1'b1;
						//reset
						uOP = 3'b111;
					end
					//check inc
					else if(INSTR[11:7] == 5'b11110)
					begin
						//r1 inc and read out (no enable)
						REGS[INSTR[5:3]*3+2] = 1'b1;
						REGS[INSTR[5:3]*3+1] = 1'b1;
						//reset
						uOP = 3'b111;
					end
					else
					begin
						//we're gonna do something slick here to avoid repeats
						//we xor the bits in
						//this means if enable is written to twice, nothing happens
						
						//enable A to write to
						REGS[0] = 1'b1;
						REGS[INSTR[5:3]*3] = (REGS[INSTR[5:3]*3]) ^ 1'b1;
						REGS[INSTR[5:3]*3+1] = 1'b1;
					end
				end
				else
				begin
					//this is the memory den
					//oh no.
					if(INSTR[14]==1'b1) //JMP set of instructions
					begin
						//00 is uncond, 01 is z = 1, 10 is z = 0, 11 is unregistered
						//i guess 11 is unconditional unjump lmao
						if(((INSTR[13:12] == 1) && (ALU_REG[0] == 1)) || (INSTR[13:12] == 2 && ALU_REG[0] == 0) ||(INSTR[13:12] == 2'b00))
						begin
							if(INSTR[15] == 1)
							begin
								//write to A
								REGS[0] = 1'b1;
								PC = 3'b011;
							end
							else
							begin
								//write addr to mar
								IR = 2'b11;
								MAR = 2'b01;
							end
						end
						else
						begin
							uOP = 3'b111;
						end
					end
					else if(INSTR[14]==1'b0) //LD or STR
					begin
						//ld and str are the same here
						IR = 2'b11;
						MAR = 2'b01;
					end
				end
			end
		3:
		    begin
				if(INSTR[15:12] == 4'b0111)
				begin
					REGS[3] = 1'b1;
					REGS[INSTR[2:0]] = REGS[INSTR[2:0]] ^ 1'b1;
					REGS[INSTR[2:0]+1] = 1'b1;
				end
				else
				begin
					if(INSTR[14]==1'b1)
					begin
						if(INSTR[15] == 1'b1)
						begin
							RAM = 2'b11;
							MAR = 2'b11;
							PC = 3'b001;
							uOP = 3'b111;
						end
						else
						begin
							REGS[3] = 1'b1;
							IR = 2'b11;
						end
					end
					else
					begin
						//this is the only case where we don't need the output of the mem
						//store immediate
						if(INSTR[13]==1'b1 && INSTR[15] == 1'b0)
						begin
							REGS[INSTR[12]*3+1] = 1'b1;
							REGS[INSTR[12]*3] = 1'b1;
							RAM = 2'b01;
							MAR = 2'b11;
							uOP = 3'b111;
						end
						else if(INSTR[13]==1'b0 && INSTR[15]==1'b0)
						begin
							MAR = 2'b11;
							RAM = 2'b11;
							REGS[INSTR[6]*3] = 1'b1;
							uOP = 3'b111;
						end
						else
						begin
							RAM = 2'b11;
							MAR = 2'b01;
						end
					end
				end
			end
		4:
		    begin
				if(INSTR[15:12] == 4'b0111)
				begin
					ALU_EN = 1'b1;
					ALU_OP = INSTR[11:7];
					REGS[INSTR[6]*3] = 1'b1;
					uOP = 3'b111;
				end
				else
				begin
					if(INSTR[14]==1'b1)
					begin
						ALU_EN = 1'b1;
						ALU_OP = 5'b00000; //NOTE: check if adds
						PC = 2'b01;
						uOP = 3'b111;
					end
					else
					begin
						if(INSTR[13] == 1'b1)
						begin
							RAM = 2'b01;
							REGS[INSTR[6]*3] = 1'b1;
							REGS[INSTR[6]*3+1] = 1'b1;
							uOP = 3'b111;
						end
						else
						begin
							REGS[INSTR[6]*3] = 1'b1;
							RAM = 2'b11;
							uOP = 3'b111;
						end
					end
				end
			end
		default:
		    begin
				uOP = 3'b111; //woops, missed one somewhere.
			end
	endcase
	end
end

endmodule
