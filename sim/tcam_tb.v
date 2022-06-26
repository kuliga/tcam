`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/18/2022 01:05:19 PM
// Design Name: 
// Module Name: tcam_tb
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


module tcam_tb(

    );
localparam WORD_WIDTH = 8;
localparam ADDR_WIDTH = 4;
localparam DATA_WIDTH = 8;
localparam PERIOD = 40;

reg clk;
reg rst_n;
reg opcode;
reg req;
reg clr;
reg [WORD_WIDTH - 1 : 0] word;
reg [WORD_WIDTH - 1 : 0] mask_in;
reg [ADDR_WIDTH - 1 : 0] addr_in;
reg [DATA_WIDTH - 1 : 0] data_in;
wire valid;
wire [DATA_WIDTH - 1 : 0] data_out;
reg ack;

tcam#(WORD_WIDTH, ADDR_WIDTH, DATA_WIDTH, 1) uut(clk, rst_n, ack, opcode, req, clr, word, mask_in, addr_in, data_in, valid, data_out);

// clock stimulus
 always begin
     clk = 1'b0;
     #(PERIOD / 2) clk = 1'b1;
     #(PERIOD / 2);
 end
 
initial begin
    ack <= 1'b0;
    word <= 8'b00000001;
    mask_in <= {WORD_WIDTH{1'b1}};
//    addr_in <= 4'b0111;
    addr_in <= 4'b1000;
    data_in <= 8'hff;
    opcode <= 1'b0;
    req <= 1'b1;
    clr <= 1'b0;
    rst_n <= 1'b0; 
//    @(posedge clk);
    #20;
    rst_n <= 1'b1;
    
    // write requests
    while (addr_in > 0) begin
        @(posedge clk);
//        #2; 
        word <= word + 1;
        data_in <= data_in - 1;
        addr_in <= addr_in - 1;
    end
//    req <= 1'b0;
//    #20;
    @(posedge clk);
//    word <= 8'b00000001;
    @(posedge clk);
        word <= 8'b00000001;
    opcode <= 1'b1;
    req <= 1'b1;
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    word <= 8'b00000010;
    ack <= 1'b1;
    @(posedge clk);
//    req <= 1'b0;
//    ack <= 1'b0;
    @(posedge clk);
    ack <= 1'b0;
    @(posedge clk);
    ack <= 1'b1;
//    #50;
    word <= 8'b00000011;
    req <= 1'b1;
        @(posedge clk);
//        req <= 1'b0;
    @(posedge clk);
    ack <= 1'b0;
    @(posedge clk);
    word <= 8'b00000100;
//    req <= 1'b1;
    @(posedge clk);
//    req <- 1'b0;
    @(posedge clk);
    @(posedge clk);
        word <= 8'b10000000;
        repeat (5) begin
            @(posedge clk);
        end
     word <= 8'b00001000;
             repeat (5) begin
            @(posedge clk);
        end
            word <= 8'b10000000;
        repeat (5) begin
            @(posedge clk);
        end
       word <= 8'b00001001;
               repeat (5) begin
            @(posedge clk);
        end
        word <= 8'b00001010;
end

endmodule
