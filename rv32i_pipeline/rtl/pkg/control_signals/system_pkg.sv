package system_pkg;
    typedef enum logic [1:0] {  
        SYSTEM_NONE   = 2'b00,
        SYSTEM_ECALL  = 2'b01,
        SYSTEM_EBREAK = 2'b10
    } system_op_t;
endpackage