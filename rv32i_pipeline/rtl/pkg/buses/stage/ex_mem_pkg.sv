package ex_mem_pkg;
    import global_types_pkg :: word_t;
    import global_types_pkg :: addr_t;
    import load_pkg         :: load_op_t;
    import store_pkg        :: store_op_t;

    typedef struct packed {
        logic      reg_write;
        addr_t     rd;
        word_t     wd;
        word_t     rd2;
        load_op_t  load_op;
        store_op_t store_op;
    } ex_mem_bus_t;
endpackage