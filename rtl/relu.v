module ReLU(
    input wire [31:0] data_in,
    output reg [7:0] data_out
);
    reg [31:0] shifted_psum;
    
    always@(*) begin
        
        shifted_psum = data_in >> 8;
        if(data_in[31]) begin
            data_out = 8'b0;
        end
        
        else if(shifted_psum > 'd127) begin
            data_out = 'd127;
        end
        
        else begin
            data_out = shifted_psum[7:0];
        end
    end

endmodule
