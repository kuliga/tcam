`timescale 1ns / 1ps

module tcam_axis#
    (
        //tcam
        WORD_WIDTH = 32,
		ADDR_WIDTH = 4,
		DATA_WIDTH = 32,
				
		//M_AXIS
		// Width of S_AXIS address bus. The slave accepts the read and write addresses of width C_M_AXIS_TDATA_WIDTH.
		parameter integer C_M_AXIS_TDATA_WIDTH	= 32,

		
		//S_AXIS
		// AXI4Stream sink: Data Width
		parameter integer C_S_AXIS_TDATA_WIDTH	= 32
    )
    (
        //M_AXIS
        // Global ports
		input wire  M_AXIS_ACLK,
		// 
		input wire  M_AXIS_ARESETN,
		// Master Stream Ports. TVALID indicates that the master is driving a valid transfer, A transfer takes place when both TVALID and TREADY are asserted. 
		output wire  M_AXIS_TVALID,
		// TDATA is the primary payload that is used to provide the data that is passing across the interface from the master.
		output wire [31 : 0] M_AXIS_TDATA,
		// TSTRB is the byte qualifier that indicates whether the content of the associated byte of TDATA is processed as a data byte or a position byte.
		output wire [(C_M_AXIS_TDATA_WIDTH/8)-1 : 0] M_AXIS_TSTRB,
		// TLAST indicates the boundary of a packet.
		output wire  M_AXIS_TLAST,
		// TREADY indicates that the slave can accept a transfer in the current cycle.
		input wire  M_AXIS_TREADY,
		
		
		//S_AXIS
		// AXI4Stream sink: Clock
		input wire  S_AXIS_ACLK,
		// AXI4Stream sink: Reset
		input wire  S_AXIS_ARESETN,
		// Ready to accept data in
		output wire  S_AXIS_TREADY,
		// Data in
		input wire [31 : 0] S_AXIS_TDATA,
		// Byte qualifier
		input wire [(C_S_AXIS_TDATA_WIDTH/8)-1 : 0] S_AXIS_TSTRB,
		// Indicates boundary of last packet
		input wire  S_AXIS_TLAST,
		// Data is in valid
		input wire  S_AXIS_TVALID
    );
    
reg [3 : 0] tcam_axis_state;
localparam IDLE = 5'b00001;
localparam DISPATCH_BEATS = 5'b00010;
localparam WRITE_OP = 5'b00100;
localparam READ_WAIT = 5'b01000;
localparam READ_OP = 5'b10000;

reg [15 : 0] control;
reg [15 : 0] addr;
wire valid;
wire [31 : 0] data_out;
reg req;

reg [2 : 0] beat_count;
/* beat_frame layout:
 * [WORD]
 * [MASK]
 * [DATA]
 */
reg [31 : 0] beat_frame[0 : 2];
reg [2 : 0] delay_count; // delay needed for read operation

assign S_AXIS_TREADY = (tcam_axis_state == IDLE) || (tcam_axis_state == DISPATCH_BEATS);

assign M_AXIS_TVALID = (tcam_axis_state == WRITE_OP) || (tcam_axis_state == READ_OP);
assign M_AXIS_TDATA = (valid == 1'b1) ? (data_out) : (32'hdeadbeef);
assign M_AXIS_TLAST = (tcam_axis_state == WRITE_OP) ? (1'b1) : ((valid == 1'b1) ? (1'b1) : (1'b0)); //no tlast if there's no match

always @(posedge S_AXIS_ACLK) begin
    if (S_AXIS_ARESETN) begin
        tcam_axis_state <= IDLE;
    end else begin  
        case (tcam_axis_state)
        IDLE: begin
            if (S_AXIS_TVALID == 1'b1) begin
                tcam_axis_state <= DISPATCH_BEATS;
                control <= S_AXIS_TDATA[15 : 0];
                addr <= S_AXIS_TDATA[31 : 16];
                beat_count <= 3'b000;
            end else begin
                tcam_axis_state <= IDLE;
            end
        end
        DISPATCH_BEATS: begin
            if (S_AXIS_TVALID == 1'b1) begin
                beat_frame[beat_count] <= S_AXIS_TDATA;
                if (S_AXIS_TLAST == 1'b1) begin
                    req <= 1'b1;
                    if (control[0] == 1'b1) begin
                        tcam_axis_state <= READ_WAIT;
                        delay_count <= 3'b000;
                    end else begin
                        tcam_axis_state <= WRITE_OP;
                    end
                end else begin
                    beat_count <= beat_count + 1;
                    tcam_axis_state <= DISPATCH_BEATS;
                end
            end else begin
                tcam_axis_state <= DISPATCH_BEATS;
            end
        end  
        WRITE_OP: begin
            req <= 1'b0;
            if (M_AXIS_TREADY == 1'b1) begin
                tcam_axis_state <= IDLE;
            end else begin
                tcam_axis_state <= WRITE_OP;
            end
        end
        READ_WAIT: begin
            req <= 1'b0;
            if (delay_count < 3'b011) begin
                delay_count <= delay_count + 1;
                tcam_axis_state <= READ_WAIT;
            end else begin
                tcam_axis_state <= READ_OP;
            end
        end     
        READ_OP: begin
            if (M_AXIS_TREADY == 1'b1) begin
                tcam_axis_state <= IDLE;
            end else begin
                tcam_axis_state <= READ_OP;
            end
        end
        endcase           
    end
end


tcam#
    (
        .WORD_WIDTH(WORD_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .DATA_SIZE_PER_ENTRY(1) //don't care
    )
    (
        // in
        .clk(S_AXIS_ACLK),
		.rst_n(S_AXIS_ARESETN),
		.ack(0),
		.opcode(control[0]), // 0 - write, 1 - read
		.req(req),
		.clr(control[1]),
		.word(beat_frame[0]),
		.mask_in(beat_frame[1]),
		.addr_in(addr),
		.data_in(beat_frame[2]),
		// out
		.valid(valid),
		.data_out(data_out)
    );
endmodule
