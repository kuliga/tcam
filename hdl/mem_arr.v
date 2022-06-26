`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/16/2022 03:42:29 PM
// Design Name: 
// Module Name: mem_cmp_block
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

/*(* dont_touch="true" *) */module mem_arr#
	(
		WORD_WIDTH = 8,
		WORD_NUM = 8
	)
	(
		clk,
		rst_n,
		word,
		mask,
		addr,
		opcode, // 1 - read request, 0 - write request
		req,
		clr,
		line
	);

input wire clk;
input wire rst_n;
input wire [WORD_WIDTH - 1 : 0] word;
input wire [WORD_WIDTH - 1 : 0] mask;
input wire [$clog2(WORD_NUM) - 1 : 0] addr;
input wire opcode;
input wire req;
input wire clr;
output wire [WORD_NUM - 1 : 0] line;

// memory array for keeping masks and words bits
// single entry:
// reg [WORD_WIDTH - 1 : 0] word_mem;
// reg [WORD_WIDTH - 1: 0] mask_mem;

/*(* ram_style="register" *) (* keep="true" *) */reg [2 * WORD_WIDTH - 1 : 0] mem_arr[WORD_NUM - 1 : 0];

// status bits indicating whether given field was updated or not
reg [WORD_NUM - 1 : 0] entry_valid;

reg [WORD_NUM - 1 : 0] line_reg;
assign line = line_reg;

integer i, j;

// write request process
always @(posedge clk) begin
	if (rst_n == 1'b0) begin
		entry_valid <= {WORD_NUM{1'b0}};
		for (j = 0; j < WORD_NUM; j = j + 1) begin
			mem_arr[j] <= {2 * WORD_WIDTH{1'b0}};
		end
	end else begin
		if (req == 1'b1 && opcode == 1'b0) begin
			entry_valid[addr] <= ~clr;
			mem_arr[addr][2 * WORD_WIDTH - 1 : WORD_WIDTH] <= word;
			mem_arr[addr][WORD_WIDTH - 1 : 0] <= mask;
		end
	end
end

// read request process
always @(posedge clk) begin
	if (rst_n == 1'b0) begin
//		line_reg <= {(WORD_WIDTH / 2){2'b01}};
        line_reg <= {WORD_WIDTH{1'b0}};
	end else begin
		if (req == 1'b1 && opcode == 1'b1) begin
			for (i = 0; i < WORD_NUM; i = i + 1) begin
				line_reg[i] <= entry_valid[i] &
				                ((word & mem_arr[i][WORD_WIDTH - 1 : 0]) ==
						mem_arr[i][2 * WORD_WIDTH - 1 : WORD_WIDTH]);
			end
		end
	end
end
endmodule
