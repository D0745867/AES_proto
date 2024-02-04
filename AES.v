`timescale 1ns/1ns


module AES_128 (
    output[ 4*4*8 - 1 : 0 ] output_text,
    output[ 4*4*8 - 1 : 0 ] master_key_out,
    output done,
    input [ 4*4*8 - 1 : 0 ] input_text,
    input [ 4*4*8 - 1 : 0 ] master_key,
    input clk,
    input rst_n,
    input inv_en
);


reg [3:0] current_state;
reg [3:0] next_state;

localparam IDLE = 4'd0;
localparam AddRoundKey = 4'd1;
localparam SubBytes = 4'd2;
localparam ShiftRows = 4'd3;
localparam MixColumns = 4'd4;
localparam I_AddRoundKey = 4'd5;
localparam I_SubBytes = 4'd6;
localparam I_ShiftRows = 4'd7;
localparam I_MixColumns = 4'd8;
localparam DONE = 4'd9;

wire mode_switch = (current_state > 4) ? 1'b1 : 1'b0;

assign done = (current_state == DONE) ? 1'b1 : 1'b0;

reg [ 4*4*8 - 1 : 0 ] state;
reg [3:0] round;
reg [ 4*4*8 - 1 : 0 ] round_key_o;
reg signed [4:0] cnt;
assign master_key_out = round_key_o;
assign output_text = state;
// wire [ 4*4*8 - 1 : 0 ] add_rk_o;

// assign add_rk_o = state ^ round_key_o;
// Key Expansion
key_expansion ke_dut(.round_key_o(round_key_o), .current_state(current_state)
, .key_in(master_key), .round(round), .cnt(cnt)
, .rst_n(rst_n), .clk(clk), .inv_en(mode_switch));

// SubBytes input: 8bits, output: 8bits
wire [7:0] subBytes_i;
wire [7:0] subBytes_o;

// Select part to replace with subBytes
assign subBytes_i = state[ ((cnt + 1)* 8 - 1) -:8 ];
// assign subBytes_i = state[ 7:0 ];


SubBytes dut_subBytes(.byte_o(subBytes_o), .byte_in(subBytes_i), .inv_en(mode_switch));

// Shift Rows
wire [ 4*4*8 - 1 : 0] sr_out;
wire [ 4*4*8 - 1 : 0] sr_in;

assign sr_in = state;
shift_rows sr_dut(.shift_rows_o(sr_out), .shift_rows_in(sr_in), .inv_en(mode_switch));

// Mix Columns
wire [ 4*8 -1 : 0] mc_out;
wire [ 4*8 -1 : 0] mc_in;

assign mc_in = (cnt <= 4'd3) ? state[(127 - (32 * cnt))  -: 32] : 32'd0; 
mix_columns mc_dut(.mix_col_o(mc_out), .mix_col_in(mc_in), .inv_en(mode_switch));

// FSM next state
always @(*) begin
    case (current_state)
        IDLE : begin
            if (inv_en == 1'b0) begin
                next_state = AddRoundKey;
            end
            else begin
                next_state = I_AddRoundKey;
            end
        end 
        AddRoundKey: begin
            if (round == 4'd0) begin
                next_state = SubBytes;
            end
            else begin
                if (cnt == 5'd6) begin
                    if (round != 4'd10) next_state = SubBytes;
                    else next_state = DONE; 
                end
                else begin
                    next_state = AddRoundKey;
                end
            end
        end
        SubBytes: begin
            if (cnt == 5'd15) begin
                next_state = ShiftRows;
            end
            else begin
                next_state = SubBytes;
            end
        end
        ShiftRows: begin
            if (round != 4'd10) next_state = MixColumns;
            else next_state = AddRoundKey;
        end
        MixColumns: begin
            if (cnt != 5'd3) next_state = MixColumns;  
            else begin
                if (inv_en == 1'b0) begin
                    next_state = AddRoundKey;
                end else begin
                    next_state = I_ShiftRows;
                end
            end 
        end
        DONE: begin
            next_state = IDLE;
        end
        //=========== Inverse Version ============
        I_AddRoundKey: begin
            if (cnt <  $signed(5'd6)) begin
                case (round)
                    4'd10: begin
                        next_state = I_ShiftRows;
                    end
                    default: begin
                        next_state = I_AddRoundKey;
                    end
                endcase
            end
            else begin
                case (round)
                    4'd0 : begin
                        next_state = DONE;
                    end 
                    default: begin
                        next_state = I_MixColumns;
                    end 
                endcase
            end
        end

        I_ShiftRows: begin
            next_state = I_SubBytes;
        end

        I_SubBytes: begin
            if (cnt < 5'd15) begin
                next_state = I_SubBytes;
            end
            else begin
                next_state = I_AddRoundKey;
            end
        end
         
        // Two step
        I_MixColumns: begin
            if (cnt < 5'd3) begin
                next_state = I_MixColumns;
            end
            else begin
                next_state = MixColumns;
            end
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

// State Matrix
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        state <= input_text;
    end
    else begin
        case (current_state)
            AddRoundKey, I_AddRoundKey : begin
                if(cnt == 5'd6) begin
                    state <= state ^ round_key_o;
                    if (inv_en == 1'b0) begin
                        #5 $display("%d %0h\n",round-1 , state);
                    end else begin
                        #5 $display("%d %0h\n",round+1 , state);
                    end
                end
                else begin
                    if((inv_en == 1'b0 && round == 4'd0) ||
                    (inv_en == 1'b1 && round == 4'd10)
                    ) begin
                        state <= state ^ round_key_o;
                    end
                end
            end 
            SubBytes, I_SubBytes : begin
                state[ ((cnt + 1)* 8 - 1) -:8 ] <= subBytes_o;
            end
            ShiftRows, I_ShiftRows : begin
                state <= sr_out;
            end
            MixColumns, I_MixColumns: begin
                state[(128 - 32 * cnt) - 1 -: 32] <= mc_out;
            end
            default: begin
                state <= state;
            end
        endcase
    end
end

// Counter
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        cnt <= 4'd0;
    end
    else begin
        if(current_state == AddRoundKey 
        || current_state == SubBytes 
        || current_state == MixColumns
        || current_state == I_AddRoundKey
        || current_state == I_SubBytes
        || current_state == I_MixColumns
        ) begin
            if( next_state != current_state) begin
                if (next_state == I_AddRoundKey) begin
                    cnt <= - 5'd1;
                end else begin
                    cnt <= 5'd0;
                end
            end
            else begin
                cnt <= cnt + 4'd1;
            end
        end
    end
end

// Round Counter
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        if(inv_en == 1'b0) begin
            round <= 4'd0;
        end
        else begin
            round <= 4'd10;
        end
    end
    else begin
        if(inv_en == 1'b0) begin
            if(current_state == AddRoundKey && next_state != AddRoundKey ) begin
                round <= round + 4'd1;
            end
            else if (round == 4'd0 && current_state == AddRoundKey) begin
                round <= round + 4'd1;
            end
        end
        else begin
            if(current_state == I_SubBytes && next_state != I_SubBytes) begin
                round <= round - 4'd1;
            end
        end
    end
end


endmodule