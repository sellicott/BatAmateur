`timescale 1ns/1ns

// to standardize the registers,
//if the bus is 2 wide, it's r/w, then en
//if three, it's inc, then  r/w, then en

module BatAmateurController(
	input wire CLK, RST,
	input wire [7:0] ALU_REG,
	input wire [15:0] INSTR,

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

always @(posedge CLK or RST) //negedge to avoid causing race conditions
begin
	//increment the uOP
	//reset state for uOP is 3, then
	uOP = uOP + 4'd1;
	//we also need to clear all of the output controls
	//to definitively avoid crosstalk
	PC_INC = 1'b0;
	PC_RW = 1'b1;
	PC_EN = 1'b0;

	MAR_LOAD = 1'b0;
	MAR_EN = 1'b1;

	RAM_RW = 1'b1;
	RAM_EN = 1'b0;

	IR_LOAD = 1'b0;
	IR_EN = 1'b0;

	REGS_INC = 8'h00;
	REGS_RW = 8'hFF;
	REGS_EN = 8'h00;

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
			PC_INC <= 1'b0;
			PC_RW  <= 1'b1;
			PC_EN  <= 1'b1;

			MAR_LOAD <= 1'b1;
		end

		1: //load from memory into IR, incriement PC
		begin
			PC_INC <= 1'b1;
			PC_RW <= 1'b0;
			PC_EN <= 1'b0;

			RAM_RW <= 1'b1;
			RAM_EN <= 1'b1;

			IR_LOAD <= 1'b1;
			IR_EN <= 1'b1;
		end
	
		2: //and he, upon, look'd his creation,
		   //wept, for it was to be ugly and dumb
		   //yet, he worked on, as if to be unfazed
		   //he'd finish if it cost him ARM and THUMB
		   // Register instructions 
		begin
			if(INSTR[15:12] == 4'b0111)
			begin
				//this is the pit of ALU
				//tread lightly, and with a big 
				
				//check MOV
				if(INSTR[11:7] == 5'b11111)
				begin
					//r1 enable
					REGS_EN[INSTR[5:3]] <= 1'b1;
					//r2 enable and read out
					REGS_EN[INSTR[2:0]] <= 1'b1;
					REGS_RW[INSTR[2:0]] <= 1'b1;
					//reset
					uOP <= 3'b111;
				end
				//check inc
				else if(INSTR[11:7] == 5'b11110)
				begin
					//r1 inc and read out (no enable)
					REGS_INC[INSTR[5:3]] <= 1'b1;
					REGS_RW[INSTR[5:3]] <= 1'b0;
					//reset
					uOP <= 3'b111;
				end
				else
				begin
					// move from op1 to register A if op1 is not register A
					if (INSTR[5:3] != 3'h0) begin
						REGS_EN[0] <= 1'b1;
						REGS_RW[0] <= 1'b0; // write reg A
						REGS_EN[INSTR[5:3]] <= 1'b1;
						REGS_RW[INSTR[5:3]] <= 1'b1; // read op1
					end
					// otherwise do nothing
				end
			end
			else if (INSTR[15:12] == 4'b0111)
			begin
				// NOP instruction
				uOP <= 3'b111;
			end
			else
			begin
				//this is the memory den
				//oh no.
				// direct jump instruction
				if(INSTR[15] == 1'b0 && INSTR[14]==1'b1) 
				begin
					//00 is uncond, 01 is z = 1, 10 is z = 0, 11 is unregistered
					//i guess 11 is unconditional unjump lmao
					if ( 
						(INSTR[13:12] == 2'd0) || // branch unconditional
						(INSTR[13:12] == 2'd1 && ALU_REG[0] == 1'b0) || // branch if zero
						(INSTR[13:12] == 2'd2 && ALU_REG[0] == 1'b1) // branch if one
					) 
					begin
						// move the location (stored in the instruction register) 
						// to the program counter
						IR_EN <= 1'b1;
						IR_LOAD <= 1'b0; 
						PC_INC <= 1'b0;
						PC_EN <= 1'b1;
						PC_RW <= 1'b0; // write

					end 
					// otherwise incriment the program counter
					else begin
						PC_INC <= 1'b1;
					end
					uOP <= 3'b111;
				end
				else begin
					// write addr to mar 
					// we can use it for direct or indirect addressing
					IR_LOAD <= 1'b0;
					IR_EN <= 1'b1;
					MAR_LOAD <= 1'b1;
				end
			end
		end
		3:
		begin
			if(INSTR[15:12] == 4'b0111)
			begin
				// move from op2 to register B if op2 is not register B
				if (INSTR[2:0] != 3'h0) 
				begin
					REGS_EN[1] <= 1'b1;
					REGS_RW[1] <= 1'b0; // write reg A
					REGS_EN[INSTR[2:0]] <= 1'b1;
					REGS_RW[INSTR[2:0]] <= 1'b1; // read op1
				end
				// otherwise do nothing

			// Memory instructions
			end 
			else 
			begin
				// check for indirect instructions
				if (INSTR[15] == 1'b1) begin
					//indirect JMP set of instructions
					if(INSTR[14]==1'b1) 
					begin
						//00 is uncond, 01 is z = 1, 10 is z = 0, 11 is unregistered
						//i guess 11 is unconditional unjump lmao
						if ( 
							(INSTR[13:12] == 2'd0) || // branch unconditional
							(INSTR[13:12] == 2'd1 && ALU_REG[0] == 1'b0) || // branch if zero
							(INSTR[13:12] == 2'd2 && ALU_REG[0] == 1'b1) // branch if one
						) 
						begin
							// move the location (stored in the RAM) 
							// to the program counter
							RAM_EN <= 1'b1;
							RAM_RW <= 1'b1; // read
							PC_INC <= 1'b0;
							PC_EN <= 1'b1;
							PC_RW <= 1'b0; // write

						end 
						// otherwise incriment the program counter
						else begin
							PC_INC <= 1'b1;
						end
						uOP <= 3'b111;
					end
					else begin
						// move the data from the memory back to MAR
						MAR_LOAD <= 1'b1;
						RAM_EN <= 1'b1;
						RAM_RW <= 1'b1; //read
					end
				end
				// store instruction
				else if (INSTR[13] == 1'b1)
				begin
					// store A
					if (INSTR[12] == 1'b0) begin
						REGS_EN[0] <= 1'b1;
						REGS_RW[0] <= 1'b1; //read
					end
					// store B
					else begin
						REGS_EN[1] <= 1'b1;
						REGS_RW[1] <= 1'b1; //read
					end

					RAM_EN <= 1'b1;
					RAM_RW <= 1'b0; // write
					uOP <= 3'b111;
				end
				// load instruction
				else 
				begin
					// load A
					if (INSTR[12] == 1'b0) begin
						REGS_EN[0] <= 1'b1;
						REGS_RW[0] <= 1'b0; // write
					end
					// load B
					else begin
						REGS_EN[1] <= 1'b1;
						REGS_RW[1] <= 1'b0; // write
					end

					RAM_EN <= 1'b1;
					RAM_RW <= 1'b1; // read 
					uOP <= 3'b111;
				end
			end
		end
		4:
		begin
			// register operation
			if(INSTR[15:12] == 4'b0111)
			begin
				ALU_EN <= 1'b1;
				ALU_OP <= INSTR[11:7];
				// select what accumulator to write to
				if (INSTR[6]) begin
					REGS_EN[0] <= 1'b1;
					REGS_RW[0] <= 1'b0; //write
				end else begin
					REGS_EN[1] <= 1'b1;
					REGS_RW[1] <= 1'b0; //write
				end
				uOP <= 3'b111;
			end
			// memory operation
			else
			begin
				// store instruction
				if (INSTR[13] == 1'b1)
				begin
					// store A
					if (INSTR[12] == 1'b0) begin
						REGS_EN[0] <= 1'b1;
						REGS_RW[0] <= 1'b1; //read
					end
					// store B
					else begin
						REGS_EN[1] <= 1'b1;
						REGS_RW[1] <= 1'b1; //read
					end

					RAM_EN <= 1'b1;
					RAM_RW <= 1'b0; // write
					uOP <= 3'b111;
				end
				// load instruction
				else 
				begin
					// load A
					if (INSTR[12] == 1'b0) begin
						REGS_EN[0] <= 1'b1;
						REGS_RW[0] <= 1'b0; // write
					end
					// load B
					else begin
						REGS_EN[1] <= 1'b1;
						REGS_RW[1] <= 1'b0; // write
					end

					RAM_EN <= 1'b1;
					RAM_RW <= 1'b1; // read 
					uOP <= 3'b111;
				end
			end
		end
		default:
		begin
			uOP <= 3'b111; //woops, missed one somewhere.
			MAR_EN <= 1'b0;
		end
	endcase
	end
end

endmodule
