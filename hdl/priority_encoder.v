`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/14/2022 08:47:59 PM
// Design Name: 
// Module Name: priority_encoder
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


// PRIORITY ENCODER ARCHITECTURE IS BASED ON THIS PAPER:
// Architecture of Block-RAM-Based Massively Parallel Memory Structures: Multi-Ported Memories and Content-Addressable Memories
// Ameer M. S. Abdelhadi

// PRIORITY TYPE: LSB is the most important one
/*(* DONT_TOUCH="TRUE" *)*/ module priority_encoder#
	(
		N = 8 // this parameter's value must be a power of two
	)
	(
		in,
		idx,
		vld
	);

input wire [N - 1 : 0] in;
output wire [$clog2(N) - 1 : 0] idx;
output wire vld;

localparam N_K = N / 2; // k equals 2

generate
    if (N == 2) begin  // the very basic component description
		assign vld = in[0] | in[1];
		// simple mux 
		assign idx = in[0] ? (1'b0) : (in[1] ? (1'b1) : (1'bX));
	end else begin // "rtl recursion" 
		wire [$clog2(N_K) - 1 : 0] idx0, idx1;
		wire vld0, vld1;
		
		// two instances since k == 2	
		priority_encoder#
		(
			.N(N_K)
		)
		priority_encoder_0
		(
			.in(in[N_K - 1 : 0]),
			.vld(vld0),
			.idx(idx0)
		);

		priority_encoder#
		(
			.N(N_K)
		)
		priority_encoder_1
		(
			.in(in[N - 1 : N_K]),
			.vld(vld1),
			.idx(idx1)
		);

		// OR each vld output from priority encoder block
		assign vld = vld0 | vld1;
		
		// mux and concatenate vectors; don't care when vld = 0 
		assign idx = vld ? (vld0 ? {1'b0, idx0} : {1'b1, idx1}) : (1'bX); 
	end
	
endgenerate

endmodule
