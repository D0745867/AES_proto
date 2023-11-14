`timescale 1ns/1ns

class MixCols;
    bit [8*4 - 1 : 0] mix_col_1d;
    task generator();
        mix_col_1d = {8'd143, 8'd199, 8'd227, 8'd241};
    endtask
endclass



module TB_mix_cols;

    logic [8*4 - 1:0] mc_in;
    logic [8*4 - 1:0] mc_out;

    logic [7:0] i1;
    logic [7:0] i2;
    logic [7:0] i3;
    logic [7:0] i4;

    logic [7:0] A1;
    logic [7:0] A2;
    logic [7:0] A3;
    logic [7:0] A4;

    mix_columns mc_dut(.mix_col_o(mc_out), .mix_col_in(mc_in));

    initial begin
        MixCols mc;
        mc = new();
        mc.generator();
        mc_in = mc.mix_col_1d;
        #5;
        i4 = mc_in[31:24];
        i3 = mc_in[23:16];
        i2 = mc_in[15:8];
        i1 = mc_in[7:0];
        A4 = mc_out[31:24];
        A3 = mc_out[23:16];
        A2 = mc_out[15:8];
        A1 = mc_out[7:0];
        #5;
        $finish();
    end

    initial begin
        $fsdbDumpfile("Mix_Cols.fsdb");
        $fsdbDumpvars;
        $fsdbDumpMDA();
    end
    
    
endmodule