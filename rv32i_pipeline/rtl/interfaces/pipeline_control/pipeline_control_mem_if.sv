interface pipeline_control_mem_if;
    logic stall_mem;

    modport pipeline_control (
        output stall_mem
    );

    modport mem_stage (
        input stall_mem
    );
endinterface