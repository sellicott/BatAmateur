`timescale 1ns/1ns

// to standardize the registers,
//if the bus is 2 wide, it's r/w, then en
//if three, it's inc, then  r/w, then en

module BatAmateurController(
	input wire [15:0] DATA,
	input wire [15:0] ADDRESS,
	input wire EXT_RAM_RW, EXT_RAM_EN, HALT, CLK, RST,
	output wire [15:0] OUT
);

reg [2:0] uOP;
	
//all the registers
reg [15:0] A, B, RTHREE, RFOUR, RFIVE, RSIX, RSEVEN, ROUT, MAR, PC, IR;

	
// resources for alu
wire [15:0] alu_in_1, alu_in_2;
wire [2:0] alu_select; 
reg [16:0] alu_out;
wire alu_enable, carry_in, carry_out, zero_flag;

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
	
	if(RST == 1'b0)
	begin
		uOP = 3'b111;
	end
	else
	begin
	//now we configure the signals correctly
	case(uOP)
	
		0: //initial retrieval
			begin
			PC <= 3'b011;
			MAR <= 2'b01;
			end

		1: //load from memory into IR
			begin
			PC <= 3'b110; 
			MAR <= 2'b11;
			RAM <= 2'b11;
			IR <= 2'b01;
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
						REGS[INSTR[5:3]*3] <= 1'b1;
						//r2 enable and read out
						REGS[INSTR[2:0]*3+1] <= 1'b1;
						REGS[INSTR[2:0]*3] <= 1'b1;
						//reset
						uOP <= 3'b111;
					end
					//check inc
					else if(INSTR[11:7] == 5'b11110)
					begin
						//r1 inc and read out (no enable)
						REGS[INSTR[5:3]*3+2] <= 1'b1;
						REGS[INSTR[5:3]*3+1] <= 1'b1;
						//reset
						uOP <= 3'b111;
					end
					else
					begin
						//we're gonna do something slick here to avoid repeats
						//we xor the bits in
						//this means if enable is written to twice, nothing happens
						
						//enable A to write to
						REGS[0] <= 1'b1;
						REGS[INSTR[5:3]*3] <= (REGS[INSTR[5:3]*3]) ^ 1'b1;
						REGS[INSTR[5:3]*3+1] <= 1'b1;
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
								REGS[0] <= 1'b1;
								PC <= 3'b011;
							end
							else
							begin
								//write addr to mar
								IR <= 2'b11;
								MAR <= 2'b01;
							end
						end
						else
						begin
							uOP <= 3'b111;
						end
					end
					else if(INSTR[14]==1'b0) //LD or STR
					begin
						//ld and str are the same here
						IR <= 2'b11;
						MAR <= 2'b01;
					end
				end
			end
		3:
		    begin
				if(INSTR[15:12] == 4'b0111)
				begin
					REGS[3] <= 1'b1;
					REGS[INSTR[2:0]] <= REGS[INSTR[2:0]] ^ 1'b1;
					REGS[INSTR[2:0]+1] <= 1'b1;
				end
				else
				begin
					if(INSTR[14]==1'b1)
					begin
						if(INSTR[15] == 1'b1)
						begin
							RAM <= 2'b11;
							MAR <= 2'b11;
							PC <= 3'b001;
							uOP <= 3'b111;
						end
						else
						begin
							REGS[3] <= 1'b1;
							IR <= 2'b11;
						end
					end
					else
					begin
						//this is the only case where we don't need the output of the mem
						//store immediate
						if(INSTR[13]==1'b1 && INSTR[15] == 1'b0)
						begin
							REGS[INSTR[12]*3+1] <= 1'b1;
							REGS[INSTR[12]*3] <= 1'b1;
							RAM <= 2'b01;
							MAR <= 2'b11;
							uOP <= 3'b111;
						end
						else if(INSTR[13]==1'b0 && INSTR[15]==1'b0)
						begin
							MAR <= 2'b11;
							RAM <= 2'b11;
							REGS[INSTR[6]*3] <= 1'b1;
							uOP <= 3'b111;
						end
						else
						begin
							RAM <= 2'b11;
							MAR <= 2'b01;
						end
					end
				end
			end
		4:
		    begin
				if(INSTR[15:12] == 4'b0111)
				begin
					ALU_EN <= 1'b1;
					ALU_OP <= INSTR[11:7];
					REGS[INSTR[6]*3] <= 1'b1;
					uOP <= 3'b111;
				end
				else
				begin
					if(INSTR[14]==1'b1)
					begin
						ALU_EN <= 1'b1;
						ALU_OP <= 5'b00000; //NOTE: check if adds
						PC <= 2'b01;
						uOP <= 3'b111;
					end
					else
					begin
						if(INSTR[13] == 1'b1)
						begin
							RAM <= 2'b01;
							REGS[INSTR[6]*3] <= 1'b1;
							REGS[INSTR[6]*3+1] <= 1'b1;
							uOP <= 3'b111;
						end
						else
						begin
							REGS[INSTR[6]*3] <= 1'b1;
							RAM <= 2'b11;
							uOP <= 3'b111;
						end
					end
				end
			end
		default:
		    begin
				uOP <= 3'b111; //woops, missed one somewhere.
			end
	endcase
	end
end

assign carry_out = (!alu_enable) ? 1'bz : alu_out[16];
assign zero_flag = (!alu_enable) ? 1'bz   
                 : (alu_out[15:0] == 16'b0) ? 1'b1
                 : 1'b0;  

always @(alu_in_1,alu_in_2,carry_in,alu_enable,alu_select)
begin
    if (alu_enable == 1)
    begin
        case (alu_select)
            0: alu_out = alu_in_1 + alu_in_2 + carry_in; // addition
            1: alu_out = alu_in_1 - alu_in_2;                     // subtraction
            2: alu_out = alu_in_1 & alu_in_2;                     // and operator
            3: alu_out = alu_in_1 | alu_in_2;                     // or operator
            4: alu_out = alu_in_1 ^ alu_in_2;                     // xor operator
            5: alu_out = ~alu_in_1;                           // inversion
            6: alu_out = alu_in_1 + 1;                        // increment
            7: alu_out = alu_in_1 - 1;                        // decrement
            default: $display("Invalid instruction to ALU");
        endcase
    end
end

endmodule
