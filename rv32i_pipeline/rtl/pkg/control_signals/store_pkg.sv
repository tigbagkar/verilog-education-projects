package store_pkg;
    typedef enum logic [1:0] {  
        STORE_NONE = 2'b00,
        STORE_SB   = 2'b01,
        STORE_SH   = 2'b10,
        STORE_SW   = 2'b11
    } store_op_t;
endpackage