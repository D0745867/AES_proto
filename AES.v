`timescale 1ns/1ns


// TODO: Add bits lenth.
module AES_128 (
    output ciphertext,
    input plaintext,
    input master_key,
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

reg [3:0] round;
reg [ 4*4*8 - 1 : 0 ]round_key_o;
reg [2:0] cnt,

// Key Expansion
key_expansion ke_dut(.round_key_o(round_key_o), .key_in(master_key), .round(round), .cnt(cnt), .rst_n(rst_n), .clk(clk));

// FSM next
always @(*) begin
    case (current_state)
        IDLE : next_state = AddRoundKey;
        AddRoundKey: begin
            if (round != 4'd11) next_state = SubBytes;
            else next_state = IDLE; 
        end
        SubBytes: begin
            next_state = ShiftRows;
        end
        ShiftRows: begin
            if (round != 4'd11) next_state = MixColumns;
            else next_state = AddRoundKey;
        end
        MixColumns: begin
            next_state = AddRoundKey;
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


    
endmodule