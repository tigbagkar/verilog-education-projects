module cpu (
    input logic clk, rst_n
);
    // stage if
    if_id_if  if_id();
    id_ex_if  id_ex();
    ex_mem_if ex_mem();
    ex_if_if  ex_if();
    mem_wb_if mem_wb();

    // regfile if
    id_regfile_if id_regfile();
    wb_regfile_if wb_regfile();

    // pipeline_control if
    pipeline_control_if_if  pipe_ctrl_if();
    pipeline_control_id_if  pipe_ctrl_id();
    pipeline_control_ex_if  pipe_ctrl_ex();
    ex_pipeline_control_if  ex_pipe_ctrl();
    pipeline_control_mem_if pipe_ctrl_mem();
    pipeline_control_wb_if  pipe_ctrl_wb();
    hzu_pipeline_control_if hzu_pipe_ctrl();

    // forwarding
    ex_fwu_if  ex_fwu();
    fwu_ex_if  fwu_ex();
    mem_fwu_if mem_fwu();
    wb_fwu_if  wb_fwu();

    // hazard
    ex_hzu_if ex_hzu();
    id_hzu_if id_hzu();

    // stage inst
    if_stage if_stage_inst (
        .clk               (clk), 
        .rst_n             (rst_n),
        .pipe_ctrl         (pipe_ctrl_if),
        .if_id_out         (if_id),
        .ex_if_in          (ex_if)
    );
    id_stage id_stage_inst (
        .clk               (clk), 
        .rst_n             (rst_n),
        .pipe_ctrl         (pipe_ctrl_id),
        .hzu               (id_hzu),
        .if_id_in          (if_id),
        .regfile           (id_regfile),
        .id_ex_out         (id_ex)
    );    
    ex_stage ex_stage_inst (
        .clk               (clk), 
        .rst_n             (rst_n),
        .pipe_ctrl         (pipe_ctrl_ex),
        .pipe_ctrl_request (ex_pipe_ctrl),
        .id_ex_in          (id_ex),
        .ex_mem_out        (ex_mem),
        .ex_if_out         (ex_if),
        .fwu_out           (ex_fwu),
        .fwu_in            (fwu_ex),
        .hzu               (ex_hzu)
    );
    mem_stage mem_stage_inst (
        .clk               (clk), 
        .rst_n             (rst_n),
        .pipe_ctrl         (pipe_ctrl_mem),
        .ex_mem_in         (ex_mem),
        .mem_wb_out        (mem_wb),
        .fwu_out           (mem_fwu)    
    );
    wb_stage wb_stage_inst (
        .clk               (clk), 
        .rst_n             (rst_n),
        .pipe_ctrl         (pipe_ctrl_wb),
        .mem_wb_in         (mem_wb),
        .regfile           (wb_regfile),
        .fwu_out           (wb_fwu)    
    );

    // regfile inst
    regfile regfile_inst (
        .clk               (clk), 
        .rst_n             (rst_n),
        .id                (id_regfile),
        .wb                (wb_regfile)  
    );

    // pipeline_control inst
    pipeline_control pipeline_control_inst (
        .ex_src            (ex_pipe_ctrl),
        .hzu_src           (hzu_pipe_ctrl),
        .if_control        (pipe_ctrl_if),
        .id_control        (pipe_ctrl_id),
        .ex_control        (pipe_ctrl_ex),
        .mem_control       (pipe_ctrl_mem),
        .wb_control        (pipe_ctrl_wb)     
    );

    // forwarding_inst
    fwu fwu_inst (
        .mem               (mem_fwu),
        .wb                (wb_fwu),
        .ex_in             (ex_fwu),
        .ex_out            (fwu_ex)
    );

    // hazard_inst
    hzu hzu_inst(
        .id                (id_hzu),
        .ex                (ex_hzu),
        .pipe_ctrl         (hzu_pipe_ctrl)
    );
endmodule