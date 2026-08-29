`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.12.2025 19:00:10
// Design Name: 
// Module Name: complex_mult
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


module complex_mult #(parameter N=32)
(
    clk,reset,B_r,B_c,W_r,W_c, Z_r,Z_c
 );
    input clk,reset;     
    input signed [N-1:0] B_r,B_c,W_r,W_c;
    output signed [N-1:0]  Z_r,Z_c;   //output width must be explicitely mentioned otherwise infers 1
    
    reg signed [N-1:0] Z_r,Z_c;
    wire signed [2*N-1:0]temp_Z_r, temp_Z_c;
    
    assign temp_Z_r= B_r*W_r - B_c*W_c;
    assign temp_Z_c= B_r*W_c + B_c*W_r;
    
    always@(posedge clk)begin
        if(reset)begin
            Z_r <= 0;
            Z_c <= 0;              
        end
        
        else begin
            Z_r <= temp_Z_r[2*N-1:N];
            Z_c <= temp_Z_c[2*N-1:N];
        end   
    end
 
endmodule
