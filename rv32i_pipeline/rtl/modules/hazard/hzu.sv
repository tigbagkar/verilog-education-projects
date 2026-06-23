import load_pkg :: LOAD_NONE;

module hzu (
    id_hzu_if               .hzu id,
    ex_hzu_if               .hzu ex,
    hzu_pipeline_control_if .hzu pipe_ctrl
);
    always_comb begin
        pipe_ctrl.stall_if_id_bubble_ex = 1'b0;

        if (
            (id.uses_rs1)             &&
            (id.rs1 == ex.rd)         && 
            (ex.load_op != LOAD_NONE) && 
            (id.rs1 != '0)
            ) 
            pipe_ctrl.stall_if_id_bubble_ex = 1'b1;
        else if (
            (id.uses_rs2)             &&
            (id.rs2 == ex.rd)         && 
            (ex.load_op != LOAD_NONE) && 
            (id.rs2 != '0)
            )
            pipe_ctrl.stall_if_id_bubble_ex = 1'b1;
    end
endmodule