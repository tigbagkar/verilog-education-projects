import global_types_pkg :: word_t;
import load_pkg         :: load_op_t;
import load_pkg         :: LOAD_NONE;
import load_pkg         :: LOAD_LB;
import load_pkg         :: LOAD_LH;
import load_pkg         :: LOAD_LW;
import load_pkg         :: LOAD_LBU;
import load_pkg         :: LOAD_LHU;
import store_pkg        :: store_op_t;
import store_pkg        :: STORE_NONE;
import store_pkg        :: STORE_SB;
import store_pkg        :: STORE_SH;
import store_pkg        :: STORE_SW;

module data_mem (
    input logic      clk, rst_n,
    input load_op_t  load_op,
    input store_op_t store_op,
    input word_t     addr,
    input  word_t    wd,
    output word_t    rd
);
    word_t mem [1023:0];
    
    always_comb begin
        rd = '0;

            // misalign exception не реализован в текущей архитектуре, если адрес не валидный - nop и варнинг от сима
        unique casez ({load_op, addr[1], addr[0]})
            {LOAD_LB, 1'b1, 1'b1}:   rd = {{24{mem[addr[31:2]][31]}}, mem[addr[31:2]][31:24]};
            {LOAD_LB, 1'b1, 1'b0}:   rd = {{24{mem[addr[31:2]][23]}}, mem[addr[31:2]][23:16]};
            {LOAD_LB, 1'b0, 1'b1}:   rd = {{24{mem[addr[31:2]][15]}}, mem[addr[31:2]][15:8]};
            {LOAD_LB, 1'b0, 1'b0}:   rd = {{24{mem[addr[31:2]][7]}},  mem[addr[31:2]][7:0]};

            {LOAD_LH, 1'b1, 1'b0}:   rd = {{16{mem[addr[31:2]][31]}}, mem[addr[31:2]][31:16]};
            {LOAD_LH, 1'b0, 1'b0}:   rd = {{16{mem[addr[31:2]][15]}}, mem[addr[31:2]][15:0]};
            
            {LOAD_LW, 1'b0, 1'b0}:   rd = mem[addr[31:2]];

            {LOAD_LBU, 1'b1, 1'b1}:  rd = mem[addr[31:2]][31:24];
            {LOAD_LBU, 1'b1, 1'b0}:  rd = mem[addr[31:2]][23:16];
            {LOAD_LBU, 1'b0, 1'b1}:  rd = mem[addr[31:2]][15:8];
            {LOAD_LBU, 1'b0, 1'b0}:  rd = mem[addr[31:2]][7:0];

            {LOAD_LHU, 1'b1, 1'b0}:  rd = mem[addr[31:2]][31:16];
            {LOAD_LHU, 1'b0, 1'b0}:  rd = mem[addr[31:2]][15:0];

            {LOAD_NONE, 1'b?, 1'b?}: begin
                // // no operation, result unused
            end
        endcase
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < 1024; i++) 
                mem[i] <= '0;
        end        
        else begin
            unique casez ({store_op, addr[1], addr[0]})
                {STORE_SB, 1'b1, 1'b1}:   mem[addr[31:2]][31:24] <= wd[7:0];
                {STORE_SB, 1'b1, 1'b0}:   mem[addr[31:2]][23:16] <= wd[7:0];
                {STORE_SB, 1'b0, 1'b1}:   mem[addr[31:2]][15:8]  <= wd[7:0];
                {STORE_SB, 1'b0, 1'b0}:   mem[addr[31:2]][7:0]   <= wd[7:0];

                {STORE_SH, 1'b1, 1'b0}:   mem[addr[31:2]][31:16] <= wd[15:0];
                {STORE_SH, 1'b0, 1'b0}:   mem[addr[31:2]][15:0]  <= wd[15:0];
                
                {STORE_SW, 1'b0, 1'b0}:   mem[addr[31:2]]        <= wd;

                {STORE_NONE, 1'b?, 1'b?}: begin
                    // no operation
                end
            endcase
        end
    end
endmodule