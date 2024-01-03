`timescale 1ns/1ns

module xtime (
    output reg [7:0] xtime_o,
    input [7:0] xtime_i
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

module xor_8b (
    output [7:0] xor_8b_o , 
    input [7:0] xor_8b_inA,
    input [7:0] xor_8b_inB
);

    assign xor_8b_o = xor_8b_inA ^ xor_8b_inB;

endmodule

module mix_columns (
    output [4*8 - 1 : 0] mix_col_o,
    input [4*8 - 1 : 0] mix_col_in,
    input inv_en
);

    wire [7:0] mix_col_in_2d [0:3];

    // XOR input A
    reg [7:0] xor_A1_in, xor_A2_in, xor_A3_in, xor_A4_in, xor_A5_in, xor_A6_in,  
    xor_A7_in, xor_A8_in, xor_A9_in, xor_A10_in, xor_A11_in, xor_A12_in, xor_A13_in, xor_A14_in, xor_A15_in;

    // XOR input B
    reg [7:0] xor_B1_in, xor_B2_in, xor_B3_in, xor_B4_in, xor_B5_in, xor_B6_in,  
    xor_B7_in, xor_B8_in, xor_B9_in, xor_B10_in, xor_B11_in, xor_B12_in, xor_B13_in, xor_B14_in, xor_B15_in;

    // XOR output C
    wire [7:0] xor1_out, xor2_out, xor3_out, xor4_out, xor5_out, xor6_out,
    xor7_out, xor8_out, xor9_out, xor10_out, xor11_out, xor12_out, xor13_out, xor14_out, xor15_out;
    
    // Xtime I/O
    reg [7:0] x1_in, x2_in, x3_in, x4_in;
    wire [7:0] x1_out, x2_out, x3_out, x4_out;

    // Matrix Convert
    assign mix_col_in_2d[3] = mix_col_in[7:0];
    assign mix_col_in_2d[2] = mix_col_in[15:8];
    assign mix_col_in_2d[1] = mix_col_in[23:16];
    assign mix_col_in_2d[0] = mix_col_in[31:24];
    
    // wire [7:0] t = mix_col_in_2d[0] ^ mix_col_in_2d[1] ^ mix_col_in_2d[2] ^ mix_col_in_2d[3];
    wire [7:0] t = (inv_en == 1'b0) ? xor7_out : x4_out; // As known as v in Python
    wire [7:0] u = (inv_en == 1'b0) ? mix_col_in_2d[0] : x3_out;

    always @(*) begin
        if (inv_en == 1'b0) begin
            x1_in = xor1_out;
            x2_in = xor2_out;
            x3_in = xor3_out;
            x4_in = xor4_out;
        end
        else begin
            x1_in = xor1_out;
            x2_in = xor2_out;
            x3_in = x1_out;
            x4_in = x2_out;
        end
    end

    always @(*) begin
        // Single MixCol - 15 xor gates
        if (inv_en == 1'b0) begin
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

            // xor with xtime and t 8~11
            xor_A8_in = x1_out;
            xor_B8_in = t;
            xor_A9_in = x2_out;
            xor_B9_in = t;
            xor_A10_in = x3_out;
            xor_B10_in = t;
            xor_A11_in = x4_out;
            xor_B11_in = t;

            // xor 12~15
            xor_A12_in = xor8_out;
            xor_B12_in = mix_col_in_2d[0];
            xor_A13_in = xor9_out;
            xor_B13_in = mix_col_in_2d[1];
            xor_A14_in = xor10_out;
            xor_B14_in = mix_col_in_2d[2];
            xor_A15_in = xor11_out;
            xor_B15_in = mix_col_in_2d[3];
            
        end
        // Single INV_Mixcol - 6 xor gates
        else begin
            // First Two 1~2
            xor_A1_in = mix_col_in_2d[0];
            xor_B1_in = mix_col_in_2d[2];
            xor_A2_in = mix_col_in_2d[1];
            xor_B2_in = mix_col_in_2d[3];

            // Last Four 12~15
            xor_A12_in = mix_col_in_2d[0];
            xor_B12_in = u;
            xor_A13_in = mix_col_in_2d[1];
            xor_B13_in = t;
            xor_A14_in = mix_col_in_2d[2];
            xor_B14_in = u;
            xor_A15_in = mix_col_in_2d[3];
            xor_B15_in = t;

            // Useless
            xor_A3_in = 8'b0;
            xor_B3_in = 8'b0;
            xor_A4_in = 8'b0;
            xor_B4_in = 8'b0;
            xor_A5_in = 8'b0;
            xor_B5_in = 8'b0;
            xor_A6_in = 8'b0;
            xor_B6_in = 8'b0;
            xor_A7_in = 8'b0;
            xor_B7_in = 8'b0;
            xor_A8_in = 8'b0;
            xor_B8_in = 8'b0;
            xor_A9_in = 8'b0; 
            xor_B9_in = 8'b0;
            xor_A10_in = 8'b0;
            xor_B10_in = 8'b0;
            xor_A11_in = 8'b0;
            xor_B11_in = 8'b0;  
        end
    end

    // Xtime Structrue 
    xtime xtime1(x1_out, x1_in);
    xtime xtime2(x2_out, x2_in);
    xtime xtime3(x3_out, x3_in);
    xtime xtime4(x4_out, x4_in);

    // XOR Structure
    // xor xor1( C, A, B );	C = A ^ B
    // 15 XOR gates

    // This four gates are for xtime func when Mixcol
    xor_8b xor1(xor1_out, xor_A1_in, xor_B1_in);
    xor_8b xor2(xor2_out, xor_A2_in, xor_B2_in);
    xor_8b xor3(xor3_out, xor_A3_in, xor_B3_in);
    xor_8b xor4(xor4_out, xor_A4_in, xor_B4_in);
    
    // This two gates are for t.
    xor_8b xor5(xor5_out, xor_A5_in, xor_B5_in);
    xor_8b xor6(xor6_out, xor_A6_in, xor_B6_in);
    xor_8b xor7(xor7_out, xor_A7_in, xor_B7_in);
    xor_8b xor8(xor8_out, xor_A8_in, xor_B8_in);
    xor_8b xor9(xor9_out, xor_A9_in, xor_B9_in);
    xor_8b xor10(xor10_out, xor_A10_in, xor_B10_in);
    xor_8b xor11(xor11_out, xor_A11_in, xor_B11_in);
    xor_8b xor12(xor12_out, xor_A12_in, xor_B12_in);
    xor_8b xor13(xor13_out, xor_A13_in, xor_B13_in);
    xor_8b xor14(xor14_out, xor_A14_in, xor_B14_in);
    xor_8b xor15(xor15_out, xor_A15_in, xor_B15_in);

    assign mix_col_o[31:24] = xor12_out;
    assign mix_col_o[23:16] = xor13_out;
    assign mix_col_o[15:8] = xor14_out;
    assign mix_col_o[7:0] = xor15_out;
    
endmodule