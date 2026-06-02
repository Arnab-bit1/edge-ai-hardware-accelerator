module dense_1_weights (
    input wire clk,
    input wire [3:0] address,      
    output reg signed [7:0] weight_out
);

    reg signed [7:0] weight_rom [0:15];

    initial begin
        weight_rom[0] = -8'd61;
        weight_rom[1] = -8'd110;
        weight_rom[2] = 8'd63;
        weight_rom[3] = -8'd90;
        weight_rom[4] = 8'd100;
        weight_rom[5] = 8'd83;
        weight_rom[6] = -8'd120;
        weight_rom[7] = 8'd72;
        weight_rom[8] = -8'd108;
        weight_rom[9] = -8'd71;
        weight_rom[10] = -8'd127;
        weight_rom[11] = -8'd87;        
        weight_rom[12] = -8'd101;
        weight_rom[13] = -8'd89;
        weight_rom[14] = 8'd5;
        weight_rom[15] = -8'd29;        
    end

    always @(posedge clk) begin
        weight_out <= weight_rom[address];
    end

endmodule
