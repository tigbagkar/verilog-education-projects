package wb_regfile_pkg;
    import global_types_pkg :: word_t;
    import global_types_pkg :: addr_t;

    typedef struct packed {
        logic  we;
        addr_t rd;
        word_t wd;
    } wb_regfile_bus_t;
endpackage