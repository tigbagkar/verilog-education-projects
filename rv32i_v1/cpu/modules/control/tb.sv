`timescale 1ns/1ps

module tb;
    // =========================================================
    // SIGNALS
    // =========================================================
    
    logic [6:0] opcode;
    logic RegWrite;
    logic MemRead;
    logic MemWrite;
    logic MemToReg;
    logic ALUSrc;
    logic ALUASrc;
    logic Branch;
    logic Jump;
    logic[1:0] ALUOp;

    // =========================================================
    // DUT
    // =========================================================

    control uut(
        .opcode(opcode),
        .RegWrite(RegWrite),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .MemToReg(MemToReg),
        .ALUSrc(ALUSrc),
        .ALUASrc(ALUASrc),
        .Branch(Branch),
        .Jump(Jump),
        .ALUOp(ALUOp)
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
    // OPCODE DRIVER
    // =========================================================

    logic [6:0] opcodes [9:0];

    task automatic drive_opcode(
        input logic [6:0]  test_opcode
    );
        opcode = test_opcode;
    endtask

    // =========================================================
    // MONITOR + CHECKER
    // =========================================================

    task automatic check_result(
        input logic exp_RegWrite,
        input logic exp_MemRead,
        input logic exp_MemWrite,
        input logic exp_MemToReg,
        input logic exp_ALUSrc,
        input logic exp_ALUASrc,
        input logic exp_Branch,
        input logic exp_Jump,
        input logic[1:0] exp_ALUOp
    );
        
        if (
            (exp_RegWrite == RegWrite) &&
            (exp_MemRead  == MemRead)  &&
            (exp_MemWrite == MemWrite) && 
            (exp_MemToReg == MemToReg) && 
            (exp_ALUSrc   == ALUSrc)   &&
            (exp_ALUASrc  == ALUASrc)  &&
            (exp_Branch   == Branch)   &&
            (exp_Jump     == Jump)     && 
            (exp_ALUOp    == ALUOp)
        ) begin
            tests_passed = tests_passed + 1;
            $display(
                "[%0t] PASS: opcode=%0h",
                $time, opcode
            );
            
            $display(
                "expected=%0b|%0b|%0b|%0b|%0b|%0b|%0b|%0b|%02b",
                exp_RegWrite, exp_MemRead, exp_MemWrite, exp_MemToReg, 
                exp_ALUSrc, exp_ALUASrc, exp_Branch, exp_Jump, exp_ALUOp
            );

            $display(
                "got     =%0b|%0b|%0b|%0b|%0b|%0b|%0b|%0b|%02b",
                RegWrite, MemRead, MemWrite, MemToReg, 
                ALUSrc, ALUASrc, Branch, Jump, ALUOp
            );
        end 
        else begin
            tests_failed = tests_failed + 1;
            $display(
                "[%0t] ERROR: opcode=%0h",
                $time, opcode
            );
            
            $display(
                "expected=%0b|%0b|%0b|%0b|%0b|%0b|%0b|%0b|%02b",
                exp_RegWrite, exp_MemRead, exp_MemWrite, exp_MemToReg, 
                exp_ALUSrc, exp_ALUASrc, exp_Branch, exp_Jump, exp_ALUOp
            );

            $display(
                "got     =%0b|%0b|%0b|%0b|%0b|%0b|%0b|%0b|%02b",
                RegWrite, MemRead, MemWrite, MemToReg, 
                ALUSrc, ALUASrc, Branch, Jump, ALUOp
            );
        end
    endtask

    // =========================================================
    // TESTCASES
    // =========================================================

    initial begin
        opcodes[0] = 7'h03; // I - Loads
        opcodes[1] = 7'h13; // I - OP-IMM
        opcodes[2] = 7'h67; // I - JALR
        opcodes[3] = 7'h23; // S - STORES
        opcodes[4] = 7'h63; // B - BRANCH
        opcodes[5] = 7'h37; // U - LUI 
        opcodes[6] = 7'h17; // U - AUIPC
        opcodes[7] = 7'h6F; // J - JAL
        opcodes[8] = 7'h33; // R - OP
        opcodes[9] = 7'h0;  // Undefined opcode

        $display("=====START TESTING=====");
        
        $display("--- TEST 1 I - Loads ---");

        drive_opcode(opcodes[0]);
        #1;
        check_result(
            1'b1, 
            1'b1,
            1'b0,
            1'b1,
            1'b1,
            1'b0,
            1'b0,
            1'b0,
            2'b00
        );

        $display("--- TEST 2 I - OP-IMM ---");
        
        drive_opcode(opcodes[1]);
        #1;
        check_result(
            1'b1, 
            1'b0,
            1'b0,
            1'b0,
            1'b1,
            1'b0,
            1'b0,
            1'b0,
            2'b10
        );

        $display("--- TEST 3 I - JALR ---");
        
        drive_opcode(opcodes[2]);
        #1;
        check_result(
            1'b1, 
            1'b0,
            1'b0,
            1'b0,
            1'b1,
            1'b0,
            1'b0,
            1'b1,
            2'b00
        );

        $display("--- TEST 4 S - STORES ---");
        
        drive_opcode(opcodes[3]);
        #1;
        check_result(
            1'b0, 
            1'b0,
            1'b1,
            1'b0,
            1'b1,
            1'b0,
            1'b0,
            1'b0,
            2'b00
        );

        $display("--- TEST 5 B - BRANCH ---");
        
        drive_opcode(opcodes[4]);
        #1;
        check_result(
            1'b0, 
            1'b0,
            1'b0,
            1'b0,
            1'b0,
            1'b0,
            1'b1,
            1'b0,
            2'b01
        );

        $display("--- TEST 6 U - LUI ---");
        
        drive_opcode(opcodes[5]);
        #1;
        check_result(
            1'b1, 
            1'b0,
            1'b0,
            1'b0,
            1'b1,
            1'b0,
            1'b0,
            1'b0,
            2'b11
        );

        $display("--- TEST 7 U - AUIPC ---");
        
        drive_opcode(opcodes[6]);
        #1;
        check_result(
            1'b1, 
            1'b0,
            1'b0,
            1'b0,
            1'b1,
            1'b1,
            1'b0,
            1'b0,
            2'b11
        );

        $display("--- TEST 8 J - JAL ---");
        
        drive_opcode(opcodes[7]);
        #1;
        check_result(
            1'b1, 
            1'b0,
            1'b0,
            1'b0,
            1'b1,
            1'b0,
            1'b0,
            1'b1,
            2'b00
        );

        $display("--- TEST 9 R - OP ---");
        
        drive_opcode(opcodes[8]);
        #1;
        check_result(
            1'b1, 
            1'b0,
            1'b0,
            1'b0,
            1'b0,
            1'b0,
            1'b0,
            1'b0,
            2'b10
        );

        $display("--- TEST 10 Undefined opcode ---");

        drive_opcode(opcodes[9]);
        #1;
        check_result(
            1'b0, 
            1'b0,
            1'b0,
            1'b0,
            1'b0,
            1'b0,
            1'b0,
            1'b0,
            2'b00
        );

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