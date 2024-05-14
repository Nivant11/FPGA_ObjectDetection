`timescale 1ns / 1ps

module Controller_top_tb;

    // Inputs to the Controller_top
    logic clk;
    logic rst;
    logic ECHO;

    // Outputs from the Controller_top
    logic PWM_out;
    logic TRIGGER_out;

    // Instantiate the Controller_top module
    Controller_top uut (
        .clk     ( clk ),
        .rst     ( rst ),
        .ECHO    ( ECHO ),
        .TRIGGER ( TRIGGER_out ),
        .PWM_out ( PWM_out )
    );

    // Clock generation (50 MHz)
    initial begin
        clk = 0;
        forever #20 clk = ~clk; // Clock period = 20 ns (50 MHz)
    end

    // Define a task to test ECHO pulse widths
    task test_echo(input integer echo_duration_ns);
        begin
            wait (TRIGGER_out);
            wait (~TRIGGER_out);
            
            # 2000 
            
            // Apply ECHO signal based on parameterized duration
            @(posedge clk);
            ECHO = 1;
            #echo_duration_ns; // Parameterized duration for ECHO pulse
            ECHO = 0;
            
            // Wait a little before ending this instance of the task
//            #20000;
        end
    endtask

    // Testbench Initial Conditions and Stimuli
    initial begin
        // Initialize inputs
        rst  = 1; 
        ECHO = 0; // ECHO low initially
        
        #50
        rst = 0;

        // Wait a little before applying test cases
        #20;

        // Test various ECHO durations using the task
        test_echo(117647);  // Test with 117647 ns ECHO pulse
        test_echo(500000);   // Example: Test with a shorter duration
        test_echo(200000);  // Example: Test with a longer duration
        test_echo(323432);  // Example: Test with a longer duration
        test_echo(435425);  // Example: Test with a longer duration
        test_echo(1176470);  // Example: Test with a longer duration

//        localparam THRESH = 1999999;

        // End simulation
        $finish;
    end

endmodule
