`timescale 1ns/1ns

// to standardize the registers,
//if the bus is 2 wide, it's r/w, then en
//if three, it's inc, then  r/w, then en

module main(
	input wire [15:0] DATA,
	input wire [15:0] ADDRESS,
	input wire EXT_RAM_RW, EXT_RAM_EN, HALT, CLK, RST,
	output wire [15:0] OUT
);

reg [2:0] uOP;
integer i; //because c89 is stupid and dumb
	
//all the registers
reg [15:0] MAR, PC, IR, TMP;
reg [15:0] REGS [7:0]; //general purpose registers
reg [15:0] RAM [65535:0];
	
// resources for alu
wire [15:0] alu_in_1, alu_in_2;
reg [2:0] alu_select; 
reg [16:0] alu_out;
reg alu_enable, carry_in;
wire carry_out, zero_flag;

reg ZERO_FLAG;
reg C_OUT;

always @(posedge CLK) //negedge to avoid causing race conditions
begin
	if(HALT == 1'b1)
	begin
	    //we essentially touch nothing else except ram
	    if(EXT_RAM_RW == 1'b0 && EXT_RAM_EN == 1'b1)
	    begin
	        RAM[ADDRESS] <= DATA;
	    end
	end
	else
	begin
	//increment the uOP
	//reset state for uOP is 3, then
	uOP = uOP + 3'd1;
	
	//clear it all out
	//all of it
	//don't be shy
	if(RST == 1'b0)
	begin
		for(i = 0; i < 65536; i++)
		begin
			RAM[i] = 0;
		end
		
		for(i = 0; i < 8; i++)
		begin
			REGS[i] = 0;
		end
		uOP = 3'b111;
    		ZERO_FLAG = 1'b0;
    		C_OUT = 1'b0;
	end
	else
	begin
	//now we configure the signals correctly
	case(uOP)
	
  0: //initial retrieval
  begin
    $display("uOP 0: fetch");
    MAR <= PC;
    PC = PC + 1;
  end

  1: //load from memory into IR, incriement PC
  begin
    $display("uOP 1: decode");

    IR <= RAM[MAR];
  end

  2: //and he, upon, look'd at his creation,
      //wept, for it was to be ugly and dumb
      //yet, he worked on, as if to be unfazed
      //he'd finish if it cost him ARM and THUMB
	  
  // ^ i'm glad y'all were willing to keep this in ^
	  
      // Register instructions 
  begin
    $display("uOP 2: execute");
    if(IR[15:12] == 4'b0111)
    begin
      $display("register instruction");
      //this is the pit of ALU
      //tread lightly, and with a big 
      
      //check MOV
      if(IR[11:7] == 5'b11111)
      begin
        $display("MOV instruction");
        //r1 enable
	//r2 enable and read out
	REGS[IR[5:3]] <= REGS[IR[2:0]];
        //reset
        uOP <= 3'b111;
      end
      //check inc
      else if(IR[11:7] == 5'b11110)
      begin
        $display("INC instruction");
        //r1 inc and read out (no enable)
	      REGS[IR[5:3]] = REGS[IR[5:3]] + 1;
        //reset
        uOP <= 3'b111;
      end
      else
      begin
        $display("ALU instruction");
        // move from op1 to register A if op1 is not register A
        if (IR[5:3] != 3'h0) begin
          $display("move op1 to A");
          REGS[0] <= REGS[IR[5:3]];
        end
        // otherwise do nothing
      end
    end
    else if (IR[15:12] == 4'b1111)
    begin
      // NOP instruction
      uOP <= 3'b111;
      $display("NOP instruction");
    end
    else
    begin
      //this is the memory den
      //oh no.
      // direct jump instruction
      if(IR[15] == 1'b0 && IR[14]==1'b1) 
      begin
        $display("JMP instruction");
        //00 is uncond, 01 is z = 1, 10 is z = 0, 11 is unregistered
        //i guess 11 is unconditional unjump lmao
        if ( 
          (IR[13:12] == 2'd0) || // branch unconditional
          (IR[13:12] == 2'd1 && ZERO_FLAG == 1'b0) || // branch if zero
          (IR[13:12] == 2'd2 && ZERO_FLAG == 1'b1) // branch if one
        ) 
        begin
          // move the location (stored in the instruction register) 
          // to the program counter
	  PC <= {4'b0, IR[11:0]};

        end 
        // otherwise incriment the program counter
	//note from robert: i don't think the above is true
        else begin
          //PC_INC <= 1'b1;
        end
        uOP <= 3'b111;
      end
      else begin
        $display("STORE or LOAD instruction");
        // write addr to mar 
        // we can use it for direct or indirect addressing
	      MAR <= {4'b0, IR[11:0]};
      end
    end
  end
  3:
  begin
    $display("uOP 3: execute");
    if(IR[15:12] == 4'b0111)
    begin
      $display("ALU instruction");
      // move from op2 to register B if op2 is not register B
      if (IR[2:0] != 3'h0) 
      begin
        $display("move op2 to B");
	REGS[1] <= REGS[IR[2:0]];
      end
      // otherwise do nothing

    // Memory instructions
    end 
    else 
    begin
      // check for indirect instructions
      if (IR[15] == 1'b1) begin
        //indirect JMP set of instructions
        if(IR[14]==1'b1) 
        begin
          $display("JMP instruction");
          //00 is uncond, 01 is z = 1, 10 is z = 0, 11 is unregistered
          //i guess 11 is unconditional unjump lmao
          if ( 
            (IR[13:12] == 2'd0) || // branch unconditional
            (IR[13:12] == 2'd1 && ZERO_FLAG == 1'b0) || // branch if zero
            (IR[13:12] == 2'd2 && ZERO_FLAG == 1'b1) // branch if one
          ) 
          begin
            // move the location (stored in the RAM) 
            // to the program counter
	    PC <= RAM[MAR];
          end 
          // otherwise incriment the program counter
	  // note from robert again, sorry- pretty sure still not true
          else begin
            //PC_INC <= 1'b1;
          end
          uOP <= 3'b111;
        end
        else begin
          // move the data from the memory back to MAR
	  MAR = RAM[MAR];
        end
      end
      // store instruction
      else if (IR[13] == 1'b1)
      begin
        $display("STORE instruction");
        // store A
        if (IR[12] == 1'b0) begin
	   RAM[MAR] <= REGS[0];
        end
        // store B
        else begin
	   RAM[MAR] <= REGS[1];
        end
        uOP <= 3'b111;
      end
      // load instruction
      else 
      begin
        $display("LOAD instruction");
        // load A
        if (IR[12] == 1'b0) begin
	  REGS[0] <= RAM[MAR];
        end
        // load B
        else begin
          REGS[1] <= RAM[MAR];
        end
        uOP <= 3'b111;
      end
    end
  end
  4:
  begin
    $display("uOP 3: execute");
    // register operation
    if(IR[15:12] == 4'b0111)
    begin
      alu_enable <= 1'b1;
      alu_select <= IR[11:7];
      ZERO_FLAG <= zero_flag;
      C_OUT <= carry_out;
      // select what accumulator to write to
      if (IR[6]) begin
	REGS[0] <= alu_out;
      end else begin
	REGS[1] <= alu_out;
      end
      uOP <= 3'b111;
    end
    // memory operation
    else
    begin
      // store instruction
      if (IR[13] == 1'b1)
      begin
        // store A
        if (IR[12] == 1'b0) begin
	  RAM[MAR] = REGS[0];
        end
        // store B
        else begin
	  RAM[MAR] = REGS[1];
        end

        uOP <= 3'b111;
      end
      // load instruction
      else 
      begin
        // load A
        if (IR[12] == 1'b0) begin
	  REGS[0] <= RAM[MAR];
        end
        // load B
        else begin
	  REGS[1] <= RAM[MAR];
        end

        uOP <= 3'b111;
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
end

//i'm a lazybones brogrammer
//how else am i to get the values i need into the alu???
assign alu_in_1 = REGS[0];
assign alu_in_2 = REGS[1];
assign OUT = REGS[7];
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
