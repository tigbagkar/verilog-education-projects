import cmd_pkg::*;
import slave_pkg::*;

module slave #(
    parameter logic CPOL = 1'b0, 
    parameter logic CPHA = 1'b0,
    parameter logic MISO_DEFAULT = 1'b0,
    parameter integer DATA_WIDTH = 8
)( 
    input logic clk, rst_n,

    input  logic MOSI,
    input  logic SCLK,
    input  logic CS,
    output logic MISO
);
    ///////////////////////////////////////////////////
    // FSM - регистрация следующего состояния
    ///////////////////////////////////////////////////
    slave_state_t slave_curr_state, slave_next_state;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            slave_curr_state <= SLAVE_IDLE;
        else 
            slave_curr_state <= slave_next_state;
    end

    ///////////////////////////////////////////////////
    // FSM - условия перехода между состояниями
    ///////////////////////////////////////////////////
    always_comb begin
        slave_next_state = slave_curr_state;
        
        case (slave_curr_state)
            SLAVE_IDLE: begin
                if (!CS) 
                    slave_next_state = SLAVE_RECEIVE_CMD_ADDR;
            end   
 
            SLAVE_RECEIVE_CMD_ADDR: begin
                if (bit_cnt == DATA_WIDTH-1 && (CPHA ? SCLK_second_front : SCLK_first_front)) begin
                    case (shift[5:4])
                        READ: 
                            slave_next_state = SLAVE_SEND_DATA;
                        WRITE:
                            slave_next_state = SLAVE_RECEIVE_DATA;
                        DELETE:
                            slave_next_state = SLAVE_STOP;
                    endcase
                end
            end

            SLAVE_RECEIVE_DATA: begin
                if (bit_cnt == DATA_WIDTH-1 && (CPHA ? SCLK_second_front : SCLK_first_front)) 
                    slave_next_state = SLAVE_STOP;
            end

            SLAVE_SEND_DATA: begin
                if (bit_cnt == DATA_WIDTH-1 && (!CPHA ? SCLK_second_front : SCLK_first_front))
                    slave_next_state = SLAVE_STOP;
            end

            SLAVE_STOP: begin
                if (CS)
                    slave_next_state = SLAVE_IDLE;
            end
        endcase
    end

    ///////////////////////////////////////////////////
    // Работа в зависимости от состояния
    ///////////////////////////////////////////////////
    logic pre_push;
    logic [DATA_WIDTH-1:0] registers [31:0];

    logic [DATA_WIDTH-1:0] shift;
    localparam BIT_CNT_SIZE = $clog2(DATA_WIDTH);
    logic [BIT_CNT_SIZE:0] bit_cnt;

    cmd_t cmd;
    logic [4:0] addr;
    logic [DATA_WIDTH-1:0] data;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            MISO     <= MISO_DEFAULT;
            pre_push <= ~CPHA;
            shift    <= '0;
            bit_cnt  <= '0;
            cmd      <= '0;
            addr     <= '0;
            data     <= '0;
            for (int i = 0; i < 32; i++) 
                registers[i] <= '0;
        end

        else begin
            case (slave_curr_state)
                SLAVE_IDLE: begin
                    MISO     <= MISO_DEFAULT;
                    pre_push <= ~CPHA;
                    shift    <= '0;
                    bit_cnt  <= '0;
                    cmd      <= '0;
                    addr     <= '0;
                    data     <= '0;
                end

                SLAVE_RECEIVE_CMD_ADDR: begin
                    if (CPHA ? SCLK_second_front : SCLK_first_front) begin
                        shift   <= {shift[DATA_WIDTH-2:0], MOSI};
                        bit_cnt <= bit_cnt + 1;
                        
                        if (bit_cnt == DATA_WIDTH-1) begin
                            bit_cnt <= '0;
                            shift <= '0;
                            addr <= {shift[3:0], MOSI};
                            cmd  <= shift[5:4];
                            if (shift[5:4] == READ) 
                                shift <= registers[{shift[3:0], MOSI}];
                        end
                    end
                end

                SLAVE_RECEIVE_DATA: begin
                    if (CPHA ? SCLK_second_front : SCLK_first_front) begin
                        shift   <= {shift[DATA_WIDTH-2:0], MOSI};
                        bit_cnt <= bit_cnt + 1;
                        
                        if (bit_cnt == DATA_WIDTH-1) begin
                            data <= {shift[DATA_WIDTH-2:0], MOSI};
                        end
                    end
                end

                SLAVE_SEND_DATA: begin
                    if (!CPHA ? SCLK_second_front : SCLK_first_front) begin
                        MISO    <= shift[DATA_WIDTH-1];
                        shift   <= shift << 1;
                        bit_cnt <= bit_cnt + 1;

                        if (pre_push)
                            pre_push <= 1'b0;
                    end
                end

                SLAVE_STOP: begin
                    if (cmd == WRITE) 
                        registers[addr] <= data;
                    else if (cmd == DELETE)
                        registers[addr] <= '0;
                end
            endcase
        end
    end

    ///////////////////////////////////////////////////
    // Вычисление момента первого и второго фронта
    ///////////////////////////////////////////////////
    logic SCLK_prev;
    logic  SCLK_first_front;
    assign SCLK_first_front = (SCLK_prev == CPOL) && (SCLK !== CPOL);    
    logic  SCLK_second_front;
    assign SCLK_second_front = (SCLK_prev !== CPOL) && (SCLK == CPOL);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            SCLK_prev <= SCLK;
        else 
            SCLK_prev <= SCLK;
    end
endmodule