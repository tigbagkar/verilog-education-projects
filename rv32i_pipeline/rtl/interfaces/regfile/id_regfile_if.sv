interface id_regfile_if;
    import id_regfile_pkg :: id_regfile_bus_t;
    import id_regfile_pkg :: regfile_id_bus_t;

    id_regfile_bus_t iori;
    regfile_id_bus_t iiro;

    modport id_stage (
        input  iiro,
        output iori
    );

    modport regfile (
        input  iori,
        output iiro
    );
endinterface 