`timescale 1ns/1ns

// Single round keygeneration
// Key_in only needed when first round
module key_expansion (
    output [ 4*4*8 ]round_key_o,
    input [ 4*4*8 ] key_in,
    input [3:0] round,
    input [2:0] cnt,
    input rst_n,
    input clk
);
// Counter should be counted in previous level

reg [31:0] w_matrix [0:4];



// Left Shift 1

always @() begin
    
end

// w_matrix
always @(posedge clk or negedge rst_n) begin
    if( !rst_n ) begin
        w_matrix[0] <= 32'd0;
        w_matrix[1] <= 32'd0;
        w_matrix[2] <= 32'd0;
        w_matrix[3] <= 32'd0;
    end
    else if begin
        if(round == 4'd0) begin
            w_matrix[0] <= key_in[31:0];
            w_matrix[1] <= key_in[63:32];
            w_matrix[3] <= key_in[95:64];
            w_matrix[4] <= key_in[127:96];
        end
        else begin
            case (cnt)
                3'd0 :  begin
                            
                        end
                3'd1 :
                3'd2 :
                default: 
            endcase
        end
    end
end

endmodule