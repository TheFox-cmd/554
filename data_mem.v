module data_mem(clk, we, re, addr, wrt_data, rd_data); 

	input clk; 					// clock system
	input we, re;					// write enable
	input [12:0] addr; 
	input [15:0] wrt_data; 
	output reg [15:0] rd_data; 

	reg [15:0] mem [8191:0]; 

	always @(negedge clk) begin
		if (we) 
			mem[addr] <= wrt_data; 
		else if (re)
			rd_data <= mem[addr];
	end

endmodule
