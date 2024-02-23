module spart_tb();
    // inputs
    logic clk;				// 50MHz clk
    logic rst_n;			// asynch active low reset
    logic iocs_n;			// active low chip select (decode address range)
    logic iorw_n;			// high for read, low for write
    logic [1:0] ioaddr;		// Read/write 1 of 4 internal 8-bit registers
    logic RX;
    // outputs
    logic tx_q_full;		// indicates transmit queue is full
    logic rx_q_empty;		// indicates receive queue is empty
    logic TX;				// UART TX line
    // inout
    wire [7:0] databus;	// bi-directional data bus
    logic [7:0] databus_out, databus_in;
    logic databus_output_enable;
    assign databus = databus_output_enable ? databus_out : 'z;
    assign databus_in = databus;

    spart iDUT(.clk(clk),.rst_n(rst_n),.iocs_n(iocs_n),.iorw_n(iorw_n),.tx_q_full(tx_q_full),.rx_q_empty(rx_q_empty),.ioaddr(ioaddr),.databus(databus),.TX(TX),.RX(RX));

    initial begin
        // reset
        clk = 0;
        rst_n = 0;
        ioaddr = '0;
        iocs_n = 1;
        RX = 1;
        databus_output_enable = 1;
        databus_out = '0;
        //deassert reset
        @(negedge clk) rst_n = 1;
        iocs_n = 0;
        iorw_n = 0;

        // test filling the TX queue to full.
        repeat (9) begin
            @(negedge clk) databus_out = $random();
        end

        // check
        if (!tx_q_full)
            $display("tx full not raised");

        // test RX queue to near full.
        
        repeat (7) begin
            @(negedge clk);
            RX = 0;
            @(posedge iDUT.iRX.shift);
            repeat (8) begin
                RX = $random();
                @(posedge iDUT.iRX.shift);
            end
            RX = 1;
            @(posedge iDUT.iRX.shift);
            
        end
        repeat (500) @(posedge clk); 

        // //test the status register to check if # entries in CBs are correct
        @(negedge clk);
        ioaddr = 2'b01;
        iorw_n = 1;
        databus_output_enable = 0;
        @(negedge clk);
        if(databus_in !== 8'h87)
            $display("Number of available entries in TX/RX queue is wrong");     

        //test baud rate configuration for BD == 57600, 230400, 9600
        @(negedge clk);
        //test R&W ay BD rate == 57600
        ioaddr = 2'b10;
        iorw_n = 0;
        databus_out = 8'h64;
        databus_output_enable = 1;
        @(negedge clk);
        ioaddr = 2'b11;
        iorw_n = 0;
        databus_out = 8'h03;
        @(negedge clk);
        if(iDUT.iTX.DB !== 16'h0364)
            $display("Baud rate configuration at 57600 is wrong. Should be 16'h0364!");

        @(negedge clk);
        //test R&W ay BD rate == 230400
        ioaddr = 2'b10;
        iorw_n = 0;
        databus_out = 8'hD9;
        @(negedge clk);
        ioaddr = 2'b11;
        iorw_n = 0;
        databus_out = 8'h00;
        @(negedge clk);
        if(iDUT.iTX.DB !== 16'h00D9)
            $display("Baud rate configuration at 230400 is wrong. Should be 16'h00D9!");

        @(negedge clk);
        //test R&W ay BD rate == 9600
        ioaddr = 2'b10;
        iorw_n = 0;
        databus_out = 8'h58;
        @(negedge clk);
        ioaddr = 2'b11;
        iorw_n = 0;
        databus_out = 8'h14;
        @(negedge clk);
        if(iDUT.iTX.DB !== 16'h1458)
            $display("Baud rate configuration at 9600 is wrong. Should be 16'h1458!");

        //interleaved read and write at different rate

        //make rx_q empty
        repeat (7) begin
            @(negedge clk);
            ioaddr = 2'b00;
            iorw_n = 1;
        end

        //wait until 2 queues are empty
        @(posedge iDUT.tx_q_empty);
        if (~rx_q_empty)
            $display("RX queue not empty");

        //write value 8'hFF to tx_q
        @(negedge clk);
        databus_output_enable = 1;
        databus_out = 8'hFF;
        ioaddr = 2'b00;
        iorw_n = 0;
        repeat (500) @(posedge clk);

        //receive 8'hFF into rx_q
        @(negedge clk);
        repeat (1) begin
            RX = 1;
            @(posedge iDUT.iRX.shift);
            $display("Shifted");
            $stop();
        end

        repeat (500) @(posedge clk);
        
        //wait until 8'hFF is stored into rx_q
        // @(posedge iDUT.rx_rdy);
        if(rx_q_empty === 1'b1)
            $display("rx queue should not be empty");
        $stop();
        
        // begin
        // //wait until 8'hFF has been read from tx_q and sent successfully
        // @(posedge iDUT.tx_done);
        // if(iDUT.iTX.tx_data !== 8'hFF)
        //     $display("tx_data is wrong. Value supposed to be 8'hFF but found to be ");
        // end
        // join

        //change BD rate back to 57600
        @(negedge clk);
        ioaddr = 2'b10;
        iorw_n = 0;
        databus_out = 8'h64;
        @(negedge clk);
        ioaddr = 2'b11;
        iorw_n = 0;
        databus_out = 8'h03;

        //write value 8'hFF to tx_q
        @(negedge clk);
        databus_out = 8'hAA;
        ioaddr = 2'b00;
        iorw_n = 0;

        @(posedge iDUT.tx_done);
        if(iDUT.iTX.tx_data !== 8'hAA)
            $display("tx_data is wrong. Value supposed to be 8'hAA but found to be ");

        $display("YAHOO! Tests passed!");
        $stop();

    end

    always  begin
        #5 clk = ~clk;
    end

endmodule