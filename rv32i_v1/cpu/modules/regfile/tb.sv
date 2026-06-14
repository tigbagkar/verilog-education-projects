`timescale 1ns/1ps

module tb;
    // =========================================================
    // SIGNALS
    // =========================================================
    
    logic clk; 
    logic rst_n;
    logic we;
    logic [4:0] rd;
    logic [31:0] wd;
    logic [4:0] rs1; 
    logic [4:0] rs2;
    logic [31:0] rd1;
    logic [31:0] rd2;
    
    // =========================================================
    // DUT
    // =========================================================

    regfile uut(
        .clk(clk),
        .rst_n(rst_n),
        .we(we),
        .rd(rd),
        .wd(wd),
        .rs1(rs1),
        .rs2(rs2),
        .rd1(rd1),
        .rd2(rd2)
    );

    // =========================================================
    // CLOCK
    // =========================================================

    initial begin
        clk = 1'b0;
        forever #0.5 clk = ~clk;
    end

    // =========================================================
    // VCD DUMP
    // =========================================================

    initial begin
        $dumpfile("tb.vcd");
        $dumpvars(0, tb);
    end

    // =========================================================
    // SCOREBOARD
    // =========================================================
    
    int exp_prev;
    int exp;
    int tests_passed = 0;
    int tests_failed = 0;

    // =========================================================
    // RESET
    // =========================================================

    task automatic reset_dut();
        rst_n = 1'b0;

        repeat(10) @(posedge clk);

        rst_n = 1'b1;

        repeat(10) @(posedge clk);
    endtask

    // =========================================================
    // DRIVER
    // =========================================================

    task automatic send_data(
        input logic [4:0]  addr,
        input logic [31:0] data
    );
        @(negedge clk);
        wd = data;
        rd = addr;
        we = 1'b1;
        @(posedge clk);
        @(negedge clk);
        we = 1'b0;
    endtask

    // =========================================================
    // MONITOR + CHECKER
    // =========================================================

    task automatic check_outputs(
        input logic [4:0] addr
    );
        logic [4:0] prev_addr;
        prev_addr = addr - 1;

        rs1 = prev_addr;
        rs2 = addr;

        if (exp_prev == rd1 && exp == rd2) begin
            tests_passed = tests_passed + 1;
        end 
        else begin
            tests_failed = tests_failed + 1;
            $display("[%0t] ERROR: exp_prev=%0d, exp=%0d : rd1=%0d, rd2=%0d",
                $time,
                exp_prev, exp, rd1, rd2    
            );
        end 
    endtask

    // =========================================================
    // TESTCASES
    // =========================================================

    initial begin
        $display("=====START TESTING=====");

        $display("--- TEST 1: Reset ---");
        reset_dut();
        exp_prev = 0;
        exp = 0;
        for (int i = 1; i < 32; i = i + 2) begin
            check_outputs(i);
        end

        $display("--- TEST 2: write to x0 ---");
        exp_prev = 1;
        send_data(0, exp_prev);
        exp_prev = 0;
        check_outputs(1);

        $display("--- TEST 3: write with we = 0 ---");
        @(negedge clk);
        wd = 1;
        rd = 1;
        we = 1'b0;
        @(posedge clk);
        exp = 0;
        check_outputs(1);

        $display("--- TEST 4: write random data ---");
        repeat(10) begin
            exp_prev = 1'b0;
            for (int i = 1; i < 32; i++) begin
                exp = $random;
                send_data(i, exp);
                check_outputs(i);
                exp_prev = exp;
            end    
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