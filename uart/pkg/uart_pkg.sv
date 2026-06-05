package uart_pkg;
    typedef enum logic [1:0] { 
        ST_IDLE,
        ST_START,
        ST_DATA,
        ST_STOP
    } state_t;
endpackage 
