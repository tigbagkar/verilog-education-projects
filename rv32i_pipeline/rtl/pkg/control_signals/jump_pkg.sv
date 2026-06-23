package jump_pkg;
    typedef enum logic[1:0] {  
        JUMP_NONE = 2'b00,
        JUMP_JAL  = 2'b01,
        JUMP_JALR = 2'b10
    } jump_op_t;
endpackage