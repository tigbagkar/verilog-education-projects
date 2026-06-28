package fwu_tb_pkg;
    import global_types_pkg :: word_t;
    import global_types_pkg :: addr_t;
    import uvm_pkg          :: *;
    
    `include "uvm_macros.svh"
    
    `include "uvm/fwu_item.sv"
    `include "uvm/fwu_sequences.sv"
    `include "uvm/fwu_driver.sv"
    `include "uvm/fwu_monitor.sv"
    `include "uvm/fwu_scoreboard.sv"
    `include "uvm/fwu_test.sv"
endpackage