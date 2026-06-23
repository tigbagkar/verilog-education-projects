interface hzu_pipeline_control_if;
    logic stall_if_id_bubble_ex;

    modport hzu (
        output stall_if_id_bubble_ex
    );    

    modport pipeline_control (
        input stall_if_id_bubble_ex
    );
endinterface 