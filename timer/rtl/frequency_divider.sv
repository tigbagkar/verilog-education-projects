import timer_pkg::MAX_COUNT;

module frequency_divider(
    input  logic clk,
    input  logic rst_n,

    input  logic enable,
    input  logic clear,

    output logic tick_1hz
);
    logic[9:0] counter;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter  <= '0;
            tick_1hz <= 1'b0;
        end
        else if (clear) begin
            counter  <= '0;
            tick_1hz <= 1'b0;
        end
        else begin
            tick_1hz <= 1'b0;
            
            if (enable) begin
                if (counter == MAX_COUNT) begin
                    counter  <= '0;
                    tick_1hz <= 1'b1;
                end
                else 
                    counter <= counter + 1;    
            end
        end
    end
endmodule