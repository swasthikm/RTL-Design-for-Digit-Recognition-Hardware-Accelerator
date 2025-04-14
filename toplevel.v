`timescale 1ns/10ps

module toplevel(
	input clk,
	input rst_b,
	input start,
	output done,
	output req,
	output req1,
	output req2,
	output [11:0] addr,
	output [14:0] addr1,
	output [11:0] addr2,
	input [31:0] rdata,
	input[ 31:0] rdata1,
	input [31:0] rdata2,
	input ack,
	input ack1,
	input ack2,
	output [159:0] dout

);
	wire [3:0]FSM_STATE;
	wire [10:0] counter1;
	wire signed[15:0] temp_sig_in;
	wire [7:0] temp_sig_out;
	wire [4:0] counter2, counter3, counter2_1;
	wire [6:0] counter2_2;
wire layer1_start,layer2_start,sigmoid_start,read;
wire [14:0] counter;
SigmoidTable SigmoidTable(.x(temp_sig_in), .y(temp_sig_out));

FSM FSM(
		.ack(ack),
		.ack1(ack1),
		.ack2(ack2),
		.clk(clk),
		.rst_b(rst_b),
		.req(req),
		.req1(req1),
		.req2(req2),
		.addr(addr),
		.addr1(addr1),
		.addr2(addr2),
		.done(done),
		.load_start(load_start),
		.load_weight(load_weight),
		.FSM_STATE(FSM_STATE),
		.start(start),
		.counter(counter),
		.load_done(load_done),
		.layer1_start(layer1_start),
		.layer2_start(layer2_start),
		.counter1(counter1),
		.counter2(counter2),
		.counter3(counter3),
		.counter2_2(counter2_2),
		.counter2_1(counter2_1),
		.sigmoid_start(sigmoid_start),
		.read(read)
	);
mac DUT5(
		.din_a(rdata),
		.din_w1(rdata1),
		.din_w2(rdata2),
		.load_start(load_start),
		.load_weight(load_weight),
		.load_done(load_done),
		.layer1_start(layer1_start),
		.layer2_start(layer2_start),
		.clk(clk),
		.rst_b(rst_b),
		.FSM_STATE(FSM_STATE),
		.counter(counter),
		.counter1(counter1),
		.counter2(counter2),
		.counter3(counter3),
		.counter2_2(counter2_2),
		.counter2_1(counter2_1),
		.temp_sig_in(temp_sig_in),
		.temp_sig_out(temp_sig_out),
		.sigmoid_start(sigmoid_start),
		.read(read),
		.dout(dout)
	);
endmodule


