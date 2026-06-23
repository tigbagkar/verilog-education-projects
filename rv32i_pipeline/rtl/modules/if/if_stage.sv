import global_types_pkg :: word_t;
import global_types_pkg :: instr_t;

module if_stage (
    input logic                      clk, rst_n,
    pipeline_control_if_if .if_stage pipe_ctrl,
    if_id_if               .if_stage if_id_out,
    ex_if_if               .if_stage ex_if_in
);
    word_t  pc;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
           pc <= '0; 
        end
        else if (!pipe_ctrl.stall_if) begin
            if (ex_if_in.bus.redirect_valid)
                pc <= ex_if_in.bus.redirect_addr;
            else
                pc <= pc + 4;
        end 
    end

    instr_t instr;
    
    instr_mem instr_mem_inst(
        .pc    (pc),
        .instr (instr)
    );

    assign if_id_out.bus.pc    = pipe_ctrl.flush_if ? 32'h00000000 : pc;
    assign if_id_out.bus.instr = pipe_ctrl.flush_if ? 32'h00000013 : instr;
endmodule