// Бесплатная Questa не поддерживает randomize пришлось заменить аналогом, изначальный код оставил закомментированным

////////////////////////////////////////////////////////////////
// SEQUENCES
////////////////////////////////////////////////////////////////

//--------------------------------------------------------------
// base
//--------------------------------------------------------------
class fwu_base_seq extends uvm_sequence #(fwu_item);
    int unsigned count = 1;

    function new(string name = "fwu_base_seq");
        super.new(name);
    endfunction

    virtual task body();
        `uvm_fatal("SEQ","fwu_base_seq cannot be started directly")
    endtask
endclass


//--------------------------------------------------------------
// random
//--------------------------------------------------------------
class fwu_rand_seq extends fwu_base_seq;
    `uvm_object_utils(fwu_rand_seq)

    function new(string name="fwu_rand_seq");
        super.new(name);
    endfunction

    task body();
        fwu_item it;

        repeat(count) begin
            it = fwu_item::type_id::create("it");

            start_item(it);

            it.rs1 = $urandom_range(0,31);
            it.rs2 = $urandom_range(0,31);

            it.mem_rd = $urandom_range(0,31);
            it.mem_we = $urandom_range(0,1);
            it.mem_wd = $urandom;

            it.wb_rd = $urandom_range(0,31);
            it.wb_we = $urandom_range(0,1);
            it.wb_wd = $urandom;

            finish_item(it);
        end
    endtask
endclass


//--------------------------------------------------------------
// MEM forwarding RS1
//--------------------------------------------------------------
class fwu_mem_rs1_seq extends fwu_base_seq;
    `uvm_object_utils(fwu_mem_rs1_seq)

    function new(string name="fwu_mem_rs1_seq");
        super.new(name);
    endfunction

    task body();
        fwu_item it;

        repeat(count) begin
            it = fwu_item::type_id::create("it");

            start_item(it);

            it.rs1 = $urandom_range(1,31);
            it.rs2 = $urandom_range(0,31);

            it.mem_rd = it.rs1;
            it.mem_we = 1;
            it.mem_wd = $urandom;

            do begin
                it.wb_rd = $urandom_range(0,31);
                it.wb_we = $urandom_range(0,1);
            end while(it.wb_rd==it.rs1 && it.wb_we);

            it.wb_wd = $urandom;

            finish_item(it);
        end
    endtask
endclass


//--------------------------------------------------------------
// MEM forwarding RS2
//--------------------------------------------------------------
class fwu_mem_rs2_seq extends fwu_base_seq;
    `uvm_object_utils(fwu_mem_rs2_seq)

    function new(string name="fwu_mem_rs2_seq");
        super.new(name);
    endfunction

    task body();
        fwu_item it;

        repeat(count) begin
            it = fwu_item::type_id::create("it");

            start_item(it);

            it.rs2 = $urandom_range(1,31);
            it.rs1 = $urandom_range(0,31);

            it.mem_rd = it.rs2;
            it.mem_we = 1;
            it.mem_wd = $urandom;

            do begin
                it.wb_rd = $urandom_range(0,31);
                it.wb_we = $urandom_range(0,1);
            end while(it.wb_rd==it.rs2 && it.wb_we);

            it.wb_wd = $urandom;

            finish_item(it);
        end
    endtask
endclass


//--------------------------------------------------------------
// WB forwarding RS1
//--------------------------------------------------------------
class fwu_wb_rs1_seq extends fwu_base_seq;
    `uvm_object_utils(fwu_wb_rs1_seq)

    function new(string name="fwu_wb_rs1_seq");
        super.new(name);
    endfunction

    task body();
        fwu_item it;

        repeat(count) begin
            it = fwu_item::type_id::create("it");

            start_item(it);

            it.rs1 = $urandom_range(1,31);
            it.rs2 = $urandom_range(0,31);

            it.wb_rd = it.rs1;
            it.wb_we = 1;
            it.wb_wd = $urandom;

            do begin
                it.mem_rd = $urandom_range(0,31);
                it.mem_we = $urandom_range(0,1);
            end while(it.mem_rd==it.rs1 && it.mem_we);

            it.mem_wd = $urandom;

            finish_item(it);
        end
    endtask
endclass


//--------------------------------------------------------------
// WB forwarding RS2
//--------------------------------------------------------------
class fwu_wb_rs2_seq extends fwu_base_seq;
    `uvm_object_utils(fwu_wb_rs2_seq)

    function new(string name="fwu_wb_rs2_seq");
        super.new(name);
    endfunction

    task body();
        fwu_item it;

        repeat(count) begin
            it = fwu_item::type_id::create("it");

            start_item(it);

            it.rs2 = $urandom_range(1,31);
            it.rs1 = $urandom_range(0,31);

            it.wb_rd = it.rs2;
            it.wb_we = 1;
            it.wb_wd = $urandom;

            do begin
                it.mem_rd = $urandom_range(0,31);
                it.mem_we = $urandom_range(0,1);
            end while(it.mem_rd==it.rs2 && it.mem_we);

            it.mem_wd = $urandom;

            finish_item(it);
        end
    endtask
