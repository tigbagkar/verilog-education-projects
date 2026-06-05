import timer_pkg::MAX_SEC_MIN;
import timer_pkg::MAX_HOUR;

module counter (
    input  logic       clk,      
    input  logic       rst_n,     

    input  logic       tick_1hz,   
    
    input  logic       enable,
    input  logic       clear,
    
    output logic [5:0] sec,
    output logic [5:0] min,
    output logic [4:0] hour,
    output logic       overflow
);  
    logic inc_sec,  inc_min,  inc_hour;
    logic wrap_sec, wrap_min, wrap_hour;
    
    assign inc_sec   = enable && tick_1hz;
    assign wrap_sec  = (sec == MAX_SEC_MIN) && inc_sec;
    assign inc_min   = wrap_sec;
    assign wrap_min  = (min == MAX_SEC_MIN) && inc_min;

    assign inc_hour  = wrap_min;
    assign wrap_hour = (hour == MAX_HOUR) && inc_hour;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sec      <= '0;
            min      <= '0;
            hour     <= '0;
            overflow <= 1'b0;
        end

        else if (clear) begin
                sec      <= '0;
                min      <= '0;
                hour     <= '0;
                overflow <= 1'b0;
        end

        else begin
            overflow <= 1'b0;

            if (inc_sec) 
                sec <= wrap_sec  ? '0 : sec + 1;

            if (inc_min) 
                min <= wrap_min  ? '0 : min + 1;

            if (inc_hour) begin
                hour     <= wrap_hour ? '0 : hour + 1;
                overflow <= wrap_hour;
            end   
        end
    end
endmodule