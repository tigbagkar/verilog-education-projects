module freq_div #(
    parameter BAUD_RATE,
    parameter CLK_FREQ
)(
    input  logic clk,
    input  logic rst_n,
    input  logic half_tick = 1'b0,

    output logic baud_tick
);
    localparam DIVIDER = CLK_FREQ / BAUD_RATE;
    localparam SIZE    = $clog2(DIVIDER);
    
    logic [SIZE - 1: 0] count;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            baud_tick <= 1'b0;
            count <= '0;
        end
        else begin
            baud_tick <= 1'b0;
            
            if (half_tick) begin
                if (count == DIVIDER / 2) begin
                    baud_tick <= 1'b1;
                    count <= '0;
                end
                else 
                    count <= count + 1;
            end
            else begin
                if (count == DIVIDER - 1) begin
                    baud_tick <= 1'b1;
                    count <= '0;
                end
                else 
                    count <= count + 1;
            end
        end
    end  
endmodule