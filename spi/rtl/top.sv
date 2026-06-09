import cmd_pkg::*;

module top #(
    parameter integer CLK_FREQ   = 50_000_000,
    parameter integer SPI_FREQ   = 1_000_000,
    parameter logic   CPOL       = 1'b0,
    parameter logic   CPHA       = 1'b0,
    parameter integer DATA_WIDTH = 8
)(
    input  logic clk, rst_n,
    input  logic start,
    input  cmd_t cmd,
    input  logic [4:0]            addr,
    input  logic [DATA_WIDTH-1:0] data,
    output logic [DATA_WIDTH-1:0] answer
);
    logic MOSI, MISO, SCLK;
    logic [0:0] CS;

    master #(
        .CLK_FREQ(CLK_FREQ),
        .SPI_FREQ(SPI_FREQ),
        .CPOL(CPOL),
        .CPHA(CPHA),
        .DATA_WIDTH(DATA_WIDTH),
        .AMOUNT_OF_SLAVES(1)
    ) u_master (
        .clk(clk), .rst_n(rst_n),
        .slave_num(1'b0),
        .start(start),
        .cmd(cmd), .addr(addr), .data(data),
        .MISO(MISO), .MOSI(MOSI), .SCLK(SCLK), .CS(CS),
        .answer(answer)
    );

    slave #(
        .CPOL(CPOL),
        .CPHA(CPHA),
        .DATA_WIDTH(DATA_WIDTH)
    ) u_slave (
        .clk(clk), .rst_n(rst_n),
        .MOSI(MOSI), .SCLK(SCLK), .CS(CS[0]),
        .MISO(MISO)
    );
endmodule