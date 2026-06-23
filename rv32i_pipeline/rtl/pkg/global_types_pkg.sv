package global_types_pkg;
    typedef logic [31:0] word_t;
    typedef logic [6:0]  opcode_t;
    typedef logic [4:0]  addr_t;
    typedef logic [2:0]  funct3_t;
    typedef logic [6:0]  funct7_t;
    
    typedef union packed {
        word_t raw;
        
        struct packed {
            funct7_t funct7;
            addr_t   rs2;
            addr_t   rs1;
            funct3_t funct3;
            addr_t   rd;
            opcode_t opcode;
        } fields;
    } instr_t;
endpackage