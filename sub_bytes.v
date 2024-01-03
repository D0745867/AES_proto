`timescale 1ns/1ns

module SubBytes (
    output [7:0] byte_o,
    input [7:0] byte_in,
    input inv_en
);
    // Store default claulate elements
    wire [7:0] data_A[0:7];
    wire [7:0] data_IA[0:7];
    wire [7:0] data_g2b[0:7];
    wire [7:0] data_b2g[0:7];

    // Convert matrix dimention to pass it between module ports
    wire [8*8 - 1:0] data_A_1d = { data_A[0], data_A[1], data_A[2], data_A[3]
    , data_A[4], data_A[5], data_A[6], data_A[7]};

    wire [8*8 - 1:0] data_IA_1d = { data_IA[0], data_IA[1], data_IA[2], data_IA[3]
    , data_IA[4], data_IA[5], data_IA[6], data_IA[7]};

    wire [8*8 - 1:0] data_g2b_1d = { data_g2b[0], data_g2b[1], data_g2b[2], data_g2b[3]
    , data_g2b[4], data_g2b[5], data_g2b[6], data_g2b[7]};

    wire [8*8 - 1:0] data_b2g_1d = { data_b2g[0], data_b2g[1], data_b2g[2], data_b2g[3]
    , data_b2g[4], data_b2g[5], data_b2g[6], data_b2g[7]};

    // Data A matrix initial value
    assign data_A[0] = 8'b10001111;
    assign data_A[1] = 8'b11000111;
    assign data_A[2] = 8'b11100011;
    assign data_A[3] = 8'b11110001;
    assign data_A[4] = 8'b11111000;
    assign data_A[5] = 8'b01111100;
    assign data_A[6] = 8'b00111110;
    assign data_A[7] = 8'b00011111;

    // Data inv_A matrix initial value
    assign data_IA[0] = 8'b00100101;
    assign data_IA[1] = 8'b10010010;
    assign data_IA[2] = 8'b01001001;
    assign data_IA[3] = 8'b10100100;
    assign data_IA[4] = 8'b01010010;
    assign data_IA[5] = 8'b00101001;
    assign data_IA[6] = 8'b10010100;
    assign data_IA[7] = 8'b01001010;

    // Data g2b matrix initial value
    assign data_g2b[0] = 8'b10011000;
    assign data_g2b[1] = 8'b11110011;
    assign data_g2b[2] = 8'b11110010;
    assign data_g2b[3] = 8'b01001000;
    assign data_g2b[4] = 8'b00001001;
    assign data_g2b[5] = 8'b10000001;
    assign data_g2b[6] = 8'b10101001;
    assign data_g2b[7] = 8'b11111111;

    // Data b2g matrix initial value
    assign data_b2g[0] = 8'b01100100;
    assign data_b2g[1] = 8'b01111000;
    assign data_b2g[2] = 8'b01101110;
    assign data_b2g[3] = 8'b10001100;
    assign data_b2g[4] = 8'b01101000;
    assign data_b2g[5] = 8'b00101001;
    assign data_b2g[6] = 8'b11011110;
    assign data_b2g[7] = 8'b01100000;

    // Store
    reg [7:0] g2b, b2g, inv, inv_AT, inv_o, at_o;
    wire [7:0] inv_in;

    // inv_en -> 1'b1 Dec, 1'b0 Enc.
    // 1. Inv_Affine_Transform
    G256_new_basis dut_IAT (.g256_nb_o(inv_AT), .x(byte_in), .b(data_IA_1d));
    assign inv_in = (inv_en == 1'b1) ? inv_AT ^ 8'h05 : byte_in;

    // 2. Inverse_elements
    G256_new_basis dut_g2b (.g256_nb_o(g2b), .x(inv_in), .b(data_g2b_1d));
    G256_inv dut_inv(.g256_inv_o(inv), .x(g2b));
    G256_new_basis dut_b2g (.g256_nb_o(inv_o), .x(inv), .b(data_b2g_1d));

    // 3. Affine
    G256_new_basis dut_A (.g256_nb_o(at_o), .x(inv_o), .b(data_A_1d));
    assign byte_o = (inv_en == 1'b1) ? inv_o  : at_o ^ 8'h63;

endmodule

module G4_mul (
    output [1:0] g4mul_o,
    input [1:0] x,
    input [1:0] y
);

    // Filter high and low part
    wire a = x[1];
    wire b = x[0];
    wire c = y[1];
    wire d = y[0];
    wire e = (a^b) & (c ^ d);
    assign g4mul_o = (((a & c) ^ e) << 1) | ((b & d) ^ e) ;
    
        
endmodule

module G4_mul_N(
    output [1:0] g4mul_N_o,
    input [1:0] x
);

    wire a = x[1];
    wire b = x[0];
    wire p = b;
    wire q = a ^ b;
    assign g4mul_N_o = (p << 1) | q; 

endmodule

module  G4_mul_N2(
    output [1:0] g4mul_N2_o,
    input [1:0] x
);

    wire a = x[1];
    wire b = x[0];
    assign g4mul_N2_o =  ((a ^ b) << 1) | a;
    
endmodule

module G4_inv (
    output [1:0] g4_inv_o,
    input [1:0] x
);
    wire a = x[1];
    wire b = x[0];
    assign g4_inv_o = (b << 1) | a;
    
endmodule

module G16_mul (
    output [3:0] g16_mul_o,
    input [3:0] x,
    input [3:0] y
);
// TODO : Change to port name connect
    wire [1:0]a = x[3:2];
    wire [1:0]b = x[1:0];
    wire [1:0]c = y[3:2];
    wire [1:0]d = y[1:0];
    wire [1:0] e, et, p, q, pt, qt;
    G4_mul g4m1(et ,a^b , c^d);
    G4_mul_N g4mn(e, et);
    G4_mul g4m2(pt, a, c);
    assign p = pt ^ e;
    G4_mul g4m3(qt, b, d);
    assign q = qt ^ e;
    assign g16_mul_o = (p << 2) | q;
    
endmodule

// not tested yet
module G16_sq_mul_u(
    output [3:0] g16_mul_sq_u_o,
    input [3:0] x
);
    wire [1:0]a = x[3:2];
    wire [1:0]b = x[1:0];
    wire [1:0] p, q, qt;

    G4_inv g4inv1(.g4_inv_o(p), .x(a ^ b));
    G4_inv g4inv2(.g4_inv_o(qt), .x(b));
    G4_mul_N2 g4mulN2(.g4mul_N2_o(q), .x(qt));
    assign g16_mul_sq_u_o = (p << 2) | q;
endmodule

// not tested yet
module G16_inv (
    output [3:0] g16_inv_o,
    input [3:0] x
);
    wire [1:0]a = x[3:2];
    wire [1:0]b = x[1:0];
    wire [1:0] c, ct, d, e, p, q;
    G4_inv g4inv1(.g4_inv_o(ct), .x(a ^ b));
    G4_mul_N g4mn(.g4mul_N_o(c), .x(ct));
    G4_mul g4m1(.g4mul_o(d), .x(a), .y(b));
    G4_inv g4inv2(.g4_inv_o(e), .x(c ^ d));
    G4_mul g4m2(.g4mul_o(p), .x(e), .y(b));
    G4_mul g4m3(.g4mul_o(q), .x(e), .y(a));
    assign g16_inv_o = ( p << 2) | q;

endmodule

// not tested yet
module G256_inv (
    output [7:0] g256_inv_o,
    input [7:0] x
);
    wire [3:0] a = x[7:4];
    wire [3:0] b = x[3:0];
    wire [3:0] c, d, e, p, q; 
    G16_sq_mul_u g16sq(.g16_mul_sq_u_o(c), .x(a ^ b));
    G16_mul g16mul1 (.g16_mul_o(d), .x(a), .y(b));
    G16_inv g16inv (.g16_inv_o(e), .x(c ^ d));
    G16_mul g16mul2 (.g16_mul_o(p), .x(e), .y(b));
    G16_mul g16mul3 (.g16_mul_o(q), .x(e), .y(a));
    assign g256_inv_o = (p << 4) | q;
endmodule

// Test pass
module G256_new_basis (
    input [7:0] x,   
    input [8*8 - 1:0] b,      
    output reg [7:0] g256_nb_o 
);
wire [7:0] mat [0:7];
reg [3:0] i;

assign mat[0] = b[63:56];
assign mat[1] = b[55:48];
assign mat[2] = b[47:40];
assign mat[3] = b[39:32];
assign mat[4] = b[31:24];
assign mat[5] = b[23:16];
assign mat[6] = b[15:8];
assign mat[7] = b[7:0];


always @(*) begin
    g256_nb_o = 8'b0; 
    for (i = 0; i < 8; i = i + 1) begin
        if (x & (1 << (7 - i))) begin
            g256_nb_o = g256_nb_o ^ mat[i];
        end
    end
end
    
endmodule