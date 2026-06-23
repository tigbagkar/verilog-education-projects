interface wb_regfile_if;
    import wb_regfile_pkg :: wb_regfile_bus_t;

    wb_regfile_bus_t bus;

    modport wb_stage (
        output bus
    );

    modport regfile (
        input bus
    );
endinterface