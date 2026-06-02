module intermediate_ram (
    input wire clk,
    
    input wire write_en,                  
    input wire [15:0] write_addr,          
    input wire signed [7:0] data_in,      
    
    input wire [10:0] read_addr,
    output wire signed [7:0] data_out
);


    reg signed [7:0] ram_block [0:2047];

    always @(posedge clk) begin
        if (write_en) begin
            ram_block[write_addr] <= data_in;
        end
        
        
    end
    
    assign data_out = ram_block[read_addr];

endmodule
