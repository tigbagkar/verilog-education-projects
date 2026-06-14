module control(
    input logic [6:0] opcode,

    output logic RegWrite,
    output logic MemRead,
    output logic MemWrite,
    output logic MemToReg,
    output logic ALUSrc,
    output logic ALUASrc,
    output logic Branch,
    output logic Jump,
    output logic[1:0] ALUOp
);

    always_comb begin
        case (opcode)
            // I - Loads
            7'h03: begin
                RegWrite = 1'b1;
                MemRead  = 1'b1;
                MemWrite = 1'b0;
                MemToReg = 1'b1;
                ALUSrc   = 1'b1;
                ALUASrc  = 1'b0; 
                Branch   = 1'b0;
                Jump     = 1'b0;
                ALUOp    = 2'b00;
            end

            // I - OP-IMM
            7'h13: begin
                RegWrite = 1'b1;
                MemRead  = 1'b0;
                MemWrite = 1'b0;
                MemToReg = 1'b0;
                ALUSrc   = 1'b1;
                ALUASrc  = 1'b0; 
                Branch   = 1'b0;
                Jump     = 1'b0;
                ALUOp    = 2'b10;
            end

            // I - JALR
            7'h67: begin
                RegWrite = 1'b1;
                MemRead  = 1'b0;
                MemWrite = 1'b0;
                MemToReg = 1'b0;
                ALUSrc   = 1'b1;
                ALUASrc  = 1'b0; 
                Branch   = 1'b0;
                Jump     = 1'b1;
                ALUOp    = 2'b00;
            end

            // S - STORES
            7'h23: begin
                RegWrite = 1'b0;
                MemRead  = 1'b0;
                MemWrite = 1'b1;
                MemToReg = 1'b0;
                ALUSrc   = 1'b1;
                ALUASrc  = 1'b0; 
                Branch   = 1'b0;
                Jump     = 1'b0;
                ALUOp    = 2'b00;
            end

            // B - BRANCH
            7'h63: begin
                RegWrite = 1'b0;
                MemRead  = 1'b0;
                MemWrite = 1'b0;
                MemToReg = 1'b0;
                ALUSrc   = 1'b0;
                ALUASrc  = 1'b0; 
                Branch   = 1'b1;
                Jump     = 1'b0;
                ALUOp    = 2'b01;
            end

            // U - LUI 
            7'h37: begin
                RegWrite = 1'b1;
                MemRead  = 1'b0;
                MemWrite = 1'b0;
                MemToReg = 1'b0;
                ALUSrc   = 1'b1;
                ALUASrc  = 1'b0; 
                Branch   = 1'b0;
                Jump     = 1'b0;
                ALUOp    = 2'b11;
            end

            // U - AUIPC
            7'h17: begin
                RegWrite = 1'b1;
                MemRead  = 1'b0;
                MemWrite = 1'b0;
                MemToReg = 1'b0;
                ALUSrc   = 1'b1;
                ALUASrc  = 1'b1; 
                Branch   = 1'b0;
                Jump     = 1'b0;
                ALUOp    = 2'b11;
            end

            // J - JAL
            7'h6F: begin
                RegWrite = 1'b1;
                MemRead  = 1'b0;
                MemWrite = 1'b0;
                MemToReg = 1'b0;
                ALUSrc   = 1'b1;
                ALUASrc  = 1'b0; 
                Branch   = 1'b0;
                Jump     = 1'b1;
                ALUOp    = 2'b00;
            end

            // R - OP
            7'h33: begin
                RegWrite = 1'b1;
                MemRead  = 1'b0;
                MemWrite = 1'b0;
                MemToReg = 1'b0;
                ALUSrc   = 1'b0;
                ALUASrc  = 1'b0; 
                Branch   = 1'b0;
                Jump     = 1'b0;
                ALUOp    = 2'b10;
            end

            default: begin
                RegWrite = 1'b0;
                MemRead  = 1'b0;
                MemWrite = 1'b0;
                MemToReg = 1'b0;
                ALUSrc   = 1'b0;
                ALUASrc  = 1'b0; 
                Branch   = 1'b0;
                Jump     = 1'b0;
                ALUOp    = 2'b00;       
            end
        endcase
    end
endmodule