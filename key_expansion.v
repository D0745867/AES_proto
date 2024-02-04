`timescale 1ns/1ns

module xor_32b (
    output [31:0] xor_32b_o , 
    input [31:0] xor_32b_inA,
    input [31:0] xor_32b_inB
);

    assign xor_32b_o = xor_32b_inA ^ xor_32b_inB;

endmodule

// Single round keygeneration
// Key_in only needed when first round
module key_expansion #(
    parameter KEY_WIDTH = 128) (
    output [ KEY_WIDTH - 1 : 0 ]round_key_o,
    input [3:0] current_state,
    input [ KEY_WIDTH - 1 : 0 ] key_in,
    input [3:0] round,
    input signed [4:0] cnt,
    input inv_en,
    input rst_n,
    input clk
);
localparam AddRoundKey = 4'd1;
localparam I_AddRoundKey = 4'd5;

// RC Table
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
wire [7:0]w_g_in[0:3]; 
// New Round Key
reg [31:0] w_matrix_cur [0:3];

assign subBytes_i = w_rot[cnt];
SubBytes dut_subBytes(.byte_o(subBytes_o), .byte_in(subBytes_i), .inv_en(1'b0));

// 4 XORs
reg [31:0]  xor_A4_in, xor_B4_in;
wire [31:0] xor_A1_in, xor_A2_in, xor_A3_in
         , xor_B1_in, xor_B2_in, xor_B3_in;
// XOR output C
wire [31:0] xor1_out, xor2_out, xor3_out, xor4_out;

// w_g_in signals are condition with mux 
// TODO: Decesie anothor condition results
// 應該是要把out拿出來
assign w_g_in[0] = (inv_en == 1'b0) ? w_matrix[3][7:0] : xor3_out[7:0];
assign w_g_in[1] = (inv_en == 1'b0) ? w_matrix[3][15:8] : xor3_out[15:8];
assign w_g_in[2] = (inv_en == 1'b0) ? w_matrix[3][23:16]: xor3_out[23:16];
assign w_g_in[3] = (inv_en == 1'b0) ? w_matrix[3][31:24]: xor3_out[31:24];

// w XOR in the last step
// w_matrix_cur is new key
always @(*) begin
    w_matrix_cur[0] = xor4_out;
    w_matrix_cur[1] = xor1_out;
    w_matrix_cur[2] = xor2_out;
    w_matrix_cur[3] = xor3_out;
end

// Regular Signal A 會變
assign xor_A1_in = (inv_en == 1'b0) ? w_matrix_cur[0] : w_matrix[0];
assign xor_A2_in = (inv_en == 1'b0) ? w_matrix_cur[1] : w_matrix[1];
assign xor_A3_in = (inv_en == 1'b0) ? w_matrix_cur[2] : w_matrix[2];
// Regular Signal B 固定
assign xor_B1_in = w_matrix[1];
assign xor_B2_in = w_matrix[2];
assign xor_B3_in = w_matrix[3];

// Chosen signal

// xor_A4_in
always @(*) begin
    if (inv_en == 1'b0) begin
        if(cnt <= 5'd4) begin
            xor_A4_in = {w_g_sub[3], 24'b0};
        end else begin
            xor_A4_in = w_matrix[0];
        end
    end
    // INV 1: W' 2: XOR
    else begin
        case (cnt)
        // Use 32bits xor
        5'd5: // Second
            xor_A4_in = w_matrix[0];
        default: // First
            xor_A4_in = {w_g_sub[3], 24'b0};
        endcase
    end
end

// xor_B4_in
always @(*) begin
    if (inv_en == 1'b0) begin
        if(cnt <= 5'd4) begin
            xor_B4_in = {rc_table[round - 4'd1], 24'b0};
        end else begin
            xor_B4_in = {w_g_sub[3], w_g_sub[2], w_g_sub[1], w_g_sub[0]};
        end
    end
    // INV
    else begin
        case (cnt)
        // Use 32bits xor
        5'd5: // Second
            xor_B4_in = {w_g_sub[3], w_g_sub[2], w_g_sub[1], w_g_sub[0]};
        default: // First
            xor_B4_in = {rc_table[round], 24'b0};
        endcase
    end
end

xor_32b xor1(xor1_out, xor_A1_in, xor_B1_in);
xor_32b xor2(xor2_out, xor_A2_in, xor_B2_in);
xor_32b xor3(xor3_out, xor_A3_in, xor_B3_in);
// Option 
xor_32b xor4(xor4_out, xor_A4_in, xor_B4_in);

// Lest Shift - 1
always @(*) begin
    w_rot[0] = w_g_in[3];
    w_rot[1] = w_g_in[0];
    w_rot[2] = w_g_in[1];
    w_rot[3] = w_g_in[2];
end


// w_matrix
always @(posedge clk or negedge rst_n) begin
    if( !rst_n ) begin
        w_matrix[0] <= key_in[127:96];
        w_matrix[1] <= key_in[95:64];
        w_matrix[2] <= key_in[63:32];
        w_matrix[3] <= key_in[31:0];
    end
    else begin
        if(current_state == AddRoundKey || current_state == I_AddRoundKey) begin
            // Write Back to the w_matrix (final XOR)
            if(cnt == 5'd5) begin
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
        if(current_state == AddRoundKey || current_state == I_AddRoundKey) begin
            if(cnt >= 5'd0 && cnt <= 5'd3) begin
                w_g_sub[cnt] <= subBytes_o;
            end
            else if(cnt == 5'd4) begin
                w_g_sub[3] <= xor4_out[31-:8];
            end  
        end
    end
end

assign round_key_o = {w_matrix[0], w_matrix[1], w_matrix[2], w_matrix[3]};

endmodule