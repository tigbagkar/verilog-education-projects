////////////////////////////////////////////////////////////////
// SEQUENCE ITEM
////////////////////////////////////////////////////////////////
class fwu_item extends uvm_sequence_item;
    `uvm_object_utils(fwu_item)
    
        // stimulus
    // ex_fwu
    rand addr_t rs1, rs2;
    // mem_fwu, wb_fwu
    rand addr_t mem_rd, wb_rd;   
    rand logic  mem_we, wb_we;  
    rand word_t mem_wd, wb_wd;
    
        // response
    // fwu_ex
    logic       rd1_valid, rd2_valid;
    word_t      rd1,       rd2;
    /*
    covergroup fwu_cg;
        cp_rs1: coverpoint rs1 {
            bins zero     = {0};
            bins nonzero  = {[1:31]};
        }
        cp_rs2: coverpoint rs2 {
            bins zero     = {0};
            bins nonzero  = {[1:31]};
        }

        cp_mem_we: coverpoint mem_we;
        cp_wb_we:  coverpoint wb_we;

        cp_fwd_rs1: coverpoint (
            (rs1 != 0 && rs1 == mem_rd && mem_we) ? 2 :  // MEM forwarding
            (rs1 != 0 && rs1 == wb_rd  && wb_we)  ? 1 :  // WB forwarding
                                                     0    // no forwarding
        ) {
            bins no_fwd  = {0};
            bins wb_fwd  = {1};
            bins mem_fwd = {2};
        }

        // То же для rs2
        cp_fwd_rs2: coverpoint (
            (rs2 != 0 && rs2 == mem_rd && mem_we) ? 2 :
            (rs2 != 0 && rs2 == wb_rd  && wb_we)  ? 1 :
                                                     0
        ) {
            bins no_fwd  = {0};
            bins wb_fwd  = {1};
            bins mem_fwd = {2};
        }

        cp_both_match_rs1: coverpoint (
            rs1 != 0 && rs1 == mem_rd && mem_we && rs1 == wb_rd && wb_we
        );
        cp_both_match_rs2: coverpoint (
            rs2 != 0 && rs2 == mem_rd && mem_we && rs2 == wb_rd && wb_we
        );

        cx_both_fwd: cross cp_fwd_rs1, cp_fwd_rs2;
    endgroup
    */
    function new(string name = "fwu_item");
        super.new(name);
        // fwu_cg = new();
    endfunction
    /*
    function void sample();
        fwu_cg.sample();
    endfunction
    */
    /*
        // x0 — редко, чтобы не забивать интересные случаи
    constraint c_x0 { rs1 dist {0:/5, [1:31]:/95};
                      rs2 dist {0:/5, [1:31]:/95}; }
    */
    function string convert2string();
        return $sformatf(
            "rs1=%0d rs2=%0d MEM(rd=%0d we=%b wd=%08h) WB(rd=%0d we=%b wd=%08h) => rd1_v=%b rd1=%08h rd2_v=%b rd2=%08h",
            rs1, rs2, mem_rd, mem_we, mem_wd, wb_rd, wb_we, wb_wd,
            rd1_valid, rd1, rd2_valid, rd2);
    endfunction
endclass