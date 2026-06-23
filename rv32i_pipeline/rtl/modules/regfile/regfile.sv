import global_types_pkg :: word_t;
import global_types_pkg :: addr_t;

module regfile (
    input logic            clk, rst_n,
    id_regfile_if .regfile id,
    wb_regfile_if .regfile wb  
);
    word_t x [31:0];

    // bypass чтобы не форвардить из wb в id
    assign id.iiro.rd1 = (wb.bus.we && wb.bus.rd != '0 && wb.bus.rd == id.iori.rs1) ? wb.bus.wd : x[id.iori.rs1];
    assign id.iiro.rd2 = (wb.bus.we && wb.bus.rd != '0 && wb.bus.rd == id.iori.rs2) ? wb.bus.wd : x[id.iori.rs2];

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < 32; i++) 
                x [i] <= '0;
        end

        else begin
            if (wb.bus.we) begin
                if (wb.bus.rd != 0)
                    x[wb.bus.rd] <= wb.bus.wd;
            end    
        end        
    end        
endmodule