module instr_mem(clk, rd_en, addr, instr); 

	input clk; 
	input rd_en;
	input [9:0] addr; 
	output reg [15:0] instr; 

	reg [15:0] mem [16383:0]; 

	always @(posedge clk) begin
		if (rd_en) 
			instr <= mem[addr];
	end

	initial begin
		$readmemh("C:/Users/erichoffman/Documents/ECE_Classes/ECE552/EricStuff/Project/Tests/instr.hex", instr);
	end

endmodule