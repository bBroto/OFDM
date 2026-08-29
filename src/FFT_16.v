`timescale 1ns / 1ps

module FFT_16 #(
    parameter N=32,
    parameter F=16)
(
    input clk, reset,
    input signed [31:0] X_r, X_c,
    output reg signed [31:0] Y_r, Y_c,
    output reg out_valid,
    
    // output control // Debug
    output reg [4:0] count, 
    output wire data_ready, 
    output wire data_ready_serial,
    output reg [3:0] out_count,
    output reg [3:0] valid_counter,
    
    output reg [N-1:0] output_bank_parallel_r [F-1:0],
    output reg [N-1:0] output_bank_parallel_c [F-1:0],
    output wire signed [N-1:0] stage_3_output_r [F-1:0],
    output wire signed [N-1:0] stage_3_output_c [F-1:0]
);
    
    
    
    // input fifo
    reg signed [N-1:0] input_bank_r [F-1:0];
    reg signed [N-1:0] input_bank_c [F-1:0];
    
    //inter stage wire
    wire signed [N-1:0] stage_0_input_r [F-1:0]; wire signed [N-1:0] stage_0_input_c [F-1:0];
    wire signed [N-1:0] stage_1_input_r [F-1:0]; wire signed [N-1:0] stage_1_input_c [F-1:0];
    wire signed [N-1:0] stage_2_input_r [F-1:0]; wire signed [N-1:0] stage_2_input_c [F-1:0];
    wire signed [N-1:0] stage_3_input_r [F-1:0]; wire signed [N-1:0] stage_3_input_c [F-1:0];

integer i;
   //serial parallel
    always @(posedge clk) begin
        if(reset) begin
            for(i=0; i<F; i=i+1) begin
                input_bank_r[i] <= 0;
                input_bank_c[i] <= 0;             
            end
        end else begin
            input_bank_r[F-1] <= X_r;
            input_bank_c[F-1] <= X_c;
            for (i=0; i<F-1; i=i+1) begin
                 input_bank_r[i] <= input_bank_r[i+1];
                 input_bank_c[i] <= input_bank_c[i+1];
            end
        end
    end
    
    //bit reversed routing
    assign stage_0_input_r[0] = input_bank_r[0];
	assign stage_0_input_c[0] = input_bank_c[0];
	
    assign stage_0_input_r[1] = input_bank_r[8]; 
	assign stage_0_input_c[1] = input_bank_c[8];
	
    assign stage_0_input_r[2] = input_bank_r[4];
	assign stage_0_input_c[2] = input_bank_c[4];
	
    assign stage_0_input_r[3] = input_bank_r[12];
	assign stage_0_input_c[3] = input_bank_c[12];
	
    assign stage_0_input_r[4] = input_bank_r[2]; 
	assign stage_0_input_c[4] = input_bank_c[2];
	
    assign stage_0_input_r[5] = input_bank_r[10];
	assign stage_0_input_c[5] = input_bank_c[10];
	
    assign stage_0_input_r[6] = input_bank_r[6];  
	assign stage_0_input_c[6] = input_bank_c[6];
	
    assign stage_0_input_r[7] = input_bank_r[14];
	assign stage_0_input_c[7] = input_bank_c[14];
	
    assign stage_0_input_r[8] = input_bank_r[1]; 
	assign stage_0_input_c[8] = input_bank_c[1];
	
    assign stage_0_input_r[9] = input_bank_r[9]; 
	assign stage_0_input_c[9] = input_bank_c[9];
	
    assign stage_0_input_r[10] = input_bank_r[5];
	assign stage_0_input_c[10]= input_bank_c[5];
	
    assign stage_0_input_r[11] = input_bank_r[13];
	assign stage_0_input_c[11]= input_bank_c[13];
	
    assign stage_0_input_r[12] = input_bank_r[3]; 
	assign stage_0_input_c[12]= input_bank_c[3];
	
    assign stage_0_input_r[13] = input_bank_r[11];
	assign stage_0_input_c[13]= input_bank_c[11];
	
    assign stage_0_input_r[14] = input_bank_r[7]; 
	assign stage_0_input_c[14]= input_bank_c[7];
	
    assign stage_0_input_r[15] = input_bank_r[15];
	assign stage_0_input_c[15]= input_bank_c[15];

  
    //stage 0
    genvar g0;
    generate
        for(g0=0; g0<8; g0=g0+1) begin : S0
            butterfly_trivial_unit #(.N(N)) B0 (
                .clk(clk),
                .reset(reset),
                .W(1'b1),
                .A_r(stage_0_input_r[2*g0]),
                .A_c(stage_0_input_c[2*g0]),
                .B_r(stage_0_input_r[2*g0+1]),
                .B_c(stage_0_input_c[2*g0+1]),
                .Y_r_top(stage_1_input_r[2*g0]),
                .Y_c_top(stage_1_input_c[2*g0]),
                .Y_r_bottom(stage_1_input_r[2*g0+1]),
                .Y_c_bottom(stage_1_input_c[2*g0+1])
            );
        end
    endgenerate

    //stage 1
    genvar g1;
    generate
        for(g1=0; g1<4; g1=g1+1) begin : S1
            butterfly_trivial_unit #(.N(N)) B1_0 (
                .clk(clk),
                .reset(reset),
                .W(1'b1),
                .A_r(stage_1_input_r[4*g1]),
                .A_c(stage_1_input_c[4*g1]),
                .B_r(stage_1_input_r[4*g1+2]),
                .B_c(stage_1_input_c[4*g1+2]),
                .Y_r_top(stage_2_input_r[4*g1]),
                .Y_c_top(stage_2_input_c[4*g1]),
                .Y_r_bottom(stage_2_input_r[4*g1+2]),
                .Y_c_bottom(stage_2_input_c[4*g1+2])
            );

            butterfly_trivial_unit #(.N(N)) B1_1 (
                .clk(clk),
                .reset(reset),
                .W(1'b0), // -j
                .A_r(stage_1_input_r[4*g1+1]),
                .A_c(stage_1_input_c[4*g1+1]),
                .B_r(stage_1_input_r[4*g1+3]),
                .B_c(stage_1_input_c[4*g1+3]),
                .Y_r_top(stage_2_input_r[4*g1+1]),
                .Y_c_top(stage_2_input_c[4*g1+1]),
                .Y_r_bottom(stage_2_input_r[4*g1+3]),
                .Y_c_bottom(stage_2_input_c[4*g1+3])
            );
        end
    endgenerate

    //stage 2
    genvar g2;
    generate
        for(g2=0; g2<2; g2=g2+1) begin : S2
            butterfly_trivial_unit #(.N(N)) B2_0 (
                .clk(clk),
                .reset(reset),
                .W(1'b1),
                .A_r(stage_2_input_r[8*g2]),
                .A_c(stage_2_input_c[8*g2]),
                .B_r(stage_2_input_r[8*g2+4]),
                .B_c(stage_2_input_c[8*g2+4]),
                .Y_r_top(stage_3_input_r[8*g2]),
                .Y_c_top(stage_3_input_c[8*g2]),
                .Y_r_bottom(stage_3_input_r[8*g2+4]),
                .Y_c_bottom(stage_3_input_c[8*g2+4])
            );

            butterfly_unit #(.N(N)) B2_1 ( // W_16^2
                .clk(clk),
                .reset(reset),
                .W_r(32'h5A82799A),
                .W_c(32'hA57D8666),
                .A_r(stage_2_input_r[8*g2+1]),
                .A_c(stage_2_input_c[8*g2+1]),
                .B_r(stage_2_input_r[8*g2+5]),
                .B_c(stage_2_input_c[8*g2+5]),
                .Y_r_top(stage_3_input_r[8*g2+1]),
                .Y_c_top(stage_3_input_c[8*g2+1]),
                .Y_r_bottom(stage_3_input_r[8*g2+5]),
                .Y_c_bottom(stage_3_input_c[8*g2+5])
            );

            butterfly_trivial_unit #(.N(N)) B2_2 (
                .clk(clk),
                .reset(reset),
                .W(1'b0), // -j
                .A_r(stage_2_input_r[8*g2+2]),
                .A_c(stage_2_input_c[8*g2+2]),
                .B_r(stage_2_input_r[8*g2+6]),
                .B_c(stage_2_input_c[8*g2+6]),
                .Y_r_top(stage_3_input_r[8*g2+2]),
                .Y_c_top(stage_3_input_c[8*g2+2]),
                .Y_r_bottom(stage_3_input_r[8*g2+6]),
                .Y_c_bottom(stage_3_input_c[8*g2+6])
            );

            butterfly_unit #(.N(N)) B2_3 ( // W_16^6
                .clk(clk),
                .reset(reset),
                .W_r(32'hA57D8666),
                .W_c(32'hA57D8666),
                .A_r(stage_2_input_r[8*g2+3]),
                .A_c(stage_2_input_c[8*g2+3]),
                .B_r(stage_2_input_r[8*g2+7]),
                .B_c(stage_2_input_c[8*g2+7]),
                .Y_r_top(stage_3_input_r[8*g2+3]),
                .Y_c_top(stage_3_input_c[8*g2+3]),
                .Y_r_bottom(stage_3_input_r[8*g2+7]),
                .Y_c_bottom(stage_3_input_c[8*g2+7])
            );
        end
    endgenerate

    //stage 3
    butterfly_trivial_unit #(.N(N)) B3_0 (
        .clk(clk),
        .reset(reset),
        .W(1'b1),
        .A_r(stage_3_input_r[0]),
        .A_c(stage_3_input_c[0]),
        .B_r(stage_3_input_r[8]),
        .B_c(stage_3_input_c[8]),
        .Y_r_top(stage_3_output_r[0]),
        .Y_c_top(stage_3_output_c[0]),
        .Y_r_bottom(stage_3_output_r[8]),
        .Y_c_bottom(stage_3_output_c[8])
    );

    butterfly_unit #(.N(N)) B3_1 ( // W_16^1
        .clk(clk),
        .reset(reset),
        .W_r(32'h7641AF3C),
        .W_c(32'hCF043AB3),
        .A_r(stage_3_input_r[1]),
        .A_c(stage_3_input_c[1]),
        .B_r(stage_3_input_r[9]),
        .B_c(stage_3_input_c[9]),
        .Y_r_top(stage_3_output_r[1]),
        .Y_c_top(stage_3_output_c[1]),
        .Y_r_bottom(stage_3_output_r[9]),
        .Y_c_bottom(stage_3_output_c[9])
    );

    butterfly_unit #(.N(N)) B3_2 ( // W_16^2
        .clk(clk),
        .reset(reset),
        .W_r(32'h5A82799A),
        .W_c(32'hA57D8666),
        .A_r(stage_3_input_r[2]),
        .A_c(stage_3_input_c[2]),
        .B_r(stage_3_input_r[10]),
        .B_c(stage_3_input_c[10]),
        .Y_r_top(stage_3_output_r[2]),
        .Y_c_top(stage_3_output_c[2]),
        .Y_r_bottom(stage_3_output_r[10]),
        .Y_c_bottom(stage_3_output_c[10])
    );

    butterfly_unit #(.N(N)) B3_3 ( // W_16^3
        .clk(clk),
        .reset(reset),
        .W_r(32'h30FBC54D),
        .W_c(32'h89BE50C4),
        .A_r(stage_3_input_r[3]),
        .A_c(stage_3_input_c[3]),
        .B_r(stage_3_input_r[11]),
        .B_c(stage_3_input_c[11]),
        .Y_r_top(stage_3_output_r[3]),
        .Y_c_top(stage_3_output_c[3]),
        .Y_r_bottom(stage_3_output_r[11]),
        .Y_c_bottom(stage_3_output_c[11])
    );

    butterfly_trivial_unit #(.N(N)) B3_4 (
        .clk(clk),
        .reset(reset),
        .W(1'b0), // -j
        .A_r(stage_3_input_r[4]),
        .A_c(stage_3_input_c[4]),
        .B_r(stage_3_input_r[12]),
        .B_c(stage_3_input_c[12]),
        .Y_r_top(stage_3_output_r[4]),
        .Y_c_top(stage_3_output_c[4]),
        .Y_r_bottom(stage_3_output_r[12]),
        .Y_c_bottom(stage_3_output_c[12])
    );

    butterfly_unit #(.N(N)) B3_5 ( // W_16^5
        .clk(clk),
        .reset(reset),
        .W_r(32'hCF043AB3),
        .W_c(32'h89BE50C4),
        .A_r(stage_3_input_r[5]),
        .A_c(stage_3_input_c[5]),
        .B_r(stage_3_input_r[13]),
        .B_c(stage_3_input_c[13]),
        .Y_r_top(stage_3_output_r[5]),
        .Y_c_top(stage_3_output_c[5]),
        .Y_r_bottom(stage_3_output_r[13]),
        .Y_c_bottom(stage_3_output_c[13])
    );

    butterfly_unit #(.N(N)) B3_6 ( // W_16^6
        .clk(clk),
        .reset(reset),
        .W_r(32'hA57D8666),
        .W_c(32'hA57D8666),
        .A_r(stage_3_input_r[6]),
        .A_c(stage_3_input_c[6]),
        .B_r(stage_3_input_r[14]),
        .B_c(stage_3_input_c[14]),
        .Y_r_top(stage_3_output_r[6]),
        .Y_c_top(stage_3_output_c[6]),
        .Y_r_bottom(stage_3_output_r[14]),
        .Y_c_bottom(stage_3_output_c[14])
    );

    butterfly_unit #(.N(N)) B3_7 ( // W_16^7
        .clk(clk),
        .reset(reset),
        .W_r(32'h89BE50C4),
        .W_c(32'hCF043AB3),
        .A_r(stage_3_input_r[7]),
        .A_c(stage_3_input_c[7]),
        .B_r(stage_3_input_r[15]),
        .B_c(stage_3_input_c[15]),
        .Y_r_top(stage_3_output_r[7]),
        .Y_c_top(stage_3_output_c[7]),
        .Y_r_bottom(stage_3_output_r[15]),
        .Y_c_bottom(stage_3_output_c[15])
    );

    //output
    always @(posedge clk) begin
        if(reset) begin
            for(i=0; i<F; i=i+1) begin
                output_bank_parallel_r[i] <= 0;
                output_bank_parallel_c[i] <= 0;       
            end
        end else if(data_ready) begin
            for(i=0; i<F; i=i+1) begin
                output_bank_parallel_r[i] <= stage_3_output_r[i];
                output_bank_parallel_c[i] <= stage_3_output_c[i];              
            end
        end
    end 
 
    //control 
    always @(posedge clk) begin
        if(reset) count <= 0;      
        else      count <= count + 1;               
    end 
    
    // latency 8 //2 per stage
    assign data_ready = (count == 5'd8) ? 1'b1 : 1'b0;         
    assign data_ready_serial = (count == 5'd9) ? 1'b1 : 1'b0;  
    
    always @(posedge clk) begin
        if (reset)          out_count <= 0;
        else if(data_ready) out_count <= 0; 
        else                out_count <= out_count + 1;       
    end

    //valid count
    always @(posedge clk) begin
        if (reset) begin
            out_valid <= 0;
            valid_counter <= 0;
        end else if (data_ready_serial) begin
            out_valid <= 1;
            valid_counter <= 0;
        end else if (out_valid) begin
            if (valid_counter == 15) begin
                out_valid <= 0; 
                valid_counter <= 0;
            end else begin
                valid_counter <= valid_counter + 1;
            end
        end
    end 
  
    // parallel to serial
    always @(posedge clk) begin
        if(reset) begin
            Y_r <= 0;
            Y_c <= 0;        
        end else begin               
            Y_r <= output_bank_parallel_r[out_count];
            Y_c <= output_bank_parallel_c[out_count];             
        end  
    end 
    
endmodule
