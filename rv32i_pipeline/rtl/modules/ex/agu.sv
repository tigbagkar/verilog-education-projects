import global_types_pkg :: word_t;

module agu (
    input  word_t rd1,
    input  word_t imm,
    output word_t result
);
    assign result = rd1 + imm;
endmodule