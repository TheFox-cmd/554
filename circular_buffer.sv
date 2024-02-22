module circular_buffer #(parameter BUFFER_SIZE = 8)(
    input logic clk,
    input logic rst_n,
    input logic write_enable,
    input logic read_enable,
    input logic [7:0] write_data,
    output logic [7:0] read_data,
    output logic full,
    output logic empty,
    output logic [2:0] counter
);

    localparam ADDR_WIDTH = $clog2(BUFFER_SIZE);

    logic [7:0] buffer[BUFFER_SIZE-1:0];
    logic [ADDR_WIDTH-1:0] write_ptr, read_ptr;
    logic [ADDR_WIDTH:0] count;

    // Write operation
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            write_ptr <= 0;
            count <= 0;
        end 
        else if (write_enable && !full) begin
            buffer[write_ptr] <= write_data;
            if(write_ptr < BUFFER_SIZE)
                write_ptr <= write_ptr + 1;
            else
                write_ptr <= 0;
            count <= count + 1;
        end
    end

    // Read operation
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            read_ptr <= 0;
            read_data <= 0;
        end else if (read_enable && !empty) begin
            read_data <= buffer[read_ptr];
            if(read_ptr < BUFFER_SIZE)
                read_ptr <= read_ptr + 1;
            else
                read_ptr <= 0;
            count <= count - 1;
        end
        else begin
            read_data <= buffer[read_ptr];
        end

    end

    // Status signals
    assign full = (count == BUFFER_SIZE);
    assign empty = (count == 0);


assign counter = count[ADDR_WIDTH-1:0]; 

endmodule