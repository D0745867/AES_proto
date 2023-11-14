`timescale 1ns/1ns


// TODO: Add bits lenth.
module AES_128 (
    output ciphertext,
    input [ 4*4*8 - 1 : 0 ] plaintext,
    input [ 0 : 4*4*8 - 1 ]master_key,
    input clk,
    input rst_n
);

reg [2:0] current_state;
reg [2:0] next_state;

localparam IDLE = 3'd0;
localparam AddRoundKey = 3'd1;
localparam SubBytes = 3'd2;
localparam ShiftRows = 3'd3;
localparam MixColumns = 3'd4;

reg [ 4*4*8 - 1 : 0 ] state;
reg [3:0] round;
reg [ 4*4*8 - 1 : 0 ] round_key_o;
reg [3:0] cnt;

// wire [ 4*4*8 - 1 : 0 ] add_rk_o;

// assign add_rk_o = state ^ round_key_o;
// Key Expansion
key_expansion ke_dut(.round_key_o(round_key_o), .key_in(master_key), .round(round), .cnt(cnt), .rst_n(rst_n), .clk(clk));
// SubBytes input: 8bits, output: 8bits
wire [7:0] subBytes_i;
wire [7:0] subBytes_o;

// Select part to replace with subBytes
assign subBytes_i = state[ (cnt + 1)* 7 +:8 ];

SubBytes dut_subBytes(.byte_o(subBytes_o), .byte_in(subBytes_i));

// Shift Rows
wire [ 4*4*8 - 1 : 0] sr_out;
wire [ 4*4*8 - 1 : 0] sr_in;

assign sr_in = state;
shift_rows sr_dut(.shift_rows_o(sr_out), .shift_rows_in(sr_in));

// Mix Columns
wire [ 4*8 -1 : 0] mc_out;
wire [ 4*8 -1 : 0] mc_in;

assign mc_in = state[(128 - 32 * cnt) - 1 +: 32]; 
mix_columns mc_dut(.mix_col_o(mc_out), .mix_col_in(mc_in));

// FSM next
always @(*) begin
    case (current_state)
        IDLE : next_state = AddRoundKey;
        AddRoundKey: begin
            if (cnt == 4'd6) begin
                if (round != 4'd11) next_state = SubBytes;
                else next_state = IDLE; 
            end
            else begin
                next_state = AddRoundKey;
            end
        end
        SubBytes: begin
            if (cnt == 4'd15) begin
                next_state = ShiftRows;
            end
            else begin
                next_state = SubBytes;
            end
        end
        ShiftRows: begin
            if (round != 4'd11) next_state = MixColumns;
            else next_state = AddRoundKey;
        end
        MixColumns: begin
            if (cnt != 4'd3) next_state = MixColumns;  
            else next_state = AddRoundKey;
        end
        default: next_state = IDLE; 
    endcase
end

// FSM current
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        current_state <= IDLE;
    end
    else begin
        current_state <= next_state;
    end
end

// Round Counter
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        round <= 4'd0;
    end
    else begin
        if(current_state == AddRoundKey) begin
            round <= round + 4'd1;
        end
    end
end

// State Matrix
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        state <= plaintext;
    end
    else begin
        case (current_state)
            AddRoundKey : begin
                if(cnt == 4'd6) begin
                    state <= state ^ round_key_o;
                end
            end 
            SubBytes : begin
                state[ (cnt + 1)* 7 +:8 ] <= subBytes_o;
            end
            ShiftRows : begin
                state <= sr_out;
            end
            MixColumns: begin
                state[(128 - 32 * cnt) - 1 +: 32] <= mc_out;
            end
            default: begin
                state <= state;
            end
        endcase
    end
end

// TODO: cnt

endmodule