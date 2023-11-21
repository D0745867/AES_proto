`timescale 1ns/1ns

// Single round keygeneration
// Key_in only needed when first round
module key_expansion (
    output [ 4*4*8 - 1 : 0 ]round_key_o,
    input [2:0] current_state,
    input [ 4*4*8 - 1 : 0 ] key_in,
    input [3:0] round,
    input [3:0] cnt,
    input rst_n,
    input clk
);
localparam AddRoundKey = 3'd1;

// RC value
wire [7:0] rc_table [0:9]; 
assign rc_table[0] = 8'h01;
assign rc_table[1] = 8'h02;
assign rc_table[2] = 8'h04;
assign rc_table[3] = 8'h08;
assign rc_table[4] = 8'h10;
assign rc_table[5] = 8'h20;
assign rc_table[6] = 8'h40;
assign rc_table[7] = 8'h80;
assign rc_table[8] = 8'h1B;
assign rc_table[9] = 8'h36;

// Reuse SubBytes
wire [7:0] subBytes_o;
wire [7:0] subBytes_i;

// Counter should be counted in previous level
reg [31:0] w_matrix [0:3];
reg [7:0] w_rot [0:3];
reg [7:0] w_g_sub [0:3];
wire [7:0]w_g_temp[0:3];
// New Round Key
reg [31:0] w_matrix_cur [0:3];

assign subBytes_i = w_rot[cnt];
SubBytes dut_subBytes(.byte_o(subBytes_o), .byte_in(subBytes_i));

assign w_g_temp[0] = w_matrix[3][7:0];
assign w_g_temp[1] = w_matrix[3][15:8];
assign w_g_temp[2] = w_matrix[3][23:16];
assign w_g_temp[3] = w_matrix[3][31:24];

// Lest Shift - 1
always @(*) begin
    w_rot[0] = w_g_temp[3];
    w_rot[1] = w_g_temp[0];
    w_rot[2] = w_g_temp[1];
    w_rot[3] = w_g_temp[2];
end

// w XOR in the last step
always @(*) begin
    w_matrix_cur[0] = {w_g_sub[3], w_g_sub[2], w_g_sub[1], w_g_sub[0]} ^ w_matrix[0];
    w_matrix_cur[1] = w_matrix_cur[0] ^ w_matrix[1];
    w_matrix_cur[2] = w_matrix_cur[1] ^ w_matrix[2];
    w_matrix_cur[3] = w_matrix_cur[2] ^ w_matrix[3];
end

// w_matrix
always @(posedge clk or negedge rst_n) begin
    if( !rst_n ) begin
        // w_matrix[0] <= key_in[0:31];
        // w_matrix[1] <= key_in[32:63];
        // w_matrix[2] <= key_in[64:95];
        // w_matrix[3] <= key_in[96:127];

        w_matrix[0] <= key_in[127:96];
        w_matrix[1] <= key_in[95:64];
        w_matrix[2] <= key_in[63:32];
        w_matrix[3] <= key_in[31:0];
    end
    else begin
        if(current_state == AddRoundKey) begin
            // Write Back to the w_matrix (final XOR)
            if(cnt == 4'd5) begin
                w_matrix[0] <= w_matrix_cur[0];
                w_matrix[1] <= w_matrix_cur[1];
                w_matrix[2] <= w_matrix_cur[2];
                w_matrix[3] <= w_matrix_cur[3];
            end
        end
    end
end

// SubBytes and Rcon
always @(posedge clk or negedge rst_n) begin
    if ( !rst_n ) begin
        w_g_sub[0] <= 8'd0;
        w_g_sub[1] <= 8'd0;
        w_g_sub[2] <= 8'd0;
        w_g_sub[3] <= 8'd0;
    end
    else begin
        if(current_state == AddRoundKey) begin
            if(cnt >= 4'd0 && cnt <= 4'd3) begin
                w_g_sub[cnt] <= subBytes_o;
            end
            else if(cnt == 4'd4) begin
                w_g_sub[3] <= w_g_sub[3] ^ rc_table[round - 4'd1];
            end  
        end
    end
end

assign round_key_o = {w_matrix[3], w_matrix[2], w_matrix[1], w_matrix[0]};

endmodule