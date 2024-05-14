`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// PWM Controller that uses a PID loop to output a PWM control signal 
//////////////////////////////////////////////////////////////////////////////////


module PWMController(
    input logic clk,
    input logic rst,

    // Distance Inputs
    input logic [31:0] DISTANCE,
    input logic        DISTANCE_VALID,

    // PWM Outputs
    output logic        PWM,
    output logic [31:0] DutyCycle
);


// Register to keep valid distance
logic [31:0] dist_reg_out;
always @(posedge clk) begin
    if (rst) begin
        dist_reg_out <= 1999999;
    end
    else if (DISTANCE_VALID) begin
        dist_reg_out <= DISTANCE;
    end
end

// Error calculation
localparam THRESH = 1999999; // All measurements above this are thrown out
logic [31:0] error;

assign error = (dist_reg_out > THRESH) ? 0 : THRESH - dist_reg_out;

// Pipeline reg. to help with timing - may not be needed
logic [31:0] error_pipeline_reg_out;
always @(posedge clk) begin
    error_pipeline_reg_out <= error;
end

// P term
localparam Kp = 1;
logic [31:0] control_sig;

assign control_sig = Kp * error_pipeline_reg_out;

// TODO: D term

// LUT for duty cycle
localparam int INDEX_INCREMENT = 85714;  // Floor(1799995 / 21) - Only using 200005 to 1999999
always_comb begin
    if      (rst)                    DutyCycle = 0; 
    else if (control_sig <= 85713)   DutyCycle = 0;
    else if (control_sig <= 171427)  DutyCycle = 5;
    else if (control_sig <= 257141)  DutyCycle = 10;
    else if (control_sig <= 342855)  DutyCycle = 15;
    else if (control_sig <= 428569)  DutyCycle = 20;
    else if (control_sig <= 514283)  DutyCycle = 25;
    else if (control_sig <= 599997)  DutyCycle = 30;
    else if (control_sig <= 685711)  DutyCycle = 35;
    else if (control_sig <= 771425)  DutyCycle = 40;
    else if (control_sig <= 857139)  DutyCycle = 45;
    else if (control_sig <= 942853)  DutyCycle = 50;
    else if (control_sig <= 1028567) DutyCycle = 55;
    else if (control_sig <= 1114281) DutyCycle = 60;
    else if (control_sig <= 1199995) DutyCycle = 65;
    else if (control_sig <= 1285709) DutyCycle = 70;
    else if (control_sig <= 1371423) DutyCycle = 75;
    else if (control_sig <= 1457137) DutyCycle = 80;
    else if (control_sig <= 1542851) DutyCycle = 85;
    else if (control_sig <= 1628565) DutyCycle = 90;
    else if (control_sig <= 1714279) DutyCycle = 95;
    else                             DutyCycle = 100;  // From 1714280 to 1799994
end

PWMGenerator pwm_gen(
    .clk (clk),
    .rst (rst),

    .duty_cycle (DutyCycle),
    .pwm_out    (PWM)
);

endmodule
