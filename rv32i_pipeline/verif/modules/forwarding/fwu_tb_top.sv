////////////////////////////////////////////////////////////////
// TOP
////////////////////////////////////////////////////////////////
`timescale 1ns/1ps

import uvm_pkg    :: *;
import fwu_tb_pkg :: *;

`include "uvm_macros.svh"

module fwu_tb_top;

    mem_fwu_if if_mem ();
    wb_fwu_if  if_wb  ();
    ex_fwu_if  if_ex  ();
    fwu_ex_if  if_out ();

    fwu dut (
        .mem    (if_mem),
        .wb     (if_wb),
        .ex_in  (if_ex),
        .ex_out (if_out)
    );

    initial begin
        uvm_config_db #(virtual mem_fwu_if)::set(null,"uvm_test_top.*","vif_mem", if_mem);
        uvm_config_db #(virtual wb_fwu_if) ::set(null,"uvm_test_top.*","vif_wb",  if_wb);
        uvm_config_db #(virtual ex_fwu_if) ::set(null,"uvm_test_top.*","vif_ex",  if_ex);
        uvm_config_db #(virtual fwu_ex_if) ::set(null,"uvm_test_top.*","vif_out", if_out);

        run_test("fwu_test");
    end

    initial begin #500_000; `uvm_fatal("TOUT","timeout") end

endmodule