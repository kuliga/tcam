`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/16/2022 11:02:59 PM
// Design Name: 
// Module Name: mem_cmp_block_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mem_arr_tb(

    );
localparam WORD_WIDTH = 8;
localparam WORD_NUM = 8;
localparam PERIOD = 80;

reg clk;
reg rst_n;
reg [WORD_WIDTH - 1 : 0] word;
reg [WORD_WIDTH - 1 : 0] mask_in;
reg [$clog2(WORD_NUM) - 1 : 0] addr_in;
reg opcode;
reg req;
reg clr;
wire [WORD_NUM - 1 : 0] matched_words;

mem_arr#(WORD_WIDTH, WORD_NUM) uut(clk, rst_n, word, mask_in, addr_in, opcode, req, clr, matched_words);

// clock stimulus
 always begin
     clk = 1'b0;
     #(PERIOD / 2) clk = 1'b1;
     #(PERIOD / 2);
 end
 
 initial begin
     rst_n <= 1'b0; 
     #10;
    word <= 8'b00000001;
    mask_in <= {WORD_WIDTH{1'b1}};
    addr_in <= 3'b111;
    opcode <= 1'b0;
    req <= 1'b1;
    clr <= 1'b0;
    rst_n <= 1'b1;
    #30;
    rst_n <= 1'b1;
    
    // write requests
    while (addr_in != 0) begin
        @(posedge clk);
        #2; 
        word <= word + 1;
        addr_in <= addr_in - 1;
    end
    #20;
    
    // read requests
    opcode <= 1'b1;
    word <= 8'b00000010;
    repeat (9) begin
        @(posedge clk);
        #1 word <= word + 1;
        @(posedge clk);
    end
    word <= 8'b00000000;
    #20;
    req <= 1'b0;
    #20;

    //clear request
    clr <= 1'b1;
    opcode <= 1'b0;
    req <= 1'b1;
    word <= 8'b00000111;
    addr_in <= 3'b001;
    @(posedge clk);
    // attempt to read cleared entry
    clr <= 1'b0;
    opcode <= 1'b1;
    #20;
    req <= 1'b0;
    
    // multiple matches
    opcode <= 1'b0;
    addr_in <= 3'b111;
    word <= 8'b11111100; //mask /6
    mask_in <= 8'b11111100;
    req <= 1'b1;
    #20;
    req <= 1'b0;
    #20;
    addr_in <= 3'b110;
    word <= 8'b11111110;
    mask_in <= 8'b11111110;
    req <= 1'b1;
    #20;
    req <= 1'b0;
    #20;
    opcode <= 1'b1;
    req <= 1'b1;
    #50;
end

endmodule
