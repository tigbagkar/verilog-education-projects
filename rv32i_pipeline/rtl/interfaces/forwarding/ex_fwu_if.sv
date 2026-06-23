interface ex_fwu_if;
    import global_types_pkg :: addr_t;

    addr_t rs1;
    addr_t rs2;

    modport ex_stage (
        output rs1,
        output rs2
    );

    modport fwu (
        input rs1,
        input rs2
    );
endinterface