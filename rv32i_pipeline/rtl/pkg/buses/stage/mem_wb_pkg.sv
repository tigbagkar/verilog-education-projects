package mem_wb_pkg;
    import global_types_pkg :: word_t;
    import global_types_pkg :: addr_t;

    typedef struct packed {
        logic  reg_write;
        addr_t rd;
        word_t wd;
    } mem_wb_bus_t;
endpackage