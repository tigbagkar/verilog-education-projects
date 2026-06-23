interface ex_mem_if;
    import ex_mem_pkg :: ex_mem_bus_t;

    ex_mem_bus_t bus;

    modport ex_stage (
        output bus
    );

    modport mem_stage (
        input bus
    );
endinterface