endclass


//--------------------------------------------------------------
// MEM priority over WB (RS1)
//--------------------------------------------------------------
class fwu_mem_wb_rs1_seq extends fwu_base_seq;
    `uvm_object_utils(fwu_mem_wb_rs1_seq)

    function new(string name="fwu_mem_wb_rs1_seq");
        super.new(name);
    endfunction

    task body();
        fwu_item it;

        repeat(count) begin
            it = fwu_item::type_id::create("it");

            start_item(it);

            it.rs1 = $urandom_range(1,31);
            it.rs2 = $urandom_range(0,31);

            it.mem_rd = it.rs1;
            it.mem_we = 1;
            it.mem_wd = $urandom;

            it.wb_rd = it.rs1;
            it.wb_we = 1;

            do
                it.wb_wd = $urandom;
            while(it.wb_wd == it.mem_wd);

            finish_item(it);
        end
    endtask
endclass


//--------------------------------------------------------------
// MEM priority over WB (RS2)
//--------------------------------------------------------------
class fwu_mem_wb_rs2_seq extends fwu_base_seq;
    `uvm_object_utils(fwu_mem_wb_rs2_seq)

    function new(string name="fwu_mem_wb_rs2_seq");
        super.new(name);
    endfunction

    task body();
        fwu_item it;

        repeat(count) begin
            it = fwu_item::type_id::create("it");

            start_item(it);

            it.rs2 = $urandom_range(1,31);
            it.rs1 = $urandom_range(0,31);

            it.mem_rd = it.rs2;
            it.mem_we = 1;
            it.mem_wd = $urandom;

            it.wb_rd = it.rs2;
            it.wb_we = 1;

            do
                it.wb_wd = $urandom;
            while(it.wb_wd == it.mem_wd);

            finish_item(it);
        end
    endtask
endclass


//--------------------------------------------------------------
// x0 test
//--------------------------------------------------------------
class fwu_x0_seq extends fwu_base_seq;
    `uvm_object_utils(fwu_x0_seq)

    function new(string name="fwu_x0_seq");
        super.new(name);
    endfunction

    task body();
        fwu_item it;

        repeat(count) begin
            it = fwu_item::type_id::create("it");

            start_item(it);

            it.rs1 = 0;
            it.rs2 = 0;

            it.mem_rd = 0;
            it.mem_we = 1;
            it.mem_wd = $urandom;

            it.wb_rd = 0;
            it.wb_we = 1;
            it.wb_wd = $urandom;

            finish_item(it);
        end
    endtask
endclass
/*
////////////////////////////////////////////////////////////////
// SEQUENCES
////////////////////////////////////////////////////////////////
    // base
class fwu_base_seq extends uvm_sequence #(fwu_item);
    int unsigned count = 1;

    function new(string name = "fwu_base_seq"); super.new(name); endfunction

    virtual task body();
        `uvm_fatal("SEQ", "fwu_base_seq cannot be started directly")
    endtask
endclass

    // random
class fwu_rand_seq extends fwu_base_seq;
    `uvm_object_utils(fwu_rand_seq)
    
    function new(string name = "fwu_rand_seq"); super.new(name); endfunction
    
    task body();
        repeat (count) begin
            fwu_item it = fwu_item::type_id::create("it");
            start_item(it);

            if (!it.randomize()) 
                `uvm_fatal("RAND","randomize failed")
            
            finish_item(it);
        end
    endtask
endclass

    // mem forwarding rs1 (wb non match)
class fwu_mem_rs1_seq extends fwu_base_seq;
    `uvm_object_utils(fwu_mem_rs1_seq)

    function new(string name = "fwu_mem_rs1_seq"); super.new(name); endfunction
    
    task body();
        repeat (count) begin
            fwu_item it = fwu_item::type_id::create("it");
            start_item(it);
            if (!it.randomize() with {
                    rs1 != 0; 
                    mem_rd == rs1; 
                    mem_we == 1;
                    !(wb_rd == rs1 && wb_we == 1); 
                })
                `uvm_fatal("RAND","randomize failed")
            finish_item(it);
        end
    endtask
