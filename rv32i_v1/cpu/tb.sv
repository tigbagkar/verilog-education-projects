`timescale 1ns/1ps

module tb;
    // =========================================================
    // SIGNALS
    // =========================================================
    
    logic clk; 
    logic rst_n;
    
    // =========================================================
    // DUT
    // =========================================================

    cpu uut (
        .clk(clk),
        .rst_n(rst_n)
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
    // MONITOR + CHECKER
    // =========================================================

    logic [31:0] got;

    task automatic check(
        input logic [4:0] rd,
        input logic [31:0] exp
    );
        got = tb.uut.regfile_inst.x[rd];

        if (exp == got) begin
            tests_passed = tests_passed + 1;
            $display("[%0t] PASS: exp = %0d, got = %0d",
                $time, got, exp    
            );
        end 
        else begin
            tests_failed = tests_failed + 1;
            $display("[%0t] ERROR: exp = %0d, got = %0d",
                $time, got, exp    
            );
        end 
    endtask

    // =========================================================
    // TESTCASES
    // =========================================================

    initial begin
        $display("=====START TESTING=====");

        $display("--- TEST 1: ---");
        reset_dut();
        repeat(3) @(posedge clk);
        check(5'b00011, 32'd8);

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