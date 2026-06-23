interface pipeline_control_id_if;
    logic flush_id;
    logic stall_id;

    modport pipeline_control (
        output flush_id,
        output stall_id
    );

    modport id_stage (
        input flush_id,
        input stall_id
    );
endinterface 