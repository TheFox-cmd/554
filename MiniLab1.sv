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

//assign specific isns to the part we want to implement
assign iocs_n = ~&addr[15:14];

assign dbus = (~iocs_n & ~iorw_n) ? wdata[7:0] : 8'hzz;
//instantiation of CPU
cpu iCPU(.clk(clk),.rst_n(rst_n),.wdata(wdata),.we(we),.rdata(rdata),.re(re),.addr(addr));
//Reset synchronization
rst_synch iRST(.clk(clk), .RST_n(RST_n), .rst_n(rst_n));
//SPART instantiation
spart iSP(.clk(clk), .rst_n(rst_n), .iocs_n(iocs_n), .iorw_n(iorw_n), .tx_q_full(tx_q_full), .rx_q_empty(rx_q_empty), .ioaddr(addr[1:0]), .databus(dbus), .TX(TX), .RX(RX));

//logical assign to read/write enable
assign iorw_n = re | ~we; 

                
endmodule
