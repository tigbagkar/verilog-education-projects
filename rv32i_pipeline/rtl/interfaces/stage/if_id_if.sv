interface if_id_if;
    import if_id_pkg :: if_id_bus_t;

    if_id_bus_t bus;

    modport if_stage (
        output bus
    );

    modport id_stage (
        input bus
    );
endinterface