package u_type_pkg;
    typedef enum logic [1:0] {  
        U_TYPE_NONE  = 2'b00,
        U_TYPE_LUI   = 2'b01,
        U_TYPE_AUIPC = 2'b10
    } u_type_op_t;
endpackage