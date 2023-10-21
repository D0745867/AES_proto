`timescale 1ns/1ns

module SubBytes (
    output [7:0] byte_o,
    input [7:0] byte_in
);

    reg [7:0] data_A[0:7];
    reg [7:0] data_g2b[0:7];
    reg [7:0] data_b2g[0:7];

    // Data A matrix initial value
    assign data_A[0] = 8'b10001111;
    assign data_A[1] = 8'b11000111;
    assign data_A[2] = 8'b11100011;
    assign data_A[3] = 8'b11110001;
    assign data_A[4] = 8'b11111000;
    assign data_A[5] = 8'b01111100;
    assign data_A[6] = 8'b00111110;
    assign data_A[7] = 8'b00011111;

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

endmodule

//not tested yet
module G256_new_basis (
    input [7:0] x,      // 输入x，8位宽
    input [7:0] b,      // 输入b，8位宽
    output reg [7:0] y  // 输出y，8位宽
);
reg [7:0] g2b [0:7];
int i;

// 放錯了!
assign g2b[0] = 8'b00100001;
assign g2b[1] = 8'b11010011;
assign g2b[2] = 8'b10000001; 
assign g2b[3] = 8'b01001010;
assign g2b[4] = 8'b10001010;
assign g2b[5] = 8'b10111001;
assign g2b[6] = 8'b10110000;
assign g2b[7] = 8'b11111111;


always @(x, g2b) begin
    y = 8'b0; 
    for (i = 0; i < 8; i = i + 1) begin
        if (x & (1 << (7 - i))) begin
            y = y ^ g2b[i];
        end
    end
end
    
endmodule