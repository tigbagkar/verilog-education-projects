package alu_pkg;
    typedef enum logic [3:0] {  
        ALU_ADD,  // 0000
        ALU_SUB,  // 0001
        ALU_AND,  // 0010
        ALU_OR,   // 0011
        ALU_XOR,  // 0100
        ALU_SLL,  // 0101
        ALU_SRL,  // 0110
        ALU_SRA,  // 0111
        ALU_SLT,  // 1000
        ALU_SLTU, // 1001
        ALU_NOP   // 1011
    } alu_op_t;
endpackage