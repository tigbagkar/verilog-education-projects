import global_types_pkg :: opcode_t;
import global_types_pkg :: funct3_t;
import global_types_pkg :: funct7_t;
import global_types_pkg :: addr_t;
import control_pkg      :: ctrl_bus_t;
import alu_pkg          :: ALU_NONE;  
import alu_pkg          :: ALU_ADD;
import alu_pkg          :: ALU_SUB;
import alu_pkg          :: ALU_AND;
import alu_pkg          :: ALU_OR;
import alu_pkg          :: ALU_XOR;
import alu_pkg          :: ALU_SLL;
import alu_pkg          :: ALU_SRL;
import alu_pkg          :: ALU_SRA;
import alu_pkg          :: ALU_SLT;
import alu_pkg          :: ALU_SLTU;
import load_pkg         :: LOAD_NONE;
import load_pkg         :: LOAD_LB;
import load_pkg         :: LOAD_LH;
import load_pkg         :: LOAD_LW;
import load_pkg         :: LOAD_LBU;
import load_pkg         :: LOAD_LHU;
import store_pkg        :: STORE_NONE;
import store_pkg        :: STORE_SB;
import store_pkg        :: STORE_SH;
import store_pkg        :: STORE_SW;
import branch_pkg       :: BRANCH_NONE;
import branch_pkg       :: BRANCH_BEQ;
import branch_pkg       :: BRANCH_BNE;
import branch_pkg       :: BRANCH_BLT;
import branch_pkg       :: BRANCH_BGE;
import branch_pkg       :: BRANCH_BLTU;
import branch_pkg       :: BRANCH_BGEU;
import jump_pkg         :: JUMP_NONE;
import jump_pkg         :: JUMP_JAL;
import jump_pkg         :: JUMP_JALR;
import u_type_pkg       :: U_TYPE_NONE;
import u_type_pkg       :: U_TYPE_LUI;
import u_type_pkg       :: U_TYPE_AUIPC;
import system_pkg       :: SYSTEM_NONE;
import system_pkg       :: SYSTEM_ECALL;
import system_pkg       :: SYSTEM_EBREAK;

module control (
    input  opcode_t   opcode,
    input  funct3_t   funct3,
    input  addr_t     rs2,
    input  funct7_t   funct7,
    output ctrl_bus_t ctrl_bus,
    output logic      uses_rs1,
    output logic      uses_rs2
);
    always_comb begin
        ctrl_bus               = '0;
        ctrl_bus.instr_invalid = 1'b1;
        uses_rs1               = 1'b0;
        uses_rs2               = 1'b0;
        unique0 casez ({funct7, rs2, funct3, opcode})
