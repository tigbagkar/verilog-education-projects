package timer_pkg;
    localparam   logic [5:0] MAX_SEC_MIN = 6'd59;
    localparam   logic [4:0] MAX_HOUR    = 5'd23;
    localparam   logic [9:0] MAX_COUNT   = 10'd999;

    typedef enum logic [1:0] {
        CMD_NOP, 
        CMD_RESET,
        CMD_RUN,
        CMD_PAUSE
    } command_t;

    typedef enum logic [1:0] {
        ST_IDLE,
        ST_RUN,
        ST_PAUSE
    } state_t;
endpackage 