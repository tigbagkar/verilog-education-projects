`timescale 1ns/1ps

import alu_pkg::*;

module tb;
    // =========================================================
    // SIGNALS
    // =========================================================

    logic [31:0] a;
    logic [31:0] b;
    alu_op_t     alu_op;
    logic [31:0] result;
    logic        zero;

    // =========================================================
    // DUT
    // =========================================================

    alu uut(
        .a(a),
        .b(b),
        .alu_op(alu_op),
        .result(result),
        .zero(zero)
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
    
    logic [31:0] expected_result;
    logic expected_zero;
    int tests_passed = 0;
    int tests_failed = 0;

    // =========================================================
    // DRIVER
    // =========================================================

    task automatic run_tests();        
        for (int i = 0; i < 10; i++) begin
            alu_op = alu_op_t'(i);;
            #1;
            check_result();
        end
    endtask

    // =========================================================
    // MONITOR + CHECKER
    // =========================================================

    task automatic check_result();
        case (alu_op)
            ALU_ADD:
                expected_result = a + b;
            ALU_SUB: 
                expected_result = a - b;
            ALU_AND: 
                expected_result = a & b;
            ALU_OR:
                expected_result = a | b;             
            ALU_XOR:
                expected_result = a ^ b;
            ALU_SLL:
                expected_result = a << b[4:0];
            ALU_SRL:
                expected_result = a >> b[4:0];
            ALU_SRA: 
                expected_result = $signed(a) >>> b[4:0];
            ALU_SLT:
                expected_result = $signed(a) < $signed(b) ? 32'd1 : 32'd0;
            ALU_SLTU:
                expected_result = a < b ? 32'd1 : 32'd0;
            default:
                expected_result = 32'd0;
        endcase
        expected_zero = (expected_result == 0);

        if (expected_result == result && expected_zero == zero) begin
            tests_passed = tests_passed + 1;
        end
        else begin
            tests_failed = tests_failed + 1;
            $display("[%0t] ERROR: a=%0d, b=%0d, op=%0b\nexpected r=%0d z=%d\ngot r=%d z=%d",
                $time,
                a, b, alu_op,
                expected_result, expected_zero,
                result, zero
            );
        end
    endtask

    initial begin
        $display("=====START TESTING=====");
        $display("--- TEST 1: Random a and b, all operations ---");
        for (int i = 0; i < 1000; i++) begin
            a = $random;
            b = $random;
            run_tests();
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