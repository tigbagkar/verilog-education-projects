module data_mem(
    input logic clk, rst_n,
    input logic [31:0] addr,
    input logic [2:0] funct3,

    input logic MemWrite,
    input logic [31:0] wd,

    input logic MemRead,
    output logic [31:0] rd
);  
    logic [31:0] mem [1023:0];
    logic addr_1;
    assign addr_1 = addr[1];
    logic addr_0;
    assign addr_0 = addr[0];

    logic [31:0] mem_word;
    assign mem_word = mem[addr[31:2]];

    logic [15:0] mem_hi;
    logic [15:0] mem_lo;
    assign mem_hi = mem_word[31:16];
    assign mem_lo = mem_word[15:0];

    logic [7:0] mem_b3, mem_b2, mem_b1, mem_b0;
    assign mem_b3 = mem_word[31:24];
    assign mem_b2 = mem_word[23:16];
    assign mem_b1 = mem_word[15:8];
    assign mem_b0 = mem_word[7:0];

    always_comb begin
        if (MemRead) begin
            case (funct3)
                    // lw
                3'o2: begin
                    rd = mem_word;
                end

                    // lh 
                3'o1: begin
                    if (addr_1 == 1'b1)
                        rd = $signed(mem_hi);
                    else if (addr_1 == 1'b0)
                        rd = $signed(mem_lo);
                    else 
                        rd = 32'b0;
                end

                    // lb
                3'o0: begin
                    if (addr_1 == 1'b1) begin
                        if (addr_0 == 1'b1)
                            rd = $signed(mem_b3);
                        else if (addr_0 == 1'b0)
                            rd = $signed(mem_b2);
                        else 
                            rd = 32'b0;
                    end

                    else if (addr_1 == 1'b0)  begin
                        if (addr_0 == 1'b1)
                            rd = $signed(mem_b1);
                        else if (addr_0 == 1'b0)
                            rd = $signed(mem_b0);
                        else 
                            rd = 32'b0;
                    end 

                    else 
                        rd = 32'b0;

                end
                    
                    // lhu
                3'o5: begin
                    if (addr_1 == 1'b1)
                        rd = mem_hi;
                    else if (addr_1 == 1'b0)
                        rd = mem_lo;
                    else
                        rd = 32'b0;
                end

                    // lbu
                3'o4: begin
                    if (addr_1 == 1'b1) begin
                        if (addr_0 == 1'b1)
                            rd = mem_b3;
                        else if (addr_0 == 1'b0)
                            rd = mem_b2;
                        else 
                            rd = 32'b0;
                    end

                    else if (addr_1 == 1'b0) begin
                        if (addr_0 == 1'b1)
                            rd = mem_b1;
                        else if (addr_0 == 1'b0)
                            rd = mem_b0;
                        else 
                            rd = 32'b0;
                    end 

                    else
                        rd = 32'b0;
                end
            endcase
        end

        else 
            rd = 32'b0;
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < 1024; i++) 
                mem[i] <= 32'b0;
        end
        
        else if (MemWrite) begin
            case (funct3)
                    // sw
                3'o2: begin
                    mem[addr[31:2]] <= wd;
                end

                    // sh 
                3'o1: begin
                    if (addr_1 == 1'b1) 
                        mem[addr[31:2]][31:16] <= wd[15:0];
                    else 
                        mem[addr[31:2]][15:0] <= wd[15:0];
                end

                    // sb
                3'o0: begin
                    if (addr_1 == 1'b1) begin
                        if (addr_0 == 1'b1)
                            mem[addr[31:2]][31:24] <= wd[7:0];
                        else
                            mem[addr[31:2]][23:16] <= wd[7:0];
                    end

                    else begin
                        if (addr_0 == 1'b1)
                            mem[addr[31:2]][15:8] <= wd[7:0];
                        else
                            mem[addr[31:2]][7:0] <= wd[7:0];
                    end
                end  
            endcase
        end
    end
endmodule