module MiniLab0_tb();
    logic clk;          // clock 
    logic KEY0;         // reset 
    logic [9:0] SW;     // switch 
    logic [9:0] LEDR;
    

    MiniLab0 iDUT(.clk(clk), .KEY0(KEY0), .SW(SW), .LEDR(LEDR));

    initial begin

        clk = 1'b0; 
        KEY0 = 1'b0;

        // Release reset
        @(negedge clk);
        KEY0 = 1'b1; 

        repeat (1000) begin

            // Wait
            repeat (5) @(posedge clk);
            SW = $random();
            repeat (5) @(posedge clk);
            // Check
            if (LEDR != SW)
                $display("Switch: %h, LED: %h\n", SW, LEDR);
        
        end

        $stop();
        
    end

	always 
		#5 clk = ~clk;
        
endmodule