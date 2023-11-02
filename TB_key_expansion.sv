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
        ke.key_in = 
        for (i=0 ; i < 11 ; i = i + 1) begin
            for (j = 0 ; j < 7; j = j + 1) begin
                ke.round <= i;
                ke.cnt <= j;
                #10;
            end
        end
        $finish();
    endtask

endclass

module TB_key_expand;

    // 實例化一個interface
    key_expand ke();

    // 實例化一個driver
    driver drv;

    // key_expansion ke_dut(ke.round_key_o, ke.round, ke.cnt, ke.rst_n, ke.clk);


    initial begin
        ke.clk <= 0;
    end

    always #5 ke.clk <= ~ke.clk;

    initial begin
        drv = new();
        drv.ke = ke;
        #5;
        drv.run();
    end

    initial begin
        $fsdbDumpfile("Key_expand.fsdb");
        $fsdbDumpvars;
        $fsdbDumpMDA();
    end
    
    
endmodule