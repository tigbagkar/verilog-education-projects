interface mem_wb_if;
    import mem_wb_pkg :: mem_wb_bus_t;

    mem_wb_bus_t bus;

    modport mem_stage (
        output bus
    );

    modport wb_stage (
        input bus
    );
endinterface