package slave_pkg;
    typedef enum logic[2:0] {  
        SLAVE_IDLE,
        SLAVE_RECEIVE_CMD_ADDR,
        SLAVE_RECEIVE_DATA,
        SLAVE_SEND_DATA,
        SLAVE_STOP
    } slave_state_t;
endpackage