import global_types_pkg :: word_t;

module instr_mem (
    input  word_t pc,
    output word_t instr
);
    word_t mem [1023:0];

    initial begin
        $readmemh("program_test_3.hex", mem);
    end
        
    assign instr = mem[pc[31:2]];
endmodule