`timescale 1ns/1ns

module xtime (
    output reg [7:0] xtime_o,
    input reg [7:0] xtime_i
);
    always @(*) begin
        if(xtime_i [7] == 1'b1) begin
            xtime_o = (xtime_i << 1) ^ 8'h1b;
        end
        else begin
            xtime_o = xtime_i << 1;
        end
    end
endmodule

module mix_columns (
    output [4*8 - 1 : 0] mix_col_o,
    input [4*8 - 1 : 0] mix_col_in,
    input inv_en
);

    reg [7:0] mix_col_in_2d [0:3];

    // Matrix Convert
    assign mix_col_in_2d[3] = mix_col_in[7:0];
    assign mix_col_in_2d[2] = mix_col_in[15:8];
    assign mix_col_in_2d[1] = mix_col_in[23:16];
    assign mix_col_in_2d[0] = mix_col_in[31:24];
    
    wire [7:0] t = mix_col_in_2d[0] ^ mix_col_in_2d[1] ^ mix_col_in_2d[2] ^ mix_col_in_2d[3];
    wire [7:0] u = mix_col_in_2d[0];

    reg [7:0] x1_in, x2_in, x3_in, x4_in;
    wire [7:0] x1_out, x2_out, x3_out, x4_out;

    always @(*) begin
        if(inv_en == 1'b0) begin
            x1_in = mix_col_in_2d[0] ^ mix_col_in_2d[1]; 
            x2_in = mix_col_in_2d[1] ^ mix_col_in_2d[2];
            x3_in = mix_col_in_2d[2] ^ mix_col_in_2d[3];
            x4_in = mix_col_in_2d[3] ^ u; 
        end
        // This is for inv_mode needs to be modified
        else begin
            x1_in = mix_col_in_2d[0] ^ mix_col_in_2d[1]; 
            x2_in = mix_col_in_2d[1] ^ mix_col_in_2d[2];
            x3_in = mix_col_in_2d[2] ^ mix_col_in_2d[3];
            x4_in = mix_col_in_2d[3] ^ u;
        end
    end

    // Xtime Structrue 
    xtime xtime1(x1_out, x1_in);
    xtime xtime2(x2_out, x2_in);
    xtime xtime3(x3_out, x3_in);
    xtime xtime4(x4_out, x4_in);

    assign mix_col_o[31:24] = mix_col_in_2d[0] ^ t ^ x1_out; 
    assign mix_col_o[23:16] = mix_col_in_2d[1] ^ t ^ x2_out;
    assign mix_col_o[15:8] = mix_col_in_2d[2] ^ t ^ x3_out;
    assign mix_col_o[7:0] = mix_col_in_2d[3] ^ t ^ x4_out;
    
endmodule