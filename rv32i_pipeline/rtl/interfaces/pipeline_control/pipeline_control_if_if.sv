interface pipeline_control_if_if;
    logic flush_if;
    logic stall_if;

    modport pipeline_control (
        output flush_if,
        output stall_if
    );

    modport if_stage (
        input flush_if,
        input stall_if
    );
endinterface