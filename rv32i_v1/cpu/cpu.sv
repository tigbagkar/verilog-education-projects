import alu_pkg::alu_op_t;

module cpu (
    input logic clk, rst_n
);  
    
    logic [31:0] PC;

    ////////////////////////////////////////
    // instr_mem 
    ////////////////////////////////////////
    logic [31:0] instr_wire; 
    
    ////////////////////////////////////////
    // Декомпозиция инструкции
    ////////////////////////////////////////
    logic [6:0] opcode_wire;
    logic [4:0] rd_wire;    
    logic [2:0] funct3_wire;
    logic [4:0] rs1_wire;
    logic [4:0] rs2_wire;
    logic [6:0] funct7_wire;

    assign opcode_wire = instr_wire[6:0];
    assign rd_wire     = instr_wire[11:7];
    assign funct3_wire = instr_wire[14:12];
    assign rs1_wire    = instr_wire[19:15];
    assign rs2_wire    = instr_wire[24:20];
    assign funct7_wire = instr_wire[31:25];

    ////////////////////////////////////////
    // control
    ////////////////////////////////////////
    logic       RegWrite_wire;
    logic       MemRead_wire;
    logic       MemWrite_wire;
    logic       MemToReg_wire;
    logic       ALUSrc_wire;
    logic       ALUASrc_wire;
    logic       Branch_wire;
    logic       Jump_wire;
    logic [1:0] ALUOp_wire;

    ////////////////////////////////////////
    // alu_control
    ////////////////////////////////////////
    alu_op_t alu_op_wire;

    ////////////////////////////////////////
    // regfile
    ////////////////////////////////////////
    logic [31:0] regfile_rd1_wire;
    logic [31:0] regfile_rd2_wire;
    logic [31:0] regfile_wd_wire;

    ////////////////////////////////////////
    // data_mem
    ////////////////////////////////////////
    logic [31:0] mem_rd_wire;

    ////////////////////////////////////////
    // imm_gen
    ////////////////////////////////////////
    logic [31:0] imm_wire;

    ////////////////////////////////////////
    // alu
    ////////////////////////////////////////
    logic [31:0] alu_a_wire;
    logic [31:0] alu_b_wire;
    
    logic [31:0] alu_result_wire;
    logic alu_zero_wire;
    
    instr_mem instr_mem_inst (
        .addr(PC),
        .instr(instr_wire)
    );
    
    control control_inst(
    .opcode(opcode_wire),
    .RegWrite(RegWrite_wire),
    .MemRead(MemRead_wire),
    .MemWrite(MemWrite_wire),
    .MemToReg(MemToReg_wire),
    .ALUSrc(ALUSrc_wire),
    .ALUASrc(ALUASrc_wire),
    .Branch(Branch_wire),
    .Jump(Jump_wire),
    .ALUOp(ALUOp_wire)    
    );

    alu_control alu_control_inst(
    .ALUOp(ALUOp_wire),
    .funct3(funct3_wire),
    .funct7(funct7_wire),
    .alu_op(alu_op_wire)
    );

    regfile regfile_inst(
        .clk(clk), 
        .rst_n(rst_n),
        .we(RegWrite_wire),
        .rd(rd_wire), 
        .wd(regfile_wd_wire),
        .rs1(rs1_wire),
        .rs2(rs2_wire),
        .rd1(regfile_rd1_wire), 
        .rd2(regfile_rd2_wire)
    );

    data_mem data_mem_inst(
        .clk(clk), 
        .rst_n(rst_n),
        .addr(alu_result_wire),
        .funct3(funct3_wire),
        .MemWrite(MemWrite_wire),
        .wd(regfile_rd2_wire),
        .MemRead(MemRead_wire),
        .rd(mem_rd_wire)
    );
    
    imm_gen imm_gen_inst(
        .instr(instr_wire),
        .imm(imm_wire)
    );
    
    alu alu_inst (
        .a(alu_a_wire),
        .b(alu_b_wire),
        .alu_op(alu_op_wire),
        .result(alu_result_wire),
        .zero(alu_zero_wire)
    );

    always_comb begin
        if (ALUASrc_wire) 
            alu_a_wire = PC;
        else
            alu_a_wire = regfile_rd1_wire;

        if (ALUSrc_wire) 
            alu_b_wire = imm_wire;
        else
            alu_b_wire = regfile_rd2_wire;

        if (Jump_wire)
            regfile_wd_wire = PC + 4;
        else if (MemToReg_wire)
            regfile_wd_wire = mem_rd_wire;
        else
            regfile_wd_wire = alu_result_wire;
    end

    logic branch_taken;

    always_comb begin
        case (funct3_wire)
            3'o0: branch_taken = alu_zero_wire;          // beq
            3'o1: branch_taken = !alu_zero_wire;         // bne
            3'o4: branch_taken = !alu_zero_wire;         // blt
            3'o5: branch_taken = alu_zero_wire;          // bge
            3'o6: branch_taken = !alu_zero_wire;         // bltu
            3'o7: branch_taken = alu_zero_wire;          // bgeu
            default: branch_taken = 1'b0;
        endcase
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            PC <= '0;
        else begin
            if (Jump_wire && opcode_wire == 7'h67)
                PC <= regfile_rd1_wire + imm_wire;
            else if (Jump_wire && opcode_wire == 7'h6F)
                PC <= PC + imm_wire;
            else if (Branch_wire && branch_taken)
                PC <= PC + imm_wire;
            else 
                PC <= PC + 4;
        end
    end
endmodule