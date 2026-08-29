`timescale 1ns / 1ps

module OFDM_TX_16 #(
    parameter N = 32,
    parameter F = 16,
    parameter CP_LEN = 4
)(
    input clk,
    input reset,
    
    // input
    input [19:0] data_in,      // 10 data carrier * 2 bits per carrier 20 bits qam
    input start_tx,            //valid
    output reg ready_for_data, //ready
    
    // serial out
    output reg signed [N-1:0] ofdm_out_r,
    output reg signed [N-1:0] ofdm_out_c,
    output reg ofdm_valid
);

    // IFFT internal connect
    reg signed [N-1:0] ifft_in_r;
    reg signed [N-1:0] ifft_in_c;
    
    wire [4:0] ifft_count;
    wire ifft_data_ready;
    wire ifft_data_ready_serial;
    wire [3:0] ifft_out_count;
    wire [3:0] ifft_valid_counter;
    
    wire signed [N-1:0] ifft_parallel_r [F-1:0];
    wire signed [N-1:0] ifft_parallel_c [F-1:0];
    
    IFFT_16 #(.N(N), .F(F)) ifft_inst (
        .clk(clk),
        .reset(reset),
        .X_r(ifft_in_r),
        .X_c(ifft_in_c),        
        .Y_r(), 
        .Y_c(),
        .out_valid(),
        .count(ifft_count),
        .data_ready(ifft_data_ready),
        .data_ready_serial(ifft_data_ready_serial),
        .out_count(ifft_out_count),
        .valid_counter(ifft_valid_counter),
        .output_bank_parallel_r(ifft_parallel_r),
        .output_bank_parallel_c(ifft_parallel_c),
        .stage_3_output_r(),
        .stage_3_output_c()
    );

    // fsm reg
    reg [19:0] payload_reg;
    reg [4:0] load_count;
    reg [4:0] tx_count;
    
    localparam STATE_IDLE = 2'b00;
    localparam STATE_LOAD = 2'b01;
    localparam STATE_WAIT = 2'b10;
    localparam STATE_TX   = 2'b11;
    reg [1:0] state;

    // constants for  qam 
    localparam POS_VAL = 32'h5A82799A; // +0.707
    localparam NEG_VAL = 32'hA57D8666; // -0.707

    // bits to  qam map
    function signed [N-1:0] map_qam_r;
        input [1:0] bits;
        begin
            map_qam_r = (bits[1] == 1'b1) ? POS_VAL : NEG_VAL;
        end
    endfunction

    function signed [N-1:0] map_qam_c;
        input [1:0] bits;
        begin
            map_qam_c = (bits[0] == 1'b1) ? POS_VAL : NEG_VAL;
        end
    endfunction

   //fsm load
    always @(posedge clk) begin
        if (reset) begin
            state <= STATE_IDLE;
            ready_for_data <= 1'b1;
            load_count <= 0;
            ifft_in_r <= 0;
            ifft_in_c <= 0;
            payload_reg <= 0;
        end else begin
            case (state)
                STATE_IDLE: begin
                    if (start_tx) begin
                        payload_reg <= data_in;
                        ready_for_data <= 1'b0;
                        state <= STATE_LOAD;
                        load_count <= 0;
                    end
                end
                
                STATE_LOAD: begin
                    case (load_count)
                        5'd0:  begin 
                            ifft_in_r <= 0; ifft_in_c <= 0; //dc
                        end 
                        5'd1:  begin 
                            ifft_in_r <= map_qam_r(payload_reg[1:0]);  
                            ifft_in_c <= map_qam_c(payload_reg[1:0]);
                        end
                        5'd2:  begin 
                            ifft_in_r <= map_qam_r(payload_reg[3:2]);  
                            ifft_in_c <= map_qam_c(payload_reg[3:2]);
                        end
                        5'd3:  begin 
                            ifft_in_r <= map_qam_r(payload_reg[5:4]);  
                            ifft_in_c <= map_qam_c(payload_reg[5:4]);
                        end
                        5'd4:  begin 
                            ifft_in_r <= POS_VAL; ifft_in_c <= POS_VAL; // pilot 1 (+,+)
                        end 
                        5'd5:  begin
                            ifft_in_r <= map_qam_r(payload_reg[7:6]);  
                            ifft_in_c <= map_qam_c(payload_reg[7:6]);
                        end
                        5'd6:  begin 
                            ifft_in_r <= map_qam_r(payload_reg[9:8]);  
                            ifft_in_c <= map_qam_c(payload_reg[9:8]); 
                        end
                        5'd7:  begin
                            ifft_in_r <= 0; // gaurd
                            ifft_in_c <= 0;
                        end 
                        5'd8:  begin
                            ifft_in_r <= 0; // gaurd
                            ifft_in_c <= 0;
                        end 
                        5'd9:  begin 
                            ifft_in_r <= 0; // gaurd
                            ifft_in_c <= 0; 
                        end 
                        5'd10: begin
                            ifft_in_r <= map_qam_r(payload_reg[11:10]);
                            ifft_in_c <= map_qam_c(payload_reg[11:10]);
                        end
                        5'd11: begin
                            ifft_in_r <= map_qam_r(payload_reg[13:12]); 
                            ifft_in_c <= map_qam_c(payload_reg[13:12]);
                        end
                        5'd12: begin
                            ifft_in_r <= POS_VAL;  // Pilot 2 (+,-)
                            ifft_in_c <= NEG_VAL; 
                        end 
                        5'd13: begin
                            ifft_in_r <= map_qam_r(payload_reg[15:14]); 
                            ifft_in_c <= map_qam_c(payload_reg[15:14]); 
                        end
                        5'd14: begin 
                            ifft_in_r <= map_qam_r(payload_reg[17:16]);
                            ifft_in_c <= map_qam_c(payload_reg[17:16]);
                        end
                        5'd15: begin 
                            ifft_in_r <= map_qam_r(payload_reg[19:18]); 
                            ifft_in_c <= map_qam_c(payload_reg[19:18]);
                        end
                        default: begin 
                            ifft_in_r <= 0; ifft_in_c <= 0;     
                        end
                    endcase
                    
                    if (load_count == F - 1) begin
                        state <= STATE_WAIT;
                    end
                    load_count <= load_count + 1;
                end
                
                STATE_WAIT: begin
                    // wait for ifft 
                    if (ifft_data_ready) begin
                        state <= STATE_TX;
                    end
                end
                
                STATE_TX: begin
                    if (tx_count == (F + CP_LEN - 1)) begin
                        state <= STATE_IDLE;
                        ready_for_data <= 1'b1;
                    end
                end
            endcase
        end
    end

//piso 
    always @(posedge clk) begin
        if (reset) begin
            ofdm_out_r <= 0;
            ofdm_out_c <= 0;
            ofdm_valid <= 1'b0;
            tx_count <= 0;
        end else if (state == STATE_TX) begin
            ofdm_valid <= 1'b1;
            
            // add cp
            if (tx_count < CP_LEN) begin
                ofdm_out_r <= ifft_parallel_r[F - CP_LEN + tx_count];
                ofdm_out_c <= ifft_parallel_c[F - CP_LEN + tx_count];
            end else begin
                ofdm_out_r <= ifft_parallel_r[tx_count - CP_LEN];
                ofdm_out_c <= ifft_parallel_c[tx_count - CP_LEN];
            end
            
            tx_count <= tx_count + 1;
        end else begin
            ofdm_valid <= 1'b0;
            ofdm_out_r <= 0;
            ofdm_out_c <= 0;
            tx_count <= 0;
        end
    end

endmodule