////////////////////////////////////////////////////////////////
// R - OP
////////////////////////////////////////////////////////////////
            {7'b000_0000, 5'b?_????, 3'b000, 7'b011_0011}: begin
                ctrl_bus.reg_write     = 1'b1;
                ctrl_bus.alu_op        = ALU_ADD;
                ctrl_bus.instr_invalid = 1'b0;
                uses_rs1               = 1'b1;
                uses_rs2               = 1'b1;
            end
            {7'b010_0000, 5'b?_????, 3'b000, 7'b011_0011}: begin
                ctrl_bus.reg_write     = 1'b1;
                ctrl_bus.alu_op        = ALU_SUB;
                ctrl_bus.instr_invalid = 1'b0;
                uses_rs1               = 1'b1;
                uses_rs2               = 1'b1;
            end
            {7'b000_0000, 5'b?_????, 3'b001, 7'b011_0011}: begin
                ctrl_bus.reg_write     = 1'b1;
                ctrl_bus.alu_op        = ALU_SLL;
                ctrl_bus.instr_invalid = 1'b0;
                uses_rs1               = 1'b1;
                uses_rs2               = 1'b1;
            end
            {7'b000_0000, 5'b?_????, 3'b010, 7'b011_0011}: begin
                ctrl_bus.reg_write     = 1'b1;
                ctrl_bus.alu_op        = ALU_SLT;
                ctrl_bus.instr_invalid = 1'b0;
                uses_rs1               = 1'b1;
                uses_rs2               = 1'b1;
            end
            {7'b000_0000, 5'b?_????, 3'b011, 7'b011_0011}: begin
                ctrl_bus.reg_write     = 1'b1;
                ctrl_bus.alu_op        = ALU_SLTU;
                ctrl_bus.instr_invalid = 1'b0;
                uses_rs1               = 1'b1;
                uses_rs2               = 1'b1;
            end
            {7'b000_0000, 5'b?_????, 3'b100, 7'b011_0011}: begin
                ctrl_bus.reg_write     = 1'b1;
                ctrl_bus.alu_op        = ALU_XOR;
                ctrl_bus.instr_invalid = 1'b0;
                uses_rs1               = 1'b1;
                uses_rs2               = 1'b1;
            end
            {7'b000_0000, 5'b?_????, 3'b101, 7'b011_0011}: begin
                ctrl_bus.reg_write     = 1'b1;
                ctrl_bus.alu_op        = ALU_SRL;
                ctrl_bus.instr_invalid = 1'b0;
                uses_rs1               = 1'b1;
                uses_rs2               = 1'b1;
            end
            {7'b010_0000, 5'b?_????, 3'b101, 7'b011_0011}: begin
                ctrl_bus.reg_write     = 1'b1;
                ctrl_bus.alu_op        = ALU_SRA;
                ctrl_bus.instr_invalid = 1'b0;
                uses_rs1               = 1'b1;
                uses_rs2               = 1'b1;
            end
            {7'b000_0000, 5'b?_????, 3'b110, 7'b011_0011}: begin
                ctrl_bus.reg_write     = 1'b1;
                ctrl_bus.alu_op        = ALU_OR;
                ctrl_bus.instr_invalid = 1'b0;
                uses_rs1               = 1'b1;
                uses_rs2               = 1'b1;
            end
            {7'b000_0000, 5'b?_????, 3'b111, 7'b011_0011}: begin
                ctrl_bus.reg_write     = 1'b1;
                ctrl_bus.alu_op        = ALU_AND;
                ctrl_bus.instr_invalid = 1'b0;
                uses_rs1               = 1'b1;
                uses_rs2               = 1'b1;
            end
////////////////////////////////////////////////////////////////
// I - OP-IMM | funct_7 = imm[11:5] 
////////////////////////////////////////////////////////////////
            {7'b???_????, 5'b?_????, 3'b000, 7'b001_0011}: begin
                ctrl_bus.reg_write     = 1'b1;
                ctrl_bus.alu_op        = ALU_ADD;
                ctrl_bus.alu_imm       = 1'b1;
                ctrl_bus.instr_invalid = 1'b0;
                uses_rs1               = 1'b1;
            end
            {7'b000_0000, 5'b?_????, 3'b001, 7'b001_0011}: begin
                ctrl_bus.reg_write     = 1'b1;
                ctrl_bus.alu_op        = ALU_SLL;
                ctrl_bus.alu_imm       = 1'b1;
                ctrl_bus.instr_invalid = 1'b0;
                uses_rs1               = 1'b1;
            end
            {7'b???_????, 5'b?_????, 3'b010, 7'b001_0011}: begin
                ctrl_bus.reg_write     = 1'b1;
                ctrl_bus.alu_op        = ALU_SLT;
                ctrl_bus.alu_imm       = 1'b1;
                ctrl_bus.instr_invalid = 1'b0;
                uses_rs1               = 1'b1;
            end
            {7'b???_????, 5'b?_????, 3'b011, 7'b001_0011}: begin
                ctrl_bus.reg_write     = 1'b1;
                ctrl_bus.alu_op        = ALU_SLTU;
                ctrl_bus.alu_imm       = 1'b1;
                ctrl_bus.instr_invalid = 1'b0;
                uses_rs1               = 1'b1;
            end
            {7'b???_????, 5'b?_????, 3'b100, 7'b001_0011}: begin
                ctrl_bus.reg_write     = 1'b1;
                ctrl_bus.alu_op        = ALU_XOR;
                ctrl_bus.alu_imm       = 1'b1;
                ctrl_bus.instr_invalid = 1'b0;
                uses_rs1               = 1'b1;
            end
            {7'b000_0000, 5'b?_????, 3'b101, 7'b001_0011}: begin
                ctrl_bus.reg_write     = 1'b1;
                ctrl_bus.alu_op        = ALU_SRL;
                ctrl_bus.alu_imm       = 1'b1;
                ctrl_bus.instr_invalid = 1'b0;
                uses_rs1               = 1'b1;
            end
            {7'b010_0000, 5'b?_????, 3'b101, 7'b001_0011}: begin
                ctrl_bus.reg_write     = 1'b1;
                ctrl_bus.alu_op        = ALU_SRA;
                ctrl_bus.alu_imm       = 1'b1;
                ctrl_bus.instr_invalid = 1'b0;
                uses_rs1               = 1'b1;
            end
            {7'b???_????, 5'b?_????, 3'b110, 7'b001_0011}: begin
                ctrl_bus.reg_write     = 1'b1;
                ctrl_bus.alu_op        = ALU_OR;
                ctrl_bus.alu_imm       = 1'b1;
                ctrl_bus.instr_invalid = 1'b0;
                uses_rs1               = 1'b1;
            end
            {7'b???_????, 5'b?_????, 3'b111, 7'b001_0011}: begin
                ctrl_bus.reg_write     = 1'b1;
                ctrl_bus.alu_op        = ALU_AND;
                ctrl_bus.alu_imm       = 1'b1;
                ctrl_bus.instr_invalid = 1'b0;
                uses_rs1               = 1'b1;
            end
