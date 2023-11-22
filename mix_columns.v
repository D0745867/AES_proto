`timescale 1ns/1ns

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

    //Mix One Column
    function [7:0] xtime;
    input [7:0] a;
    begin
        if (a[7] == 1'b1)  
        xtime = (a << 1) ^ 8'h1b;
        else
        xtime = a << 1;
    end
    endfunction

    wire [7:0] t = mix_col_in_2d[0] ^ mix_col_in_2d[1] ^ mix_col_in_2d[2] ^ mix_col_in_2d[3];
    wire [7:0] u = mix_col_in_2d[0];

    assign mix_col_o[31:24] = mix_col_in_2d[0] ^ t ^ xtime(mix_col_in_2d[0] ^ mix_col_in_2d[1]); 
    assign mix_col_o[23:16] = mix_col_in_2d[1] ^ t ^ xtime(mix_col_in_2d[1] ^ mix_col_in_2d[2]);
    assign mix_col_o[15:8] = mix_col_in_2d[2] ^ t ^ xtime(mix_col_in_2d[2] ^ mix_col_in_2d[3]);
    assign mix_col_o[7:0] = mix_col_in_2d[3] ^ t ^ xtime(mix_col_in_2d[3] ^ u);
    
endmodule