import global_types_pkg :: word_t;

module pc_adder (
    input  word_t pc,
    output word_t result
);
    assign result = pc + 4;
endmodule