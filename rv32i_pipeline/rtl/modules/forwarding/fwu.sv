module fwu (
    mem_fwu_if .fwu mem,
    wb_fwu_if  .fwu wb,
    ex_fwu_if  .fwu ex_in,
    fwu_ex_if  .fwu ex_out
);

    always_comb begin
        ex_out.rd1_valid = 1'b0;
        ex_out.rd1       = '0;
        
        if (ex_in.rs1 == '0) begin
            // no operation, x0 is always 0 
        end
        else if ((ex_in.rs1 == mem.rd) && mem.reg_write) begin
            ex_out.rd1_valid = 1'b1;
            ex_out.rd1       = mem.wd;
        end
        else if ((ex_in.rs1 == wb.rd) && wb.reg_write) begin
            ex_out.rd1_valid = 1'b1;
            ex_out.rd1       = wb.wd;
        end
    end

    always_comb begin
        ex_out.rd2_valid = 1'b0;
        ex_out.rd2       = '0;
        if (ex_in.rs2 == '0) begin
            // no operation, x0 is always 0            
        end
        else if ((ex_in.rs2 == mem.rd) && mem.reg_write) begin
            ex_out.rd2_valid = 1'b1;
            ex_out.rd2       = mem.wd;            
        end
        else if ((ex_in.rs2 == wb.rd) && wb.reg_write) begin
            ex_out.rd2_valid = 1'b1;
            ex_out.rd2       = wb.wd;
        end
    end
endmodule