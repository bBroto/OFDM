`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.12.2025 18:49:53
// Design Name: 
// Module Name: butterfly_unit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
                    // THIS MODULE HAS A DELAY OF 2 UNITS
//////////////////////////////////////////////////////////////////////////////////


module butterfly_unit #(parameter N=32)
   (
    clk,reset,A_r,A_c,B_r,B_c,W_r,W_c, Y_r_top,Y_c_top,Y_r_bottom,Y_c_bottom
    );
    
    input clk,reset;
    input signed  [N-1:0] A_r,A_c,B_r,B_c,W_r,W_c;
    output signed [N-1:0] Y_r_top,Y_c_top,Y_r_bottom,Y_c_bottom;
    
    wire signed [N-1:0] Y_r_top,Y_c_top,Y_r_bottom,Y_c_bottom;
    
    reg signed [N-1:0] A_r_delayed_scaled,A_c_delayed_scaled;
    wire signed [N-1:0] Z_r,Z_c;
    
    always@(posedge clk) begin
        if(reset) begin
            A_r_delayed_scaled<= 0;
            A_c_delayed_scaled<= 0;
        end 
        
        else begin
            A_r_delayed_scaled<= A_r>>>1;
            A_c_delayed_scaled<= A_c>>>1;
        end
    end
    
    complex_mult #(.N(N)) M1
    ( 
        .clk(clk),
        .reset(reset),
        .B_r(B_r),
        .B_c(B_c),
        .W_r(W_r),
        .W_c(W_c), 
        .Z_r(Z_r),
        .Z_c(Z_c)
    );
    
    complex_add_sub #(.N(N)) A_top
    (
        .clk(clk),
        .reset(reset),
        .A_r(A_r_delayed_scaled),
        .A_c(A_c_delayed_scaled),
        .B_r(Z_r),
        .B_c(Z_c), 
        .Y_r(Y_r_top),
        .Y_c(Y_c_top),
        .Sub(1'b0)
    );
    
    complex_add_sub #(.N(N)) A_bottom
    (
        .clk(clk),
        .reset(reset),
        .A_r(A_r_delayed_scaled),
        .A_c(A_c_delayed_scaled),
        .B_r(Z_r),
        .B_c(Z_c), 
        .Y_r(Y_r_bottom),
        .Y_c(Y_c_bottom),
        .Sub(1'b1)
    );
           
endmodule
