////////////////////////////////////////////////////////////////
// TEST
////////////////////////////////////////////////////////////////

class fwu_test extends uvm_test;
    `uvm_component_utils(fwu_test)

    event                     data_settled;
    fwu_driver                drv;
    fwu_monitor               mon;
    fwu_scoreboard            scb;
    uvm_sequencer #(fwu_item) seqr;


    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        uvm_config_db#(event)           :: set(this, "*", "data_settled", data_settled);
        drv = fwu_driver                :: type_id::create("drv", this);
        mon = fwu_monitor               :: type_id::create("mon", this);
        scb = fwu_scoreboard            :: type_id::create("scb", this);
        seqr = uvm_sequencer#(fwu_item) :: type_id::create("seqr", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        drv.seq_item_port.connect(seqr.seq_item_export);
        mon.ap.connect(scb.analysis_export);
    endfunction

    task automatic run_seq(
        input fwu_base_seq seq,
        input int unsigned count
    );
        seq.count = count;
        seq.start(seqr);
    endtask

    task run_phase(uvm_phase phase);
        fwu_base_seq seq;

        phase.raise_objection(this);
            // direct 
        begin seq = fwu_mem_rs1_seq    :: type_id::create("seq");
            run_seq(seq, 25); end
        begin seq = fwu_mem_rs2_seq    :: type_id::create("seq");
            run_seq(seq, 25); end
        begin seq = fwu_wb_rs1_seq     :: type_id::create("seq");
            run_seq(seq, 25); end 
        begin seq = fwu_wb_rs2_seq     :: type_id::create("seq");
            run_seq(seq, 25); end
        begin seq = fwu_mem_wb_rs1_seq :: type_id::create("seq");
            run_seq(seq, 25); end
        begin seq = fwu_mem_wb_rs2_seq :: type_id::create("seq");
            run_seq(seq, 25); end
        begin seq = fwu_x0_seq         :: type_id::create("seq");
            run_seq(seq, 25); end
            // random
        begin seq = fwu_rand_seq       :: type_id::create("seq");
            run_seq(seq, 200); end
        phase.drop_objection(this);
    endtask
endclass