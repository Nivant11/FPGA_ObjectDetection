`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Controller top level. Ties Sensor Controller to PWM Controller 
//////////////////////////////////////////////////////////////////////////////////


module Controller_top(

    input logic clk,
    input logic rst, // TODO: Maybe add an enable that is tied to a switch?

    // Sensor interface
    output logic TRIGGER,
    input  logic ECHO,

    // PWM Interface
    output logic PWM_out

);

    logic [31:0] DISTANCE;
    logic        DISTANCE_VALID;
    
    logic TRIGGER_OUT;
    assign TRIGGER = (rst) ? 0 : TRIGGER_OUT;
    
    logic        ECHO_sync;   // Synchronized ECHO signal
    logic        ECHO_sync_2; // Second stage for synchronization
    
    // Two-flip-flop synchronizer for ECHO signal
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            ECHO_sync   <= 0;
            ECHO_sync_2 <= 0;
        end else begin
            ECHO_sync   <= ECHO;        // First stage of synchronization
            ECHO_sync_2 <= ECHO_sync;   // Second stage of synchronization
        end
    end
    
    SensorController sensor_ctrl (
        .clk            ( clk ),
        .rst            ( rst ),
        
        .READ           ( 1 ), // Keep the sensor controller enabled
        
        .TRIGGER_OUT    ( TRIGGER_OUT ),
        .ECHO_IN        ( ECHO_sync_2 ),
        
        .DISTANCE       ( DISTANCE ),
        .DISTANCE_VALID ( DISTANCE_VALID )
    );

    logic [31:0] DutyCycle_out; // Not needed at top level?
    PWMController pwm_ctrl(
        .clk            ( clk ),
        .rst            ( rst ),
    
        .DISTANCE       ( DISTANCE ),
        .DISTANCE_VALID ( DISTANCE_VALID ),
    
        .PWM            ( PWM_out ),
        .DutyCycle      ( DutyCycle_out )
);

endmodule
