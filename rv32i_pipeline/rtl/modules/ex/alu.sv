import global_types_pkg :: word_t;
import alu_pkg          :: alu_op_t;
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

module alu (
    input  word_t   a,
    input  word_t   b,
    input  alu_op_t op,
    
    output word_t   result
);
    always_comb begin
        result = '0;
        unique case (op)
            ALU_ADD:
                result = a + b;
            ALU_SUB:
                result = a - b;
            ALU_AND:
                result = a & b;
            ALU_OR:
                result = a | b;
            ALU_XOR:
                result = a ^ b;
            ALU_SLL:
                result = a << b[4:0];
            ALU_SRL:
                result = a >> b[4:0];
            ALU_SRA:
                result = $signed(a) >>> b[4:0]; 
            ALU_SLT:
                result = $signed(a) < $signed(b);
            ALU_SLTU:
                result = a < b;
            ALU_NONE: begin
                // no operation, result unused    
            end
        endcase 
    end
endmodule