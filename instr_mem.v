module instr_mem(clk, rd_en, addr, instr); 

	input clk; 
	input rd_en;
	input [9:0] addr; 
	output reg [15:0] instr; 

	reg [15:0] mem [16383:0]; 

	always @(negedge clk) begin
		if (rd_en) 
			instr <= mem[addr];
	end

	initial begin
		// $readmemh("I:/ECE554/Miniproj0/demo2/verilog/instr.hex", mem);
		$readmemh("C:/Users/zyang537/Downloads/554-main/554-main/MiniLab0_test.hex", mem);
	end

endmodule