module mlp_tb();
	reg clk;
	reg rst_b;
	reg start_l1;
	reg start_l2;
	
	wire img_mem_req;
	wire img_mem_ack;
	wire [4:0]img_mem_addr;
	wire [255:0] img_mem_rdata;
	
	wire wgh_mem_req;
	wire wgh_mem_ack;
	wire [9:0]wgh_mem_addr;
	wire [255:0] wgh_mem_rdata;
	
	wire layer1_done;
	wire layer2_done;
	
	wire [159:0] dout;
	
	reg [7:0] ext_mem_img[0:784*10-1];
	reg [7:0] ext_mem_wgh1[0:784*30-1];
	reg [7:0] ext_mem_wgh2[0:30*10-1];
	reg [7:0] ext_mem_bias1[0:29];
	reg [7:0] ext_mem_bias2[0:9];
	
	reg signed [15:0] final_value [0:9];
	
	genvar i,j;
	integer k;
	reg[3:0] inference;
	reg signed[15:0] max;
	reg[3:0] labels[0:9999];
	integer img_cnt;
	integer correct_cnt;
	
	MLP_no_sram DUT(
		.clk(clk),
		.rst_b(rst_b),
		.start_layer1_i(start_l1),
		.start_layer2_i(start_l2),
	
		.weight_bias_mem_req_o(wgh_mem_req),
		.weight_bias_mem_ack_i(wgh_mem_ack),
		.weight_bias_mem_addr_o(wgh_mem_addr),
	
		.img_mem_req_o(img_mem_req),
		.img_mem_ack_i(img_mem_ack),
		.img_mem_addr_o(img_mem_addr),
	
		.layer1_done_o(layer1_done),
		.layer2_done_o(layer2_done),
		
		.image_i(img_mem_rdata),
		.weight_i(wgh_mem_rdata),
			
		.dout_o(dout)
	);
	
	dummy_sram #(.depth(32), .width(256), .addr_bit(5))
	U_SRAM_IMG(
		.clk(clk),
		.rst_b(rst_b),
		.req(img_mem_req),
		.r0w1(1'b0),
		.addr(img_mem_addr),
		.wdata(256'h0),
		.rdata(img_mem_rdata),
		.ack(img_mem_ack)
	);
	
	dummy_sram #(.depth(1024), .width(256), .addr_bit(10))
	U_SRAM_WGH(
		.clk(clk),
		.rst_b(rst_b),
		.req(wgh_mem_req),
		.r0w1(1'b0),
		.addr(wgh_mem_addr),
		.wdata(256'h0),
		.rdata(wgh_mem_rdata),
		.ack(wgh_mem_ack)
	);
	
	initial begin
		clk = 0;
		rst_b = 0;
		start_l1 = 0;
		start_l2 = 0;
		inference = 0;
		$readmemh("/bgfs/ece2193-2024s/yul230/project01_working/IMG.txt",ext_mem_img);
		$readmemh("/bgfs/ece2193-2024s/yul230/project01_working/W1.txt",ext_mem_wgh1);
		$readmemh("/bgfs/ece2193-2024s/yul230/project01_working/W2.txt",ext_mem_wgh2);
		$readmemh("/bgfs/ece2193-2024s/yul230/project01_working/B1.txt",ext_mem_bias1);
		$readmemh("/bgfs/ece2193-2024s/yul230/project01_working/B2.txt",ext_mem_bias2);
		$readmemh("/bgfs/ece2193-2024s/yul230/project01_working/labels.csv", labels);
		img_cnt = 0;
		correct_cnt = 0;
		#10
		rst_b = 1;

		#10
		start_l1 = 1;
		#10
		start_l1 = 0;
		
	end
	
	always@(posedge layer1_done) begin
		#15
		start_l2 = 1'b1;
		#10
		start_l2 = 1'b0;
	end
	
	generate
		for(i=0;i<784;i=i+1)begin:load_img_init
			initial begin		
				#10
				U_SRAM_IMG.mem_cell[i[31:5]][(i[4:0]+1)*8-1:i[4:0]*8] <= ext_mem_img[i];
			end
			always @(posedge layer2_done)begin
				#10
				U_SRAM_IMG.mem_cell[i[31:5]][(i[4:0]+1)*8-1:i[4:0]*8] <= ext_mem_img[i + 784*img_cnt];
			end
		end
		for(j=0;j<30;j=j+1)begin:load_wgh1
			for(i=0;i<784;i=i+1)begin
				initial begin		
					#10
					U_SRAM_WGH.mem_cell[j*25+i[31:5]+1][(i[4:0]+1)*8-1:i[4:0]*8] <= ext_mem_wgh1[j*784+i];
				end				
				always @(posedge layer2_done)begin		
					#10
					U_SRAM_WGH.mem_cell[j*25+i[31:5]+1][(i[4:0]+1)*8-1:i[4:0]*8] <= ext_mem_wgh1[j*784+i];
				end
				
			end
		end
		for(i=0;i<30;i=i+1)begin:load_bias1
			initial begin		
				#10
				U_SRAM_WGH.mem_cell[0][(i[4:0]+1)*8-1:i[4:0]*8] <= ext_mem_bias1[i];
			end
			always @(posedge layer2_done)begin			
				#10
				U_SRAM_WGH.mem_cell[0][(i[4:0]+1)*8-1:i[4:0]*8] <= ext_mem_bias1[i];
			end
		end
		
		for(j=0;j<10;j=j+1)begin:load_wgh2
			for(i=0;i<30;i=i+1)begin
				always @(posedge layer1_done) begin		
					
					U_SRAM_WGH.mem_cell[j+1][(i+1)*8-1:i*8] <= ext_mem_wgh2[j*30+i];
				end
			end
		end
		for(i=0;i<10;i=i+1)begin:load_bias2
			always@(posedge layer1_done) begin		
				
				U_SRAM_WGH.mem_cell[0][(i+1)*8-1:i*8] <= ext_mem_bias2[i];
			end
		end
		for(i=0;i<10;i=i+1)begin:final_val
			always @ (*)begin
				final_value[i] = dout[16*(i+1)-1:16*i];
			end
		end
	endgenerate
	
	always @(posedge layer2_done)begin
		img_cnt = img_cnt + 1;
		if(img_cnt==11)begin
			$display("Tested %d images with %d corerct.",img_cnt-1, correct_cnt);
			$stop;
		end
		#10
		max = final_value[0];
		inference = 0;
		for(k=1;k<10;k=k+1)begin
			if(final_value[k] > max)begin
				//$display("final_value[%d] is %d, max is %d, final_value[%d] is larger.",k,final_value[k],max,k);
				max = final_value[k];
				inference = k;
			end
		end
		if (inference == labels[img_cnt-1])begin 
			correct_cnt = correct_cnt + 1;
			$display("Image%d, number is %d, inferred result is correct.",img_cnt-1, inference);
		end
		else begin
			$display("Image%d, number is %d, inferred result is not matching!",img_cnt-1, inference);
		end
		
		#10
		start_l1 = 1;
		#10
		start_l1 = 0;
	end
	
	always #5 clk = ~clk;
	initial
		$sdf_annotate("/bgfs/ece2193-2024s/swm58/Project/apr/save/MLP_no_sram.apr.sdf", MLP_no_sram);
endmodule
