`timescale 1ns / 1ps

module PWMController_tb;

    // Inputs
    logic clk;
    logic rst;
    logic [31:0] DISTANCE;
    logic DISTANCE_VALID;

    // Outputs
    logic PWM;
    logic [31:0] DutyCycle;

    // Instantiate the Unit Under Test (UUT)
    PWMController uut (
        .clk            (clk),
        .rst            (rst),
        .DISTANCE       (DISTANCE),
        .DISTANCE_VALID (DISTANCE_VALID),
        .PWM            (PWM),
        .DutyCycle      (DutyCycle)
    );

    // Clock generation
    always #5 clk = ~clk; // 100MHz Clock

    // Initial Setup and Stimuli
    initial begin
        // Initialize Inputs
        clk = 0;
        rst = 0;
        DISTANCE = 1999999;
        DISTANCE_VALID = 0;

        // Reset the system
        #10;
        rst = 1;
        #10;
        rst = 0;
        #10;

        @(posedge clk);
        // Test Case: Set DISTANCE to 200005
        DISTANCE = 1999999;
        DISTANCE_VALID = 1;
        #10;
        DISTANCE_VALID = 0;  // Pulse the valid signal

        // Allow some time to pass
        #1000;

        @(posedge clk);
        DISTANCE = 200005;
        DISTANCE_VALID = 1;
        #10;
        DISTANCE_VALID = 0;  // Pulse the valid signal
        
        // Allow some time to pass
        #10000;

        @(posedge clk);
        DISTANCE = 1100002;
        DISTANCE_VALID = 1;
        #10;
        DISTANCE_VALID = 0;  // Pulse the valid signal

        // Finish the simulation
        $finish;
    end

    // Optional: Additional monitoring or assertions can be added here to automatically
    // check for expected behavior rather than manually inspecting the waveform.

endmodule
