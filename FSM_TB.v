`timescale 1ns/10ps

module fsm_tb();
	parameter parallel = 784;
	parameter bias= 30;
	reg[7:0] din_a_base[0:parallel*10000-1];
	reg[7:0] din_w1_base[0:parallel*bias-1];
	reg[7:0] din_b1_base [0:bias-1];
	reg[7:0] din_w2_base [0:bias*10-1];
	reg[7:0] din_b2_base[0:9];
	reg clk;
	reg rst_b;
	reg start;
	wire done;
	wire [159:0] dout;
	wire req,req1,layer1_start,layer2_start,sigmoid_start;
	wire [11:0] addr,addr2;
	wire [14:0] addr1;
	wire [14:0] counter;
	wire[31:0] wdata,wdata1,wdata2,wdata3;
	wire[31:0] rdata,rdata1,rdata2,rdata3;
	wire ack,r0w1,r0w11;
	wire [3:0]FSM_STATE;
	wire [10:0] counter1;
	wire [15:0] temp_sig_in;
	wire [7:0] temp_sig_out;
	wire [4:0] counter2, counter3, counter2_1;
	wire [6:0] counter2_2;
	reg[3:0] labels[0:9999];
	reg signed [15:0] final_value [0:9];
	reg signed[15:0] max;

	integer img_cnt,correct_cnt,l;
	genvar i,j,k;
	reg[3:0] inference;

toplevel topelevel(
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
		.start(start),
		.rdata(rdata),
		.rdata1(rdata1),
		.rdata2(rdata2),
		.dout(dout)
);
		

dummy_sram #(.width(32),.depth(196)) DUT1 (	
		.clk(clk),
		.rst_b(rst_b),
		.req(req),
		.r0w1(1'b0),
		.addr(addr),
		.wdata(wdata),
		.rdata(rdata),
		.ack(ack)
		
	);
dummy_sram #(.width(32),.depth(5880),.addr_bit(15)) DUT2 (	
		.clk(clk),
		.rst_b(rst_b),
		.req(req1),
		.r0w1(1'b0),
		.addr(addr1),
		.wdata(wdata1),
		.rdata(rdata1),
		.ack(ack1)
		
	);
dummy_sram #(.width(32),.depth(86)) DUT3(	
		.clk(clk),
		.rst_b(rst_b),
		.req(req2),
		.r0w1(1'b0),
		.addr(addr2),
		.wdata(wdata2),
		.rdata(rdata2),
		.ack(ack2)
		
	);


	initial begin
		clk = 0;
		rst_b = 0;
		start = 0;
		img_cnt = 0;
		correct_cnt =0;
		
		$readmemh("/bgfs/ece2193-2024s/swm58/project1/IMG.txt", din_a_base);
		$readmemh("/bgfs/ece2193-2024s/swm58/project1/W1.txt", din_w1_base);
		$readmemh("/bgfs/ece2193-2024s/swm58/project1/B1.txt", din_b1_base);
		$readmemh("/bgfs/ece2193-2024s/swm58/project1/W2.txt", din_w2_base);
		$readmemh("/bgfs/ece2193-2024s/swm58/project1/B2.txt", din_b2_base);
		$readmemh("/bgfs/ece2193-2024s/swm58/project1/labels.txt", labels);

		#30
		rst_b = 1;
		
		#10
		start = 1;
		
		
	end
	always #5 clk = ~clk;
	

generate
	for(i=0;i<196;i=i+1)begin:img
		for(j=0;j<4;j=j+1)begin
			initial begin
				#35				
				DUT1.mem_cell[i][(j+1)*8-1:j*8] <=  din_a_base[(i*4)+j];
			end
			always@(posedge done)begin	
				#35	
				DUT1.mem_cell[i][(j+1)*8-1:j*8] <=  din_a_base[(i*4)+j + 784 * img_cnt];
			end
		end
	end
	for(k=0;k<30;k=k+1)begin:weight1
		for(i=0;i<196;i=i+1)begin
			for(j=0;j<4;j=j+1)begin
				initial begin
					#35				
					DUT2.mem_cell[k*196+i][(j+1)*8-1:j*8] <=  din_w1_base[k*784+(i*4)+j];
				end
				always@(posedge done)begin			
					DUT2.mem_cell[k*196+i][(j+1)*8-1:j*8] <=  din_w1_base[k*784+(i*4)+j];
				end
			end
		end
	end
	for(i=0;i<75;i=i+1)begin:weight2
		for(j=0;j<4;j=j+1)begin
			initial begin
				#35				
				DUT3.mem_cell[i+11][(j+1)*8-1:j*8] <=  din_w2_base[(i*4)+j];
			end
		end
	end
	for(i=0;i<8;i=i+1)begin:bias1
		for(j=0;j<4;j=j+1)begin
			initial begin
				#35
				DUT3.mem_cell[i][(j+1)*8-1:j*8] <= din_b1_base[(i*4)+j];
			end
		end
	end
	for(i=0;i<3;i=i+1)begin:bias2
		for(j=0;j<4;j=j+1)begin
			initial begin
				#35
				DUT3.mem_cell[i+8][(j+1)*8-1:j*8] <= din_b2_base[(i*4)+j];
			end
		end
	end
	for(i=0;i<10;i=i+1)begin:final_val
		always @ (*)begin
			final_value[i] = dout[16*(i+1)-1:16*i];
		end
	end
endgenerate

always @ (posedge done)begin		
		img_cnt = img_cnt + 1;
		if(img_cnt == 1)begin
			$display("Accuracy %d/10000", correct_cnt);
			$stop();
		end
		#10
		max = final_value[0];
		inference = 0;
		for(l=1;l<10;l=l+1)begin
			if(final_value[l] > max)begin
				//$display("final_value[%d] is %d, max is %d, final_value[%d] is larger.",l,final_value[l],max,l);
				max = final_value[l];
				inference = l;
			end
		end
		if (inference == labels[img_cnt-1])begin 
			correct_cnt = correct_cnt + 1;
			$display("Image%d, number is %d, inferred result is correct.",img_cnt-1, inference);
		end
		else begin
			$display("Image%d, number is %d, inferred result is not matching!",img_cnt-1, inference);
		end
	end
	/*initial
		$sdf_annotate("/bgfs/ece2193-2024s/swm58/project1/New/toplevel.dc.sdf", toplevel);
*/endmodule
