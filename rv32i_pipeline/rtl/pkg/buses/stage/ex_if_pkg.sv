package ex_if_pkg;
    import global_types_pkg :: word_t;

    typedef struct packed {
        logic  redirect_valid;
        word_t redirect_addr;
    } ex_if_bus_t;
endpackage