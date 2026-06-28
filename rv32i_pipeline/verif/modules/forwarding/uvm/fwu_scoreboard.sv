////////////////////////////////////////////////////////////////
// SCOREBOARD  
////////////////////////////////////////////////////////////////
class fwu_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(fwu_scoreboard)

    uvm_analysis_imp #(fwu_item, fwu_scoreboard) analysis_export;

    int unsigned pass_cnt, fail_cnt;

    function new(string name, uvm_component parent); super.new(name, parent); endfunction

    function void build_phase(uvm_phase phase);
        analysis_export = new("analysis_export", this);
    endfunction

    function automatic void ref_port(
        input addr_t  rs,
        
        input addr_t  mem_rd, 
        input logic   mem_we, 
        input word_t  mem_wd,
        
        input addr_t  wb_rd,  
        input logic   wb_we,  
        input word_t  wb_wd,
        
        output logic  exp_v,
        output word_t exp_d
    );
        exp_v = 0; exp_d = '0;
        if      (rs == 0);
        else if (rs == mem_rd && mem_we) begin 
            exp_v = 1; exp_d = mem_wd; 
        end
        else if (rs == wb_rd  && wb_we)  begin 
            exp_v = 1; exp_d = wb_wd;  
        end
    endfunction

    function void write(fwu_item it);
        logic  exp_rd1_v, exp_rd2_v;
        word_t exp_rd1,   exp_rd2;
        bit ok = 1;

        ref_port(it.rs1, it.mem_rd, it.mem_we, it.mem_wd,
                         it.wb_rd,  it.wb_we,  it.wb_wd,  exp_rd1_v, exp_rd1);
        ref_port(it.rs2, it.mem_rd, it.mem_we, it.mem_wd,
                         it.wb_rd,  it.wb_we,  it.wb_wd,  exp_rd2_v, exp_rd2);

        if (it.rd1_valid !== exp_rd1_v || (exp_rd1_v && it.rd1 !== exp_rd1)) begin
            `uvm_error("SCB", $sformatf("rd1 FAIL exp_v=%b got_v=%b exp=%08h got=%08h | %s",
                                         exp_rd1_v, it.rd1_valid, exp_rd1, it.rd1, it.convert2string()))
            ok = 0;
        end
        if (it.rd2_valid !== exp_rd2_v || (exp_rd2_v && it.rd2 !== exp_rd2)) begin
            `uvm_error("SCB", $sformatf("rd2 FAIL exp_v=%b got_v=%b exp=%08h got=%08h | %s",
                                         exp_rd2_v, it.rd2_valid, exp_rd2, it.rd2, it.convert2string()))
            ok = 0;
        end

        if (ok) pass_cnt++; else fail_cnt++;
    endfunction

    function void report_phase(uvm_phase phase);
        `uvm_info("SCB", $sformatf("PASS=%0d  FAIL=%0d", pass_cnt, fail_cnt), UVM_NONE)
        if (fail_cnt) `uvm_error("SCB","TEST FAILED")
    endfunction
endclass