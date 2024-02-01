module data_mem(clk, we, addr, wdata, rdata); 

	input clk; 					// clock system
	input we;					// write enable
	input [12:0] addr; 
	input [15:0] wdata; 
	output reg [15:0] rdata; 

	reg [15:0] mem [8191:0]; 

	always @(posedge clk) begin
		if (we) 
			mem[addr] <= wdata; 
		rdata <= mem[addr];
	end

endmodule
