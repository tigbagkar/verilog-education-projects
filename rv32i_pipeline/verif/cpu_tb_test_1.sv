/*
# INIT
x0 = 0 (constant)

------------------------------------------------------------
00100093  | addi x1, x0, 1      | x1=1
00200113  | addi x2, x0, 2      | x2=2
002081B3  | add  x3, x1, x2     | x3=3
00318233  | add  x4, x3, x3     | x4=6
004202B3  | add  x5, x4, x4     | x5=12
00528333  | add  x6, x5, x5     | x6=24

00100013  | addi x0, x0, 1      | x0=0 (unchanged)

00600393  | addi x7, x0, 6      | x7=6
00730433  | add  x8, x6, x7     | x8=30
008404B3  | add  x9, x8, x8     | x9=60
00948533  | add  x10,x9, x9     | x10=120
00A505B3  | add  x11,x10,x10    | x11=240

07B00013  | addi x0, x0, 123    | x0=0 (ignored)

00000613  | addi x12,x0, 0      | x12=0
03700693  | addi x13,x0, 55     | x13=55
00168713  | addi x14,x13,1      | x14=56

006307B3  | add  x15,x6, x6     | x15=48
00F78833  | add  x16,x15,x15    | x16=96
010808B3  | add  x17,x16,x16    | x17=192

00000013  | nop                 | -
00000013  | nop                 | -
00000013  | nop                 | -
00000013  | nop                 | -

------------------------------------------------------------

# FINAL REGISTER STATE

x0  = 0
x1  = 1
x2  = 2
x3  = 3
x4  = 6
x5  = 12
x6  = 24
x7  = 6
x8  = 30
x9  = 60
x10 = 120
x11 = 240
x12 = 0
x13 = 55
x14 = 56
x15 = 48
x16 = 96
x17 = 192
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

cpu dut (
    .clk   (clk),
    .rst_n (rst_n)
);

initial clk = 0;
always #5 clk = ~clk;

task automatic reset();
    rst_n = 0;
    repeat (5) @(posedge clk);
    rst_n = 1;
endtask

task automatic run_program();
    repeat (100) @(posedge clk);
endtask

task automatic check_reg(
    input int reg_num,
    input logic [31:0] expected
);
    if (dut.regfile_inst.x[reg_num] !== expected) begin
        $display(
            "[FAIL] x%0d DUT=%h EXP=%h",
            reg_num,
            dut.regfile_inst.x[reg_num],
            expected
        );
        $fatal;
    end
endtask

task automatic check_no_unknowns();
    int i;

    for (i = 0; i < 32; i++) begin
        if ($isunknown(dut.regfile_inst.x[i])) begin
            $display("[FAIL] x%0d contains X/Z", i);
            $fatal;
        end
    end
endtask

initial begin

    reset();

    run_program();

    check_reg(0 , 32'd0);

    check_reg(1 , 32'd1);
    check_reg(2 , 32'd2);

    check_reg(3 , 32'd3);
    check_reg(4 , 32'd6);
    check_reg(5 , 32'd12);
    check_reg(6 , 32'd24);

    check_reg(7 , 32'd6);
    check_reg(8 , 32'd30);
    check_reg(9 , 32'd60);
    check_reg(10, 32'd120);
    check_reg(11, 32'd240);

    check_reg(12, 32'd0);

    check_reg(13, 32'd55);
    check_reg(14, 32'd56);

    check_reg(15, 32'd48);
    check_reg(16, 32'd96);
    check_reg(17, 32'd192);

    check_no_unknowns();

    $display("[PASS] CPU directed pipeline test passed");

    $finish;
end

endmodule