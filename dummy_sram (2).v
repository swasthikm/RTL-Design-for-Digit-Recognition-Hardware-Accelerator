module dummy_sram #(parameter depth=2048, width=32, addr_bit = 12)(
	clk,
	rst_b,
	req,
	r0w1,
	addr,
	wdata,
	rdata,
	ack
);
	input clk;
	input rst_b;
	input req;
	input r0w1;
	input [addr_bit-1:0] addr;
	input [width-1:0] wdata;
	output reg [width-1:0] rdata;
	output reg ack;
	
	reg [width-1:0] mem_cell [0:depth-1];
	integer i;
	
	always @ (posedge clk or negedge rst_b) begin
		if(~rst_b)begin
			for(i=0;i<depth;i=i+1)begin
				mem_cell[i] <= 0;
			end
			rdata <= 0;
		end
		else begin
			if(req & (~ack))begin
				if(~r0w1)begin
					rdata <= mem_cell[addr];
				end
				else begin
					mem_cell[addr] <= wdata;
				end
			end
		end
	end
	
	always @ (posedge clk or negedge rst_b)begin
		if(~rst_b)begin
			ack <= 1'b0;
		end
		else begin
			ack <= req;
		end
	end
endmodule
