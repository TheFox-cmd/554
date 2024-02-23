module MiniLab1(
    input clk, 
    input rst_n,
    input TX, 
    output RX
);

logic rst_n, we, re;
logic [15:0] wdata, addr, rdata;
logic clk;
logic [9:0] SW,
logic [9:0] LEDR
logic iorw_n;
logic tx_q_full, rx_q_empty;

cpu iCPU(.clk(clk),.rst_n(rst_n),.wdata(wdata),.we(we),.rdata(rdata),.re(re),.addr(addr));

rst_synch iRST(.clk(clk), .RST_n(KEY0), .rst_n(rst_n));

spart iSP(.clk(clk), .rst_n(rst_n), .iocs_n(1'b0), .iorw_n(iorw_n), .tx_q_full(tx_q_full), .rx_q_empty(rx_q_empty), .ioaddr(addr[1:0]), .databus(wdata[7:0]), .TX(TX), .RX(RX));

assign iorw_n = re | ~we; 

always_ff @(posedge clk, negedge rst_n)
    if(!rst_n)
        LEDR <= '0;
    else
        if(addr == 16'hC000 && we)
            LEDR <= wdata[9:0];



// assign LEDR = SW; 
				
endmodule