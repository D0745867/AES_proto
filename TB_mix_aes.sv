`timescale 1ns/1ns

interface aes_inter;

    logic [ 4*4*8 - 1 : 0 ] output_text;
    logic [ 4*4*8 - 1 : 0 ] master_key_out;
    logic done;
    logic [ 4*4*8 - 1 : 0 ] input_text;
    logic [ 0 : 4*4*8 - 1 ] master_key;
    logic clk;
    logic rst_n;
    logic inv_en;

    // output 是輸出給DUT
    modport DRV (
        output input_text, master_key, clk, rst_n, inv_en,
        input output_text , master_key_out ,done
    );

endinterface //aes_inter

// 這邊只要處理plaintext輸入 & Master Key
class driver;
    virtual aes_inter.DRV aes;
    event test_done;
    int i, j;
    rand bit [4*4*8 - 1 : 0] input_text;

    task init();
        if(aes.inv_en == 1'b0) begin
            // aes.input_text = input_text;
            aes.input_text =  input_text;
            aes.master_key = 128'h2B7E151628AED2A6ABF7158809CF4F3C;
            $display("\n=================Start AES-128 Encryption!=================\n");
            $display("The PlainText: %h\n", aes.input_text);
            $display("The MasterKey: %h\n", aes.master_key);
        end
        else begin
            $display("\n=================Start AES-128 Decryption!=================\n");
            $display("The CipherText: %h\n",aes.input_text);
            $display("The MasterKey: %h\n", aes.master_key);
        end


    endtask

    task run();
        wait(aes.done == 1);
        #10;
        if(aes.inv_en == 1'b0) begin
            $display("The CipherText: %h\n",aes.output_text);
        end else begin
            $display("The PlainText: %h\n",aes.output_text);
        end
        $display("The Final RoundKey: %h\n", aes.master_key_out);
        
        -> test_done;
    endtask

endclass

module TB_aes;

    // New aes
    aes_inter aes();

    // 實例化一個driver
    driver drv;
    logic [ 4*4*8 - 1 : 0 ] output_temp, master_key_temp;
    logic [ 4*4*8 - 1 : 0 ] plaintext_ans, plaintext_dec;
    int succeed = 0;
    int failed = 0;
    int test_num = 100;

    AES_128 aes_dut(aes.output_text, aes.master_key_out, aes.done, aes.input_text
    , aes.master_key, aes.clk, aes.rst_n, aes.inv_en);

    event rst_n_reset;
    
    task rst();
        // ENC
        aes.inv_en <= 0;
        aes.clk <= 0;
        aes.rst_n <= 1;
        #10;
        aes.rst_n <= 0;
        #10
        -> rst_n_reset;
        aes.rst_n <= 1;
        wait (drv.test_done.triggered);

        // DEC
        aes.inv_en <= 1;
        aes.clk <= 0;
        aes.rst_n <= 1;
        #10;
        aes.rst_n <= 0;
        #10
        -> rst_n_reset;
        aes.rst_n <= 1;
    endtask

    task data_flow();
        drv = new();
        drv.aes = aes;
        drv.randomize();
        #1;
        drv.init();

        wait (rst_n_reset.triggered); 
        #4;
        drv.run();
        
        wait (drv.test_done.triggered); 
        output_temp = aes.output_text;
        master_key_temp = aes.master_key_out;
        plaintext_ans = aes.input_text;
        $display("ENC Done!");
        

        drv = new();
        drv.aes = aes;
        aes.input_text = output_temp;
        aes.master_key = master_key_temp;
        #1;
        drv.init();

        wait (rst_n_reset.triggered); 
        #4;
        drv.run();

        wait (drv.test_done.triggered);
        plaintext_dec = aes.output_text;
        $display("DEC Done!");

        if (plaintext_ans == plaintext_dec) begin
            succeed = succeed + 1;
            $display("AES Enc/Dec Succeed !");
        end else begin
            failed = failed + 1;
            $display("Error : AES Enc/Dec Failed !");
        end
    endtask

    always #5 aes.clk <= ~aes.clk;

    initial begin
    for(int i=0; i<test_num; i++) begin
        fork
        rst();  
        data_flow();
        join
    end
    $display("\n\nTotal Test data: %d, Succeed:%d, Failed:%d\n\n",test_num ,succeed, failed);
    $finish;
    end

    initial begin
        $fsdbDumpfile("AES.fsdb");
        $fsdbDumpvars;
        $fsdbDumpMDA();
    end
    
    
endmodule