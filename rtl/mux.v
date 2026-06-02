module MUX(
    inout [7:0] val_A, val_B, val_C, val_D,
    input [1:0] sel,
    output reg [7:0] data_out
);

    always @(*) begin 
        case(sel)
            2'b00: data_out = val_A;
            2'b01: data_out = val_B;
            2'b11: data_out = val_C;
            2'b10: data_out = val_D;
        endcase 
    end

endmodule
