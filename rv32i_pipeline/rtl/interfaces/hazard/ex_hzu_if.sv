interface ex_hzu_if;
    import global_types_pkg :: addr_t;
    import load_pkg         :: load_op_t;

    addr_t    rd;
    load_op_t load_op;

    modport ex_stage (
        output rd,
        output load_op
    );

    modport hzu (
        input rd,
        input load_op
    );
endinterface