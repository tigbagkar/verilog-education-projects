package id_ex_pkg;
    import control_pkg      :: ctrl_bus_t;
    import global_types_pkg :: word_t;
    import global_types_pkg :: addr_t;

    typedef struct packed {
        word_t     pc;
        ctrl_bus_t ctrl_bus;
        word_t     rd1;
        word_t     rd2;
        addr_t     rd;
        word_t     imm;
        addr_t     rs1;
        addr_t     rs2;
    } id_ex_bus_t;
endpackage