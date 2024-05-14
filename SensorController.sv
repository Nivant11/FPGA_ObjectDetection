`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// The controller for the Ultra sonic sensor
//////////////////////////////////////////////////////////////////////////////////


module SensorController(
    input logic clk,
    input logic rst,
    
    // Read command
    input logic READ,
    
    // Sensor signals
    output logic TRIGGER_OUT,
    input  logic ECHO_IN,
    
    // Distance
    output logic [31:0] DISTANCE,
    output logic        DISTANCE_VALID
);

localparam IDLE = 0,
           TRIGGER = 1,
           WAIT_ECHO = 2,
           MEASURE = 3,
           DONE = 4;

logic [4:0] state, state_next;

localparam SOUND_SPEED_DIV2 = 145;
localparam DONE_DELAY = 200;  // Delay in DONE state
logic [9:0] done_counter;   // Counter for DONE state delay

// Timeout for WAIT_ECHO state
localparam int ECHO_TIMEOUT = 3000000;
logic [26:0] echo_wait_counter; // Counter to track time spent in WAIT_ECHO state

// State Update
always @(posedge clk) begin
    if (rst) begin
        state <= IDLE;
    end else begin
        state <= state_next;
    end
end

// State transitions
always_comb begin
    if (rst) begin
        state_next = IDLE;
    end else begin
        case (state)
            IDLE: begin
                if (READ) state_next = TRIGGER;
                else state_next = state;
            end
            TRIGGER: begin
                if (timer_out) state_next = WAIT_ECHO;
                else state_next = state;
            end
            WAIT_ECHO: begin
                if (ECHO_IN) begin
                    state_next = MEASURE;
                end else if (echo_wait_counter >= ECHO_TIMEOUT) begin
                    state_next = IDLE; // Transition to IDLE after timeout
                end else begin
                    state_next = state;
                end
            end
            MEASURE: begin
                if (~ECHO_IN) state_next = DONE;
                else state_next = state;
            end
            DONE: begin
                if (done_counter >= DONE_DELAY - 1 && READ) begin
                    state_next = TRIGGER;
                end else begin
                    state_next = state;
                end
            end
            default: state_next = IDLE;
        endcase
    end
end

// Control done_counter and echo_wait_counter
always @(posedge clk) begin
    if (rst || state != DONE) begin
        done_counter <= 0;
    end else if (state == DONE) begin
        done_counter <= done_counter + 1;
    end

    // Manage echo_wait_counter
    if (rst || state != WAIT_ECHO) begin
        echo_wait_counter <= 0; // Reset counter when not in WAIT_ECHO
    end else begin
        echo_wait_counter <= echo_wait_counter + 1; // Increment in WAIT_ECHO
    end
end
    // Control signals
    always_comb begin
        TRIGGER_OUT    = 0;
        counter_en     = 0;
        counter_rst    = 0;
        DISTANCE_VALID = 0;

        if (state == IDLE) begin
            counter_rst    = 1;
        end
        else if (state == TRIGGER) begin
            counter_en  = 1;
            TRIGGER_OUT = 1;
        end
        else if (state == WAIT_ECHO) begin
            counter_rst = 1;
        end
        else if (state == MEASURE) begin
            counter_rst    = 1;
        end
        else if (state == DONE) begin
            DISTANCE_VALID = 1;
        end
        else begin
            TRIGGER_OUT    = 0;
            counter_en     = 0;
            counter_rst    = 0;
            DISTANCE_VALID = 0;
        end

    end

    logic counter_en;
    logic counter_rst;
    logic timer_out;
    ten_us_counter trig_counter(
        .clk ( clk ),
        .rst ( counter_rst ),

        .counter_en ( counter_en ),
        .timer_out  ( timer_out )
    );

    // Distance calculation

    logic [31:0] echo_count;
    always @(posedge clk) begin
        if (rst || TRIGGER_OUT) begin
            echo_count <= 0;
        end
        else if (ECHO_IN) begin
            echo_count <= echo_count + 1;
        end
    end

    assign DISTANCE = (((echo_count << 4) + (echo_count)) << 1) << 1;

endmodule
