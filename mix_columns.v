`timescale 1ns/1ns

module xtime (
    output [7:0] xtime_o,
    input [7:0] xtime_i,
    input inv_en
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
    input [4*8 - 1 : 0] mix_col_in
);

    wire [7:0] mix_col_in_2d [0:3];

    // Matrix Convert
    assign mix_col_in_2d[3] = mix_col_in[7:0];
    assign mix_col_in_2d[2] = mix_col_in[15:8];
    assign mix_col_in_2d[1] = mix_col_in[23:16];
    assign mix_col_in_2d[0] = mix_col_in[31:24];
    
    wire [7:0] t = mix_col_in_2d[0] ^ mix_col_in_2d[1] ^ mix_col_in_2d[2] ^ mix_col_in_2d[3];
    wire [7:0] u = mix_col_in_2d[0];

    wire [7:0] x1_in, x2_in, x3_in, x4_in;
    wire [7:0] x1_out, x2_out, x3_out, x4_out;

    always @(*) begin
        if(inv_en) begin
            x1_in = ; 
            x2_in = ;
            x3_in = ;
            x4_in = ; 
        end
        else begin
            x1_in = ; 
            x2_in = ;
            x3_in = ;
            x4_in = ;
        end
    end

    // Xtime Structrue 
    xtime xtime1(x1_out, x1_in);
    xtime xtime2(x2_out, x2_in);
    xtime xtime3(x3_out, x3_in);
    xtime xtime4(x4_out, x4_in);
    

    assign mix_col_o[31:24] = mix_col_in_2d[0] ^ t ^ xtime(mix_col_in_2d[0] ^ mix_col_in_2d[1]); 
    assign mix_col_o[23:16] = mix_col_in_2d[1] ^ t ^ xtime(mix_col_in_2d[1] ^ mix_col_in_2d[2]);
    assign mix_col_o[15:8] = mix_col_in_2d[2] ^ t ^ xtime(mix_col_in_2d[2] ^ mix_col_in_2d[3]);
    assign mix_col_o[7:0] = mix_col_in_2d[3] ^ t ^ xtime(mix_col_in_2d[3] ^ u);
    
endmodule