module MiniLab0_tb();
    logic clk;          // clock 
    logic KEY0;         // reset 
    logic [9:0] SW;     // switch 
    logic [9:0] LEDR;
    

    MiniLab0 iDUT(.clk(clk), .KEY0(KEY0), .SW(SW), .LEDR(LEDR));
    initial begin
        clk = 1'b0; 
        KEY0 = 1'b0;
        SW = 10'b1010101010;            // random value on switch 

        @(negedge clk);
        KEY0 = 1'b1; 

        repeat (2000) @(posedge clk);
        
        $stop();
        
    end

	always 
		#5 clk = ~clk; 
endmodule