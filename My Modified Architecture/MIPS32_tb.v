`timescale 1ns / 1ps


module MIPS32_tb();

    reg clk, rst;
    MIPS32_TOP DUT (.clk(clk), .rst(rst));

    initial begin
        clk = 0;
    end
    always #25 clk = ~clk; //clk gen
    
    initial begin
        rst = 1'b1;
        #50;
        rst = 1'b0; 
        #2000; 
        $finish; 
    end

endmodule