interface fwu_ex_if;
    import global_types_pkg :: word_t;

    logic  rd1_valid;
    word_t rd1;
    logic  rd2_valid;
    word_t rd2;

    modport fwu (
        output rd1_valid,
        output rd1,
        output rd2_valid,
        output rd2
    );

    modport ex_stage (
        input rd1_valid,
        input rd1,
        input rd2_valid,
        input rd2
    );
endinterface