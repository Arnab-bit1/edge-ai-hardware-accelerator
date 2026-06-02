module RAM(
    input clk,
    input wire [7:0] sensor_data_in,
    input wire [7:0] write_addr,
    input wire write_en,
    
    input wire [7:0] read_addr,
    output wire signed [7:0] data_out
);

    reg [7:0] main_mem [0:255];
    
    always @(posedge clk) begin
        if(write_en) begin
            main_mem[write_addr] <= sensor_data_in;
        end
        
        
    end
    
    assign data_out = main_mem[read_addr];

endmodule
