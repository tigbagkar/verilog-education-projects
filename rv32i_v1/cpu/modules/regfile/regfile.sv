module regfile(
    input logic clk, rst_n,
    
    input logic we,
    input logic [4:0] rd,
    input logic [31:0] wd,
    
    input logic [4:0] rs1, rs2,
    output logic [31:0] rd1, rd2
);
    logic [31:0] x [31:0];

    assign rd1 = x[rs1];
    assign rd2 = x[rs2];

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < 32; i++) 
                x [i] <= '0;
        end

        else begin
            if (we) begin
                if (rd != 0)
                    x[rd] <= wd;
            end    
        end        
    end
endmodule