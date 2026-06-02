module MaxPooling1D(
	input clk, rst,
	input wire signed [7:0] data_in,
	input write_in,
	output reg write_out,	
	output reg [7:0] data_out
);

    reg toggle;
    reg signed [7:0] hold_val;
    
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            write_out <= 1'b0;
            data_out <= 8'b0;
            hold_val <= 8'b0;
            toggle <= 1'b0;
        end
        else begin
            write_out <= 1'b0;
            if(write_in) begin
                if(toggle == 1'b0) begin
                    hold_val <= data_in;
                    toggle <= 1'b1;
                end
                
                else begin
                    if(data_in >= hold_val)
                        data_out <= data_in;
                    else begin
                        data_out <= hold_val;
                    end
                    write_out <= 1'b1;
                    toggle <= 1'b0;
                end
            end
        end
    end

endmodule
