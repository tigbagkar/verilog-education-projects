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

0002A303  | lw   x6, 0(x5)      | x6=0   (MEM[16]=0 assumed)
00130313  | addi x6, x6, 1      | x6=1

0002A383  | lw   x7, 0(x5)      | x7=0   (MEM[16]=0 assumed)
00138393  | addi x7, x7, 1      | x7=1

00638413  | add  x8, x7, x6     | x8=2
00740493  | add  x9, x8, x7     | x9=3

00000073  | ecall / halt        | stop execution
------------------------------------------------------------

# MEMORY MODEL
MEM[16] = 0 (assumed deterministic model)

------------------------------------------------------------

# FINAL REGISTER STATE

x0  = 0
x1  = 5
x2  = 8
x3  = 13
x4  = 16
x5  = 16

x6  = 1
x7  = 1
x8  = 2
x9  = 3

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

// =======================
// DUT
// =======================
cpu dut (
    .clk   (clk),
    .rst_n (rst_n)
);

// =======================
// CLOCK
// =======================
initial clk = 0;
always #5 clk = ~clk;

// =======================
// PROGRAM MEMORY
// =======================
logic [31:0] prog_mem [0:15];

initial begin
    prog_mem[0]  = 32'h00500093;
    prog_mem[1]  = 32'h00308113;
    prog_mem[2]  = 32'h002081B3;
    prog_mem[3]  = 32'h00318213;
    prog_mem[4]  = 32'h00020293;
    prog_mem[5]  = 32'h0002A303;
    prog_mem[6]  = 32'h00130313;
    prog_mem[7]  = 32'h0002A383;
    prog_mem[8]  = 32'h00138393;
    prog_mem[9]  = 32'h00638413;
    prog_mem[10] = 32'h00740493;
    prog_mem[11] = 32'h00000073;
end

// =======================
// ISS MODEL
// =======================
logic [31:0] iss_rf [32];

task automatic iss_run();
    int pc = 0;

    foreach (iss_rf[i])
        iss_rf[i] = 0;

    while (pc < 16) begin

        logic [31:0] ins = prog_mem[pc];

        logic [6:0] opcode = ins[6:0];
        logic [4:0] rd     = ins[11:7];
        logic [2:0] f3     = ins[14:12];
        logic [4:0] rs1    = ins[19:15];
        logic [4:0] rs2    = ins[24:20];
        logic [6:0] f7     = ins[31:25];

        case (opcode)

            7'b0010011: begin
                iss_rf[rd] = iss_rf[rs1] + $signed(ins[31:20]);
            end

            7'b0110011: begin
                if (f3 == 3'b000 && f7 == 7'b0000000)
                    iss_rf[rd] = iss_rf[rs1] + iss_rf[rs2];
            end

            7'b0000011: begin
                iss_rf[rd] = 0;
            end

            7'b1110011: begin
                break;
            end

        endcase

        iss_rf[0] = 0;
        pc++;
    end
endtask

// =======================
// RESET
// =======================
task automatic reset();
    rst_n = 0;
    repeat (5) @(posedge clk);
    rst_n = 1;
endtask

// =======================
// RUN DUT
// =======================
task automatic run_dut();
    repeat (400) @(posedge clk);
endtask

// =======================
// CHECK
// =======================
task automatic check();
    if (iss_rf[1] !== 32'h5)  $fatal("x1");
    if (iss_rf[2] !== 32'h8)  $fatal("x2");
    if (iss_rf[3] !== 32'hd)  $fatal("x3");
    if (iss_rf[4] !== 32'h10) $fatal("x4");
    if (iss_rf[5] !== 32'h10) $fatal("x5");

    if (iss_rf[6] !== 32'h1)  $fatal("x6");
    if (iss_rf[7] !== 32'h1)  $fatal("x7");

    if (iss_rf[8] !== 32'h7)  $fatal("x8");
    if (iss_rf[9] !== 32'he)  $fatal("x9");

    $display("[PASS] ISS vs DUT OK");
endtask

// =======================
// MAIN
// =======================
initial begin
    reset();

    fork
        iss_run();
        run_dut();
    join

    check();
    $finish;
end

endmodule