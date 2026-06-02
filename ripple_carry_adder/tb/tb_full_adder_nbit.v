`timescale 1ns/1ps
module tb_full_adder_nbit;
    parameter N = 8;

    reg [N-1:0] a, b;
    reg cin;
    
    wire [N-1:0] sum;
    wire cout;

    reg [N:0] expected_result;

    integer i_bf;
    integer j_bf;
    integer k_bf;
    integer i_rnd;

    integer errors;

    full_adder_nbit #(.N(N)) dut (
        .a(a),  
        .b(b),
        .cin(cin),
        .sum(sum),
        .cout(cout)
    );

    initial begin
        errors = 0;
        
        for (i_bf = 0; i_bf < (1 << N); i_bf = i_bf + 1) begin 
            for (j_bf = 0; j_bf < (1 << N); j_bf = j_bf + 1) begin 
                for (k_bf = 0; k_bf < 2; k_bf = k_bf + 1) begin
                    a = i_bf;
                    b = j_bf;
                    cin = k_bf;
                    #10;
                    check_result; 
                end
            end
        end

        for (i_rnd = 0; i_rnd < 1000; i_rnd = i_rnd + 1) begin
            a = $random % ((1 << N) - 1);
            b = $random % ((1 << N) - 1);
            cin = $random % 1'b1;
            #10;
            check_result;
        end

        if (errors == 0) 
            $display("All tests passed!");
        else 
            $display("$0d errors found.", errors);
        $finish;     
    end 


    task check_result;
        begin 
            expected_result = a + b + cin;
            if ({cout, sum} !== expected_result) begin
                $display("Error: a=%h, b=%h, cin=%b => sum=%h, cout=%b, expected=%h",
                a, b, cin, sum, cout, expected_result);
                errors = errors + 1;
            end
        end
    endtask
endmodule