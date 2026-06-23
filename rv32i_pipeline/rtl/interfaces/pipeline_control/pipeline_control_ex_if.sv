interface pipeline_control_ex_if;
    logic stall_ex;
    
    modport pipeline_control (
        output stall_ex
    );

    modport ex_stage (
        input stall_ex
    );
endinterface 