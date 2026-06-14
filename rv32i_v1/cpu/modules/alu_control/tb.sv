import alu_pkg::*;

`timescale 1ns/1ps

module tb;
    // =========================================================
    // SIGNALS
    // =========================================================
    
    logic [1:0] ALUOp;
    logic [2:0] funct3;
    logic [6:0] funct7;
    alu_op_t alu_op;

    // =========================================================
    // DUT
    // =========================================================

    alu_control uut (
        .ALUOp  (ALUOp),
        .funct3 (funct3),
        .funct7 (funct7),
        .alu_op (alu_op)
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

    logic [1:0] test_ALUOp [4:0];
    logic [2:0] test_funct3 [8:0];
    logic [6:0] test_funct7 [2:0];

    task automatic drive(
        input logic [1:0] drive_ALUOp,
        input logic [2:0] drive_funct3,
        input logic [6:0] drive_funct7        
    );
        ALUOp = drive_ALUOp;
        funct3 = drive_funct3;
        funct7 = drive_funct7;
    endtask

    // =========================================================
    // MONITOR + CHECKER
    // =========================================================

    task automatic check_result(
        input alu_op_t exp_alu_op
    );
        
        if (exp_alu_op == alu_op) begin
            tests_passed = tests_passed + 1;
            $display(
                "[%0t] PASS: expected = %4b : got = %4b",
                $time, exp_alu_op, alu_op
            );
            
            $display(
                "drived = ALUOP = %2b, funct3 = %3b, funct7 = %7b\n",
                ALUOp, funct3, funct7
            );
        end 

        else begin
            tests_failed = tests_failed + 1;
            $display(
                "[%0t] ERROR: expected = %4b : got = %4b",
                $time, exp_alu_op, alu_op
            );
            
            $display(
                "drived = ALUOP = %2b, funct3 = %3b, funct7 = %7b\n",
                ALUOp, funct3, funct7
            );
        end
    endtask

    // =========================================================
    // TESTCASES
    // =========================================================
    
    initial begin
        test_ALUOp [0] = 2'b00;
        test_ALUOp [1] = 2'b01;
        test_ALUOp [2] = 2'b10;
        test_ALUOp [3] = 2'b11;
        test_ALUOp [4] = 'x;
    
        test_funct3 [0] = 3'o0;
        test_funct3 [1] = 3'o1;
        test_funct3 [2] = 3'o2;
        test_funct3 [3] = 3'o3;
        test_funct3 [4] = 3'o4;
        test_funct3 [5] = 3'o5;
        test_funct3 [6] = 3'o6;
        test_funct3 [7] = 3'o7;
        test_funct3 [8] = 'x;

        test_funct7 [0] = 7'b0000000;
        test_funct7 [1] = 7'b0010000;
        test_funct7 [2] = 'x;

        
        $display("=====START TESTING=====");
        
        $display("--- TEST 1 ALUOP=00 ---");

        drive(test_ALUOp[0], test_funct3[8], test_funct7[2]);
        #1;
        check_result(ALU_ADD);

        $display("--- TEST 2 ALUOP=01 ---");

        drive(test_ALUOp[1], test_funct3[8], test_funct7[2]);
        #1;
        check_result(ALU_SUB);

        $display("--- TEST 3 ALUOP=10 funct3=000 funct7=0000000 ---");

        drive(test_ALUOp[2], test_funct3[0], test_funct7[0]);
        #1;
        check_result(ALU_ADD);

        $display("--- TEST 4 ALUOP=10 funct3=000 funct7=0010000 ---");

        drive(test_ALUOp[2], test_funct3[0], test_funct7[1]);
        #1;
        check_result(ALU_SUB);

        $display("--- TEST 5 ALUOP=10 funct3=000 funct7=x ---");

        drive(test_ALUOp[2], test_funct3[0], test_funct7[2]);
        #1;
        check_result(ALU_NOP);

        $display("--- TEST 6 ALUOP=10 funct3=001 ---");

        drive(test_ALUOp[2], test_funct3[1], test_funct7[2]);
        #1;
        check_result(ALU_SLL);

        $display("--- TEST 7 ALUOP=10 funct3=010 ---");

        drive(test_ALUOp[2], test_funct3[2], test_funct7[2]);
        #1;
        check_result(ALU_SLT);

        $display("--- TEST 8 ALUOP=10 funct3=011 ---");

        drive(test_ALUOp[2], test_funct3[3], test_funct7[2]);
        #1;
        check_result(ALU_SLTU);

        $display("--- TEST 9 ALUOP=10 funct3=100 ---");

        drive(test_ALUOp[2], test_funct3[4], test_funct7[2]);
        #1;
        check_result(ALU_XOR);

        $display("--- TEST 10 ALUOP=10 funct3=101 funct7=0000000 ---");

        drive(test_ALUOp[2], test_funct3[5], test_funct7[0]);
        #1;
        check_result(ALU_SRL);

        $display("--- TEST 11 ALUOP=10 funct3=101 funct7=0010000 ---");

        drive(test_ALUOp[2], test_funct3[5], test_funct7[1]);
        #1;
        check_result(ALU_SRA);

        $display("--- TEST 12 ALUOP=10 funct3=101 funct7=x ---");

        drive(test_ALUOp[2], test_funct3[5], test_funct7[2]);
        #1;
        check_result(ALU_NOP);

        $display("--- TEST 13 ALUOP=10 funct3=110 ---");

        drive(test_ALUOp[2], test_funct3[6], test_funct7[2]);
        #1;
        check_result(ALU_OR);

        $display("--- TEST 14 ALUOP=10 funct3=111 ---");

        drive(test_ALUOp[2], test_funct3[7], test_funct7[2]);
        #1;
        check_result(ALU_AND);

        $display("--- TEST 15 ALUOP=10 funct3=x ---");

        drive(test_ALUOp[2], test_funct3[8], test_funct7[2]);
        #1;
        check_result(ALU_NOP);

        $display("--- TEST 16 ALUOP=11 ---");

        drive(test_ALUOp[3], test_funct3[8], test_funct7[2]);
        #1;
        check_result(ALU_ADD);

        $display("--- TEST 17 ALUOP=x ---");

        drive(test_ALUOp[4], test_funct3[8], test_funct7[2]);
        #1;
        check_result(ALU_NOP);

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