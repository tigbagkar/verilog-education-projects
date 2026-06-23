interface pipeline_control_wb_if;
    logic stall_wb;

    modport pipeline_control (
        output stall_wb
    );

    modport wb_stage (
        input stall_wb
    );
endinterface