////////////////////////////////////////////////////////////////
// I - LOAD
////////////////////////////////////////////////////////////////
            {7'b???_????, 5'b?_????, 3'b000, 7'b000_0011}: begin
                ctrl_bus.reg_write     = 1'b1;
                ctrl_bus.load_op       = LOAD_LB;    
                ctrl_bus.instr_invalid = 1'b0;
                uses_rs1               = 1'b1;
            end
            {7'b???_????, 5'b?_????, 3'b001, 7'b000_0011}: begin
                ctrl_bus.reg_write     = 1'b1;
                ctrl_bus.load_op       = LOAD_LH;    
                ctrl_bus.instr_invalid = 1'b0;
                uses_rs1               = 1'b1;
            end
            {7'b???_????, 5'b?_????, 3'b010, 7'b000_0011}: begin
                ctrl_bus.reg_write     = 1'b1;
                ctrl_bus.load_op       = LOAD_LW;    
                ctrl_bus.instr_invalid = 1'b0;
                uses_rs1               = 1'b1;
            end
            {7'b???_????, 5'b?_????, 3'b100, 7'b000_0011}: begin
                ctrl_bus.reg_write     = 1'b1;
                ctrl_bus.load_op       = LOAD_LBU;    
                ctrl_bus.instr_invalid = 1'b0;
                uses_rs1               = 1'b1;
            end
            {7'b???_????, 5'b?_????, 3'b101, 7'b000_0011}: begin
                ctrl_bus.reg_write     = 1'b1;
                ctrl_bus.load_op       = LOAD_LHU;    
                ctrl_bus.instr_invalid = 1'b0;
                uses_rs1               = 1'b1;
            end
////////////////////////////////////////////////////////////////
// S - STORE
////////////////////////////////////////////////////////////////                
            {7'b???_????, 5'b?_????, 3'b000, 7'b010_0011}: begin
                ctrl_bus.store_op      = STORE_SB;   
                ctrl_bus.instr_invalid = 1'b0;
                uses_rs1               = 1'b1;
                uses_rs2               = 1'b1;
            end
            {7'b???_????, 5'b?_????, 3'b001, 7'b010_0011}: begin
                ctrl_bus.store_op      = STORE_SH;   
                ctrl_bus.instr_invalid = 1'b0;
                uses_rs1               = 1'b1;
                uses_rs2               = 1'b1;
            end
            {7'b???_????, 5'b?_????, 3'b010, 7'b010_0011}: begin
                ctrl_bus.store_op      = STORE_SW;   
                ctrl_bus.instr_invalid = 1'b0;
                uses_rs1               = 1'b1;
                uses_rs2               = 1'b1;
            end
