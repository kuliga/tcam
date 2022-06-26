`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/18/2022 03:39:43 AM
// Design Name: 
// Module Name: tcam
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


module tcam#
	(
		WORD_WIDTH = 8,
		ADDR_WIDTH = 4,
		DATA_WIDTH = 8,
		DATA_SIZE_PER_ENTRY = 4
	)
	(
		//in
		clk,
		rst_n,
		ack,
		opcode, // 0 - write, 1 - read
		req,
		clr,
		word,
		mask_in,
		addr_in,
		data_in,
		//out
		valid,
		data_out
	);


input wire clk;
input wire rst_n;
input wire ack;
input wire opcode;
input wire req;
input wire clr;
input wire [WORD_WIDTH - 1 : 0] word;
input wire [WORD_WIDTH - 1 : 0] mask_in;
input wire [ADDR_WIDTH - 1 : 0] addr_in;
input wire [DATA_WIDTH - 1 : 0] data_in;
output wire valid;
output wire [DATA_WIDTH - 1 : 0] data_out;

//reg valid;
reg valid_reg;
wire valid_wire;
wire vld;
//assign valid = valid_reg;// & opcode;
assign valid = ack ? 1'b0 : valid_reg;

// mem_arr -> priority_encoder
wire [2 ** ADDR_WIDTH - 1 : 0] line;
// priority_encoder -> ram
wire [ADDR_WIDTH - 1 : 0] encoded_addr;

assign valid_wire = vld;//ack ? 1'b0 : vld;

always @(posedge clk) begin
    if (rst_n == 1'b0) begin
        valid_reg <= 1'b0;
    end else begin
        valid_reg <= valid_wire;
    end
end

mem_arr#
	(
		.WORD_WIDTH(WORD_WIDTH),
		.WORD_NUM(2 **ADDR_WIDTH)
	)
mem_arr_0	
	(
		.clk(clk),
		.rst_n(rst_n),
		.opcode(opcode),
		.req(req),
		.clr(clr),
		.word(word),
		.mask(mask_in),
		.addr(addr_in),
		.line(line)
	);

priority_encoder#
	(
		.N(2 ** ADDR_WIDTH)
	)
priority_encoder_0
	(
		.in(line),
		.vld(vld),
		.idx(encoded_addr)
	);

ram#
	(
		.DATA_WIDTH(DATA_WIDTH),
		.ADDR_WIDTH(ADDR_WIDTH)
	)
ram_0
	(
		.clk(clk),
		.rst_n(rst_n),
		.wr_addr(addr_in),
		.wr_en(~opcode),
		.wr_data(data_in),
		.rd_addr(encoded_addr),
		.rd_data(data_out)
	);

endmodule
