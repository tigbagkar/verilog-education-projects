////////////////////////////////////////////////////////////////
// DRIVER
////////////////////////////////////////////////////////////////
class fwu_driver extends uvm_driver #(fwu_item);
    `uvm_component_utils(fwu_driver)

    event              data_settled;
    virtual mem_fwu_if vif_mem;
    virtual wb_fwu_if  vif_wb;
    virtual ex_fwu_if  vif_ex;

    function new(string name, uvm_component parent); super.new(name, parent); endfunction

    function void build_phase(uvm_phase phase);
        if (!uvm_config_db #(event)              :: get(this, "", "data_settled", data_settled))
            `uvm_fatal("EVENT", "no data_settled")
        
        if (!uvm_config_db #(virtual mem_fwu_if) :: get(this,"","vif_mem",vif_mem)) 
            `uvm_fatal("VIF", "no vif_mem")
        
        if (!uvm_config_db #(virtual wb_fwu_if)  :: get(this,"","vif_wb", vif_wb))  
            `uvm_fatal("VIF", "no vif_wb")
        
        if (!uvm_config_db #(virtual ex_fwu_if)  :: get(this,"","vif_ex",  vif_ex)) 
            `uvm_fatal("VIF", "no vif_ex")
    endfunction

    task run_phase(uvm_phase phase);
        fwu_item it;
        forever begin
            seq_item_port.get_next_item(it);
            vif_mem.rd        = it.mem_rd;
            vif_mem.reg_write = it.mem_we;
            vif_mem.wd        = it.mem_wd;
            vif_wb.rd         = it.wb_rd;
            vif_wb.reg_write  = it.wb_we;
            vif_wb.wd         = it.wb_wd;
            vif_ex.rs1        = it.rs1;
            vif_ex.rs2        = it.rs2;
            #0;
            // it.sample(); Не поддерживается в бесплатной questa covergroup тоже не работает :(
            ->data_settled;
            seq_item_port.item_done();
        end
    endtask
endclass