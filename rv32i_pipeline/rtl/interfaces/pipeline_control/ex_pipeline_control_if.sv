interface ex_pipeline_control_if;
        // jump/branch penalty, если переход произошел нужно превратить то что уже успело обработаться в NOP
    logic flush_if_id_request;
        // ebreak/ecall, заглушка т.к. нет ОС или хэндлера, останавливаем конвеер навсегда
    logic stall_all_request;

    modport ex_stage (
        output flush_if_id_request,
        output stall_all_request
    );

    modport pipeline_control (
        input flush_if_id_request,
        input stall_all_request
    );
endinterface 