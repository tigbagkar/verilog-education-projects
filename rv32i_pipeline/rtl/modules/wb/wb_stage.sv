import global_types_pkg :: word_t;
import global_types_pkg :: addr_t;

module wb_stage (
    input logic                      clk, rst_n,
    pipeline_control_wb_if .wb_stage pipe_ctrl,
    mem_wb_if              .wb_stage mem_wb_in,
    wb_regfile_if          .wb_stage regfile,
    wb_fwu_if              .wb_stage fwu_out
);
    logic  reg_write;
    addr_t rd;
    word_t wd;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            reg_write <= '0;
            rd        <= '0;
            wd        <= '0;
        end 
        else if (!pipe_ctrl.stall_wb) begin
            reg_write <= mem_wb_in.bus.reg_write;
            rd        <= mem_wb_in.bus.rd;
            wd        <= mem_wb_in.bus.wd;
        end
    end

    assign regfile.bus.we = reg_write;
    assign regfile.bus.rd = rd;
    assign regfile.bus.wd = wd;

    assign fwu_out.reg_write = reg_write;
    assign fwu_out.rd        = rd;
    assign fwu_out.wd        = wd;
endmodule