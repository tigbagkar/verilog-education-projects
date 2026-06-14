import alu_pkg::*;

module alu_control(
    input logic [1:0] ALUOp,
    input logic [2:0] funct3,
    input logic [6:0] funct7,
    output alu_op_t alu_op
);
    logic funct7_5;
    assign funct7_5 = funct7[4];

    always_comb begin
        case (ALUOp)
                // Always ADD
            2'b00:
                alu_op = ALU_ADD;

            2'b01: begin
                case (funct3)
                    3'o0: alu_op = ALU_SUB;   // beq
                    3'o1: alu_op = ALU_SUB;   // bne
                    3'o4: alu_op = ALU_SLT;   // blt
                    3'o5: alu_op = ALU_SLT;   // bge
                    3'o6: alu_op = ALU_SLTU;  // bltu
                    3'o7: alu_op = ALU_SLTU;  // bgeu
                    default: alu_op = ALU_NOP; 
                endcase
            end

                // Check funct3 and funct7
            2'b10: begin
                case (funct3)
                    3'o0:begin
                        if (funct7_5 == 1'b1)
                            alu_op = ALU_SUB;                            
                        else if (funct7_5 == 1'b0)
                            alu_op = ALU_ADD; 
                        else 
                            alu_op = ALU_NOP;
                    end

                    3'o1:
                        alu_op = ALU_SLL;
                    
                    3'o2:
                        alu_op = ALU_SLT;
                    
                    3'o3:
                        alu_op = ALU_SLTU;
                    
                    3'o4:
                        alu_op = ALU_XOR;
                    
                    3'o5: begin
                        if (funct7_5 == 1'b1)
                            alu_op = ALU_SRA;
                        else if (funct7_5 == 1'b0)
                            alu_op = ALU_SRL;    
                        else 
                            alu_op = ALU_NOP;
                    end

                    3'o6:
                        alu_op = ALU_OR;

                    3'o7:
                        alu_op = ALU_AND;

                    default:
                        alu_op = ALU_NOP;
                endcase
            end

                // BPass => ADD a=0 b=imm 
            2'b11:
                alu_op = ALU_ADD;

            default:
                alu_op = ALU_NOP;
        endcase
    end
endmodule   