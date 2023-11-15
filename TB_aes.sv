`timescale 1ns/1ns

interface aes_inter;

    logic [ 4*4*8 - 1 : 0 ] ciphertext,
    logic [ 4*4*8 - 1 : 0 ] plaintext,
    logic [ 0 : 4*4*8 - 1 ] master_key,
    logic rst_n;
    logic clk;

    // output 是輸出給DUT
    modport DRV (
        output plaintext, master_key, rst_n, clk,
        input ciphertext
    );

endinterface //aes_inter

// 這邊只要處理plaintext輸入 & Master Key
class AES;
    virtual aes_inter.DRV aes;
    int i, j;
    task run();
        // Setting aesy
        // aes.aesy_in = { 8'h3C, 8'hA1, 8'h0B, 8'h21
        //             , 8'h57, 8'hF0, 8'h19, 8'h16
        //             , 8'h90, 8'h2E, 8'h13, 8'h80
        //             , 8'hAC, 8'hC1, 8'h07, 8'hBD };
        for (i=0 ; i < 11 ; i = i + 1) begin
            for (j = 0 ; j < 6; j = j + 1) begin
                aes.round <= #1 i;
                aes.cnt <=  #1 j;
                #10;
            end
            $display("%0h\n", aes.round_aesy_o);
        end
        $finish();
    endtask

endclass

module TB_aes;

    // 實例化一個interface
    aes_inter aes();

    // 實例化一個driver
    driver drv;

    aes aes_dut(aes.round_aesy_o, aes.aesy_in, aes.round, aes.cnt, aes.rst_n, aes.clk);

    event rst_n_reset;

    initial begin
        // Setting aesy
        aes.aesy_in = { 8'h3C, 8'hA1, 8'h0B, 8'h21
                    , 8'h57, 8'hF0, 8'h19, 8'h16
                    , 8'h90, 8'h2E, 8'h13, 8'h80
                    , 8'hAC, 8'hC1, 8'h07, 8'hBD };
        // aes.aesy_in = { 8'hBD, 8'h07, 8'hC1, 8'hAC
        //     , 8'h80, 8'h13, 8'h2E, 8'h90
        //     , 8'h16, 8'h19, 8'hF0, 8'h57
        //     , 8'h21, 8'h0B, 8'hA1, 8'h3C };
    end

    initial begin
        aes.clk <= 0;
        aes.rst_n <= 1;
        #10;
        aes.rst_n <= 0;
        #10
        -> rst_n_reset;
        aes.rst_n <= 1;
    end

    always #5 aes.clk <= ~aes.clk;

    initial begin
        drv = new();
        drv.aes = aes;
        wait (rst_n_reset.triggered); 
        #5;
        drv.run();
    end

    initial begin
        $fsdbDumpfile("AES.fsdb");
        $fsdbDumpvars;
        $fsdbDumpMDA();
    end
    
    
endmodule