`timescale 1ns / 1ps

module SensorController_tb;

    // Testbench Signals
    logic clk;
    logic rst;
    logic read;
    logic echo_in;
    logic [31:0] distance;
    logic distance_valid;
    logic trigger_out;

    // Instantiate the Device Under Test (DUT)
    SensorController dut(
        .clk(clk),
        .rst(rst),
        .READ(read),
        .ECHO_IN(echo_in),
        .DISTANCE(distance),
        .DISTANCE_VALID(distance_valid),
        .TRIGGER_OUT(trigger_out)
    );

    // Clock Generation
    always #10 clk = ~clk;

    // Test Stimulus
    initial begin
        // Initialize Signals
        clk = 0;
        rst = 1;
        read = 0;
        echo_in = 0;

        // Apply Reset
        #20 rst = 0;

        // Start Reading after reset
        #10 read = 1;
        #10 read = 0;  // Pulse the read signal

        // Wait for trigger to activate
        wait(trigger_out == 1);
//        #10;  // wait for 10us trigger duration to end
        wait(trigger_out == 0);

        // Simulate echo signal 20us after trigger falls (400ns after trigger start)
        #400;  
        echo_in = 1;
        #1176470;  // Length of echo pulse, 117647 - 2cm, 1176470 - 20 cm, 23529412 - 400cm
        echo_in = 0;

        // Wait to observe the output
        #100;
        
        // Finish simulation
        $finish;
    end

    // Optional: Monitor outputs
    initial begin
        $monitor("Time = %t, TRIGGER_OUT = %b, ECHO_IN = %b, DISTANCE = %d, DISTANCE_VALID = %b", 
                 $time, trigger_out, echo_in, distance, distance_valid);
    end

endmodule
