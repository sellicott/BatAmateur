// Single-Port Block RAM Write-First Mode (recommended template)
// File: rams_sp_wf.v
module rams_sp_wf (clk, we, en, addr, di, dout);
input clk; 
input we; 
input en;
input [15:0] addr; 
input [15:0] di; 
output [15:0] dout;
reg [15:0] RAM [(16 ** 2)-1:0];
reg [15:0] dout;
always @(posedge clk)
begin
  if (en)
  begin
    if (we)
      begin
        RAM[addr] <= di;
        dout <= di;
      end
   else
    dout <= RAM[addr];
  end
end
endmodule
