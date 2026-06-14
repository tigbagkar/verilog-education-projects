`timescale 1ns/1ps

module tb;
    // =========================================================
    // SIGNALS
    // =========================================================
    
    logic clk, rst_n;
    logic [31:0] addr;
    logic [2:0] funct3;
    logic MemWrite;
    logic [31:0] wd;
    logic MemRead;
    logic [31:0] rd;

    // =========================================================
    // DUT
    // =========================================================

    data_mem uut (
        .clk(clk),
        .rst_n(rst_n),
        .addr(addr),
        .funct3(funct3),
        .MemWrite(MemWrite),
        .wd(wd),
        .MemRead(MemRead),
        .rd(rd)
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

        repeat(100) @(posedge clk);

        rst_n = 1'b1;

        repeat(10) @(posedge clk);
    endtask

    // =========================================================
    // DRIVER
    // =========================================================

    task automatic drive_data(
        input logic [31:0] drive_addr,
        input logic [2:0]  drive_funct3,
        input logic [31:0] drive_wd,
        input logic drive_MemWrite
    );
        @(negedge clk);
        addr = drive_addr;
        funct3 = drive_funct3;
        wd = drive_wd;
        MemWrite = drive_MemWrite;

        @(posedge clk);
        @(negedge clk);
        MemWrite = 1'b0;
    endtask

    // =========================================================
    // MONITOR + CHECKER
    // =========================================================

    task automatic check_result(
        input logic [31:0] check_addr,
        input logic [2:0]  check_funct3,
        input logic [31:0] exp_rd,
        input logic check_MemRead
    );
        logic [31:0] got;
        
        addr = check_addr;
        funct3 = check_funct3;
        MemRead = check_MemRead;
        #1;
        got = rd;

        MemRead = 1'b0;

        if (exp_rd === rd) begin
            tests_passed = tests_passed + 1;
            $display(
                "[%0t] PASS: expected = %32b : got = %32b\n",
                $time, exp_rd, got
            );
        end 

        else begin
            tests_failed = tests_failed + 1;
            $display(
                "[%0t] ERROR: expected = %32b : got = %32b\n",
                $time, exp_rd, got
            );
        end
    endtask

    // =========================================================
    // TESTCASES
    // =========================================================

    initial begin
        $display("=====START TESTING=====");

        $display("--- TEST 1: Reset + lw ---");
        reset_dut();

        for (int i = 0; i < 1024; i++) begin
            check_result(i, 3'o2, 32'b0, 1'b1);
        end

        $display("--- TEST 2: sw + lw ---");
        drive_data(32'b0, 3'o2, 32'hFFFFFFFF, 1'b1);
        check_result(32'b0, 3'o2, 32'hFFFFFFFF, 1'b1);
        
        $display("--- TEST 3: sh + lh + lhu ---");
        drive_data(32'b110, 3'o1, 32'h000000FF, 1'b1);
        drive_data(32'b100, 3'o1, 32'h0000FFFF, 1'b1);
        
        check_result(32'b110, 3'o1, 32'h000000FF, 1'b1);
        check_result(32'b100, 3'o1, 32'hFFFFFFFF, 1'b1);

        check_result(32'b110, 3'o5, 32'h000000FF, 1'b1);
        check_result(32'b100, 3'o5, 32'h0000FFFF, 1'b1);


        $display("--- TEST 4: sb + lb + lbu ---");
        drive_data(32'b1111, 3'o0, 32'h000000FF, 1'b1);
        drive_data(32'b1110, 3'o0, 32'h000000AF, 1'b1);
        drive_data(32'b1101, 3'o0, 32'h00000011, 1'b1);
        drive_data(32'b1100, 3'o0, 32'h00000001, 1'b1);

        check_result(32'b1111, 3'o0, 32'hFFFFFFFF, 1'b1);
        check_result(32'b1110, 3'o0, 32'hFFFFFFAF, 1'b1);
        check_result(32'b1101, 3'o0, 32'h00000011, 1'b1);
        check_result(32'b1100, 3'o0, 32'h00000001, 1'b1);

        check_result(32'b1111, 3'o4, 32'h000000FF, 1'b1);
        check_result(32'b1110, 3'o4, 32'h000000AF, 1'b1);
        check_result(32'b1101, 3'o4, 32'h00000011, 1'b1);
        check_result(32'b1100, 3'o4, 32'h00000001, 1'b1);

        $display("--- TEST 5: write without MemWrite---");
        drive_data(32'b10000, 3'o2, 32'hFFFFFFFF, 1'b0);
        check_result(32'b10000, 3'o2, 32'h00000000, 1'b1);

        $display("--- TEST 6: read without MemRead ---");
        drive_data(32'b100000, 3'o2, 32'hFFFFFFFF, 1'b1);
        check_result(32'b100000, 3'o2, 32'h00000000, 1'b0);
 
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