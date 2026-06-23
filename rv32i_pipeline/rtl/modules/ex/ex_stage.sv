import control_pkg      :: ctrl_bus_t;
import global_types_pkg :: word_t;
import global_types_pkg :: addr_t;
import jump_pkg         :: JUMP_JAL;
import jump_pkg         :: JUMP_JALR;
import branch_pkg       :: BRANCH_NONE;
import u_type_pkg       :: U_TYPE_LUI;
import u_type_pkg       :: U_TYPE_AUIPC;
import load_pkg         :: LOAD_NONE;
import store_pkg        :: STORE_NONE;
import system_pkg       :: SYSTEM_NONE;

module ex_stage (
    input logic                      clk, rst_n,
    pipeline_control_ex_if .ex_stage pipe_ctrl,
    ex_pipeline_control_if .ex_stage pipe_ctrl_request,
    ex_fwu_if              .ex_stage fwu_out,
    fwu_ex_if              .ex_stage fwu_in,
    ex_hzu_if              .ex_stage hzu,
    id_ex_if               .ex_stage id_ex_in,
    ex_mem_if              .ex_stage ex_mem_out,
    ex_if_if               .ex_stage ex_if_out
);
    word_t     pc;
    ctrl_bus_t ctrl_bus;
    word_t     rd1;
    word_t     rd2;
    addr_t     rd;
    word_t     imm;
    addr_t     rs1;
    addr_t     rs2;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc       <= '0;
            ctrl_bus <= '0;
            rd1      <= '0;
            rd2      <= '0;
            rd       <= '0;
            imm      <= '0;
            rs1      <= '0;
            rs2      <= '0;
        end
        else if (!pipe_ctrl.stall_ex) begin
           pc       <= id_ex_in.bus.pc;
           ctrl_bus <= id_ex_in.bus.ctrl_bus;
           rd1      <= id_ex_in.bus.rd1;
           rd2      <= id_ex_in.bus.rd2;
           rd       <= id_ex_in.bus.rd;
           imm      <= id_ex_in.bus.imm;
           rs1      <= id_ex_in.bus.rs1;
           rs2      <= id_ex_in.bus.rs2; 
        end
    end

    assign fwu_out.rs1 = rs1;
    assign fwu_out.rs2 = rs2;

    assign hzu.rd      = rd;
    assign hzu.load_op = ctrl_bus.load_op;

    word_t alu_result;
    word_t agu_result;
    logic  branch_taken;
    word_t pc_plus_imm;
    word_t pc_plus_4;

    alu alu_inst (
        .a            (fwu_in.rd1_valid ? fwu_in.rd1 : rd1),
        .b            (ctrl_bus.alu_imm ? imm : fwu_in.rd2_valid ? fwu_in.rd2 : rd2),
        .op           (ctrl_bus.alu_op),
        .result       (alu_result)
    );

    agu agu_inst (
        .rd1          (fwu_in.rd1_valid ? fwu_in.rd1 : rd1),
        .imm          (imm),
        .result       (agu_result)
    );

    branch_comp branch_comp_inst (
        .rd1          (fwu_in.rd1_valid ? fwu_in.rd1 : rd1),
        .rd2          (fwu_in.rd2_valid ? fwu_in.rd2 : rd2),
        .op           (ctrl_bus.branch_op),
        .branch_taken (branch_taken)
    );

    pc_target_adder pc_target_adder_inst (
        .pc           (pc),
        .imm          (imm),
        .result       (pc_plus_imm) 
    );

    pc_adder pc_adder_inst (
        .pc           (pc),
        .result       (pc_plus_4)
    );

    always_comb begin
        ex_mem_out.bus.reg_write              = ctrl_bus.reg_write;
        ex_mem_out.bus.rd                     = rd;
        ex_mem_out.bus.wd                     = alu_result;
        ex_mem_out.bus.rd2                    = fwu_in.rd2_valid ? fwu_in.rd2 : rd2;
        ex_mem_out.bus.load_op                = ctrl_bus.load_op;
        ex_mem_out.bus.store_op               = ctrl_bus.store_op;
        ex_if_out.bus.redirect_valid          = 1'b0;
        ex_if_out.bus.redirect_addr           = 32'b0;
        pipe_ctrl_request.flush_if_id_request = 1'b0;
        pipe_ctrl_request.stall_all_request   = 1'b0;

        if (ctrl_bus.jump_op == JUMP_JAL) begin
            ex_mem_out.bus.wd                     = pc_plus_4;            
            ex_if_out.bus.redirect_valid          = 1'b1;
            ex_if_out.bus.redirect_addr           = pc_plus_imm;
            pipe_ctrl_request.flush_if_id_request = 1'b1;
        end
        else if (ctrl_bus.jump_op == JUMP_JALR) begin
            ex_mem_out.bus.wd                     = pc_plus_4;
            ex_if_out.bus.redirect_valid          = 1'b1;
            ex_if_out.bus.redirect_addr           = {agu_result[31:1], 1'b0};
            pipe_ctrl_request.flush_if_id_request = 1'b1;
        end
        else if (ctrl_bus.branch_op != BRANCH_NONE) begin
            if (branch_taken) begin
                ex_if_out.bus.redirect_valid          = 1'b1;
                ex_if_out.bus.redirect_addr           = pc_plus_imm;
                pipe_ctrl_request.flush_if_id_request = 1'b1;
            end
        end
        else if (ctrl_bus.u_type_op == U_TYPE_LUI)   ex_mem_out.bus.wd                   = imm;
        else if (ctrl_bus.u_type_op == U_TYPE_AUIPC) ex_mem_out.bus.wd                   = pc_plus_imm;
        else if (ctrl_bus.load_op != LOAD_NONE)      ex_mem_out.bus.wd                   = agu_result;
        else if (ctrl_bus.store_op != STORE_NONE) begin
            ex_mem_out.bus.wd                   = agu_result;
                // из-за того что rd в s type часть imm надо обнулить чтобы форвардинг не срабатывал на мусорный адрес
            ex_mem_out.bus.rd                   = '0;
        end    
        else if (ctrl_bus.system_op != SYSTEM_NONE)  pipe_ctrl_request.stall_all_request = 1'b1;
        else if (ctrl_bus.instr_invalid) begin
            /*
                В случае если инструкция не валидна, все управляющие сигналы уже выставлены в 0
                так что фактически инструкция уже превращена в NOP и ничего плохого не сделает
                Фактически здесь должен быть хэндлер или обращение к нему, но в нынешнем дизайне это не предусмотрено
            */
        end
    end
endmodule