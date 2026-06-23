package id_regfile_pkg;
    import global_types_pkg :: addr_t;
    import global_types_pkg :: word_t;

    typedef struct packed {
        addr_t rs1;
        addr_t rs2;
    } id_regfile_bus_t;

    typedef struct packed {
        word_t rd1;
        word_t rd2;
    } regfile_id_bus_t;
endpackage