package if_id_pkg;
    import global_types_pkg :: word_t;
    import global_types_pkg :: instr_t;

    typedef struct packed {
        word_t  pc;
        instr_t instr;
    } if_id_bus_t;
endpackage