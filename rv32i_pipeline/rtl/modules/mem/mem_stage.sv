import global_types_pkg :: word_t;
import global_types_pkg :: addr_t;
import load_pkg         :: load_op_t;
import load_pkg         :: LOAD_NONE;
import store_pkg        :: store_op_t;
import store_pkg        :: STORE_NONE;


module mem_stage (
    input logic                        clk, rst_n,
    pipeline_control_mem_if .mem_stage pipe_ctrl,
    mem_fwu_if              .mem_stage fwu_out,
    ex_mem_if               .mem_stage ex_mem_in,
    mem_wb_if               .mem_stage mem_wb_out
);
    logic      reg_write;
    addr_t     rd;
    word_t     wd;
    word_t     rd2;
    load_op_t  load_op;
    store_op_t store_op;

    always_ff @(posedge clk or negedge rst_n) begin        
        if (!rst_n) begin
            reg_write <= '0;
            rd        <= '0;
            wd        <= '0;
            rd2       <= '0;
            load_op   <= LOAD_NONE;
            store_op  <= STORE_NONE;
        end
        else if (!pipe_ctrl.stall_mem) begin
            reg_write <= ex_mem_in.bus.reg_write;
            rd        <= ex_mem_in.bus.rd;
            wd        <= ex_mem_in.bus.wd;
            rd2       <= ex_mem_in.bus.rd2;
            load_op   <= ex_mem_in.bus.load_op;
            store_op  <= ex_mem_in.bus.store_op;
        end
    end

    word_t mem_rd;
    data_mem data_mem_inst (
        .clk      (clk), 
        .rst_n    (rst_n),
        .load_op  (load_op),
        .store_op (store_op),
        .addr     (wd),
        .wd       (rd2),
        .rd       (mem_rd)
    );

    assign mem_wb_out.bus.reg_write = reg_write;
    assign mem_wb_out.bus.rd        = rd;
    assign mem_wb_out.bus.wd        = (load_op != LOAD_NONE) ? mem_rd : wd;

    assign fwu_out.reg_write        = reg_write;
    assign fwu_out.rd               = rd;
    // в текущей архитектуре при load операциях hazard unit сталлит if id и значения load читается в wb
    // когда оно уже стабильно, так что форвардить отдельно результат не нужно (load_op != LOAD_NONE) ? mem_rd : wd
    assign fwu_out.wd               = wd; 
endmodule