////////////////////////////////////////////////////////////////
// B - BRANCH
////////////////////////////////////////////////////////////////
            {7'b???_????, 5'b?_????, 3'b000, 7'b110_0011}: begin
                ctrl_bus.branch_op     = BRANCH_BEQ;   
                ctrl_bus.instr_invalid = 1'b0;
                uses_rs1               = 1'b1;
                uses_rs2               = 1'b1;
            end
            {7'b???_????, 5'b?_????, 3'b001, 7'b110_0011}: begin
                ctrl_bus.branch_op     = BRANCH_BNE;   
                ctrl_bus.instr_invalid = 1'b0;
                uses_rs1               = 1'b1;
                uses_rs2               = 1'b1;
            end
            {7'b???_????, 5'b?_????, 3'b100, 7'b110_0011}: begin
                ctrl_bus.branch_op     = BRANCH_BLT;   
                ctrl_bus.instr_invalid = 1'b0;
                uses_rs1               = 1'b1;
                uses_rs2               = 1'b1;
            end
            {7'b???_????, 5'b?_????, 3'b101, 7'b110_0011}: begin
                ctrl_bus.branch_op     = BRANCH_BGE;   
                ctrl_bus.instr_invalid = 1'b0;
                uses_rs1               = 1'b1;
                uses_rs2               = 1'b1;
            end
            {7'b???_????, 5'b?_????, 3'b110, 7'b110_0011}: begin
                ctrl_bus.branch_op     = BRANCH_BLTU;   
                ctrl_bus.instr_invalid = 1'b0;
                uses_rs1               = 1'b1;
                uses_rs2               = 1'b1;
            end
            {7'b???_????, 5'b?_????, 3'b111, 7'b110_0011}: begin
                ctrl_bus.branch_op     = BRANCH_BGEU;   
                ctrl_bus.instr_invalid = 1'b0;
                uses_rs1               = 1'b1;
                uses_rs2               = 1'b1;
            end
////////////////////////////////////////////////////////////////
// J - JAL
////////////////////////////////////////////////////////////////
            {7'b???_????, 5'b?_????, 3'b???, 7'b110_1111}: begin
                ctrl_bus.reg_write     = 1'b1;
                ctrl_bus.jump_op       = JUMP_JAL;   
                ctrl_bus.instr_invalid = 1'b0;
                uses_rs1               = 1'b0;
                uses_rs2               = 1'b0;
            end
////////////////////////////////////////////////////////////////
// I - JALR
////////////////////////////////////////////////////////////////
            {7'b???_????, 5'b?_????, 3'b000, 7'b110_0111}: begin
                ctrl_bus.reg_write     = 1'b1;
                ctrl_bus.jump_op       = JUMP_JALR;   
                ctrl_bus.instr_invalid = 1'b0;
                uses_rs1               = 1'b1;
            end
////////////////////////////////////////////////////////////////
// U - LUI
////////////////////////////////////////////////////////////////
            {7'b???_????, 5'b?_????, 3'b???, 7'b011_0111}: begin
                ctrl_bus.reg_write     = 1'b1;
                ctrl_bus.u_type_op     = U_TYPE_LUI;
                ctrl_bus.instr_invalid = 1'b0;
                uses_rs1               = 1'b0;
                uses_rs2               = 1'b0;
            end
////////////////////////////////////////////////////////////////
// U - AUIPC
////////////////////////////////////////////////////////////////
            {7'b???_????, 5'b?_????, 3'b???, 7'b001_0111}: begin
                ctrl_bus.reg_write     = 1'b1;
                ctrl_bus.u_type_op     = U_TYPE_AUIPC;
                ctrl_bus.instr_invalid = 1'b0;
                uses_rs1               = 1'b0;
                uses_rs2               = 1'b0;
            end
////////////////////////////////////////////////////////////////
// I - SYSTEM | funct7 = imm[11:5] rs2 = imm[4:0]
////////////////////////////////////////////////////////////////
            {7'b000_0000, 5'b0_0000, 3'b000, 7'b111_0011}: begin
                ctrl_bus.system_op     = SYSTEM_ECALL;
                ctrl_bus.instr_invalid = 1'b0;
            end
            {7'b000_0000, 5'b0_0001, 3'b000, 7'b111_0011}: begin
                ctrl_bus.system_op     = SYSTEM_EBREAK;
                ctrl_bus.instr_invalid = 1'b0;
            end
        endcase
    end

endmodule