module main(
    input wire clk,
    input wire rst,
    input wire start,
    input wire sensor_write_en,
    input wire [7:0] sensor_addr,
    input wire signed [7:0] sensor_data_in,
    output wire final_prediction,
    output wire prediction_valid,
    output wire done
    
);
    
    wire mac_en, clear_accum;
    wire [15:0] weight_addr, act_addr;
    wire write_to_RAM;
    wire [1:0] bram_sel;
    wire [7:0] data_from_ram_ip, intermediate_data_out, data_out_relu;
    wire [7:0] dw_out, dw_1_out, conv1d_out, conv1d_1_out;
    wire [7:0] mac_val_b, mac_val_a;
    wire act_mux_sel;
    wire [31:0] mac_psum_out;
    wire [7:0] relu_data_out;
    wire [7:0] br_node_idx;
    wire [7:0] current_bias;
    wire [7:0] pooled_data_out;
    wire pool_write_en;
    wire [2:0] cn_state;
    wire final_ram_write_en;
    wire [7:0] final_ram_data_in;
    reg [15:0] ram_write_ptr;
    wire signed [31:0] biased_psum;
    wire [1:0] br_state;
    wire is_pooling_layer;
    assign is_pooling_layer = (cn_state == 3'd1 || cn_state == 3'd2);
    assign final_ram_data_in = is_pooling_layer ? pooled_data_out : relu_data_out;
    assign final_ram_write_en = is_pooling_layer ? pool_write_en : write_to_RAM;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            ram_write_ptr <= 16'd0;
        end else if (final_ram_write_en) begin
            ram_write_ptr <= ram_write_ptr + 1'b1;
        end
    end
    wire [15:0] safe_conv1_addr = (bram_sel == 2'b00) ? weight_addr : 16'd0;
    wire [15:0] safe_conv2_addr = (bram_sel == 2'b01) ? weight_addr : 16'd0;
    wire [15:0] safe_dense_addr = (bram_sel == 2'b11) ? weight_addr : 16'd0;
    wire [15:0] safe_dense1_addr = (bram_sel == 2'b10) ? weight_addr : 16'd0;
    controller CN (.clk(clk), .cn_state(cn_state), .prediction_valid(prediction_valid), .node_idx(br_node_idx), .bias_state(br_state), .act_mux_sel(act_mux_sel), .rst(rst), .start(start), .mac_en(mac_en), .clear_accum(clear_accum), .weight_addr(weight_addr), .act_addr(act_addr), .write_en_next_layer(write_to_RAM), .bram_sel(bram_sel), .done(done));
    RAM sensor_ram (.clk(clk), .sensor_data_in(sensor_data_in), .write_addr(sensor_addr), .read_addr(act_addr[7:0]), .data_out(data_from_ram_ip), .write_en(sensor_write_en));
    intermediate_ram layer_buffer (.clk(clk), .write_en(final_ram_write_en), .write_addr(ram_write_ptr), .read_addr(act_addr), .data_in(final_ram_data_in), .data_out(intermediate_data_out));
    
    blk_mem_gen_1 dense_weights (.clka(clk), .addra(safe_dense_addr), .douta(dw_out));
    blk_mem_gen_2 conv1d_1_weights (.clka(clk), .addra(safe_conv2_addr), .douta(conv1d_1_out));
    blk_mem_gen_0 conv1d_weights (.clka(clk), .addra(safe_conv1_addr), .douta(conv1d_out));
    dense_1_weights dw_1_weights (.clk(clk), .address(safe_dense1_addr), .weight_out(dw_1_out));
    
    MUX m (.val_A(conv1d_out), .val_B(conv1d_1_out), .val_C(dw_out), .val_D(dw_1_out), .sel(bram_sel), .data_out(mac_val_b));
    
    assign mac_val_a = (act_mux_sel == 1'b0)? data_from_ram_ip: intermediate_data_out;
    
    
    assign biased_psum = mac_psum_out + current_bias;

    MAC calc (.clk(clk), .rst(rst), .clear_accum(clear_accum), .en(mac_en), .val_A(mac_val_a), .val_B(mac_val_b), .psum_out(mac_psum_out));
    ReLU relu (.data_in(biased_psum), .data_out(relu_data_out));
    bias_ram BR (.state(br_state), .output_node_idx(br_node_idx), .current_bias(current_bias));
    MaxPooling1D m1d (.clk(clk), .rst(rst), .data_in(relu_data_out), .write_in(write_to_RAM), .data_out(pooled_data_out), .write_out(pool_write_en));
    assign final_prediction = (prediction_valid == 1'b1)? ~biased_psum[31]: 1'bx;
endmodule
