////////////////////////////////////////////////////////////////
// MONITOR
////////////////////////////////////////////////////////////////
class fwu_monitor extends uvm_monitor;
    `uvm_component_utils(fwu_monitor)

    event                         data_settled;
    virtual mem_fwu_if            vif_mem;
    virtual wb_fwu_if             vif_wb;
    virtual ex_fwu_if             vif_ex;
    virtual fwu_ex_if             vif_out;
    uvm_analysis_port #(fwu_item) ap;

    function new(string name, uvm_component parent); super.new(name, parent); endfunction

    function void build_phase(uvm_phase phase);
        if (!uvm_config_db #(event)              :: get(this, "", "data_settled", data_settled))
            `uvm_fatal("EVENT", "no data_settled")
        
        if (!uvm_config_db #(virtual mem_fwu_if) :: get(this,"","vif_mem",vif_mem)) 
            `uvm_fatal("VIF","no vif_mem")
        
        if (!uvm_config_db #(virtual wb_fwu_if)  :: get(this,"","vif_wb", vif_wb))  
            `uvm_fatal("VIF","no vif_wb")
        
        if (!uvm_config_db #(virtual ex_fwu_if)  :: get(this,"","vif_ex",  vif_ex))
            `uvm_fatal("VIF","no vif_ex")
        
        if (!uvm_config_db #(virtual fwu_ex_if)  :: get(this,"","vif_out", vif_out))
            `uvm_fatal("VIF","no vif_out")
        
        ap = new("ap", this);
    endfunction

    task run_phase(uvm_phase phase);
        fwu_item it;
        forever begin
            @(data_settled);
            
            it = fwu_item::type_id::create("mon");
                
            it.rs1       = vif_ex.rs1;    
            it.rs2       = vif_ex.rs2;
                
            it.mem_rd    = vif_mem.rd;     
            it.mem_we    = vif_mem.reg_write; 
            it.mem_wd    = vif_mem.wd;
                
            it.wb_rd     = vif_wb.rd;      
            it.wb_we     = vif_wb.reg_write;  
            it.wb_wd     = vif_wb.wd;
                
            it.rd1_valid = vif_out.rd1_valid; 
            it.rd1       = vif_out.rd1;
            it.rd2_valid = vif_out.rd2_valid; 
            it.rd2       = vif_out.rd2;
                
            ap.write(it);
        end
    endtask
endclass