`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/17/2022 04:30:34 PM
// Design Name: 
// Module Name: ram
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

module ram#
	(
		//DATA_SIZE_PER_ENTRY = 1
		// this value must be equal to multiple of 8
		DATA_WIDTH = 8, 
		// this values must be equal to a power of two
		ADDR_WIDTH = 8
	)
	(
		clk,
		rst_n,
		wr_addr,
		wr_en,
		wr_data,
		rd_addr,
		rd_data
	);


input wire clk;
input wire rst_n;
input wire [ADDR_WIDTH - 1 : 0] wr_addr;
input wire wr_en;
input wire [DATA_WIDTH - 1 : 0] wr_data;
input wire [ADDR_WIDTH - 1 : 0] rd_addr;
output wire [DATA_WIDTH - 1 : 0] rd_data;

(* ram_style="block" *)reg [DATA_WIDTH - 1 : 0] mem[2 ** ADDR_WIDTH - 1 : 0];

reg [DATA_WIDTH - 1 : 0] rd_data_reg;
assign rd_data = rd_data_reg;

integer i;

always @(posedge clk) begin
	if (rst_n == 1'b0) begin
		for (i = 0; i < 2 ** ADDR_WIDTH; i = i + 1) begin
			mem[i] <= {DATA_WIDTH{1'b0}};
		end
	end else begin
		if (wr_en == 1'b1) begin
			mem[wr_addr] <= wr_data; 
		end

		rd_data_reg <= mem[rd_addr];
	end
end

endmodule
