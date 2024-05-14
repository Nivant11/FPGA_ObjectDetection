module PWMGenerator(
    input  logic clk,           
    input  logic rst,
    
    input  logic [31:0] duty_cycle,  
    output logic pwm_out        // PWM output signal
);

    localparam PERIOD = 256;   // Define the period of the PWM cycle
    logic [7:0] counter;        // Counter to track the current position in the PWM period

    logic pwm;
    assign pwm_out = pwm;
    always @(posedge clk) begin
        if (rst) begin
            counter <= 8'd0;  // Reset the counter
            pwm <= 1'b0;  // Reset the PWM output
        end
        else begin
            if (counter < PERIOD - 1)
                counter <= counter + 1'b1;  // Increment the counter
            else
                counter <= 8'd0;  // Reset the counter at the end of the period
            
            // Generate PWM signal based on the duty cycle
            if (counter < (duty_cycle << 8) / 100) // Too much compute?
                pwm <= 1'b1;  // Output high for 'duty_cycle' percent of the period
            else
                pwm <= 1'b0;  // Output low for the remainder of the period
        end
    end
endmodule
