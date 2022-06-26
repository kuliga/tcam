`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/15/2022 01:06:55 AM
// Design Name: 
// Module Name: priority_encoder_tb
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


module priority_encoder_tb(

    );
parameter N = 8;
reg [N - 1 : 0] in = 8'b00000000;
reg [N - 1 : 0] dbg = 8'b00000000;
wire vld;
wire [$clog2(N) - 1 : 0] idx;
integer shift = 0;

priority_encoder#(N) uut(in, idx, vld);

initial begin
    // test case: normal one-hot to binary decoder
    repeat (N + 1) begin
         # 2;
        in = 1 << shift;
        shift = shift + 1;
        # 2; // additional delay in order to see clearly the dbg output
        dbg = 1 << idx; 
     end
     
     #20
     in = 8'b00000000;
     //test case: priority encoder
     forever begin
        #2;
        in = in + 1;
        #2;
        dbg = 1 << idx;
     end
end
endmodule
