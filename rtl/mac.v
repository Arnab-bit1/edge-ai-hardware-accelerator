module MAC(
    input wire clk,
    input wire rst,
    input wire clear_accum,  
    input wire en,
    input wire signed [7:0] val_A,
    input wire signed [7:0] val_B,
    output wire signed [31:0] psum_out
);

    reg signed [15:0] mult_reg;
    reg clear_accum_pipe;         
    reg signed [31:0] accumulator;

    always @(posedge clk) begin
        if (rst) begin
            mult_reg         <= 16'b0;
            clear_accum_pipe <= 1'b0;
            accumulator      <= 32'b0;
        end 
        else if (en) begin

            mult_reg         <= val_A * val_B;
            clear_accum_pipe <= clear_accum;    
            
            if (clear_accum_pipe) begin
                accumulator <= mult_reg; 
            end else begin
                accumulator <= accumulator + mult_reg;
            end
        end
    end

    assign psum_out = accumulator;

endmodule
