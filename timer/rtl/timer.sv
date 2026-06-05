import timer_pkg::command_t;
import timer_pkg::CMD_NOP;
import timer_pkg::CMD_RESET;
import timer_pkg::CMD_RUN;
import timer_pkg::CMD_PAUSE;

import timer_pkg::state_t;
import timer_pkg::ST_IDLE;
import timer_pkg::ST_RUN;
import timer_pkg::ST_PAUSE; 

module timer(
    input  logic       clk,
    input  logic       rst_n,

    input  command_t   cmd,

    output logic [5:0] sec,
    output logic [5:0] min,
    output logic [4:0] hour,
    output logic       overflow
);

    state_t state, next_state;
    logic enable, clear;
    logic tick_1hz;
    
    
    frequency_divider fd_inst(
        .clk      (clk),
        .rst_n    (rst_n),
        .enable   (enable),
        .clear    (clear), 
        .tick_1hz (tick_1hz)
    );
    counter c_inst(
        .clk      (clk),
        .rst_n    (rst_n),
        .tick_1hz (tick_1hz),
        .enable   (enable),
        .clear    (clear),
        .sec      (sec),
        .min      (min),
        .hour     (hour),
        .overflow (overflow) 
    );
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= ST_IDLE;
        end
        else 
            state <= next_state;
    end

    always_comb begin 
        next_state = state;

        case (state)
            ST_IDLE: begin
                if (cmd == CMD_RUN)
                    next_state = ST_RUN;
            end
            
            ST_RUN: begin
                case (cmd)
                    CMD_PAUSE: next_state = ST_PAUSE;
                    CMD_RESET: next_state = ST_IDLE;
                endcase
            end
            ST_PAUSE: begin
                case (cmd)
                    CMD_RUN:   next_state = ST_RUN;
                    CMD_RESET: next_state = ST_IDLE;
                endcase
            end            
        endcase
    end

    always_comb begin
        clear  = (state != ST_IDLE) && (cmd == CMD_RESET);
        enable = (state == ST_RUN);
    end
endmodule