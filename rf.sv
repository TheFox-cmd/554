module rf(clk,p0_addr,p1_addr,p0,p1,re0,re1,dst_addr,dst,we);
//////////////////////////////////////////////////////////////////
// Triple ported register file.  Two read ports (p0 & p1), and //
// one write port (dst).  Data is written on clock high, and  //
// read on clock low //////////////////////////////////////////
//////////////////////

input clk;
input [3:0] p0_addr, p1_addr;			// two read port addresses
input re0,re1;							// read enables (power not functionality)
input [3:0] dst_addr;					// write address
input [15:0] dst;						// dst bus
input we;								// write enable
										// test is halted.

output reg [15:0] p0,p1;  				//output read ports

integer indx;

reg [15:0]mem0[0:15];					// 16 registers each 16-bit wide
reg [15:0]mem1[0:15];					// 16 registers each 16-bit wide

logic [15:0] p0_tmp;
logic [15:0] p1_tmp;  

// Set to memory when Write enable
always @(negedge clk)
  if(we) begin
    mem0[dst_addr] <= dst;
    mem1[dst_addr] <= dst;
  end
	
// Set to memory when Read0 enable
always @(negedge clk)
  if (re0)
    p0_tmp <= mem0[p0_addr];
	
// Set to memory when Read1 enable
always @(negedge clk)
  if(re1)
    p1_tmp <= mem1[p1_addr];

assign p0 = (p0_addr == 4'h0) ? 16'b0 :
            (re0 && we && (p0_addr == dst_addr)) ? dst : p0_tmp;

assign p1 = (p1_addr == 4'h0) ? 16'b0 :
            (re1 && we && (p1_addr == dst_addr)) ? dst : p1_tmp;

endmodule
  

