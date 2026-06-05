import uart_pkg::state_t;
import uart_pkg::ST_IDLE;        
import uart_pkg::ST_START;
import uart_pkg::ST_DATA;
import uart_pkg::ST_STOP;

module uart_rx #(
    parameter BAUD_RATE,
    parameter CLK_FREQ
)(
    input  logic clk,
    input  logic rst_n,
    input  logic rx,

    output logic [7:0] data
);
    state_t state, next_state;
    logic baud_tick;
    logic half_tick;

    logic [7:0] shift_reg;
    logic [2:0] bit_cnt;

    freq_div #(
        .BAUD_RATE (BAUD_RATE),
        .CLK_FREQ  (CLK_FREQ)
    ) fd (
        .clk       (clk),
        .rst_n     (rst_n),
        .half_tick  (half_tick),
        .baud_tick (baud_tick)
    );

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            state <= ST_IDLE;
        else 
            state <= next_state;
    end

    always_comb begin
        next_state = state;

        case (state)
            ST_IDLE: begin
                if (!rx) begin
                    next_state = ST_START;
                end
            end

            ST_START: begin
                if (baud_tick) 
                    next_state = ST_DATA;
            end

            ST_DATA: begin
                if (bit_cnt == 7 && baud_tick)
                    next_state = ST_STOP;
            end

            ST_STOP: begin
                if (baud_tick)
                    next_state = ST_IDLE;
            end
        endcase
    end


    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            shift_reg <= '0;
            bit_cnt   <= '0;
            data      <= '0;
        end
        else if (baud_tick) begin
            case (state)
                ST_IDLE: begin
                    data <= '0;
                end

                ST_START: begin
                    shift_reg <= '0;
                    bit_cnt   <= '0;
                end

                ST_DATA: begin
                    shift_reg[bit_cnt] <= rx;
                    bit_cnt <= bit_cnt + 1;
                end

                ST_STOP: begin
                    data <= shift_reg;
                end
            endcase
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            half_tick <= 1'b0;
        
        else if (state == ST_IDLE && !rx) 
            half_tick <= 1'b1;

        else if (state == ST_START && baud_tick)
            half_tick <= 1'b0;

        else if (state == ST_STOP && baud_tick)
            half_tick <= 1'b1;
    end
endmodule