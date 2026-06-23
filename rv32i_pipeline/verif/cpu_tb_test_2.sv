/*
# INIT
x0 = 0 (constant)
x1–x31 = 0 (initial state)

------------------------------------------------------------
00500093  | addi x1, x0, 5      | x1=5
00308113  | addi x2, x1, 3      | x2=8
002081B3  | add  x3, x1, x2     | x3=13
00318213  | addi x4, x3, 3      | x4=16
00020293  | addi x5, x4, 0      | x5=16

0002A303  | lw   x6, 0(x5)      | x6=MEM[16]
00130313  | addi x6, x6, 1      | x6=MEM[16]+1
006303B3  | add  x7, x6, x6     | x7=2*(MEM[16]+1)

00000073  | ecall / halt        | stop execution
------------------------------------------------------------

# NOTE
This program depends on memory content at address 16.

------------------------------------------------------------

# FINAL REGISTER STATE

x0  = 0
x1  = 5
x2  = 8
x3  = 13
x4  = 16
x5  = 16

x6  = MEM[16] + 1
x7  = 2 * (MEM[16] + 1)

x8  = 0
x9  = 0
x10 = 0
x11 = 0
x12 = 0
x13 = 0
x14 = 0
x15 = 0
x16 = 0
x17 = 0
x18 = 0
x19 = 0
x20 = 0
x21 = 0
x22 = 0
x23 = 0
x24 = 0
x25 = 0
x26 = 0
x27 = 0
x28 = 0
x29 = 0
x30 = 0
x31 = 0
*/

`timescale 1ns/1ps

module cpu_tb;

logic clk;
logic rst_n;

int stall_count;

cpu dut (
    .clk   (clk),
    .rst_n (rst_n)
);

// clock
initial clk = 0;
always #5 clk = ~clk;

// =====================================
// STALL TRACKER
// =====================================
always @(posedge clk) begin
    if (dut.hzu_pipe_ctrl.stall_if_id_bubble_ex)
        stall_count++;
end

// =====================================
// RESET
// =====================================
task automatic reset();
    rst_n = 0;
    stall_count = 0;

    repeat (5) @(posedge clk);

    rst_n = 1;
endtask

// =====================================
// RUN PROGRAM
// =====================================
task automatic run_program();
    repeat (60) @(posedge clk);
endtask

// =====================================
// CHECK REGISTER
// =====================================
task automatic check_reg(
    input int reg_num,
    input logic [31:0] expected
);
    if (dut.regfile_inst.x[reg_num] !== expected) begin
        $display("[FAIL] x%0d DUT=%h EXP=%h",
                 reg_num,
                 dut.regfile_inst.x[reg_num],
                 expected);
        $fatal;
    end
endtask

// =====================================
// CHECK NO X
// =====================================
task automatic check_no_unknowns();
    int i;
    for (i = 0; i < 32; i++) begin
        if ($isunknown(dut.regfile_inst.x[i])) begin
            $display("[FAIL] x%0d contains X/Z", i);
            $fatal;
        end
    end
endtask

// =====================================
// MAIN TEST
// =====================================
initial begin

    reset();
    run_program();

    // =========================
    // BASE + FORWARDING CHAIN
    // =========================

    check_reg(0, 0);

    check_reg(1, 5);     // addi x1,0,5
    check_reg(2, 8);     // addi x2,x1,3
    check_reg(3, 13);    // add x3,x1,x2
    check_reg(4, 16);    // addi x4,x3,3
    check_reg(5, 16);    // addi x5,x4,0

    // =========================
    // MEMORY CHECK
    // =========================
    check_reg(6, 1);     // lw x6,0(x5)

    // =========================
    // LOAD-USE HAZARD
    // =========================
    check_reg(7, 2);     // addi x6,x6,1 (stall required)

    // =========================
    // STALL ASSERTION
    // =========================
    if (stall_count != 1) begin
        $display("[FAIL] expected 1 stall, got %0d", stall_count);
        $fatal;
    end

    // =========================
    // FINAL SANITY
    // =========================
    check_no_unknowns();

    $display("[PASS] HARD forwarding + hazard test passed");

    $finish;
end

endmodule