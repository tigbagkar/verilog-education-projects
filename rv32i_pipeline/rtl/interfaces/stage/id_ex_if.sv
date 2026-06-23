interface id_ex_if;
    import id_ex_pkg :: id_ex_bus_t;
    
    id_ex_bus_t bus;

    modport id_stage (
        output bus
    );

    modport ex_stage (
        input bus
    );
endinterface 