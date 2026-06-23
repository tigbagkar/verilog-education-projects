package load_pkg;
    typedef enum logic[2:0] {  
        LOAD_NONE = 3'b000,
        LOAD_LB   = 3'b001,
        LOAD_LH   = 3'b010,
        LOAD_LW   = 3'b011,
        LOAD_LBU  = 3'b100,
        LOAD_LHU  = 3'b101
    } load_op_t;
endpackage