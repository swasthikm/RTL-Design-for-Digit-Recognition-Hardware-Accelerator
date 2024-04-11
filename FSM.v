`timescale 1ns/10ps
module FSM (
    input ack,
	input ack1,
	input ack2,
	output req,
	output req1,
	output req2,
	input clk,
	input rst_b,
	input start,
	output [14:0] counter,
	output load_done,
	output done,
	output layer1_start,
	output layer2_start,
	output load_start,
	output load_weight,
	output [3:0] FSM_STATE,
	output [11:0]addr,
	output [14:0]addr1,
	output [11:0]addr2,
	output [10:0] counter1,
	output [4:0] counter2,
	output [4:0] counter3,
	output [6:0] counter2_2,
	output [4:0] counter2_1, 
	output sigmoid_start,
	output read
);

reg	[3:0] next_state, current_state;
reg req_reg,req1_reg,req2_reg,sigmoid_start_reg,sigmoid_done_reg,next;
reg [11:0] current_addr,current_addr2;
reg [14:0] current_addr1;
reg load_done_reg,load_start_reg,done_reg,layer1_start_reg,layer2_start_reg,done_start,layer1_done_reg,layer2_done_reg,read_reg,load_wgh_done_reg,load_weight_reg;
reg [10:0] counter1_reg;
reg [4:0] counter3_reg,counter2_reg,counter2_1_reg;
reg [6:0] counter2_2_reg;
reg [14:0] counter_reg;
reg [1:0] i;

localparam 
	IDLE = 4'b0000,
	READ = 4'b0001,
	WAIT = 4'b0010,
	LOAD = 4'b0011,
	LAYER1 = 4'b0100,
	SIGMOID = 4'b0101,
	WGH_READ = 4'b0110,
	WGH_WAIT = 4'b0111,
	WGH_LOAD = 4'b1000,
	LAYER2 = 4'b1001,
	DONE = 4'b1010;
	assign read = read_reg;
	assign counter = counter_reg;
	assign addr = current_addr; 
	assign addr1 = current_addr1; 
	assign addr2 = current_addr2; 
	assign req = req_reg;
	assign req1 = req1_reg;
	assign req2 = req2_reg;
	assign FSM_STATE = current_state;
	assign load_start = load_start_reg;
	assign load_weight = load_weight_reg;
	assign load_done = load_done_reg;
	assign done = done_reg;
	assign layer1_start = layer1_start_reg;
	assign layer2_start = layer2_start_reg;
	assign counter1 = counter1_reg;
	assign counter2 = counter2_reg;
	assign counter3 = counter3_reg;
	assign counter2_2 = counter2_2_reg;
	assign counter2_1 = counter2_1_reg;
	assign sigmoid_start = sigmoid_start_reg;

	always @ (posedge clk or negedge rst_b)begin
		if(~rst_b)begin
			current_state <= IDLE;
		end
		else begin
			current_state <= next_state;
		end
	end
    always @ (*) begin
		case(current_state)
			IDLE:begin
				if(rst_b)begin
					next_state <= READ;
				end
				else begin
					next_state <= IDLE;
				end
			end
           	READ:begin
				
				next_state <= WAIT;
			end
			WAIT:begin
				if(load_start)begin
					next_state <= LOAD;
				end
				else begin
                    next_state <= WAIT;
                end
			end
            LOAD:begin
				if(layer1_start_reg)begin
                    next_state <= LAYER1;
                end				
				else if(counter_reg < 44)begin
					next_state <= READ;
				end                
				
                else begin
                    next_state <= LOAD;
                end
            end
			LAYER1:begin
				if(sigmoid_start)begin
					next_state <= SIGMOID;
				end
				else if(read_reg) begin
					next_state <= READ;
				end
				else begin
					next_state <= LAYER1;
				end
			end
			SIGMOID:begin
				if(layer1_done_reg)begin
					next_state <= WGH_READ;
				end
				else if(sigmoid_done_reg)begin
					next_state <= LAYER1;
				end
				else begin
					next_state<= SIGMOID;
				end
			end
			WGH_READ:begin
				next_state <= WGH_WAIT;
			end
			WGH_WAIT:begin
				if(load_weight_reg)begin
					next_state <= WGH_LOAD;
				end
				else begin
                    next_state <= WGH_WAIT;
                end
			end
            WGH_LOAD:begin
				if(layer2_start_reg)begin
                    next_state <= LAYER2;
                end				
				else if(counter_reg < 60)begin
					next_state <= WGH_READ;
				end                
				
                else begin
                    next_state <= WGH_LOAD;
                end
            end
			LAYER2:begin
				if(done_start)begin
					next_state <= DONE;
				end
				else if(read_reg)begin
					next_state <= WGH_READ;
				end
				else begin
					next_state <= LAYER2;
				end
			end
			DONE:begin
                    next_state <= READ;
            end
            default:begin
				next_state <= IDLE;
			end
        endcase
    end
	always @ (posedge clk or negedge rst_b) begin
		if(~rst_b)begin
			done_reg <= 1'b0;
			done_start <= 1'b0;
			load_start_reg <=1'b0;
			load_done_reg <= 1'b0;
			current_addr <= 1'b0;
			req_reg <= 0;
			current_addr1 <= 1'b0;
			req2_reg <= 0;
			current_addr2 <= 1'b0;
			load_weight_reg <= 0;
			req1_reg <= 0;
			counter_reg <= 0;
			counter1_reg <= 0;
			counter2_reg <= 0;
			counter3_reg <= 0;
			counter2_2_reg <= 0;
			counter2_1_reg <= 0;
			layer1_start_reg <= 0;
			layer1_done_reg <=0;
			layer2_start_reg <= 0;
			layer2_done_reg <=0;
			sigmoid_done_reg <= 0;
			sigmoid_start_reg <= 0;
			load_wgh_done_reg <= 0;
			i <= 0;
			next <= 0;
			read_reg <= 0;
		end
		else begin
            case(next_state)
				IDLE:begin
                    done_reg <= 1'b0;
					done_start <= 1'b0;
					load_start_reg <= 1'b0;
					load_done_reg <= 1'b0;
					load_wgh_done_reg <= 0;
					current_addr <= 1'b0;
					req_reg <= 0;
					current_addr1 <= 1'b0;
					load_weight_reg <= 0;
					req1_reg <= 0;
					req2_reg <= 0;
					current_addr2 <= 1'b0;
					counter_reg <= 0;
					counter1_reg <= 0;
					counter2_reg <= 0;
					counter3_reg <= 0;
					counter2_2_reg <= 0;
					counter2_1_reg <= 0;
					layer1_start_reg <= 0;
					layer1_done_reg <=0;
					layer2_start_reg <= 0;
					layer2_done_reg <=0;
					sigmoid_start_reg <= 0;
					sigmoid_done_reg <= 0;
					i <=0;
					next <= 0;
					read_reg <= 0;
				end
				READ:begin
					load_done_reg <= 0;
					done_reg <= 0;
				end
				WAIT:begin
					//#10
					load_start_reg <= 1'b1;

				end
						
				LOAD:begin
				if(current_addr ==  196)begin
					current_addr <= 0;
				end
				if(counter_reg > 15 && read_reg)begin
					layer1_start_reg <= 1'b1;
					load_start_reg <= 1'b0;
					counter_reg <= 0;
					read_reg <= 0;
				end
				if(counter_reg > 43)begin
					layer1_start_reg <= 1'b1;
					load_start_reg <= 1'b0;
					counter_reg <= 0;
				end
				if(read & counter_reg<=15) begin
					if(ack && ack1)begin
                        req_reg <= 0;
						req1_reg <= 0;
						load_done_reg <= 1;
						current_addr <= current_addr+1;
						current_addr1 <= current_addr1+1;
						counter_reg <= counter_reg + 4;
						load_start_reg <= 0;
                    end 
                    else begin
                        req_reg <= 1;
                        current_addr <= current_addr;
                        req1_reg <= 1;
                        current_addr1 <= current_addr1;
						counter_reg <= counter_reg;
                    end
				end
				if(counter_reg<=43 & ~read_reg)begin                  
					if(ack2)begin
						req2_reg <= 0;
						load_done_reg <= 1;
						current_addr2 <= current_addr2+1;
						counter_reg <= counter_reg + 4;
						load_start_reg <= 0;
                    end 
                    else begin
						req2_reg <= 1;
                        current_addr2 <= current_addr2;
						counter_reg <= counter_reg;
                    end	
				end
				if(counter_reg<=15 & ~read)begin		
					if(ack && ack1)begin
                        req_reg <= 0;
						req1_reg <= 0;
						load_done_reg <= 1;
						current_addr <= current_addr+1;
						current_addr1 <= current_addr1+1;
						counter_reg <= counter_reg + 4;
						load_start_reg <= 0;
                    end 
                    else begin
                        req_reg <= 1;
                        current_addr <= current_addr;
                        req1_reg <= 1;
                        current_addr1 <= current_addr1;
						counter_reg <= counter_reg;
                    end
				end
				end
				LAYER1:begin
					
					if(counter_reg < 16 )begin
						counter_reg <= counter_reg + 1'b1;
						
					end
					if(counter_reg == 16 && counter1_reg < 784)begin
						counter_reg <= 0;
						counter1_reg <= counter1_reg + 16;
						layer1_start_reg <= 0;
						read_reg <= 1;
					end
						
					if(counter1_reg == 784)begin
						sigmoid_start_reg <= 1;
						counter1_reg <= 0;
						layer1_start_reg <= 0;
						sigmoid_done_reg <= 0;
						read_reg <= 0;
					end		
				end
				SIGMOID:begin
					if(counter2_reg == 30)begin
						counter1_reg <= 0;
						counter2_reg <= 0;
						layer1_start_reg <= 0;
						layer1_done_reg <= 1;
						counter_reg <= 0;
						current_addr1 <= 0;
						current_addr1 <= 0;
					end
					else begin
						counter2_reg <= counter2_reg + 1;
						layer1_start_reg <= 1;
						sigmoid_done_reg <= 1;
						sigmoid_start_reg <= 0;
						counter_reg <= 0;
					end
				end
				WGH_READ:begin
					//$display(" addr2 %d",current_addr2);
					load_wgh_done_reg <= 0;
				end
				WGH_WAIT:begin
					load_weight_reg <= 1'b1;
					read_reg <= 0;
				end
				WGH_LOAD:begin
					if(counter_reg==60)begin
						counter_reg <= 0;
						layer2_start_reg <= 1'b1;
					end
					if(counter_reg < 60)begin
						if(ack2)begin
							req2_reg <= 0;
							load_wgh_done_reg <= 1;
							current_addr2 <= current_addr2+1;
							counter_reg <= counter_reg + 4;
							load_weight_reg <= 0;
                   		end 
                    	else begin
							req2_reg <= 1;
                        	current_addr2 <= current_addr2;
							counter_reg <= counter_reg;
							layer2_start_reg <= 1'b0;
                   		end	
					end
				end
						
				LAYER2:begin
					if(counter3_reg == 10)begin
						done_start <= 1'b1;
						counter3_reg <= 0;
						current_addr <= 0;
						current_addr1 <= 0;
						current_addr2 <= 0;
						layer2_start_reg <= 0;
						read_reg <= 0;
					end				
					
					if(counter2_2_reg < 60)begin
						counter2_1_reg <= counter2_1_reg +1;
						counter2_2_reg <= counter2_2_reg +1;
					end
					
					if(counter2_1_reg == 30)begin
						counter2_1_reg <= 0;
						if(counter2_2_reg < 60)begin
							counter2_2_reg <= 30;
						end 
						counter3_reg <= counter3_reg +1;
					end	
					if(counter2_2_reg == 60 && counter3_reg < 9 )begin
						counter2_2_reg <=0;
						read_reg <= 1;
					end
					
				end
				DONE:begin
					done_reg <= 1'b1;
					done_start <= 1'b0;
					load_start_reg <= 1'b0;
					load_done_reg <= 1'b0;
					load_wgh_done_reg <= 0;
					current_addr <= 1'b0;
					req_reg <= 0;
					current_addr1 <= 1'b0;
					load_weight_reg <= 0;
					req1_reg <= 0;
					req2_reg <= 0;
					current_addr2 <= 1'b0;
					counter_reg <= 0;
					counter1_reg <= 0;
					counter2_reg <= 0;
					counter3_reg <= 0;
					counter2_2_reg <= 0;
					counter2_1_reg <= 0;
					layer1_start_reg <= 0;
					layer1_done_reg <=0;
					layer2_start_reg <= 0;
					layer2_done_reg <=0;
					sigmoid_start_reg <= 0;
					sigmoid_done_reg <= 0;
					i <=0;
					next <= 0;
					read_reg <= 0;
				end
			endcase
		end
	end


endmodule







			


