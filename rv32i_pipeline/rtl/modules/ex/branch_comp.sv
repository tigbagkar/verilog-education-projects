import global_types_pkg :: word_t;
import branch_pkg       :: branch_op_t;
import branch_pkg       :: BRANCH_NONE;  
import branch_pkg       :: BRANCH_BEQ;    
import branch_pkg       :: BRANCH_BNE;    
import branch_pkg       :: BRANCH_BLT;    
import branch_pkg       :: BRANCH_BGE;    
import branch_pkg       :: BRANCH_BLTU;   
import branch_pkg       :: BRANCH_BGEU;   


module branch_comp (
    input  word_t      rd1,
    input  word_t      rd2,
    input  branch_op_t op,

    output logic       branch_taken
);
    always_comb begin
        branch_taken = 1'b0;

        unique case (op)
            BRANCH_BEQ: 
                branch_taken = rd1 == rd2;   
            BRANCH_BNE:    
                branch_taken = rd1 != rd2;            
            BRANCH_BLT:    
                branch_taken = $signed(rd1) < $signed(rd2);            
            BRANCH_BGE:    
                branch_taken = $signed(rd1) >= $signed(rd2);            
            BRANCH_BLTU:   
                branch_taken = rd1 < rd2;            
            BRANCH_BGEU:
                branch_taken = rd1 >= rd2;
            BRANCH_NONE: begin
                // no operation, result unused 
            end
        endcase
    end
endmodule