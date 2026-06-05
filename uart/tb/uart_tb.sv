`timescale 1ns/1ps

module uart_tb;
    // =========================================================
    // PARAMETERS
    // =========================================================

    localparam BAUD_RATE = 9_600;
    localparam CLK_FREQ  = 1_000_000;       

    // =========================================================
    // SIGNALS
    // =========================================================
    
    logic       clk;
    logic       rst_n;
    logic [7:0] data;
    logic       tx_start;
    logic [7:0] rx_data;
    
    // =========================================================
    // DUT
    // =========================================================

    uart_top #(
        .BAUD_RATE (BAUD_RATE),
        .CLK_FREQ  (CLK_FREQ)
    ) uut (
        .clk       (clk),
        .rst_n     (rst_n),
        .data      (data),
        .tx_start  (tx_start),
        .rx_data   (rx_data)
    );

    // =========================================================
    // CLOCK
    // =========================================================

    initial begin
        clk = 0;
        forever #500 clk = ~clk;
    end

    // =========================================================
    // VCD DUMP
    // =========================================================

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, uart_tb);
    end

    // =========================================================
    // SCOREBOARD
    // =========================================================

    int exp_data     = 0;
    int tests_passed = 0;
    int tests_failed = 0;

    // =========================================================
    // RESET
    // =========================================================

    task automatic reset_dut;
    begin
        rst_n = 0;        

        repeat (20) @(posedge clk);

        rst_n = 1;

        repeat (20) @(posedge clk);
    end
    endtask

    // =========================================================
    // DRIVER
    // =========================================================

    task automatic send_data(
        input logic [7:0] send
    );
    begin
        @(negedge clk);
        data = send;
        tx_start = 1'b1;
        @(posedge clk);
        tx_start = 1'b0;
    end
    endtask

    // =========================================================
    // MONITOR + CHECKER
    // =========================================================

    task automatic check_output;
    begin
        if (exp_data == rx_data) begin
            tests_passed = tests_passed + 1;
            $display("[%0t] PASS:  expected= %0d  got= %0d",
                $time,
                exp_data,
                rx_data
            );
        end
        else begin
            tests_failed = tests_failed + 1;
            $display("[%0t] ERROR: expected= %0d  got= %0d",
                $time,
                exp_data,
                rx_data,
            );
        end
    end
    endtask

    // =========================================================
    // TESTCASES
    // =========================================================

    initial begin
        $display("=====START TESTING=====");

        $display("--- TEST 1: Reset ---");
        reset_dut();
        exp_data = 0;
        check_output();

        $display("--- TEST 2: Send 1 ---");
        exp_data = 1;
        send_data(exp_data);
        @(rx_data);
        check_output();

        $display("--- TEST 3: Send 100 ---");
        exp_data = 100;
        send_data(exp_data);
        @(rx_data);
        check_output();

        $display("--- TEST 4: Send 0 ---");
        exp_data = 0;
        send_data(exp_data);
        @(rx_data);
        check_output();

        $display("--- TEST 5: Random 100 tests ---");
        
        for (int i = 0; i < 100; i++) begin
            exp_data = $urandom % 250;
            send_data(exp_data);
            @(rx_data);
            check_output();
            @(rx_data);
        end

        $display("\n==================================");
        $display("TEST SUMMARY");
        $display("PASSED = %0d", tests_passed);
        $display("FAILED = %0d", tests_failed);
        $display("==================================\n");

        if (tests_failed == 0)
            $display("ALL TESTS PASSED");
        else
            $display("SOME TESTS FAILED");

        $finish;
    end

endmodule