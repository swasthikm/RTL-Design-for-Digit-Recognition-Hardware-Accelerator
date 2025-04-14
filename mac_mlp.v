
module mac#(parameter parallel=16, bias = 30, depth=2048, width=32,num = 4)(
	input [31:0] din_a,
	input [31:0] din_w1,
	input [31:0] din_w2,

	input clk,
	input rst_b,
	input [3:0] FSM_STATE,
	input load_start,
	input load_weight,
	input load_done,
	input layer1_start,
	input layer2_start,
	input [14:0] counter,
	input [10:0] counter1,
	input [4:0] counter2,
	input [4:0] counter3,
	input [6:0] counter2_2,
	input [4:0] counter2_1,
	output signed [15:0] temp_sig_in,
	input [7:0] temp_sig_out,
	input sigmoid_start,
	output [159:0] dout,
	input read
	//output done
);

	reg signed[7:0] img [0:parallel-1];
	reg signed[7:0] B1 [0:31];
	reg signed[7:0] B2 [0:11];
	reg signed[7:0] W2 [0:59];
	reg signed[7:0] W1[0:parallel-1];
	reg	signed[7:0] B [0:bias-1];
	reg signed[15:0] C [0:9];
	reg signed[15:0] partial_sum [0:3];
	reg [7:0] partial_sum1 [0:3];
	reg signed[15:0] temp_sig_in_reg;
	reg signed[15:0] temp2,sum,sum2;
	reg signed[15:0] sum1[0:7];
	reg signed[15:0] temp1 [0:29];
	reg signed[15:0] temp [0:29];
	reg signed[7:0] B1mux,B2mux,weight,sum4,sum2_truncate;
	reg signed[7:0] sum1_truncate[0:7];
	genvar i;
	reg [1:0] k,l,m,sel2,sel1;
	reg [2:0]j;
	//reg done_reg;
	assign temp_sig_in = temp_sig_in_reg;
	always @ (posedge clk) begin
		if(load_start && read) begin
			if(counter<=15)begin
				img[counter] <= din_a[7:0];
				img[counter+1] <= din_a[15:8];
				img[counter+2] <= din_a[23:16];
				img[counter+3] <= din_a[31:24];
				W1[counter] <= din_w1[7:0];
				W1[counter+1] <= din_w1[15:8];
				W1[counter+2] <= din_w1[23:16];
				W1[counter+3] <= din_w1[31:24];
			end
		end
		else if(load_start) begin		
			if(counter<=15)begin
				B1[counter] <= din_w2[7:0];
				B1[counter+1] <= din_w2[15:8];
				B1[counter+2] <= din_w2[23:16];
				B1[counter+3] <= din_w2[31:24];
				img[counter] <= din_a[7:0];
				img[counter+1] <= din_a[15:8];
				img[counter+2] <= din_a[23:16];
				img[counter+3] <= din_a[31:24];
				W1[counter] <= din_w1[7:0];
				W1[counter+1] <= din_w1[15:8];
				W1[counter+2] <= din_w1[23:16];
				W1[counter+3] <= din_w1[31:24];
			end
			else if(counter <= 31)begin
				B1[counter] <= din_w2[7:0];
				B1[counter+1] <= din_w2[15:8];
				B1[counter+2] <= din_w2[23:16];
				B1[counter+3] <= din_w2[31:24];
			end
			else if(counter <= 43)begin				
				B2[counter-32] <= din_w2[7:0];	
				B2[counter-32+1] <= din_w2[15:8];
				B2[counter-32+2] <= din_w2[23:16];
				B2[counter-32+3] <= din_w2[31:24];				
			end
		end
	end
	always @(posedge clk)begin
		if(load_weight)begin
				if(counter<60)begin
					W2[counter] <= din_w2[7:0];
					W2[counter+1] <= din_w2[15:8];
					W2[counter+2] <= din_w2[23:16];
					W2[counter+3] <= din_w2[31:24];
				end
		end
	end
	always@(*)begin
		if(layer1_start && counter <16)begin
			sum1[0] <= img[counter] * W1[counter];
			sum1[1] <= img[counter+1] * W1[counter+1];
			sum1[2] <= img[counter+2] * W1[counter+2];
			sum1[3] <= img[counter+3] * W1[counter+3];
			sum1[4] <= img[counter+4] * W1[counter+4];
			sum1[5] <= img[counter+5] * W1[counter+5];
			sum1[6] <= img[counter+6] * W1[counter+6];
			sum1[7] <= img[counter+7] * W1[counter+7];

		end
		else begin
			sum1[0] <= 15'b0;
			sum1[1] <= 15'b0;
			sum1[2] <= 15'b0;
			sum1[3] <= 15'b0;
			sum1[4] <= 15'b0;
			sum1[5] <= 15'b0;
			sum1[6] <= 15'b0;
			sum1[7] <= 15'b0;
		end
	end
	/*generate
		for(i=1;i<4;i=i+1)begin
			always @ (*)begin
				partial_sum[i] = partial_sum[i-1] + img[counter1+i]* W1[counter1+counter2*784+i];
			end	
		end
	endgenerate*/
	always@(posedge clk)begin
		if(layer2_start && counter2_1 <30 &&~read)begin
			sum2 <= B[counter2_1] * W2[counter2_2];
		end
		else
			sum2 <= 15'b0;
	end
	/*generate
		for(i=1;i<4;i=i+1)begin
			always @ (*)begin
				partial_sum1[i] = partial_sum1[i-1] + B[counter2_1] * W2[counter2_1+counter3*30];
			end	
		end
	endgenerate*/
	always @ (posedge clk or negedge rst_b)begin
		if(~rst_b)begin
			//temp<= 15'h0;
			sum <= 15'h0;
			k <=0;
			j<=0;
			B1mux <= 0;
		end
		else begin
			if(layer1_start) begin
				if(counter1 == 784)begin
					temp1[counter2] <= sum + B1[counter2];
					//temp[counter2] <= sum;// <= 15'h0;
					sum <= 15'h0;
				end
				else begin
					//temp <=  {partial_sum[3][15],partial_sum[3][11:5]};
					//sum1_truncate <= {sum1[15],sum1[11:5]};
					sum <= sum +sum1_truncate[0]+sum1_truncate[1]+sum1_truncate[2]+sum1_truncate[3]+sum1_truncate[4]+sum1_truncate[5]+sum1_truncate[6]+sum1_truncate[7];
				end
			end
			else begin
				sum <= sum;
			end
		end
	end
	always@(*) begin
			sum1_truncate[0] <= {sum1[0][15],sum1[0][11:5]};
			sum1_truncate[1] <= {sum1[1][15],sum1[1][11:5]};
			sum1_truncate[2] <= {sum1[2][15],sum1[2][11:5]};
			sum1_truncate[3] <= {sum1[3][15],sum1[3][11:5]};
			sum1_truncate[4] <= {sum1[4][15],sum1[4][11:5]};
			sum1_truncate[5] <= {sum1[5][15],sum1[5][11:5]};
			sum1_truncate[6] <= {sum1[6][15],sum1[6][11:5]};
			sum1_truncate[7] <= {sum1[7][15],sum1[7][11:5]};
	end

	always@(posedge clk)begin
		if(sigmoid_start)begin
			temp_sig_in_reg <= temp1[counter2];			
			B[counter2-1] <= temp_sig_out;			
		end
	end
	always @ (posedge clk or negedge rst_b)begin
		if(~rst_b)begin
			temp2<= 15'h0;
			k <=0;
			j<=0;
			B1mux <= 0;
		end
		else begin
			if(layer2_start) begin
				if(counter2_1 == 30)begin
					C[counter3] <= temp2 + B2[counter3];
					temp2 <= 15'h0;
				end
				else begin
					temp2 <=  temp2 + sum2_truncate;
				end
			end
			else begin
				temp2 <=  15'b0;
			end
		end
	end
	always@(*) begin
		if(layer2_start)begin		
			sum2_truncate <= {sum2[15],sum2[11:5]};
		end
		else begin
			sum2_truncate <= 7'b0;
		end
	end
	assign dout = {C[9],C[8],C[7],C[6],C[5],C[4],C[3],C[2],C[1],C[0]};
	
endmodule
	
