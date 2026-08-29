`timescale 1ns / 1ps

module OFDM_RX_16 #(
    parameter N = 32,
    parameter F = 16,
    parameter CP_LEN = 4
)(
    input clk,
    input reset,
    
    //serial in
    input signed [N-1:0] ofdm_in_r,
    input signed [N-1:0] ofdm_in_c,
    input rx_valid, // high during 20 cycle
    
    // demod out
    output reg [19:0] data_out,
    output reg data_out_valid
);

    // state
    localparam STATE_IDLE     = 2'b00;
    localparam STATE_STRIP_CP = 2'b01;
    localparam STATE_LOAD_FFT = 2'b10;
    localparam STATE_WAIT_FFT = 2'b11;
    
    reg [1:0] state;
    reg [4:0] sample_count;
    
    // internal fft signal
    reg fft_reset_ctrl;
    wire fft_reset = reset | fft_reset_ctrl;
    reg signed [N-1:0] fft_in_r;
    reg signed [N-1:0] fft_in_c;
    
    wire fft_data_ready;
    wire signed [N-1:0] fft_parallel_r [F-1:0];
    wire signed [N-1:0] fft_parallel_c [F-1:0];

    // 16p fft
    FFT_16 #(.N(N), .F(F)) fft_inst (
        .clk(clk),
        .reset(fft_reset),
        .X_r(fft_in_r),
        .X_c(fft_in_c),
        .Y_r(), 
        .Y_c(),
        .out_valid(),
        .count(),
        .data_ready(fft_data_ready),
        .data_ready_serial(),
        .out_count(),
        .valid_counter(),
        .output_bank_parallel_r(fft_parallel_r),
        .output_bank_parallel_c(fft_parallel_c),
        .stage_3_output_r(),
        .stage_3_output_c()
    );

    // 4 qam
    function [1:0] demap_qam;
        input signed [N-1:0] sym_r;
        input signed [N-1:0] sym_c;
        begin
            demap_qam[1] = ~sym_r[N-1];
            demap_qam[0] = ~sym_c[N-1];
        end
    endfunction

    // control fsm
    always @(posedge clk) begin
        if (reset) begin
            state <= STATE_IDLE;
            sample_count <= 0;
            fft_reset_ctrl <= 1'b1; // reset and wait for data
            fft_in_r <= 0;
            fft_in_c <= 0;
            data_out <= 0;
            data_out_valid <= 1'b0;
        end else begin
            case (state)
                STATE_IDLE: begin
                    data_out_valid <= 1'b0;
                    fft_reset_ctrl <= 1'b1;
                    if (rx_valid) begin
                        state <= STATE_STRIP_CP;
                        sample_count <= 1; // cp cycle
                    end
                end
                
                STATE_STRIP_CP: begin
                    if (sample_count == CP_LEN - 1) begin
                        state <= STATE_LOAD_FFT;
                        sample_count <= 0;
                        fft_reset_ctrl <= 1'b0; //reset cleared
                    end else begin
                        sample_count <= sample_count + 1;
                    end
                end
                
                STATE_LOAD_FFT: begin
                    fft_in_r <= ofdm_in_r;
                    fft_in_c <= ofdm_in_c;
                    
                    if (sample_count == F - 1) begin
                        state <= STATE_WAIT_FFT;
                    end
                    sample_count <= sample_count + 1;
                end
                
                STATE_WAIT_FFT: begin
                    fft_in_r <= 0;
                    fft_in_c <= 0;
                    
                    if (fft_data_ready) begin
                        // map back to bits
                        data_out[1:0]   <= demap_qam(fft_parallel_r[1],  fft_parallel_c[1]);
                        data_out[3:2]   <= demap_qam(fft_parallel_r[2],  fft_parallel_c[2]);
                        data_out[5:4]   <= demap_qam(fft_parallel_r[3],  fft_parallel_c[3]);
                        data_out[7:6]   <= demap_qam(fft_parallel_r[5],  fft_parallel_c[5]);
                        data_out[9:8]   <= demap_qam(fft_parallel_r[6],  fft_parallel_c[6]);
                        data_out[11:10] <= demap_qam(fft_parallel_r[10], fft_parallel_c[10]);
                        data_out[13:12] <= demap_qam(fft_parallel_r[11], fft_parallel_c[11]);
                        data_out[15:14] <= demap_qam(fft_parallel_r[13], fft_parallel_c[13]);
                        data_out[17:16] <= demap_qam(fft_parallel_r[14], fft_parallel_c[14]);
                        data_out[19:18] <= demap_qam(fft_parallel_r[15], fft_parallel_c[15]);
                        
                        data_out_valid <= 1'b1;
                        fft_reset_ctrl <= 1'b1; // fft reset state to idle
                        state <= STATE_IDLE;
                    end
                end
            endcase
        end
    end

endmodule