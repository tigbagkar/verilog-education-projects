import cmd_pkg::*;
import master_pkg::*;

module master #(
    parameter integer CLK_FREQ,
    parameter integer SPI_FREQ,
    parameter logic CPOL = 1'b0, 
    parameter logic CPHA = 1'b0,
    parameter integer DATA_WIDTH = 8,
    parameter logic MOSI_DEFAULT = 1'b0,
    parameter integer AMOUNT_OF_SLAVES = 1
)(
    input logic clk, rst_n,

    input logic[$clog2(AMOUNT_OF_SLAVES)-1:0] slave_num,

    input logic start,

    input cmd_t cmd,
    input logic [4:0] addr,
    input logic [DATA_WIDTH-1:0] data,

    input logic MISO, 
    output logic MOSI,
    output logic SCLK,
    output logic [AMOUNT_OF_SLAVES-1:0] CS,

    output logic [DATA_WIDTH-1:0] answer
);

    ///////////////////////////////////////////////////
    // FSM - регистрация следующего состояния
    ///////////////////////////////////////////////////
    master_state_t master_curr_state, master_next_state;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            master_curr_state <= MASTER_IDLE;
        else 
            master_curr_state <= master_next_state;
    end

    ///////////////////////////////////////////////////
    // FSM - условия перехода между состояниями
    ///////////////////////////////////////////////////
    always_comb begin
        master_next_state = master_curr_state;
        
        case (master_curr_state)
            MASTER_IDLE: begin
                if (start) 
                    master_next_state = MASTER_START;
            end   
 
            MASTER_START: begin
                master_next_state = MASTER_SEND_CMD_ADDR;       
            end

            MASTER_SEND_CMD_ADDR: begin
                if (bit_cnt == DATA_WIDTH-1 && (!CPHA ? SCLK_second_front : SCLK_first_front)) begin
                    case (cmd_latch)
                        READ:
                            if (CPHA) 
                                master_next_state = MASTER_DUMMY;
                            else 
                                master_next_state = MASTER_DUMMY;
                        WRITE:
                            master_next_state = MASTER_SEND_DATA;
                        DELETE:
                            master_next_state = MASTER_STOP;
                    endcase
                end
            end

            MASTER_DUMMY: begin
                if (CPHA ? SCLK_second_front : SCLK_first_front)
                    master_next_state = MASTER_RECEIVE_DATA;
            end

            MASTER_RECEIVE_DATA: begin
                if (bit_cnt == DATA_WIDTH-1 && (CPHA ? SCLK_second_front : SCLK_first_front)) begin
                    master_next_state = MASTER_STOP;
                end
            end

            MASTER_SEND_DATA: begin
                if (bit_cnt == DATA_WIDTH-1 && (!CPHA ? SCLK_second_front : SCLK_first_front)) begin
                    master_next_state = MASTER_STOP;
                end
            end

            MASTER_STOP: begin
                if (!CPHA ? SCLK_second_front : SCLK_first_front)
                    master_next_state = MASTER_IDLE;
            end
        endcase
    end

    ///////////////////////////////////////////////////
    // Работа в зависимости от состояния
    ///////////////////////////////////////////////////
    logic pre_push;

    logic [DATA_WIDTH-1:0] shift;
    localparam BIT_CNT_SIZE = $clog2(DATA_WIDTH);
    logic [BIT_CNT_SIZE:0] bit_cnt;
 
    cmd_t cmd_latch;
    logic [4:0] addr_latch;
    logic [DATA_WIDTH-1:0] data_latch;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            CS          <= '1;
            MOSI        <= MOSI_DEFAULT;
            pre_push    <= ~CPHA;
            answer      <= '0;
            cmd_latch   <= '0;
            addr_latch  <= '0;
            data_latch  <= '0;
            shift       <= '0;
            bit_cnt     <= '0;
        end

        else begin
            case (master_curr_state)
                MASTER_IDLE: begin
                    CS         <= '1;
                    MOSI       <= MOSI_DEFAULT;
                    pre_push    <= ~CPHA;          
                    cmd_latch  <= '0;
                    addr_latch <= '0;
                    data_latch <= '0;
                    shift      <= '0;
                    bit_cnt    <= '0;
                end

                MASTER_START: begin
                    cmd_latch     <= cmd;
                    addr_latch    <= addr;
                    data_latch    <= data;
                    CS[slave_num] <= 1'b0;
                    shift         <= {cmd, addr};
                end

                MASTER_SEND_CMD_ADDR: begin
                    if (!CPHA ? (SCLK_second_front || pre_push) : SCLK_first_front) begin
                        MOSI <= shift[DATA_WIDTH-1];
                        shift <= shift << 1;
                        bit_cnt <= bit_cnt + 1;
                        
                        if (pre_push)
                            pre_push <= 1'b0;

                        if (bit_cnt == DATA_WIDTH-1) begin
                            bit_cnt <= '0;
                            if (cmd_latch == WRITE)
                                shift <= data_latch;
                        end
                    end
                end

                MASTER_SEND_DATA: begin
                    if (!CPHA ? SCLK_second_front : SCLK_first_front) begin
                        MOSI    <= shift[DATA_WIDTH-1];
                        shift   <= shift << 1;
                        bit_cnt <= bit_cnt + 1;
                    end
                end

                MASTER_DUMMY: begin
                    if (CPHA ? SCLK_second_front : SCLK_first_front) 
                        MOSI <= MOSI_DEFAULT;
                end

                MASTER_RECEIVE_DATA: begin
                    if (CPHA ? SCLK_second_front : SCLK_first_front) begin
                        shift   <= {shift[DATA_WIDTH-2:0], MISO};
                        bit_cnt <= bit_cnt + 1;
                        
                        if (bit_cnt == DATA_WIDTH-1) 
                            answer <= {shift[DATA_WIDTH-2:0], MISO};
                    end
                end

                MASTER_STOP: begin
                        CS <= '1; 
                end
            endcase
        end
    end

    ///////////////////////////////////////////////////
    // Генерация SCLK
    ///////////////////////////////////////////////////
    localparam DIVIDER = CLK_FREQ / SPI_FREQ / 2;
    localparam SCLK_CNT_SIZE = $clog2(DIVIDER);
    logic [SCLK_CNT_SIZE-1:0] SCLK_cnt;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            SCLK     <= CPOL;
            SCLK_cnt <= '0;
        end

        else if (master_curr_state == MASTER_IDLE) begin
            SCLK     <= CPOL;
            SCLK_cnt <= '0;
        end
  
        else begin
            if (SCLK_cnt == DIVIDER - 1) begin
                SCLK     <= ~SCLK;                
                SCLK_cnt <= '0;
            end
            else
                SCLK_cnt <= SCLK_cnt + 1;
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