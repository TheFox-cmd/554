module MiniLab0(
    input CLOCK_50, 
    input KEY0,
    input [9:0] SW,
    output logic [9:0] LEDR
);

logic rst_n, we, re;
logic [15:0] wdata, addr, rdata;
logic clk;

assign clk = CLOCK_50; 

cpu iCPU(.clk(clk),.rst_n(rst_n),.wdata(wdata),.we(we),.rdata(rdata),.re(re),.addr(addr));

rst_synch iRST(.clk(clk), .RST_n(KEY0), .rst_n(rst_n));

assign rdata = (addr == 16'hC001 && re) ? {6'h00, SW}   : 16'hxxxx;


always_ff @(posedge clk, negedge rst_n)
    if(!rst_n)
        LEDR <= '0;
    else
        if(addr == 16'hC000 && we)
            LEDR <= wdata[9:0];



// assign LEDR = SW; 
				
endmodule