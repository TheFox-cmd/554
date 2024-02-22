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
logic [12:0] DB;                                                                // Baud Rate
logic [2:0] tx_remain, rx_filled; 
logic rx_rdy;
logic rx_q_full;
logic tx_q_empty;                                                               // 1 if TX CB is empty

assign databus = ((~iocs_n) || (~iorw_n)) ? 'z :                                 // Read condition
                 (ioaddr == 2'b00) ? buffer_data : 
                 (ioaddr == 2'b01) ? status_data : 
                 (ioaddr == 2'b10) ? DBL : DBH;

assign status_data = {{1'b0, tx_remain[2:0]}, {1'b0, rx_filled[2:0]}};

always_ff @(posedge clk, negedge rst_n) begin
    if(!rst_n) begin                                                            // reset DB register
        // Baud rate reset to 0x01B2 = 115200 
        DBL <= 8'hB2;
        DBH <= 8'h01;
    end 
    else begin                                                                  
        if((!iocs_n) && (ioaddr == 2'b11) && (!iorw_n))                         // Select DBH on WRITE only
            DBH <= databus;
        else if((!iocs_n) && (ioaddr == 2'b10) && (!iorw_n))                    // Select DBL on WRITE only
            DBL <= databus;
    end
end
assign DB = {DBH[4:0], DBL};                                                                    // Parametrized Baud Rate

circular_buffer #(8) iBUF_TX(.clk(clk), .rst_n(rst_n), .write_enable(wr_cb_tx), .read_enable(trmt), .write_data(databus), .read_data(tx_data), .full(tx_q_full), .empty(tx_q_empty), .counter(tx_remain));
circular_buffer #(8) iBUF_RX(.clk(clk), .rst_n(rst_n), .write_enable(rx_rdy), .read_enable(rd_cb_rx), .write_data(rx_data), .read_data(buffer_data), .full(rx_q_full), .empty(rx_q_empty), .counter(rx_filled));

assign wr_cb_tx = (!iocs_n) && (ioaddr == 2'b00) && (!iorw_n);    // write enable from databus for tx cb
assign rd_cb_rx = (!iocs_n) && (ioaddr == 2'b00) && (iorw_n);     // read enable from databus for rx cb
assign clr_rx_rdy = !rx_rdy && !rx_q_full;
// assign trmt = (!iocs_n) && (ioaddr == 2'b01) && (iorw_n);

UART_tx iTX(.clk(clk), .rst_n(rst_n), .TX(TX), .trmt(trmt), .tx_data(tx_data), .tx_done(tx_done), .DB(DB));
UART_rx iRX(.clk(clk), .rst_n(rst_n), .RX(RX), .rdy(rx_rdy), .clr_rdy(), .rx_data(rx_data), .DB(DB));
				   
endmodule

// /*
// // This flop delays the signal tx_done by 1 cycle, allowing circular buffer to correctly output the next byte before passing it into UART_tx
// always_ff @(posedge clk, negedge rst_n) begin
//     if (!rst_n)
//         trmt <= 1'b0;
//     else if (!empty)
//         trmt <= tx_done;
//     else
//         trmt <= 1'b0;
// end

// */