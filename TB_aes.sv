`timescale 1ns/1ns

interface aes_inter;

    logic [ 4*4*8 - 1 : 0 ] ciphertext;
    logic done;
    logic [ 4*4*8 - 1 : 0 ] plaintext;
    logic [ 0 : 4*4*8 - 1 ] master_key;
    logic clk;
    logic rst_n;
    logic inv_en;

    // output 是輸出給DUT
    modport DRV (
        output plaintext, master_key, clk, rst_n, inv_en,
        input ciphertext, done
    );

endinterface //aes_inter

// 這邊只要處理plaintext輸入 & Master Key
class driver;
    virtual aes_inter.DRV aes;
    int i, j;
    task run();
        wait(aes.done == 1);
        #10;
        $finish();
    endtask

endclass

module TB_aes;

    // New aes
    aes_inter aes();

    // 實例化一個driver
    driver drv;
    

    AES_128 aes_dut(aes.ciphertext, aes.done, aes.plaintext
    , aes.master_key, aes.clk, aes.rst_n, aes.inv_en);

    event rst_n_reset;

    initial begin
        `ifdef ENC
        // Setting Master Key for enc mode
        aes.master_key =  128'h2B7E151628AED2A6ABF7158809CF4F3C;
        // Setting plaintext
        aes.plaintext = 128'h3243F6A8885A308D313198A2E0370734;
        $display("Start AES-128 Encryption!");

        `else
        // Setting Master Key for dec mode
        aes.master_key =  128'h2B7E151628AED2A6ABF7158809CF4F3C;
        // Setting ciphertext
        aes.plaintext = 128'h3925841d02dc09fbdc118597196a0b32;
        $display("Start AES-128 Decryptionz!");
        `endif 
    end

    initial begin
        `ifdef ENC
        aes.inv_en <= 1;
        `else
        aes.inv_en <= 0;
        `endif
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