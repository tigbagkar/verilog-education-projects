package alu_pkg;
    typedef enum logic [3:0] {
        ALU_NONE = 4'b0000,  
        ALU_ADD  = 4'b0001,
        ALU_SUB  = 4'b0010,
        ALU_AND  = 4'b0011,
        ALU_OR   = 4'b0100,
        ALU_XOR  = 4'b0101,
        ALU_SLL  = 4'b0110,
        ALU_SRL  = 4'b0111,
        ALU_SRA  = 4'b1000,
        ALU_SLT  = 4'b1001,
        ALU_SLTU = 4'b1010 
    } alu_op_t;
endpackage