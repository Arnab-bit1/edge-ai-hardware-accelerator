module bias_ram(
    input wire [1:0] state,
    input wire [7:0] output_node_idx,
    output reg [7:0] current_bias
);

    wire [31:0] conv1d_biases [0:7];
    assign conv1d_biases[0] = -32'd61;
    assign conv1d_biases[1] = 32'd65;
    assign conv1d_biases[2] = 32'd5;
    assign conv1d_biases[3] = 32'd43;
    assign conv1d_biases[4] = 32'd69;
    assign conv1d_biases[5] = 32'd127;
    assign conv1d_biases[6] = 32'd20;
    assign conv1d_biases[7] = -32'd22;
    
    wire [31:0] conv1d_1_biases [15:0];
    assign conv1d_1_biases[0] = 32'd63;
    assign conv1d_1_biases[1] = -32'd3;
    assign conv1d_1_biases[2] = 32'd62;
    assign conv1d_1_biases[3] = 32'd112;
    assign conv1d_1_biases[4] = 32'd51;
    assign conv1d_1_biases[5] = -32'd14;
    assign conv1d_1_biases[6] = 32'd47;
    assign conv1d_1_biases[7] = 32'd127;
    assign conv1d_1_biases[8] = -32'd33;
    assign conv1d_1_biases[9] = 32'd84;
    assign conv1d_1_biases[10] = -32'd29;
    assign conv1d_1_biases[11] = 32'd74;
    assign conv1d_1_biases[12] = 32'd22;
    assign conv1d_1_biases[13] = -32'd87;
    assign conv1d_1_biases[14] = 32'd75;
    assign conv1d_1_biases[15] = 32'd104;
    
    wire [31:0] dense_biases [0:15];
    assign dense_biases[0] = 32'd26;
    assign dense_biases[1] = 32'd64;
    assign dense_biases[2] = -32'd36;
    assign dense_biases[3] = 32'd29;
    assign dense_biases[4] = -32'd92;
    assign dense_biases[5] = 32'd49;
    assign dense_biases[6] = 32'd108;
    assign dense_biases[7] = -32'd45;
    assign dense_biases[8] = 32'd113;
    assign dense_biases[9] = -32'd127;
    assign dense_biases[10] = -32'd76;
    assign dense_biases[11] = 32'd37;
    assign dense_biases[12] = 32'd94;
    assign dense_biases[13] = 32'd105;
    assign dense_biases[14] = -32'd31;
    assign dense_biases[15] = 32'd19;
    
    wire [31:0] dense_1_bias;
    assign dense_1_bias = 32'd127;
    
    always @(*) begin
        case(state)
            2'b00: current_bias = conv1d_biases[output_node_idx];
            2'b01: current_bias = conv1d_1_biases[output_node_idx];
            2'b11: current_bias = dense_biases[output_node_idx];
            2'b10: current_bias = dense_1_bias;
        endcase
    end

endmodule
