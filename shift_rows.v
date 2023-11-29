`timescale 1ns/1ns

module shift_rows (
    output reg [4*4*8 - 1 : 0] shift_rows_o,
    input [4*4*8 - 1 : 0] shift_rows_in
);

    reg [7:0] shift_rows_in_matrix [0:3][0:3];
    wire [7:0] shift_rows_o_matrix [0:3][0:3];
    integer i, j, k, p, q;

    always @(*) begin
        for(i=0; i<4; i=i+1) begin
            for(j=0; j<4; j=j+1) begin
                shift_rows_in_matrix[j][i] = shift_rows_in[(i*4 + j)*8 +: 8];
            end 
        end
    end

    // assign shift_rows_o_matrix[0] = {shift_rows_in_matrix[0][1], shift_rows_in_matrix[0][2], shift_rows_in_matrix[0][3], shift_rows_in_matrix[0][0]};
    // assign shift_rows_o_matrix[1] = {shift_rows_in_matrix[1][2], shift_rows_in_matrix[1][3], shift_rows_in_matrix[1][0], shift_rows_in_matrix[1][1]};
    // assign shift_rows_o_matrix[2] = {shift_rows_in_matrix[2][3], shift_rows_in_matrix[2][0], shift_rows_in_matrix[2][1], shift_rows_in_matrix[2][2]};
    // assign shift_rows_o_matrix[3] = {shift_rows_in_matrix[3][0], shift_rows_in_matrix[3][1], shift_rows_in_matrix[3][2], shift_rows_in_matrix[3][3]};
    assign shift_rows_o_matrix[0][0] = shift_rows_in_matrix[0][1];
    assign shift_rows_o_matrix[0][1] = shift_rows_in_matrix[0][2];
    assign shift_rows_o_matrix[0][2] = shift_rows_in_matrix[0][3];
    assign shift_rows_o_matrix[0][3] = shift_rows_in_matrix[0][0];

    assign shift_rows_o_matrix[1][0] = shift_rows_in_matrix[1][2];
    assign shift_rows_o_matrix[1][1] = shift_rows_in_matrix[1][3];
    assign shift_rows_o_matrix[1][2] = shift_rows_in_matrix[1][0]; 
    assign shift_rows_o_matrix[1][3] = shift_rows_in_matrix[1][1];

    assign shift_rows_o_matrix[2][0] = shift_rows_in_matrix[2][3]; 
    assign shift_rows_o_matrix[2][1] = shift_rows_in_matrix[2][0];
    assign shift_rows_o_matrix[2][2] = shift_rows_in_matrix[2][1]; 
    assign shift_rows_o_matrix[2][3] = shift_rows_in_matrix[2][2];

    assign shift_rows_o_matrix[3][0] = shift_rows_in_matrix[3][0];
    assign shift_rows_o_matrix[3][1] = shift_rows_in_matrix[3][1];
    assign shift_rows_o_matrix[3][2] = shift_rows_in_matrix[3][2];
    assign shift_rows_o_matrix[3][3] = shift_rows_in_matrix[3][3];

    always @(*) begin
        for(p=0; p<4; p=p+1) begin
            for(q=0; q<4; q=q+1) begin 
                shift_rows_o[(p*4 + q)*8 +: 8] = shift_rows_o_matrix[q][p];
            end
        end
    end
    
endmodule