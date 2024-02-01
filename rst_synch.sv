module rst_synch(
    input logic clk, RST_n,
    output logic rst_n
);

logic rst1;

always @(negedge clk, negedge RST_n) begin
    if(!RST_n) begin
        rst1 <= 1'b0;
        rst_n <= 1'b0;
    end
    else begin
        rst1 <= 1'b1;
        rst_n <= rst1;
    end
end

endmodule