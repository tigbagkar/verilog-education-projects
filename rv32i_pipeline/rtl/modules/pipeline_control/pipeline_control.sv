module pipeline_control (
    ex_pipeline_control_if  .pipeline_control ex_src,
    hzu_pipeline_control_if .pipeline_control hzu_src,
    pipeline_control_if_if  .pipeline_control if_control,
    pipeline_control_id_if  .pipeline_control id_control,
    pipeline_control_ex_if  .pipeline_control ex_control,
    pipeline_control_mem_if .pipeline_control mem_control,
    pipeline_control_wb_if  .pipeline_control wb_control   
);
    always_comb begin
        if_control.flush_if   = 1'b0;
        if_control.stall_if   = 1'b0;
        id_control.flush_id   = 1'b0;
        id_control.stall_id   = 1'b0;
        ex_control.stall_ex   = 1'b0;
        mem_control.stall_mem = 1'b0;
        wb_control.stall_wb   = 1'b0;

        if (hzu_src.stall_if_id_bubble_ex) begin
            if_control.stall_if   = 1'b1;
            id_control.stall_id   = 1'b1;
            id_control.flush_id   = 1'b1;
        end
        else if (ex_src.stall_all_request) begin
            if_control.stall_if   = 1'b1;
            id_control.stall_id   = 1'b1;
            ex_control.stall_ex   = 1'b1;
        end
        else if (ex_src.flush_if_id_request) begin
            if_control.flush_if   = 1'b1;
            id_control.flush_id   = 1'b1;    
        end
    end
endmodule