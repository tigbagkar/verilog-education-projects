package master_pkg; 
    typedef enum logic[2:0] {  
        MASTER_IDLE,          // 000
        MASTER_START,         // 001
        MASTER_SEND_CMD_ADDR, // 010
        MASTER_SEND_DATA,     // 011
        MASTER_RECEIVE_DATA,  // 100
        MASTER_DUMMY,         // 101
        MASTER_STOP           // 110
    } master_state_t;
endpackage