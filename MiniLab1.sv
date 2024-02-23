module MiniLab1(
    input clk, 
    input RST_n,
    input RX, 
    output TX
);

logic we, re;
wire [15:0] wdata, addr, rdata;
wire [7:0] dbus;

logic iorw_n, iocs_n;
logic tx_q_full, rx_q_empty;
logic rst_n;

assign iocs_n = ~&addr[15:14];

assign dbus = (~iocs_n & ~iorw_n) ? wdata[7:0] : 8'hzz;

cpu iCPU(.clk(clk),.rst_n(rst_n),.wdata(wdata),.we(we),.rdata(rdata),.re(re),.addr(addr));

rst_synch iRST(.clk(clk), .RST_n(RST_n), .rst_n(rst_n));

spart iSP(.clk(clk), .rst_n(rst_n), .iocs_n(iocs_n), .iorw_n(iorw_n), .tx_q_full(tx_q_full), .rx_q_empty(rx_q_empty), .ioaddr(addr[1:0]), .databus(dbus), .TX(TX), .RX(RX));

assign iorw_n = re | ~we; 
/*
always_ff @(posedge clk, negedge rst_n)
    if(!rst_n)
        LEDR <= '0;
    else
        if(addr == 16'hC000 && we)
            LEDR <= wdata[9:0];
*/


// assign LEDR = SW; 
				
endmodule