`timescale 1ns/1ns

class ShiftRows;
    rand bit [7:0] shift_rows_in_matrix[4][4];
    bit [8*8*4 - 1 : 0] shift_rows_1d;
    task generator();
        for (int i=0; i<4; i++) begin
            for (int j=0; j<4; j++) begin
                shift_rows_in_matrix[i][j] = $random; 
            end
        end

         // Print matrix
        $display("Random matrix:");
        for (int i=0; i<4; i++) begin
            for (int j=0; j<4; j++) begin 
                $write("%2x ", shift_rows_in_matrix[i][j]);
            end
            $display("\n");
        end

        for(int p=0; p<4; p=p+1) begin
            for(int q=0; q<4; q=q+1) begin 
                shift_rows_1d[(p*4 + q)*8 +: 8] = shift_rows_in_matrix[p][q][7:0];
            end
        end
    endtask
endclass



module TB_shift_rows;

    logic [8*4*4 - 1:0] sr_in;
    logic [8*4*4 - 1:0] sr_out;
    logic inv_en;

    shift_rows sr_dut(.shift_rows_o(sr_out), .shift_rows_in(sr_in), .inv_en(inv_en));

    initial begin
        ShiftRows sr;
        sr = new();
        sr.generator();
        
        #5;
        sr_in = sr.shift_rows_1d;
        inv_en = 1'b0;
        #5;
        inv_en = 1'b1;
        #5;
        $finish();
    end

    initial begin
        $fsdbDumpfile("Shift_Rows.fsdb");
        $fsdbDumpvars;
        $fsdbDumpMDA();
    end
    
    
endmodule