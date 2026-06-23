package control_pkg;
    import alu_pkg    :: alu_op_t;
    import load_pkg   :: load_op_t;
    import store_pkg  :: store_op_t;
    import branch_pkg :: branch_op_t;
    import jump_pkg   :: jump_op_t;
    import u_type_pkg :: u_type_op_t;
    import system_pkg :: system_op_t;


    typedef struct packed {
        logic       reg_write;
        alu_op_t    alu_op;
        logic       alu_imm;
        load_op_t   load_op;
        store_op_t  store_op;
        branch_op_t branch_op;
        jump_op_t   jump_op;
        u_type_op_t u_type_op;
        system_op_t system_op;
        logic       instr_invalid;
    } ctrl_bus_t;
endpackage