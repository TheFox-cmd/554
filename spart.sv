//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:   
// Design Name: 
// Module Name:    spart 
// Project Name: 
// Target Devices: DE1_SOC board
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module spart(
    input clk,				// 50MHz clk
    input rst_n,			// asynch active low reset
    input iocs_n,			// active low chip select (decode address range)
    input iorw_n,			// high for read, low for write
    output tx_q_full,		// indicates transmit queue is full
    output rx_q_empty,		// indicates receive queue is empty
    input [1:0] ioaddr,		// Read/write 1 of 4 internal 8-bit registers
    inout [7:0] databus,	// bi-directional data bus
    output TX,				// UART TX line
    input RX				// UART RX line
    );

logic [7:0] databus_drv,tx_data,rx_data;
logic databus_enable;
logic wr_cb_tx, rd_cb_rx; 
logic tx_done;
logic trmt;                                                                     // Start signal for UART_tx
logic [7:0] buffer_data, status_data, DBL, DBH;                                 // Registers 
logic tReg, sReg, wr_DBH, wr_DBL;                                               // Control signals for registers
logic [12:0] DB;                                                                // Baud Rate
logic [3:0] tx_remain, rx_filled; 
logic rx_rdy;
logic rx_q_full;
logic tx_q_empty;                                                               // 1 if TX CB is empty
//2 to 4 Decoder connecting Databus to Registers
always_ff @(posedge clk, negedge rst_n) begin
    if(!rst_n) begin                                                            // reset All Register
        buffer_data <= 8'h0;
        status_data <= 8'h0;
        databus_enable <= 1'b0;
        // Baud rate reset to 0x01B2 = 115200 
        DBL <= 8'hB2;
        DBH <= 8'h01;
    end 
    else begin                                                                  // assign Register to Databus
        if (tReg)
            buffer_data <= databus;
        else if (sReg) 
            databus_enable <= 1'b1;
        else if(wr_DBH)
            DBH <= databus;
        else if(wr_DBL)
            DBL <= databus;
    end
end
assign databus_drv = {tx_remain, {1'b0, !rx_filled[2:0]}};
assign databus = sReg ? databus_drv: 8'bz;
/*
// This flop delays the signal tx_done by 1 cycle, allowing circular buffer to correctly output the next byte before passing it into UART_tx
always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n)
        trmt <= 1'b0;
    else if (!empty)
        trmt <= tx_done;
    else
        trmt <= 1'b0;
end

*/

assign trmt = !tx_q_empty && tx_done;                                                // transmit signal for Uart_tx
assign tReg = (!iocs_n) && (ioaddr == 2'b00);                                   // Select Transmit Register 
assign sReg = (!iocs_n) && (ioaddr == 2'b01) && (iorw_n);                       // Select Status Register on READ only
assign wr_DBL = (!iocs_n) && (ioaddr == 2'b10) && (!iorw_n);                    // Select DBL on WRITE only
assign wr_DBH = (!iocs_n) && (ioaddr == 2'b11) && (!iorw_n);                    // Select DBH on WRITE only
assign DB = {DBH[4:0], DBL};                                                    // Parametrized Baud Rate



circular_buffer #(8) iBUF_TX(.clk(clk), .rst_n(rst_n), .write_enable(wr_cb_tx), .read_enable(trmt), .write_data(buffer_data), .read_data(tx_data), .full(tx_q_full), .empty(tx_q_empty), .counter(tx_remain));
circular_buffer #(8) iBUF_RX(.clk(clk), .rst_n(rst_n), .write_enable(rx_rdy), .read_enable(rd_cb_rx), .write_data(rx_data), .read_data(), .full(rx_q_full), .empty(rx_q_empty), .counter(rx_filled));

assign wr_cb_tx = (!iocs_n) && (ioaddr == 2'b00) && (!iorw_n);    // write enable from databus for tx cb
assign rd_cb_rx = (!iocs_n) && (ioaddr == 2'b00) && (iorw_n);     // read enable from databus for rx cb
assign clr_rx_rdy = !rx_rdy && !rx_q_full;


UART_tx iTX(.clk(clk), .rst_n(rst_n), .TX(TX), .trmt(trmt), .tx_data(tx_data), .tx_done(tx_done), .DB(DB));
UART_rx iRX(.clk(clk), .rst_n(rst_n), .RX(RX), .rdy(rx_rdy), .clr_rdy(clr_rx_rdy), .rx_data(rx_data), .DB(DB));
				   
endmodule
