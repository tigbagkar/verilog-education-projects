import global_types_pkg :: word_t;
import global_types_pkg :: instr_t;
import control_pkg      :: ctrl_bus_t;

module id_stage (
    input logic                      clk, rst_n,
    pipeline_control_id_if .id_stage pipe_ctrl,
    id_hzu_if              .id_stage hzu,
    if_id_if               .id_stage if_id_in,
    id_regfile_if          .id_stage regfile,
    id_ex_if               .id_stage id_ex_out
);
    word_t  pc;
    instr_t instr;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc    <= '0;
            instr <= 32'h00000013;
        end
        else if (!pipe_ctrl.stall_id) begin
            pc    <= if_id_in.bus.pc;
            instr <= if_id_in.bus.instr;    
        end
    end

    ctrl_bus_t ctrl_bus;
    logic      uses_rs1;
    logic      uses_rs2;
    control control_inst (
        .opcode   (instr.fields.opcode),
        .funct3   (instr.fields.funct3),
        .rs2      (instr.fields.rs2),
        .funct7   (instr.fields.funct7),
        .ctrl_bus (ctrl_bus),
        .uses_rs1 (uses_rs1),
        .uses_rs2 (uses_rs2)
    );

    word_t imm;
    imm_gen imm_gen_inst (
        .instr    (instr.raw),
        .imm      (imm)
    );

    word_t rd1;
    word_t rd2;
    assign regfile.iori.rs1       = instr.fields.rs1;
    assign regfile.iori.rs2       = instr.fields.rs2;
    assign rd1                    = regfile.iiro.rd1;
    assign rd2                    = regfile.iiro.rd2;

    assign id_ex_out.bus.pc       = pipe_ctrl.flush_id ? '0 : pc;
    assign id_ex_out.bus.ctrl_bus = pipe_ctrl.flush_id ? '0 : ctrl_bus;
    assign id_ex_out.bus.rd1      = pipe_ctrl.flush_id ? '0 : rd1;
    assign id_ex_out.bus.rd2      = pipe_ctrl.flush_id ? '0 : rd2;
    assign id_ex_out.bus.rd       = pipe_ctrl.flush_id ? '0 : instr.fields.rd;
    assign id_ex_out.bus.imm      = pipe_ctrl.flush_id ? '0 : imm;
    assign id_ex_out.bus.rs1      = pipe_ctrl.flush_id ? '0 : instr.fields.rs1;
    assign id_ex_out.bus.rs2      = pipe_ctrl.flush_id ? '0 : instr.fields.rs2;

    assign hzu.rs1                = instr.fields.rs1;
    assign hzu.uses_rs1           = uses_rs1;
    assign hzu.rs2                = instr.fields.rs2;
    assign hzu.uses_rs2           = uses_rs2;
endmodule