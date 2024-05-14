`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
//  A ten microsecond counter implementation
//////////////////////////////////////////////////////////////////////////////////

module ten_us_counter(    
    input logic clk,
    input logic rst,

    // Input enable
    input logic counter_en,
    
    // Timer output
    output logic timer_out
);
    
    localparam TRIG_CLOCK_CYCLES = 350;
    
    // Register to keep count when enabled
    logic [15:0] counter; 
    always @(posedge clk) begin
        if (rst) begin
            counter <= 0;
        end
        else if (counter_en) begin
            if (counter != TRIG_CLOCK_CYCLES) begin
                counter <= counter + 1;
            end
        end
        else begin
            counter <= 0;
        end
    end
    
    // Check if the count indicates 10us
    assign timer_out = (counter == TRIG_CLOCK_CYCLES);
    
endmodule
