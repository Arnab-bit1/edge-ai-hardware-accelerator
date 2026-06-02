module tb_top();

    reg clk;
    reg rst;
    reg start;

    wire final_prediction;
    wire prediction_valid;
    

    main uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .final_prediction(final_prediction),
        .prediction_valid(prediction_valid),
        
        .done(done)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

    initial begin
        rst = 1;
        start = 0;
        
        #100; 
        start = 1;

        
        $readmemh("patient_data.txt", uut.sensor_ram.main_mem);
        
        $display("System Reset Complete. Patient Data Loaded.");

        @(posedge clk);
        rst = 0;
        
        
        $monitor("Time: %d, %b %d",$time, uut.CN.state, uut.biased_psum);
        $display("AI Accelerator Started. Calculating...");
        
        
        
        wait (prediction_valid == 1'b1);
        
        
        @(posedge clk);
        

        $display(" Valid Flag = %b", prediction_valid);
        $display(" Final Diagnosis       = %b", final_prediction);
        
        #5000;
        $finish;
    end

endmodule
