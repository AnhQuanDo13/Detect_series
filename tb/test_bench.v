`timescale 1ns / 1ns

module test_bench();
    parameter MEALY_FSM = 1'b1; // MEALY = 1, MOORE = 0
    parameter STR_LEN = 32;
    reg clk;
    reg rst_n;
    reg series;
    wire detect;

    reg [STR_LEN-1:0] series_stream;
    integer i;
    reg detect_flag;

    detect_1011 dut (
        .clk(clk), 
        .rst_n(rst_n), 
        .series(series), 
        .detect(detect)
    );
    
    initial begin 
        clk = 0;
        series = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst_n = 1'b0;
        #15 rst_n = 1'b1;
    end

    initial begin 
        detect_flag = 0; 
        #25;    
        if (MEALY_FSM)
            $display ("================ MEALY FSM TB =================");
        else
            $display ("================ MOORE FSM TB =================");

        series_stream = $urandom_range(0,{STR_LEN{1'b1}});

        for (i = 0; i < STR_LEN; i = i + 1) begin
            series = series_stream[i];
            #10; 
        end

        #50;
        if (!detect_flag)
            $display("==== There is no series 1011 in the string ====");
            $display("===============================================");
        $finish;
    end 
    
    always @(posedge clk) begin 
        if (detect) begin
            detect_flag = 1;
            $display("========= At %0t: Detected series 1011 ========", $time);
        end
    end
endmodule

