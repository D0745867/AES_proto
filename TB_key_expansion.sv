`timescale 1ns/1ns

interface key_expand;

    logic [ 4*4*8 ] round_key_o;
    logic [ 4*4*8 ] key_in;
    logic [3:0] round;
    logic [2:0] cnt;
    logic rst_n;
    logic clk;

    modport DRV (
        output key_in, round, cnt, rst_n, clk,
        input round_key_o
    );

endinterface //key_expand

class driver;
    virtual key_expand.DRV ke;
    int i, j;
    task run();
        // Setting Key
        // ke.key_in = { 8'h3C, 8'hA1, 8'h0B, 8'h21
        //             , 8'h57, 8'hF0, 8'h19, 8'h16
        //             , 8'h90, 8'h2E, 8'h13, 8'h80
        //             , 8'hAC, 8'hC1, 8'h07, 8'hBD };
        for (i=0 ; i < 11 ; i = i + 1) begin
            for (j = 0 ; j < 6; j = j + 1) begin
                ke.round <= #1 i;
                ke.cnt <=  #1 j;
                #10;
            end
            $display("%0h\n", ke.round_key_o);
        end
        $finish();
    endtask

endclass

module TB_key_expand;

    // 實例化一個interface
    key_expand ke();

    // 實例化一個driver
    driver drv;

    key_expansion ke_dut(ke.round_key_o, ke.key_in, ke.round, ke.cnt, ke.rst_n, ke.clk);

    event rst_n_reset;

    initial begin
        // Setting Key
        ke.key_in = { 8'h3C, 8'hA1, 8'h0B, 8'h21
                    , 8'h57, 8'hF0, 8'h19, 8'h16
                    , 8'h90, 8'h2E, 8'h13, 8'h80
                    , 8'hAC, 8'hC1, 8'h07, 8'hBD };
        // ke.key_in = { 8'hBD, 8'h07, 8'hC1, 8'hAC
        //     , 8'h80, 8'h13, 8'h2E, 8'h90
        //     , 8'h16, 8'h19, 8'hF0, 8'h57
        //     , 8'h21, 8'h0B, 8'hA1, 8'h3C };
    end

    initial begin
        ke.clk <= 0;
        ke.rst_n <= 1;
        #10;
        ke.rst_n <= 0;
        #10
        -> rst_n_reset;
        ke.rst_n <= 1;
    end

    always #5 ke.clk <= ~ke.clk;

    initial begin
        drv = new();
        drv.ke = ke;
        wait (rst_n_reset.triggered); 
        #5;
        drv.run();
    end

    initial begin
        $fsdbDumpfile("Key_expand.fsdb");
        $fsdbDumpvars;
        $fsdbDumpMDA();
    end
    
    
endmodule