endclass

    // mem forwarding rs2 (wb non match)
class fwu_mem_rs2_seq extends fwu_base_seq;
    `uvm_object_utils(fwu_mem_rs2_seq)

    function new(string name = "fwu_mem_rs2_seq"); super.new(name); endfunction

    task body();
        repeat (count) begin
            fwu_item it = fwu_item::type_id::create("it");
            start_item(it);
            if (!it.randomize() with {
                    rs2 != 0; 
                    mem_rd == rs2; 
                    mem_we == 1; 
                    !(wb_rd == rs2 && wb_we == 1);
                })
                `uvm_fatal("RAND","randomize failed")
            finish_item(it);
        end
    endtask
endclass

    // wb forwarding rs1 (mem non match)
class fwu_wb_rs1_seq extends fwu_base_seq;
    `uvm_object_utils(fwu_wb_rs1_seq)
    
    function new(string name = "fwu_wb_rs1_seq"); super.new(name); endfunction
    
    task body();
        repeat (count) begin
            fwu_item it = fwu_item::type_id::create("it");
            start_item(it);
            if (!it.randomize() with {
                    rs1 != 0; 
                    wb_rd == rs1; 
                    wb_we == 1;
                    !(mem_rd == rs1 && mem_we == 1); 
                })
                `uvm_fatal("RAND","randomize failed")
            finish_item(it);
        end
    endtask
endclass

    // wb forwarding rs2 (mem non match)
class fwu_wb_rs2_seq extends fwu_base_seq;
    `uvm_object_utils(fwu_wb_rs2_seq)
    
    function new(string name = "fwu_wb_rs2_seq"); super.new(name); endfunction

    task body();
        repeat (count) begin
            fwu_item it = fwu_item::type_id::create("it");
            start_item(it);
            if (!it.randomize() with {
                    rs2 != 0;
                    wb_rd == rs2;
                    wb_we == 1;
                    !(mem_rd == rs2 && mem_we == 1); 
                })
                `uvm_fatal("RAND","randomize failed")
            finish_item(it);
        end
    endtask
endclass

    // mem forwarding rs1 (wb match)
class fwu_mem_wb_rs1_seq extends fwu_base_seq;
    `uvm_object_utils(fwu_mem_wb_rs1_seq)

    function new(string name = "fwu_mem_wb_rs1_seq"); super.new(name); endfunction
    
    task body();
        repeat (count) begin
            fwu_item it = fwu_item::type_id::create("it");
            start_item(it);
            if (!it.randomize() with {
                    rs1 != 0; 
                    
                    mem_rd == rs1; 
                    mem_we == 1;
                    
                    wb_rd == rs1;
                    wb_we == 1; 
                })
                `uvm_fatal("RAND","randomize failed")
            finish_item(it);
        end
    endtask
endclass

    // mem forwarding rs2 (wb match)
class fwu_mem_wb_rs2_seq extends fwu_base_seq;
    `uvm_object_utils(fwu_mem_wb_rs2_seq)
    
    function new(string name = "fwu_mem_wb_rs2_seq"); super.new(name); endfunction
    
    task body();
        repeat (count) begin
            fwu_item it = fwu_item::type_id::create("it");
            start_item(it);
            if (!it.randomize() with {
                    rs2 != 0; 
                    
                    mem_rd == rs2; 
                    mem_we == 1;
                    
                    wb_rd == rs2;
                    wb_we == 1; 
                })
                `uvm_fatal("RAND","randomize failed")
            finish_item(it);
        end
    endtask
endclass

    // no forwarding for x0
class fwu_x0_seq extends fwu_base_seq;    
    `uvm_object_utils(fwu_x0_seq)
    
    function new(string name = "fwu_x0_seq"); super.new(name); endfunction

    task body();
        repeat (count) begin
            fwu_item it = fwu_item::type_id::create("it");
            start_item(it);
            if (!it.randomize() with {
                    rs1 == 0; 
                    rs2 == 0;
                    
                    mem_rd == 0; 
                    mem_we == 1;
                    
                    wb_rd  == 0; 
                    wb_we  == 1; 
                })
                `uvm_fatal("RAND","randomize failed")
            finish_item(it);
        end
    endtask
endclass
*/