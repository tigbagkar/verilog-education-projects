import global_types_pkg :: word_t;

module imm_gen (
    input word_t  instr,
    output word_t imm
);
    always_comb begin
        imm = 32'b0;
        
        unique0 case (instr[6:0])
            // I
            7'b000_0011, 7'b001_0011, 7'b110_0111, 7'b111_0011:
                imm = {{20{instr[31]}} , instr[31:20]};
            // S
            7'b010_0011:
                imm = {{20{instr[31]}} , instr[31:25] , instr[11:7]};
            // B
            7'b110_0011:
                imm = {{19{instr[31]}} , instr[31] , instr[7] , instr[30:25] , instr[11:8] , 1'b0};
            // U
            7'b001_0111, 7'b011_0111:
                imm = {instr[31:12] , 12'b0};
            // J
            7'b110_1111:
                imm = {{11{instr[31]}} , instr[31] , instr[19:12] , instr[20] , instr[30:21] , 1'b0};
        endcase
    end
endmodule