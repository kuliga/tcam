`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/17/2022 06:31:20 PM
// Design Name: 
// Module Name: ram_tb
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


module ram_tb(

    );
    

// this value must be equal to multiple of 8
localparam DATA_WIDTH = 8; 
// this values must be equal to a power of two
localparam ADDR_WIDTH = 4;
localparam DATA_SIZE_PER_ENTRY = 1;    
localparam PERIOD = 10;

reg clk;
reg rst_n;
reg [ADDR_WIDTH - 1 : 0] wr_addr;
reg wr_en;
reg [DATA_WIDTH - 1 : 0] wr_data;
reg [ADDR_WIDTH - 1 : 0] rd_addr;
wire [DATA_WIDTH - 1 : 0] rd_data;


ram#(DATA_WIDTH, ADDR_WIDTH, DATA_SIZE_PER_ENTRY) uut(clk, rst_n, wr_addr, wr_en, wr_data, rd_addr, rd_data);

// clock stimulus
 always begin
     clk = 1'b0;
     #(PERIOD / 2) clk = 1'b1;
     #(PERIOD / 2);
 end
 
 initial begin
    rst_n <= 1'b0;
    #15
    wr_en <= 1'b1;
    rd_addr <= 4'b0000;
    wr_addr <= 4'b0011;
    wr_data <= 8'hfe;
    #25;
//#5;
    rst_n <= 1'b1;
    wr_en <= 1'b1;
    repeat (5) begin
        @(posedge clk);
        #2;
        wr_addr <= wr_addr + 1;
        wr_data <= wr_data - 1;
//        @(posedge clk);
//        #20;
     end
     wr_en <= 1'b0;
     rd_addr <= 4'b0011;
     #25;
     repeat (5) begin
        @(posedge clk);
        #2;
        rd_addr <= rd_addr + 1;
//                @(posedge clk);
     end
     #20;
     
//    rst_n <= 1'b0;
//    wr_en <= 1'b0;
//    rd_addr <= 4'b0000;
//    wr_addr <= 4'b0011;
//    wr_data <= 8'hfe;
//    #20;
//    rst_n <= 1'b1;
//    wr_en <= 1'b1;
//    repeat (5) begin
//        @(posedge clk);
//        #2;
//        wr_addr <= wr_addr + 1;
//        wr_data <= wr_data - 1;
//        @(posedge clk);
//        #20;
//     end
//     wr_en <= 1'b0;
//     rd_addr <= 4'b0011;
//     #25;
//     repeat (5) begin
//        @(posedge clk);
//        #2;
//        rd_addr <= rd_addr + 1;
//        @(posedge clk);
//     end
//     #20;
     
     //two entries
         
//      repeat (5) begin 
//      @(posedge clk); 
//        repeat (1) begin
////        @(posedge clk);
//        wr_data <= wr_data - 1;
//        @(posedge clk);
//     end
//     wr_addr <= wr_addr + 1;
//     end
     
//     wr_en <= 1'b0;
//     rd_addr <= 4'b0011;
////     #25;
//     repeat (5) begin
//     @(posedge clk);
//     repeat (1) begin
//        @(posedge clk);
//                #20;
//     end
//             rd_addr <= rd_addr + 1;
//    end
//     #20;
     
//    rst_n <= 1'b0;
//    wr_en <= 1'b0;
//    rd_addr <= 4'b0000;
//    wr_addr <= 4'b0011;
//    wr_data <= 8'hfe;
//    #20;
//    rst_n <= 1'b1;
//    wr_en <= 1'b1;
//    repeat (5) begin
//        @(posedge clk);
//        repeat (1)
//        @(posedge clk)
//        wr_addr <= wr_addr + 1;
//        wr_data <= wr_data - 1;
//        @(posedge clk);
//        #20;
//     end
//     wr_en <= 1'b0;
//     rd_addr <= 4'b0011;
//     #25;
//     repeat (5) begin
//        @(posedge clk);
//        #2;
//        rd_addr <= rd_addr + 1;
//        @(posedge clk);
//     end
//     #20;
     
     #20;
 end


endmodule
