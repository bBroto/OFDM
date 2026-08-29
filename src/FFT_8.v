`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.12.2025 11:18:57
// Design Name: 
// Module Name: FFT_8
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


module FFT_8 #(
    parameter N=32,
    parameter F=8)
(
    clk,reset,X_r,X_c,Y_r,Y_c,out_valid,
      count,data_ready,data_ready_serial,out_count,valid_counter
    , output_bank_parallel_r ,
     output_bank_parallel_c ,
     stage_2_output_r,
     stage_2_output_c
    );
    
    input clk,reset;
    input signed [31:0] X_r,X_c;
    output signed [31:0] Y_r,Y_c;
    output reg out_valid;
    reg signed [31:0] Y_r,Y_c;
    
   //debug signals //output control 
    output reg [2:0]count; ///change these for difeerent N
    output wire data_ready; //control signal for parallel data latching
    output wire data_ready_serial; //control signal for serial conversion
    output reg [2:0]out_count;
    output reg [2:0] valid_counter;   
    
    reg signed [N-1:0] input_bank_r [F-1:0];
    reg signed [N-1:0] input_bank_c [F-1:0];
    
 
 //stage 0   
    wire signed [N-1:0] stage_0_input_r [F-1:0];
    wire signed [N-1:0] stage_0_input_c [F-1:0];
    
    
  //stage 1  
    wire signed [N-1:0] stage_1_input_r [F-1:0];
    wire signed [N-1:0] stage_1_input_c [F-1:0];
    
 //stage 2
    wire signed [N-1:0] stage_2_input_r [F-1:0];
    wire signed [N-1:0] stage_2_input_c [F-1:0];
    
    output   wire signed [N-1:0] stage_2_output_r [F-1:0];
    output   wire signed [N-1:0] stage_2_output_c [F-1:0];
  
  //output  debug
    output reg [N-1:0] output_bank_parallel_r [F-1:0];
    output reg [N-1:0] output_bank_parallel_c [F-1:0];
    
    
    ////////////////DATA PATH///////////////
    
   ///////////////////STAGE 0////////////////////
   
   butterfly_trivial_unit #(.N(N))
   B_0_0 (
        .clk(clk),
        .reset(reset),
        .A_r(stage_0_input_r [0]),
        .A_c(stage_0_input_c [0]),
        .B_r(stage_0_input_r [1]),
        .B_c(stage_0_input_c [1]),
        .W(1'b1),              // 1 for 1 and 0 for -j;          
        .Y_r_top(stage_1_input_r [0]),
        .Y_c_top(stage_1_input_c [0]),
        .Y_r_bottom(stage_1_input_r [1]),
        .Y_c_bottom(stage_1_input_c [1])
    );
    
     butterfly_trivial_unit #(.N(N))
   B_0_1 (
        .clk(clk),
        .reset(reset),
        .A_r(stage_0_input_r [2]),
        .A_c(stage_0_input_c [2]),
        .B_r(stage_0_input_r [3]),
        .B_c(stage_0_input_c [3]),
        .W(1'b1),              // 1 for 1 and 0 for -j; 
        .Y_r_top(stage_1_input_r [2]),
        .Y_c_top(stage_1_input_c [2]),
        .Y_r_bottom(stage_1_input_r [3]),
        .Y_c_bottom(stage_1_input_c [3])
    );  
    
     butterfly_trivial_unit #(.N(N))
   B_0_2 (
        .clk(clk),
        .reset(reset),
        .A_r(stage_0_input_r [4]),
        .A_c(stage_0_input_c [4]),
        .B_r(stage_0_input_r [5]),
        .B_c(stage_0_input_c [5]),
        .W(1'b1),               // 1 for 1 and 0 for -j; 
        .Y_r_top(stage_1_input_r [4]),
        .Y_c_top(stage_1_input_c [4]),
        .Y_r_bottom(stage_1_input_r [5]),
        .Y_c_bottom(stage_1_input_c [5])
    );
    
     butterfly_trivial_unit #(.N(N))
   B_0_3 (
        .clk(clk),
        .reset(reset),
        .A_r(stage_0_input_r [6]),
        .A_c(stage_0_input_c [6]),
        .B_r(stage_0_input_r [7]),
        .B_c(stage_0_input_c [7]),
        .W(1'b1),               // 1 for 1 and 0 for -j; 
        .Y_r_top(stage_1_input_r [6]),
        .Y_c_top(stage_1_input_c [6]),
        .Y_r_bottom(stage_1_input_r [7]),
        .Y_c_bottom(stage_1_input_c [7])
    );
    
    
 ///////////////////STAGE 1////////////////////
 
  butterfly_trivial_unit #(.N(N))
   B_1_0 (
        .clk(clk),
        .reset(reset),
        .A_r(stage_1_input_r [0]),
        .A_c(stage_1_input_c [0]),
        .B_r(stage_1_input_r [2]),
        .B_c(stage_1_input_c [2]),
        .W(1'b1),               // 1 for 1 and 0 for -j; 
        .Y_r_top(stage_2_input_r [0]),
        .Y_c_top(stage_2_input_c [0]),
        .Y_r_bottom(stage_2_input_r [2]),
        .Y_c_bottom(stage_2_input_c [2])
    );
    
     butterfly_trivial_unit #(.N(N))
   B_1_1 (
        .clk(clk),
        .reset(reset),
        .A_r(stage_1_input_r [1]),
        .A_c(stage_1_input_c [1]),
        .B_r(stage_1_input_r [3]),
        .B_c(stage_1_input_c [3]),
        .W(1'b0),               // 1 for 1 and 0 for -j; 
        .Y_r_top(stage_2_input_r [1]),
        .Y_c_top(stage_2_input_c [1]),
        .Y_r_bottom(stage_2_input_r [3]),
        .Y_c_bottom(stage_2_input_c [3])
    );  
    
     butterfly_trivial_unit #(.N(N))
   B_1_2 (
        .clk(clk),
        .reset(reset),
        .A_r(stage_1_input_r [4]),
        .A_c(stage_1_input_c [4]),
        .B_r(stage_1_input_r [6]),
        .B_c(stage_1_input_c [6]),
        .W(1'b1),               // 1 for 1 and 0 for -j; 
        .Y_r_top(stage_2_input_r [4]),
        .Y_c_top(stage_2_input_c [4]),
        .Y_r_bottom(stage_2_input_r [6]),
        .Y_c_bottom(stage_2_input_c [6])
    );
    
     butterfly_trivial_unit #(.N(N))
   B_1_3 (
        .clk(clk),
        .reset(reset),
        .A_r(stage_1_input_r [5]),
        .A_c(stage_1_input_c [5]),
        .B_r(stage_1_input_r [7]),
        .B_c(stage_1_input_c [7]),
        .W(1'b0),               // 1 for 1 and 0 for -j; 
        .Y_r_top(stage_2_input_r [5]),
        .Y_c_top(stage_2_input_c [5]),
        .Y_r_bottom(stage_2_input_r [7]),
        .Y_c_bottom(stage_2_input_c [7])
    );
    
 
    
     ///////////////////STAGE 2////////////////////
 
  butterfly_trivial_unit #(.N(N))
   B_2_0 (
        .clk(clk),
        .reset(reset),
        .A_r(stage_2_input_r [0]),
        .A_c(stage_2_input_c [0]),
        .B_r(stage_2_input_r [4]),
        .B_c(stage_2_input_c [4]),
        .W(1'b1),               // 1 for 1 and 0 for -j; 
        .Y_r_top(stage_2_output_r [0]),
        .Y_c_top(stage_2_output_c [0]),
        .Y_r_bottom(stage_2_output_r [4]),
        .Y_c_bottom(stage_2_output_c [4])
    );
    
     butterfly_unit #(.N(N))
   B_2_1 (
        .clk(clk),
        .reset(reset),
        .A_r(stage_2_input_r [1]),
        .A_c(stage_2_input_c [1]),
        .B_r(stage_2_input_r [5]),
        .B_c(stage_2_input_c [5]),
        .W_r(32'b01011010100000100111100110011010), 
        .W_c(32'b10100101011111011000011001100110),
        .Y_r_top(stage_2_output_r [1]),
        .Y_c_top(stage_2_output_c [1]),
        .Y_r_bottom(stage_2_output_r [5]),
        .Y_c_bottom(stage_2_output_c [5])
    );  
    
     butterfly_trivial_unit #(.N(N))
   B_2_2 (
        .clk(clk),
        .reset(reset),
        .A_r(stage_2_input_r [2]),
        .A_c(stage_2_input_c [2]),
        .B_r(stage_2_input_r [6]),
        .B_c(stage_2_input_c [6]),
        .W(1'b0),               // 1 for 1 and 0 for -j; 
        .Y_r_top(stage_2_output_r [2]),
        .Y_c_top(stage_2_output_c [2]),
        .Y_r_bottom(stage_2_output_r [6]),
        .Y_c_bottom(stage_2_output_c [6])
    );
    
     butterfly_unit #(.N(N))
   B_2_3 (
        .clk(clk),
        .reset(reset),
        .A_r(stage_2_input_r [3]),
        .A_c(stage_2_input_c [3]),
        .B_r(stage_2_input_r [7]),
        .B_c(stage_2_input_c [7]),
        .W_r(32'b10100101011111011000011001100110), 
        .W_c(32'b10100101011111011000011001100110), 
        .Y_r_top(stage_2_output_r [3]),
        .Y_c_top(stage_2_output_c [3]),
        .Y_r_bottom(stage_2_output_r [7]),
        .Y_c_bottom(stage_2_output_c [7])
    );
  /////////////////////input_fifo//////////////  
   integer i; 
    always@(posedge clk) begin
        if(reset) begin
            for(i=0;i<F;i=i+1)begin
                input_bank_r[i]<=0;
                input_bank_c[i]<=0;             
            end
        end
        
        else begin
            input_bank_r[F-1]<=X_r;
            input_bank_c[F-1]<=X_c;
            
            for (i = 0; i < F-1; i = i+1) begin
                 input_bank_r[i] <= input_bank_r[i+1];
                 input_bank_c[i] <= input_bank_c[i+1];
            end

        end
    end
    
///////////////////////comb_assign//////////////////////////    
assign stage_0_input_r[0] = input_bank_r[0]; // x[0]
assign stage_0_input_c[0] = input_bank_c[0];

assign stage_0_input_r[1] = input_bank_r[4]; // x[4]
assign stage_0_input_c[1] = input_bank_c[4];

assign stage_0_input_r[2] = input_bank_r[2]; // x[2]
assign stage_0_input_c[2] = input_bank_c[2];

assign stage_0_input_r[3] = input_bank_r[6]; // x[6]
assign stage_0_input_c[3] = input_bank_c[6];

assign stage_0_input_r[4] = input_bank_r[1]; // x[1]
assign stage_0_input_c[4] = input_bank_c[1];

assign stage_0_input_r[5] = input_bank_r[5]; // x[5]
assign stage_0_input_c[5] = input_bank_c[5];

assign stage_0_input_r[6] = input_bank_r[3]; // x[3]
assign stage_0_input_c[6] = input_bank_c[3];

assign stage_0_input_r[7] = input_bank_r[7]; // x[7]
assign stage_0_input_c[7] = input_bank_c[7];
 //////////////////////////////////////////////// 
 
   
 //////////////output buffered//////////////////  
  
    always@(posedge clk) begin
        if(reset) begin
            for(i=0;i<F;i=i+1)begin
                    output_bank_parallel_r[i]<=0;
                    output_bank_parallel_c[i]<=0;       
            end
        end
            
        else if(data_ready) begin
            for(i=0;i<F;i=i+1)begin
                output_bank_parallel_r[i]<=stage_2_output_r[i];
                output_bank_parallel_c[i]<=stage_2_output_c[i];              
            end
        end
       
        else begin         
            for(i=0;i<F;i=i+1)begin
                output_bank_parallel_r[i]<=output_bank_parallel_r[i];
                output_bank_parallel_c[i]<=output_bank_parallel_c[i];              
            end
        end  
    end 
 ////////////////////////////////////////////////////////////////////////////
 
 //////////////////////////////////control signa/////////////////////////////

    always@(posedge clk) begin
        if(reset) begin
            count<=0;
        end      
                  
        else begin 
            count<=count+1;               
        end
    end 
    
    assign data_ready= (count==3'b110) ? 1'b1:1'b0;         //change these for different no. of stages 
    assign data_ready_serial= (count==3'b111) ? 1'b1:1'b0;  //change these for different no. of stages 
    
    //////////////////////////////////////////////////////
    
     //out_count  
    always @(posedge clk) begin
    if (reset) out_count <= 0;
    else if    (data_ready) out_count<=0; 
    else       out_count<=out_count+1;       
    end
  ////////////////////////////////////////
  
  //output valid signal //review this later    
    // Logic to control how long valid stays high
    always @(posedge clk) begin
        if (reset) begin
            out_valid <= 0;
            valid_counter <= 0;
        end
        else if (data_ready_serial) begin
            out_valid <= 1;
            valid_counter <= 0;
        end
        else if (out_valid) begin
            if (valid_counter == 7) begin
                out_valid <= 0; // Turn off after 8 samples (0 to 7)
                valid_counter <= 0;
            end
            else begin
                valid_counter <= valid_counter + 1;
            end
        end
    end 
  
  
    ///////////////////output parallel to serial///////////
      
    always@(posedge clk) begin
        if(reset) begin
            for(i=0;i<F;i=i+1)begin
                    Y_r<=0;
                    Y_c<=0;        
            end
        end  
        
        else begin               
                Y_r<=output_bank_parallel_r[out_count];
                Y_c<=output_bank_parallel_c[out_count];             
        end  
    end 
    
    
endmodule
