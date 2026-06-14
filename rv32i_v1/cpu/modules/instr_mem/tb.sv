`timescale 1ns/1ps

module tb;
    // =========================================================
    // SIGNALS
    // =========================================================

    logic [31:0] addr;
    logic [31:0] instr;    

    // =========================================================
    // DUT
    // =========================================================

    instr_mem uut(
        .addr(addr),
        .instr(instr)
    );

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
    // DRIVER
    // =========================================================

    logic [31:0] test_addr [5:0];

    task automatic drive(
        input logic [31:0] drive_addr
    );
        addr = drive_addr;
    endtask

    // =========================================================
    // MONITOR + CHECKER
    // =========================================================

    task automatic check_result(
        input logic [31:0] exp_instr
    );
        
        if (exp_instr === instr) begin
            tests_passed = tests_passed + 1;
            $display(
                "[%0t] PASS: expected = %4b : got = %4b",
                $time, exp_instr, instr
            );
            
            $display(
                "drived addr = %32b\n",
                addr
            );
        end 

        else begin
            tests_failed = tests_failed + 1;
            $display(
                "[%0t] ERROR: expected = %4b : got = %4b",
                $time, exp_instr, instr
            );
            
            $display(
                "drived addr = %32b\n",
                addr
            );
        end
    endtask

    // =========================================================
    // TESTCASES
    // =========================================================
    
    initial begin
        test_addr[0] = 32'b0;
        for (int i = 1; i < 6; i++) 
            test_addr[i] = test_addr[i-1] + 4;
        
        $display("=====START TESTING=====");
        
        $display("--- TEST 1 addr with data ---");

        drive(test_addr[0]);
        #1;
        check_result(32'h00000000);

        drive(test_addr[1]);
        #1;
        check_result(32'h00000011);

        drive(test_addr[2]);
        #1;
        check_result(32'h00011000);

        drive(test_addr[3]);
        #1;
        check_result(32'h000FF000);

        drive(test_addr[4]);
        #1;
        check_result(32'hFF000000);

        drive(test_addr[5]);
        #1;
        check_result(32'hFFFFFFFF);

        $display("--- TEST 2 addr without data ---");

        drive(32'h000000FF);
        #1;
        check_result(32'hxxxxxxxx);

        $display("--- TEST 3 addr out of bounds ---");

        drive(32'hFFFFFFFF);
        #1;
        check_result(32'hxxxxxxxx);

        $display("--- TEST 4 addr=x ---");

        drive(32'hxxxxxxxx);
        #1;
        check_result(32'hxxxxxxxx);

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