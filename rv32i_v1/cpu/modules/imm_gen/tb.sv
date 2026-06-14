`timescale 1ns/1ps

module tb;
    // =========================================================
    // SIGNALS
    // =========================================================
    
    logic [31:0] instr;
    logic [31:0] imm;

    // =========================================================
    // DUT
    // =========================================================

    imm_gen uut (
        .instr(instr),
        .imm(imm)
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
    
    int exp_imm;
    int tests_passed = 0;
    int tests_failed = 0;

    // =========================================================
    // INSTRUCTION BUILDER / DRIVER
    // =========================================================
    
    logic [31:0] test_instr;
    logic [6:0] opcodes [8:0];
    logic [24:0] payload;

    task automatic build_and_drive_instr(
        input logic [6:0]  opcode,
        input logic [24:0] payload
    );
        test_instr = {payload , opcode};
        instr = test_instr;
    endtask

    // =========================================================
    // MONITOR + CHECKER
    // =========================================================

    task automatic check_result(
        input logic [31:0] test_instr
    );
        // reference model
        case (test_instr[6:0])
            // I
            7'h03, 7'h13, 7'h67:
                exp_imm = {{20{test_instr[31]}} , test_instr[31:20]};
            // S
            7'h23:
                exp_imm = {{20{test_instr[31]}} , test_instr[31:25] , test_instr[11:7]};
            // B
            7'h63:
                exp_imm = {{19{test_instr[31]}} , test_instr[31] , test_instr[7] , test_instr[30:25] , test_instr[11:8] , 1'b0};
            // U
            7'h37, 7'h17:
                exp_imm = {test_instr[31:12] , 12'b0};
            // J
            7'h6F:
                exp_imm = {{11{test_instr[31]}} , test_instr[31] , test_instr[19:12] , test_instr[20] , test_instr[30:21] , 1'b0};
            default:
                exp_imm = 32'b0;
        endcase

        if (exp_imm == imm) begin
            tests_passed = tests_passed + 1;
        end 
        else begin
            tests_failed = tests_failed + 1;
            $display("[%0t] ERROR: expected=%0b : got=%0b",
                $time, exp_imm, imm
            );
        end
    endtask

    // =========================================================
    // TESTCASES
    // =========================================================

    initial begin
        opcodes[0] = 7'h03;
        opcodes[1] = 7'h13;
        opcodes[2] = 7'h67;
        opcodes[3] = 7'h23;
        opcodes[4] = 7'h63;
        opcodes[5] = 7'h37;
        opcodes[6] = 7'h17;
        opcodes[7] = 7'h6F;
        opcodes[8] = 7'b0;

        $display("=====START TESTING=====");

        $display("--- TEST 1: payload = all 0 ---");
        payload = '0;

        for (int i = 0; i <= 8; i++) begin
            build_and_drive_instr(opcodes[i], payload);
            #1;
            check_result(test_instr);  
        end
        
        $display("--- TEST 2: payload = all 1 ---");
        payload = '1;

        for (int i = 0; i <= 8; i++) begin
            build_and_drive_instr(opcodes[i], payload);
            #1;
            check_result(test_instr);  
        end
        
        $display("--- TEST 3: random payload ---");
        repeat(1000) begin
            payload = $random;

            for (int i = 0; i <= 8; i++) begin
                build_and_drive_instr(opcodes[i], payload);
                #1;
                check_result(test_instr);  
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