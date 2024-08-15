module detect_1011 #(parameter MEALY_FSM = 1'b1)(clk, rst_n, series, detect);
    input wire clk;
    input wire rst_n;
    input wire series;
    output reg detect;

    parameter IDLE = 5'b00001;
    parameter S1   = 5'b00010;
    parameter S2   = 5'b00100;
    parameter S3   = 5'b01000;
    parameter S4   = 5'b10000;
                
    reg [4:0] current_state, next_state;
	reg delay_series;

// Delay series 1 cycle to check for S3 of MEALY
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            delay_series <= 1'b0;
        end else begin
            delay_series <= series;
        end
    end

// Current state logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end

// Next state logic
    always @(series or current_state) begin
        detect = 1'b0;
// MOORE FSM
        if (!MEALY_FSM) begin
            case (current_state)
                IDLE: begin
                    	if (series) next_state = S1;
                    	else        next_state = IDLE;
                end

                S1: begin
		                if (!series) next_state = S2;
		                else         next_state = S1;
                end   
     
                S2: begin
		                if (series) next_state = S3;
		                else        next_state = IDLE;
                end

                S3: begin
		                if (series) next_state = S4;
		                else        next_state = S2;
                end

                S4: begin
                    	detect = 1'b1;
		                if (series) next_state = S1;
						else 		next_state = S2;
                end
                default: next_state = IDLE;
            endcase
        end else begin // MEALY FSM
            case (current_state)
                IDLE: begin
                    detect = 1'b0;
					next_state = series ? S1 : IDLE;        
        		end
                S1: begin
                    detect = 1'b0;
                    next_state = series ? S1 : S2;
                end
                S2: begin
                    detect = 1'b0;
                    next_state = series ? S3 : IDLE;
                end
                S3: begin
                    next_state = series ? S1 : S2;
					if (!delay_series)
						detect = 1'b0;
					else detect = 1'b1;
                end
                default: begin
                    next_state = IDLE;
                    detect = 1'b0;
                end
            endcase
        end
    end


endmodule

