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
    
    // wire [7:0] t = mix_col_in_2d[0] ^ mix_col_in_2d[1] ^ mix_col_in_2d[2] ^ mix_col_in_2d[3];
    wire [7:0] t = 
    wire [7:0] u = mix_col_in_2d[0];

    reg [7:0] x1_in, x2_in, x3_in, x4_in;
    wire [7:0] x1_out, x2_out, x3_out, x4_out;

    assign x1_in = xor1_out;
    assign x2_in = xor2_out;
    assign x3_in = xor3_out;
    assign x4_in = xor4_out;

    // TODO: Add two wire of xor1_in always block
    always @(*) begin
        // MixCol
        if(inv_en == 1'b0) begin
            // Generate inputs pass to Xtimes. 1~4
            xor_A1_in = mix_col_in_2d[0];
            xor_B1_in = mix_col_in_2d[1];
            xor_A2_in = mix_col_in_2d[1];
            xor_B2_in = mix_col_in_2d[2];
            xor_A3_in = mix_col_in_2d[2];
            xor_B3_in = mix_col_in_2d[3];
            xor_A4_in = mix_col_in_2d[3];
            xor_B4_in = u;
            // t 5~7
            xor_A5_in = mix_col_in_2d[0];
            xor_B5_in = mix_col_in_2d[1];
            xor_A6_in = xor5_out;
            xor_B6_in = mix_col_in_2d[2];
            xor_A7_in = xor6_out;
            xor_B7_in = mix_col_in_2d[3];
            // Final xor 8~15
            
        end
        // INV_Mixcol
        else begin
            xor_A1_in = ;
            xor_A2_in = ;
            xor_A3_in = ;
            xor_A4_in = ;
        end
    end

    // Xtime Structrue 
    xtime xtime1(x1_out, x1_in);
    xtime xtime2(x2_out, x2_in);
    xtime xtime3(x3_out, x3_in);
    xtime xtime4(x4_out, x4_in);

    // XOR input A
    reg [7:0] xor_A1_in, xor_A2_in, xor_A3_in, xor_A4_in, xor_A5_in, xor_A6_in,  
    xor_A7_in, xor_A8_in, xor_A9_in, xor_A10_in, xor_A11_in, xor_A12_in;
    // XOR input B
    reg [7:0] xor_B1_in, xor_B2_in, xor_B3_in, xor_B4_in, xor_B5_in, xor_B6_in,  
    xor_B7_in, xor_B8_in, xor_B9_in, xor_B10_in, xor_B11_in, xor_B12_in;

    // XOR output C
    wire [7:0] xor1_out, xor2_out, xor3_out, xor4_out, xor5_out, xor6_out,
    xor7_out, xor8_out, xor9_out, xor10_out, xor11_out, xor12_out;

    // XOR Structure
    // xor xor1( C, A, B );	C = A ^ B
    // 15 XOR gates

    // This four gates are for xtime func when Mixcol
    xor xor1(xor1_out, xor_A1_in, xor_B1_in);
    xor xor2(xor2_out, xor_A2_in, xor_B2_in);  
    xor xor3(xor3_out, xor_A3_in, xor_B3_in);
    xor xor4(xor4_out, xor_A4_in, xor_B4_in);
    // This two gates are for t.
    xor xor5(xor5_out, xor_A5_in, xor_B5_in);  
    xor xor6(xor6_out, xor_A6_in, xor_B6_in);
    xor xor7(xor7_out, xor_A7_in, xor_B7_in);
    // 
    xor xor8(xor8_out, xor_A8_in, xor_B8_in);
    xor xor9(xor9_out, xor_A9_in, xor_B9_in);  
    xor xor10(xor10_out, xor_A10_in, xor_B10_in);
    xor xor11(xor11_out, xor_A11_in, xor_B11_in);  
    xor xor12(xor12_out, xor_A12_in, xor_B12_in);
    xor xor13(xor13_out, xor_A13_in, xor_B13_in);
    xor xor14(xor14_out, xor_A14_in, xor_B14_in);
    xor xor15(xor15_out, xor_A15_in, xor_B15_in);

    assign mix_col_o[31:24] = mix_col_in_2d[0] ^ t ^ x1_out; 
    assign mix_col_o[23:16] = mix_col_in_2d[1] ^ t ^ x2_out;
    assign mix_col_o[15:8] = mix_col_in_2d[2] ^ t ^ x3_out;
    assign mix_col_o[7:0] = mix_col_in_2d[3] ^ t ^ x4_out;
    
endmodule