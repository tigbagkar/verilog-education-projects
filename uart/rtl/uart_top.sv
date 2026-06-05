module uart_top #(
    parameter BAUD_RATE,
    parameter CLK_FREQ
)(
    input  logic       clk,
    input  logic       rst_n,
    input  logic [7:0] data,
    input  logic       tx_start,

    output logic [7:0] rx_data
); 
    logic tx_line;

    uart_tx #(
        .BAUD_RATE (BAUD_RATE),
        .CLK_FREQ  (CLK_FREQ)
    ) tx_inst (
        .clk      (clk),
        .rst_n    (rst_n),
        .data     (data),
        .tx_start (tx_start),
        .tx       (tx_line)
    );

    uart_rx #(
        .BAUD_RATE (BAUD_RATE),
        .CLK_FREQ  (CLK_FREQ)
    ) rx_inst (
        .clk   (clk),
        .rst_n (rst_n),
        .rx    (tx_line),
        .data  (rx_data)
    );
endmodule