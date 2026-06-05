import timer_pkg::command_t;
import timer_pkg::CMD_NOP;
import timer_pkg::CMD_RESET;
import timer_pkg::CMD_RUN;
import timer_pkg::CMD_PAUSE;

`timescale 1ms/1ps

module timer_tb;
    // =========================================================
    // PARAMETERS
    // =========================================================

    localparam CLK_PERIOD = 1;
    localparam TICK_1HZ   = 1000;

    // =========================================================
    // SIGNALS
    // =========================================================

    logic       clk;
    logic       rst_n;

    command_t   cmd;

    logic [5:0] sec;
    logic [5:0] min;
    logic [4:0] hour;
    logic       overflow;

    // =========================================================
    // DUT
    // =========================================================

    timer uut (
        .clk      (clk),
        .rst_n    (rst_n),
        .cmd      (cmd),
        .sec      (sec),
        .min      (min),
        .hour     (hour),
        .overflow (overflow)
    );

    // =========================================================
    // CLOCK
    // =========================================================

    initial begin
        clk = 0;
        forever #0.5 clk = ~clk;
    end

    // =========================================================
    // VCD DUMP
    // =========================================================

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, timer_tb);
    end

    // =========================================================
    // SCOREBOARD
    // =========================================================

    int tests_passed = 0;
    int tests_failed = 0;

    logic [5:0] exp_sec;
    logic [5:0] exp_min;
    logic [4:0] exp_hour;
    logic       exp_overflow;

    // =========================================================
    // RESET
    // =========================================================

    task automatic reset_dut;
    begin
        rst_n = 0;
        cmd   = CMD_NOP;

        repeat (20) @(posedge clk);

        rst_n = 1;

        repeat (20) @(posedge clk);
    end
    endtask

    // =========================================================
    // DRIVER
    // =========================================================

    task automatic send_command(
        input command_t cmd_to_send
    );
    begin
        @(negedge clk);
        cmd = cmd_to_send;
        @(posedge clk);
        @(negedge clk);
        cmd = CMD_NOP;
        @(posedge clk);
    end
    endtask

    // =========================================================
    // MONITOR + CHECKER
    // =========================================================

    task automatic check_output;
    begin
        if (
            (exp_sec      == sec)      &&
            (exp_min      == min)      &&
            (exp_hour     == hour)     &&
            (exp_overflow == overflow)
        ) begin
            tests_passed = tests_passed + 1;
            $display("[%0t] PASS:  expected= %0d:%0d:%0d|ovf=%0d  got= %0d:%0d:%0d|ovf=%0d",
                $time,
                exp_hour, exp_min, exp_sec, exp_overflow,
                hour,     min,     sec,     overflow
            );
        end
        else begin
            tests_failed = tests_failed + 1;
            $display("[%0t] ERROR: expected= %0d:%0d:%0d|ovf=%0d  got= %0d:%0d:%0d|ovf=%0d",
                $time,
                exp_hour, exp_min, exp_sec, exp_overflow,
                hour,     min,     sec,     overflow
            );
        end
    end
    endtask

    // =========================================================
    // TESTCASES
    // =========================================================

    initial begin
        $display("=====START TESTING=====");

        $display("--- TEST 1: Reset state ---");
        reset_dut();
        @(negedge clk);

        exp_sec      = 0;
        exp_min      = 0;
        exp_hour     = 0;
        exp_overflow = 0;
        check_output();

        $display("--- TEST 2: Run 5 seconds ---");
        send_command(CMD_RUN);
        repeat((TICK_1HZ * 5) + 2) @(posedge clk);
        @(negedge clk);

        exp_sec      = 5;
        exp_min      = 0;
        exp_hour     = 0;
        exp_overflow = 0;
        check_output();

        $display("--- TEST 3: Pause, counter must freeze ---");
        send_command(CMD_PAUSE);
        repeat((TICK_1HZ * 5)) @(posedge clk);
        @(negedge clk);

        exp_sec      = 5;
        exp_min      = 0;
        exp_hour     = 0;
        exp_overflow = 0;
        check_output();

        $display("--- TEST 4: Reset ---");
        send_command(CMD_RESET);
        @(posedge clk);
        @(negedge clk);
        
        exp_sec      = 0;
        exp_min      = 0;
        exp_hour     = 0;
        exp_overflow = 0;
        check_output();

        $display("--- TEST 5: Run again after reset ---");
        send_command(CMD_RUN);
        repeat((TICK_1HZ * 3) + 2) @(posedge clk);
        @(negedge clk);

        exp_sec      = 3;
        exp_min      = 0;
        exp_hour     = 0;
        exp_overflow = 0;
        check_output();

        $display("--- TEST 6: Minute rollover ---");
        repeat((TICK_1HZ * 57)) @(posedge clk);
        @(negedge clk);
        
        exp_hour     = 0;
        exp_min      = 1;
        exp_sec      = 0;
        exp_overflow = 0;
        check_output();

        $display("--- TEST 7: Overflow ---");
        @(posedge overflow); 
        @(negedge clk);       
        exp_hour     = 0;
        exp_min      = 0;
        exp_sec      = 0;
        exp_overflow = 1;
        check_output();

        // =========================================================
        // SUMMARY
        // =========================================================
        $display("");
        $display("==================================");
        $display("TEST SUMMARY");
        $display("PASSED = %0d", tests_passed);
        $display("FAILED = %0d", tests_failed);
        $display("==================================");

        if (tests_failed == 0)
            $display("ALL TESTS PASSED");
        else
            $display("SOME TESTS FAILED");

        $finish;
    end

endmodule