`timescale 1ns/1ns

interface aes_inter;

    logic [ 4*4*8 - 1 : 0 ] ciphertext;
    logic done;
    logic [ 4*4*8 - 1 : 0 ] plaintext;
    logic [ 0 : 4*4*8 - 1 ] master_key;
    logic rst_n;
    logic clk;

    // output 是輸出給DUT
    modport DRV (
        output plaintext, master_key, rst_n, clk,
        input ciphertext, done
    );

endinterface //aes_inter

// 這邊只要處理plaintext輸入 & Master Key
class driver;
    virtual aes_inter.DRV aes;
    int i, j;
    task run();
        wait(aes.done == 1);
        $finish();
    endtask

endclass

module TB_aes;

    // New aes
    aes_inter aes();

    // 實例化一個driver
    driver drv;

    AES_128 aes_dut(aes.ciphertext, aes.done, aes.plaintext, aes.master_key, aes.clk, aes.rst_n);

    event rst_n_reset;

    initial begin
        // Setting Master Key
        aes.master_key = { 8'h3C, 8'hA1, 8'h0B, 8'h21
                    , 8'h57, 8'hF0, 8'h19, 8'h16
                    , 8'h90, 8'h2E, 8'h13, 8'h80
                    , 8'hAC, 8'hC1, 8'h07, 8'hBD };
        // Setting plaintext
        aes.plaintext = 128'hEA5BDD583B6BAFB11A80D2F481ADC4CE;
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