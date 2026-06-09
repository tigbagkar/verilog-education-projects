// tb.sv
`timescale 1ns/1ps
import cmd_pkg::*;

module tb;
    localparam CLK_FREQ   = 50_000_000;
    localparam SPI_FREQ   = 1_000_000;
    localparam CLK_PERIOD = 1_000_000_000 / CLK_FREQ;
    localparam WAIT       = CLK_FREQ / SPI_FREQ * 8 * 6;

    logic        clk, rst_n, start;
    cmd_t        cmd;
    logic [4:0]  addr;
    logic [7:0]  data;
    logic [7:0]  answer;

    // можно поменять чтобы разные режимы протестировать, что в них тоже все корректно работает
    localparam logic CPOL = 1'b0;
    localparam logic CPHA = 1'b0;

    top #(
        .CLK_FREQ(CLK_FREQ),
        .SPI_FREQ(SPI_FREQ),
        .CPOL(CPOL),
        .CPHA(CPHA)
    ) dut (
        .clk(clk), .rst_n(rst_n),
        .start(start), .cmd(cmd),
        .addr(addr), .data(data),
        .answer(answer)
    );

    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    task wait_cycles(input int n);
        repeat(n) @(posedge clk);
    endtask

    task send(input cmd_t t_cmd, input logic [4:0] t_addr, input logic [7:0] t_data);
        @(posedge clk);
        cmd   <= t_cmd;
        addr  <= t_addr;
        data  <= t_data;
        start <= 1'b1;
        @(posedge clk);
        start <= 1'b0;
        wait_cycles(WAIT);
    endtask

    task check(input logic [7:0] expected, input string test_name);
        if (answer === expected)
            $display("PASS: %s — answer=0x%0h", test_name, answer);
        else
            $display("FAIL: %s — got=0x%0h expected=0x%0h", test_name, answer, expected);
    endtask

    task run_tests(input string mode);
        $display("\n=== MODE: %s ===", mode);

        // WRITE + READ
        send(WRITE, 5'h05, 8'hAB);
        send(READ,  5'h05, 8'h00);
        check(8'hAB, {mode, " READ after WRITE"});

        // WRITE другой адрес
        send(WRITE, 5'h1F, 8'h37);
        send(READ,  5'h1F, 8'h00);
        check(8'h37, {mode, " READ addr 0x1F"});

        // DELETE + READ
        send(DELETE, 5'h05, 8'h00);
        send(READ,   5'h05, 8'h00);
        check(8'h00, {mode, " READ after DELETE"});

        wait_cycles(20);
    endtask

    initial begin
        rst_n = 0; start = 0;
        cmd = WRITE; addr = '0; data = '0;
        wait_cycles(5);
        rst_n = 1;
        wait_cycles(5);

        run_tests($sformatf("CPOL=%0b CPHA=%0b", CPOL, CPHA));

        $display("\n=== ALL TESTS DONE ===");
        $finish;
    end

    initial begin
        $dumpfile("tb.vcd");
        $dumpvars(0, tb);
        for (int i = 0; i < 32; i++)
            $dumpvars(0, dut.u_slave.registers[i]);
    end
endmodule