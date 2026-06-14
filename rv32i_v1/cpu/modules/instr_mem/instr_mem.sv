module instr_mem(
    input logic [31:0] addr,
    output logic [31:0] instr
);
    logic [31:0] mem [1023:0];

    initial begin
        $readmemh("program.hex", mem);
    end

    assign instr = mem[addr[31:2]]; 
endmodule