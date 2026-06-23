#!/bin/bash
# compile.sh — запускать из папки sim/
set -e

vlog -sv -mfcu \
  ../rtl/pkg/global_types_pkg.sv \
  ../rtl/pkg/control_signals/alu_pkg.sv \
  ../rtl/pkg/control_signals/branch_pkg.sv \
  ../rtl/pkg/control_signals/jump_pkg.sv \
  ../rtl/pkg/control_signals/load_pkg.sv \
  ../rtl/pkg/control_signals/store_pkg.sv \
  ../rtl/pkg/control_signals/system_pkg.sv \
  ../rtl/pkg/control_signals/u_type_pkg.sv \
  ../rtl/pkg/control_signals/control_pkg.sv \
  ../rtl/pkg/buses/stage/if_id_pkg.sv \
  ../rtl/pkg/buses/stage/ex_mem_pkg.sv \
  ../rtl/pkg/buses/stage/id_ex_pkg.sv \
  ../rtl/pkg/buses/stage/mem_wb_pkg.sv \
  ../rtl/pkg/buses/stage/ex_if_pkg.sv \
  ../rtl/pkg/buses/regfile/wb_regfile_pkg.sv \
  ../rtl/pkg/buses/regfile/id_regfile_pkg.sv \
  ../rtl/interfaces/stage/if_id_if.sv \
  ../rtl/interfaces/stage/id_ex_if.sv \
  ../rtl/interfaces/stage/ex_mem_if.sv \
  ../rtl/interfaces/stage/mem_wb_if.sv \
  ../rtl/interfaces/stage/ex_if_if.sv \
  ../rtl/interfaces/hazard/id_hzu_if.sv \
  ../rtl/interfaces/hazard/ex_hzu_if.sv \
  ../rtl/interfaces/pipeline_control/pipeline_control_if_if.sv \
  ../rtl/interfaces/pipeline_control/pipeline_control_id_if.sv \
  ../rtl/interfaces/pipeline_control/pipeline_control_ex_if.sv \
  ../rtl/interfaces/pipeline_control/pipeline_control_mem_if.sv \
  ../rtl/interfaces/pipeline_control/pipeline_control_wb_if.sv \
  ../rtl/interfaces/pipeline_control/hzu_pipeline_control_if.sv \
  ../rtl/interfaces/pipeline_control/ex_pipeline_control_if.sv \
  ../rtl/interfaces/forwarding/ex_fwu_if.sv \
  ../rtl/interfaces/forwarding/fwu_ex_if.sv \
  ../rtl/interfaces/forwarding/mem_fwu_if.sv \
  ../rtl/interfaces/forwarding/wb_fwu_if.sv \
  ../rtl/interfaces/regfile/wb_regfile_if.sv \
  ../rtl/interfaces/regfile/id_regfile_if.sv \
  ../rtl/modules/ex/agu.sv \
  ../rtl/modules/ex/alu.sv \
  ../rtl/modules/ex/branch_comp.sv \
  ../rtl/modules/ex/pc_adder.sv \
  ../rtl/modules/ex/pc_target_adder.sv \
  ../rtl/modules/id/imm_gen.sv \
  ../rtl/modules/id/control.sv \
  ../rtl/modules/if/instr_mem.sv \
  ../rtl/modules/mem/data_mem.sv \
  ../rtl/modules/regfile/regfile.sv \
  ../rtl/modules/forwarding/fwu.sv \
  ../rtl/modules/hazard/hzu.sv \
  ../rtl/modules/pipeline_control/pipeline_control.sv \
  ../rtl/modules/if/if_stage.sv \
  ../rtl/modules/id/id_stage.sv \
  ../rtl/modules/ex/ex_stage.sv \
  ../rtl/modules/mem/mem_stage.sv \
  ../rtl/modules/wb/wb_stage.sv \
  ../rtl/top/cpu.sv \
  ../verif/cpu_tb_test_1.sv

vsim -batch -do "run -all; quit -f" cpu_tb
