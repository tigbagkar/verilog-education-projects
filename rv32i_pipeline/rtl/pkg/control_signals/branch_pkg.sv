package branch_pkg;
    typedef enum logic [2:0] {  
        BRANCH_NONE = 3'b000,
        BRANCH_BEQ  = 3'b001,
        BRANCH_BNE  = 3'b010,
        BRANCH_BLT  = 3'b011,
        BRANCH_BGE  = 3'b100,
        BRANCH_BLTU = 3'b101,
        BRANCH_BGEU = 3'b110
    } branch_op_t;
endpackage