`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.12.2025 07:46:23
// Design Name: 
// Module Name: complex_add_sub
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


module complex_add_sub #(parameter N=32)
 (
    clk,reset,A_r,A_c,B_r,B_c, Y_r,Y_c,Sub
 );
    input clk,reset;
    input Sub;   
    input signed [N-1:0] A_r,A_c,B_r,B_c;
    output signed [N-1:0] Y_r, Y_c;

    reg    signed [N-1:0] Y_r, Y_c;

    
    wire [N-1:0]temp_Y_r, temp_Y_c;
    
    assign temp_Y_r= Sub ? (A_r-B_r):(A_r+B_r);
    assign temp_Y_c= Sub ? (A_c-B_c):(A_c+B_c);
    
    always@(posedge clk)begin
        if(reset)begin
            Y_r <= 0;
            Y_c <= 0;              
        end
        
        else begin
            Y_r <= temp_Y_r;
            Y_c <= temp_Y_c;
        end   
    end
 
endmodule
