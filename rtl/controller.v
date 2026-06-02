module controller(
	input wire clk, rst, start,
	output reg mac_en, clear_accum, done,
	output reg [15:0] weight_addr, act_addr,
	output reg write_en_next_layer,
	output reg [1:0] bram_sel,
	output reg act_mux_sel,
    	output reg [1:0] bias_state,
	output wire [7:0] node_idx,
	output reg [2:0] cn_state,
    	output reg prediction_valid
);

	reg [2:0] state, next_state;
	reg [15:0] dense_count, next_dense_count;
	reg [3:0] dense1_count, next_dense1_count;
	reg [15:0] dense_act_addr, next_dense_act_addr;
	reg [15:0] dense_act_count, next_dense_act_count, dense1_act_count, next_dense1_act_count;
	reg [7:0] dense_node_index, next_dense_node_index;
    	reg [7:0] dense1_node_index, next_dense1_node_index;
	reg [7:0] filter_idx_c1, next_filter_idx_c1, kernel_step_c1, next_kernel_step_c1, window_c1, next_window_c1;
    	reg [7:0] filter_idx_c, next_filter_idx_c, kernel_step_c, next_kernel_step_c, window_c, next_window_c;
	
	parameter S_IDLE = 'd0, S_CONV1 = 'd1, S_CONV_2 = 'd2, S_DENSE = 'd3, S_DENSE1 = 'd4, OUTPUT = 'd5, WAIT = 'd6;
	
	always @(posedge clk) begin
		if(rst) begin
			state <= S_IDLE;

			dense_count <= 16'b0;
			dense1_count <= 16'b0;
			dense_act_addr <= 16'b0;
			dense_act_count <= 16'b0;
			dense_node_index <= 8'b0;
			filter_idx_c1 <= 8'b0;
            		filter_idx_c <= 8'b0;
			kernel_step_c1 <= 8'b0;
            		kernel_step_c <= 8'b0;
			window_c1 <= 8'b0;
            		window_c <= 8'b0;
			dense1_act_count <= 16'b0;
			dense1_node_index <= 8'b0;
		end
		else begin
			state <= next_state;

		        dense_count <= next_dense_count;
		        dense1_count <= next_dense1_count;
		        dense_act_addr <= next_dense_act_addr;
		        dense_act_count <= next_dense_act_count;
		        dense1_act_count <= next_dense1_act_count;
		        dense_node_index <= next_dense_node_index;
		        filter_idx_c1 <= next_filter_idx_c1;
		        kernel_step_c1 <= next_kernel_step_c1;
		        window_c1 <= next_window_c1;
		        dense1_node_index <= next_dense1_node_index;
		        kernel_step_c <= next_kernel_step_c;
		        window_c <= next_window_c;
		        filter_idx_c <= next_filter_idx_c;
		end
	end
	
	always @(*) begin 
	   next_state = state;
	   mac_en = 1'b0;
	   clear_accum = 1'b0;
	   weight_addr = 16'b0;
	   dense_act_addr = 16'b0;

	   next_dense_count = dense_count;
	   next_dense1_count = dense1_count;
	   next_dense_act_addr = dense_act_addr;
	   next_dense_act_count = dense_act_count;
	   next_dense1_act_count = dense1_act_count;
	   next_dense_node_index = dense_node_index;
           next_dense1_node_index = dense1_node_index;
           next_window_c1 = window_c1;
           next_kernel_step_c1 = kernel_step_c1;
           next_kernel_step_c = kernel_step_c;
           next_window_c = window_c;
	   write_en_next_layer = 1'b0;
	   next_filter_idx_c = filter_idx_c;
	   next_filter_idx_c1 = filter_idx_c1;
	   done = 1'b0;
	   cn_state = 3'b0;
	   
	   
	   case(state)
	       S_IDLE: begin
	           mac_en = 0;
	           cn_state = S_IDLE;
	           if(start) next_state = S_CONV1;
	           else next_state = S_IDLE;
	       end
	       
	       S_CONV1: begin
               mac_en = 1'b1;
	           bram_sel = 2'b00;
	           weight_addr = (filter_idx_c * 5) + kernel_step_c;
	           act_mux_sel = 1'b0;
                   act_addr = window_c + kernel_step_c;
                   bias_state = 2'b00;
                   cn_state = S_CONV1;

                if(kernel_step_c == 'd4) begin
                    write_en_next_layer = 1'b1;
                    clear_accum = 1'b1;
                    next_kernel_step_c = 0;

                    if(window_c == 'd251) begin
                        
                        next_filter_idx_c = filter_idx_c + 1'b1;
                        next_window_c = 0;

                        if(filter_idx_c == 'd7) begin
                            next_state = S_CONV_2;
                            next_filter_idx_c = 0;
                        end
                        else begin
                            next_state = S_CONV1;
                        end
                    end

                    else begin
                        next_window_c = window_c + 1'b1;
                        next_state = S_CONV1;
                        next_filter_idx_c = filter_idx_c;
                    end

               end

               else begin
                    write_en_next_layer = 1'b0;
                    clear_accum = 1'b0;
                    next_kernel_step_c = kernel_step_c + 1'b1;
                    next_filter_idx_c = filter_idx_c;
                    next_state = S_CONV1;
               end
	       
	           
	       end
	       
	       S_CONV_2: begin 
	           
	           mac_en = 1'b1;
	           bram_sel = 2'b01;
	           act_mux_sel = 1'b1;
                   weight_addr = (filter_idx_c1 * 24) + kernel_step_c1;
                   act_addr = window_c1 + kernel_step_c1;
                   bias_state = 2'b01;
                   cn_state = S_CONV_2;

		       if(kernel_step_c1 == 'd23) begin
		            write_en_next_layer = 1'b1;
		            clear_accum = 1'b1;
		            next_kernel_step_c1 = 0;

		            if(window_c1 == 'd123) begin
		                
		                next_filter_idx_c1 = filter_idx_c1 + 1'b1;
		                next_window_c1 = 0;

		                if(filter_idx_c1 == 'd15) begin
		                    next_state = S_DENSE;
		                    next_filter_idx_c1 = 0;
		                end
		                else begin
		                    next_state = S_CONV_2;
		                end
		            end

		            else begin
		                next_window_c1 = window_c1 + 1'b1;
		                next_filter_idx_c1 = filter_idx_c1;
		            end

		       end

		       else begin
		            write_en_next_layer = 1'b0;
		            clear_accum = 1'b0;
		            next_state = S_CONV_2;
		            next_kernel_step_c1 = kernel_step_c1 + 1'b1;
		            next_window_c1 = window_c1;
		            next_filter_idx_c1 = filter_idx_c1;
		       end
	       end
	       
	       S_DENSE: begin
	           mac_en = 1'b1;
                   bram_sel = 2'b11;
                   weight_addr = dense_count;
                   act_addr = 16'd1008 + dense_act_count;
                   act_mux_sel = 1'b1;
                   next_dense_count = dense_count + 1'b1;
                   bias_state = 2'b11;
                   cn_state = S_DENSE;
               
		       if(dense_act_count == 'd991) begin
		        next_dense_act_count = 0;
		        clear_accum = 1'b1;
		        next_dense_node_index = dense_node_index + 1'b1;
		        write_en_next_layer = 1'b1;
		       
		               if(dense_count == 'd15871) begin
		                   
		                   next_state = S_DENSE1;
		                   next_dense_node_index = 0;
		                   next_dense_count = 0;
		               end
		               
		               else begin

		                   next_state = S_DENSE;
		                  
		               end
			   end
	           
		   else begin
		       next_dense_act_count = dense_act_count + 1'b1;
		       next_dense_node_index = dense_node_index; 
		       clear_accum = 1'b0;  
		       write_en_next_layer = 1'b0;
		       next_state = S_DENSE;
		   end
	           
	       end

	       S_DENSE1: begin
	       mac_en = 1'b1;
               bram_sel = 2'b10;
               next_dense1_count = dense1_count + 1'b1;
               weight_addr = dense1_count;
               act_addr = dense1_act_count;
               act_mux_sel = 1'b1;
           
               bias_state = 2'b00;
               cn_state = S_DENSE1;
	           if(dense1_act_count == 'd15) begin
	               next_dense1_act_count = 0;
	               clear_accum = 1'b1;
	               next_dense1_node_index = dense1_node_index + 1'b1;
	               write_en_next_layer = 1'b1;
                   if(dense1_count == 'd15) begin
                       next_dense1_node_index = 0;
                       next_state = OUTPUT;
                       next_dense1_count = 0;
                   end
                   
                   else begin
                       
                       next_state = S_DENSE1;
                   end
                   
               end else begin
                next_dense1_act_count = dense1_act_count + 1'b1;
                next_dense1_node_index = dense1_node_index;
                clear_accum = 0;
                write_en_next_layer = 1'b0;
                next_state = S_DENSE1;
               end
	           
	           
	       end
	       
	       OUTPUT: begin
	           mac_en = 1'b0;
	           write_en_next_layer = 1'b0;
	           prediction_valid = 1'b1;
	           done = 1'b1; next_state = OUTPUT;
	       end
	       
	   endcase
	   
	end

    assign node_idx = 
        (state == S_CONV1)  ? filter_idx_c :
        (state == S_CONV_2) ? next_filter_idx_c1 :
        (state == S_DENSE)  ? dense_node_index : 
        (state == S_DENSE1) ? 6'd0 : 6'd0;

endmodule
