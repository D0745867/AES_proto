`timescale 1ns/1ns

module shift_rows (
    output reg [4*4*8 - 1 : 0] shift_rows_o,
    input [4*4*8 - 1 : 0] shift_rows_in
    // input clk,
    // input rst_n
);

    reg [7:0] shift_rows_in_matrix [0:3][0:3];
    reg [7:0] shift_rows_o_matrix [0:3][0:3];
    int i, j, k;

    always @(*) begin
        int i;
        int j;
        for(i=0; i<4; i=i+1) begin
            for(j=0; j<4; j=j+1) begin
                shift_rows_in_matrix[i][j] = shift_rows_in[(i*4 + j)*8 +: 8];
            end 
        end
    end


    always@(*) begin
        shift_rows_o_matrix[0] = {shift_rows_in_matrix[0][0], shift_rows_in_matrix[0][1], shift_rows_in_matrix[0][2], shift_rows_in_matrix[0][3]};
        shift_rows_o_matrix[1] = {shift_rows_in_matrix[1][1], shift_rows_in_matrix[1][2], shift_rows_in_matrix[1][3], shift_rows_in_matrix[1][0]};
        shift_rows_o_matrix[2] = {shift_rows_in_matrix[2][2], shift_rows_in_matrix[2][3], shift_rows_in_matrix[2][0], shift_rows_in_matrix[2][1]};
        shift_rows_o_matrix[3] = {shift_rows_in_matrix[3][3], shift_rows_in_matrix[3][0], shift_rows_in_matrix[3][1], shift_rows_in_matrix[3][2]};
    end
    
    always @(*) begin

        int p;
        int q;

        for(p=0; p<4; p=p+1) begin
            for(q=0; q<4; q=q+1) begin 
                shift_rows_o[(p*4 + q)*8 +: 8] = shift_rows_o_matrix[p][q];
            end
        end
    end
    
endmodule