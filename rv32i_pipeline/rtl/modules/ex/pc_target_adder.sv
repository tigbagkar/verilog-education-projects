import global_types_pkg :: word_t;

module pc_target_adder (
    input  word_t pc,
    input  word_t imm,
    output word_t result 
);
    assign result = pc + imm;
endmodule