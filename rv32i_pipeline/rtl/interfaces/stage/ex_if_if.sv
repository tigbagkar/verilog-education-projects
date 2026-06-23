interface ex_if_if;
    import ex_if_pkg :: ex_if_bus_t;
    
    ex_if_bus_t bus;

    modport if_stage (
        input bus
    );

    modport ex_stage (
        output bus
    );
endinterface 