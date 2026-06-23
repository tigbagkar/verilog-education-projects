interface mem_fwu_if;
    import global_types_pkg :: word_t;
    import global_types_pkg :: addr_t;

    logic  reg_write;
    addr_t rd;
    word_t wd;

    modport mem_stage (
        output reg_write,
        output rd,
        output wd
    );

    modport fwu (
        input reg_write,
        input rd,
        input wd
    );
endinterface