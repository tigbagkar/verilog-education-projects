interface id_hzu_if;
    import global_types_pkg :: addr_t;

    addr_t rs1;
    addr_t rs2;
    logic  uses_rs1;
    logic  uses_rs2;

    modport id_stage (
        output rs1,
        output rs2,
        output uses_rs1,
        output uses_rs2
    );

    modport hzu (
        input rs1,
        input rs2,
        input uses_rs1,
        input uses_rs2
    );
endinterface 