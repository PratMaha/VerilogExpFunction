
module priority_encoder(
			input [24:0] significand,
			input [7:0] Exponent_a,
			output reg [24:0] Significand,
			output [7:0] Exponent_sub
			);

reg [4:0] shift;

always @(significand)
begin
	casex (significand)
		25'b1_1xxx_xxxx_xxxx_xxxx_xxxx_xxxx :	begin
													Significand = significand;
									 				shift = 5'd0;
								 			  	end
		25'b1_01xx_xxxx_xxxx_xxxx_xxxx_xxxx : 	begin						
										 			Significand = significand << 1;
									 				shift = 5'd1;
								 			  	end

		25'b1_001x_xxxx_xxxx_xxxx_xxxx_xxxx : 	begin						
										 			Significand = significand << 2;
									 				shift = 5'd2;
								 				end

		25'b1_0001_xxxx_xxxx_xxxx_xxxx_xxxx : 	begin 							
													Significand = significand << 3;
								 	 				shift = 5'd3;
								 				end

		25'b1_0000_1xxx_xxxx_xxxx_xxxx_xxxx : 	begin						
									 				Significand = significand << 4;
								 	 				shift = 5'd4;
								 				end

		25'b1_0000_01xx_xxxx_xxxx_xxxx_xxxx : 	begin						
									 				Significand = significand << 5;
								 	 				shift = 5'd5;
								 				end

		25'b1_0000_001x_xxxx_xxxx_xxxx_xxxx : 	begin						// 24'h020000
									 				Significand = significand << 6;
								 	 				shift = 5'd6;
								 				end

		25'b1_0000_0001_xxxx_xxxx_xxxx_xxxx : 	begin						// 24'h010000
									 				Significand = significand << 7;
								 	 				shift = 5'd7;
								 				end

		25'b1_0000_0000_1xxx_xxxx_xxxx_xxxx : 	begin						// 24'h008000
									 				Significand = significand << 8;
								 	 				shift = 5'd8;
								 				end

		25'b1_0000_0000_01xx_xxxx_xxxx_xxxx : 	begin						// 24'h004000
									 				Significand = significand << 9;
								 	 				shift = 5'd9;
								 				end

		25'b1_0000_0000_001x_xxxx_xxxx_xxxx : 	begin						// 24'h002000
									 				Significand = significand << 10;
								 	 				shift = 5'd10;
								 				end

		25'b1_0000_0000_0001_xxxx_xxxx_xxxx : 	begin						// 24'h001000
									 				Significand = significand << 11;
								 	 				shift = 5'd11;
								 				end

		25'b1_0000_0000_0000_1xxx_xxxx_xxxx : 	begin						// 24'h000800
									 				Significand = significand << 12;
								 	 				shift = 5'd12;
								 				end

		25'b1_0000_0000_0000_01xx_xxxx_xxxx : 	begin						// 24'h000400
									 				Significand = significand << 13;
								 	 				shift = 5'd13;
								 				end

		25'b1_0000_0000_0000_001x_xxxx_xxxx : 	begin						// 24'h000200
									 				Significand = significand << 14;
								 	 				shift = 5'd14;
								 				end

		25'b1_0000_0000_0000_0001_xxxx_xxxx  : 	begin						// 24'h000100
									 				Significand = significand << 15;
								 	 				shift = 5'd15;
								 				end

		25'b1_0000_0000_0000_0000_1xxx_xxxx : 	begin						// 24'h000080
									 				Significand = significand << 16;
								 	 				shift = 5'd16;
								 				end

		25'b1_0000_0000_0000_0000_01xx_xxxx : 	begin						// 24'h000040
											 		Significand = significand << 17;
										 	 		shift = 5'd17;
												end

		25'b1_0000_0000_0000_0000_001x_xxxx : 	begin						// 24'h000020
									 				Significand = significand << 18;
								 	 				shift = 5'd18;
								 				end

		25'b1_0000_0000_0000_0000_0001_xxxx : 	begin						// 24'h000010
									 				Significand = significand << 19;
								 	 				shift = 5'd19;
												end

		25'b1_0000_0000_0000_0000_0000_1xxx :	begin						// 24'h000008
									 				Significand = significand << 20;
								 					shift = 5'd20;
								 				end

		25'b1_0000_0000_0000_0000_0000_01xx : 	begin						// 24'h000004
									 				Significand = significand << 21;
								 	 				shift = 5'd21;
								 				end

		25'b1_0000_0000_0000_0000_0000_001x : 	begin						// 24'h000002
									 				Significand = significand << 22;
								 	 				shift = 5'd22;
								 				end

		25'b1_0000_0000_0000_0000_0000_0001 : 	begin						// 24'h000001
									 				Significand = significand << 23;
								 	 				shift = 5'd23;
								 				end

		25'b1_0000_0000_0000_0000_0000_0000 : 	begin						// 24'h000000
								 					Significand = significand << 24;
							 	 					shift = 5'd24;
								 				end
		default : 	begin
						Significand = (~significand) + 1'b1;
						shift = 8'd0;
					end

	endcase
end
assign Exponent_sub = Exponent_a - shift;

endmodule

module fl_multi(input [31:0] a_operand, input [31:0] b_operand, output reg Exception, output reg Overflow, output reg Underflow, output reg [31:0] result, input run, input clk);
reg sign,product_round,normalised,zero;
reg [8:0] exponent,sum_exponent;
reg [22:0] product_mantissa;
reg [23:0] operand_a,operand_b;
reg [47:0] product,product_normalised; //48 Bits
always@(posedge clk)
begin
if(run)
begin
sign = a_operand[31] ^ b_operand[31];
Exception = (&a_operand[30:23]) | (&b_operand[30:23]);
operand_a = (|a_operand[30:23]) ? {1'b1,a_operand[22:0]} : {1'b0,a_operand[22:0]};
operand_b = (|b_operand[30:23]) ? {1'b1,b_operand[22:0]} : {1'b0,b_operand[22:0]};
product = operand_a * operand_b;	
product_round = |product_normalised[22:0];
normalised = product[47] ? 1'b1 : 1'b0;
product_normalised = normalised ? product : product << 1;
product_mantissa = product_normalised[46:24] + (product_normalised[23] & product_round); 
zero = Exception ? 1'b0 : (product_mantissa == 23'd0) ? 1'b1 : 1'b0;
sum_exponent = a_operand[30:23] + b_operand[30:23];
exponent = sum_exponent - 8'd127 + normalised;
Overflow = ((exponent[8] & !exponent[7]) & !zero) ; //If overall exponent is greater than 255 then Overflow condition.
Underflow = ((exponent[8] & exponent[7]) & !zero) ? 1'b1 : 1'b0; 
result = Exception ? 32'd0 : zero ? {sign,31'd0} : Overflow ? {sign,8'hFF,23'd0} : Underflow ? {sign,31'd0} : {sign,exponent[7:0],product_mantissa};
end
//$display("A= %h",a_operand);
//$display("B= %h",b_operand);
//$display("R= %h",result);
end
endmodule

module fl_adder(input [31:0] a_operand,b_operand, input AddBar_Sub, output reg Exception, output reg [31:0] result, input clk, input run);
reg operation_sub_addBar;
reg Comp_enable;
reg output_sign;
reg [31:0] operand_a,operand_b;
reg exp_a, exp_b;
reg [23:0] significand_a,significand_b;
reg [7:0] exponent_diff;
reg [23:0] significand_b_add_sub;
reg [7:0] exponent_b_add_sub;
reg [24:0] significand_add;
reg [30:0] add_sum;
reg check_sign;
reg perform;
reg [23:0] significand_sub_complement;
reg [24:0] significand_sub;
reg [30:0] sub_diff;
wire [24:0] subtraction_diff; 
wire [7:0] exponent_sub;
priority_encoder pe(significand_sub,operand_a[30:23],subtraction_diff,exponent_sub);

always @ (posedge clk)
begin
check_sign= a_operand[31] ^ b_operand[31];
if(run & (~check_sign))
begin
{Comp_enable,operand_a,operand_b} = (a_operand[30:0] < b_operand[30:0]) ? {1'b1,b_operand,a_operand} : {1'b0,a_operand,b_operand};
exp_a = operand_a[30:23];
exp_b = operand_b[30:23];
Exception = (&operand_a[30:23]) | (&operand_b[30:23]);
output_sign = AddBar_Sub ? Comp_enable ? !operand_a[31] : operand_a[31] : operand_a[31] ;
operation_sub_addBar = AddBar_Sub ? operand_a[31] ^ operand_b[31] : ~(operand_a[31] ^ operand_b[31]);
significand_a = (|operand_a[30:23]) ? {1'b1,operand_a[22:0]} : {1'b0,operand_a[22:0]};
significand_b = (|operand_b[30:23]) ? {1'b1,operand_b[22:0]} : {1'b0,operand_b[22:0]};
exponent_diff = operand_a[30:23] - operand_b[30:23];
significand_b_add_sub = significand_b >> exponent_diff;
exponent_b_add_sub = operand_b[30:23] + exponent_diff; 
perform = (operand_a[30:23] == exponent_b_add_sub);
significand_add = (perform & operation_sub_addBar) ? (significand_a + significand_b_add_sub) : 25'd0; 
add_sum[22:0] = significand_add[24] ? significand_add[23:1] : significand_add[22:0];
add_sum[30:23] = significand_add[24] ? (1'b1 + operand_a[30:23]) : operand_a[30:23];
result = Exception ? 32'b0 : ({output_sign,add_sum});
end
//$display("A= %h",a_operand);
//$display("B= %h",b_operand);
//$display("R= %h",result);
end

always @ (posedge clk)
begin
check_sign= a_operand[31] ^ b_operand[31];
if(run & (check_sign))
begin
$display("LEG");
{Comp_enable,operand_a,operand_b} = (a_operand[30:0] < b_operand[30:0]) ? {1'b1,b_operand,a_operand} : {1'b0,a_operand,b_operand};
exp_a = operand_a[30:23];
exp_b = operand_b[30:23];
Exception = (&operand_a[30:23]) | (&operand_b[30:23]);
output_sign = AddBar_Sub ? Comp_enable ? !operand_a[31] : operand_a[31] : operand_a[31] ;
//$display(output_sign);
operation_sub_addBar = AddBar_Sub ? operand_a[31] ^ operand_b[31] : ~(operand_a[31] ^ operand_b[31]);
$display(operation_sub_addBar);
significand_a = (|operand_a[30:23]) ? {1'b1,operand_a[22:0]} : {1'b0,operand_a[22:0]};
significand_b = (|operand_b[30:23]) ? {1'b1,operand_b[22:0]} : {1'b0,operand_b[22:0]};
exponent_diff = operand_a[30:23] - operand_b[30:23];
significand_b_add_sub = significand_b >> exponent_diff;
exponent_b_add_sub = operand_b[30:23] + exponent_diff; 
perform = (operand_a[30:23] == exponent_b_add_sub);
significand_sub_complement = (perform & !operation_sub_addBar) ? ~(significand_b_add_sub) + 24'd1 : 24'd0 ; 
significand_sub = perform ? (significand_a + significand_sub_complement) : 25'd0;
#3
sub_diff[30:23] = exponent_sub;
sub_diff[22:0] = subtraction_diff[22:0];
result = Exception ? 32'b0 : {output_sign,sub_diff};
end
end
endmodule

module memory(output reg [31:0] memOut, input [7:0] address, input [31:0] dataIn, input clk, input readEnable, input writeEnable, input initializeMemory, input printOutput);
reg [31:0] mem [0:202];
integer i, f;

always @ (posedge initializeMemory)
	begin
	$readmemh("Input.txt", mem);
	$display("Data read");
	//for (i=0; i<2; i=i+1)
	//	$display("%h",mem[i]);
	end

always @ (posedge printOutput)
begin
	f = $fopen("Result.txt", "w");
		if (f)  $display("File was opened successfully : %0d", f);
		else    $display("File was NOT opened successfully : %0d", f);		
		for(i = 0; i < 203; i = i+1)
			begin
			$display("Memory: %h",mem[i]);
			$fwrite(f, "%h\n", mem[i]);
			end
		$fclose(f);
end

always @ (posedge clk)
begin
	if(readEnable)
		begin
		$display("Address: %h",address);
		memOut <= mem[address];
		$display("Data Read is %h",mem[address]);
		end
	else if (writeEnable)
		begin
		mem[address] <= dataIn;
		$display("Address: %h",address);
		$display("Data in is %h",dataIn);
		end
	else memOut <= 31'd0;
end

endmodule

module control_unit(output reg rEn1, output reg wEn2, output reg printOutput, input clk, output reg run_multi1, output reg run_adder1, output reg run_multi2, output reg run_adder2, output reg run_multi3, output reg run_adder3, output reg run_multi4, output reg exp_f, input[7:0] state_count, output reg state_check);
reg[3:0] curr, next;
localparam idle = 4'd0, mem_read = 4'd1, s1 = 4'd2, s2 = 4'd3, s3 = 4'd4, s4 = 4'd5, s5 = 4'd6, s6 = 4'd7, s7 = 4'd8, s8 = 4'd9, init=4'd10, s10=4'd11, s11=4'd12, s12=4'd13, s13=4'd14;
initial
begin
curr<=init;
next<=init;
end

always @(negedge clk)
begin
curr<=next;
//$display("Change");
end

always @(posedge clk)
begin
case(curr)
idle:
	begin
	rEn1<=1'b0;
	wEn2<=1'b0;
	printOutput<=1'b0;
	exp_f<=1'b0;
	run_multi1<=1'b0;
	run_adder1<=1'b0;
	run_multi2<=1'b0;
	run_adder2<=1'b0;
	run_multi3<=1'b0;
	run_adder3<=1'b0;
	run_multi4<=1'b0;
	state_check<=1'b0;
	$display("idle");
	end
init:
	begin
	rEn1<=1'b0;
	wEn2<=1'b0;
	printOutput<=1'b0;
	exp_f<=1'b0;
	run_multi1<=1'b0;
	run_adder1<=1'b0;
	run_multi2<=1'b0;
	run_adder2<=1'b0;
	run_multi3<=1'b0;
	run_adder3<=1'b0;
	run_multi4<=1'b0;
	state_check<=1'b0;
	//$display("init");
	next<=mem_read;
	end
mem_read:
	begin
	$display("Mem_Read");
	rEn1<=1'b1;
	wEn2<=1'b0;
	printOutput<=1'b0;
	exp_f<=1'b0;
	run_multi1<=1'b0;
	run_adder1<=1'b0;
	run_multi2<=1'b0;
	run_adder2<=1'b0;
	run_multi3<=1'b0;
	run_adder3<=1'b0;
	run_multi4<=1'b0;
	next<=s1;
	state_check<=1'b0;
	end
s1:
	begin
	$display("S1");
	rEn1<=1'b0;
	wEn2<=1'b0;
	printOutput<=1'b0;
	exp_f<=1'b0;
	run_multi1<=1'b1;
	run_adder1<=1'b0;
	run_multi2<=1'b0;
	run_adder2<=1'b0;
	run_multi3<=1'b0;
	run_adder3<=1'b0;
	run_multi4<=1'b0;
	next<=s2;
	end
s2:
	begin
	$display("S2");
	rEn1<=1'b0;
	wEn2<=1'b0;
	printOutput<=1'b0;
	exp_f<=1'b0;
	run_multi1<=1'b0;
	run_adder1<=1'b0;
	run_multi2<=1'b1;
	run_adder2<=1'b0;
	run_multi3<=1'b1;
	run_adder3<=1'b0;
	run_multi4<=1'b0;
	next<=s10;
	end
s10:
	begin
	//$display("S2");
	rEn1<=1'b0;
	wEn2<=1'b0;
	printOutput<=1'b0;
	exp_f<=1'b0;
	run_multi1<=1'b0;
	run_adder1<=1'b0;
	run_multi2<=1'b1;
	run_adder2<=1'b0;
	run_multi3<=1'b1;
	run_adder3<=1'b0;
	run_multi4<=1'b0;
	next<=s3;
	end
s3:
	begin
	$display("S3");
	rEn1<=1'b0;
	wEn2<=1'b0;
	printOutput<=1'b0;
	exp_f<=1'b0;
	run_multi1<=1'b0;
	run_adder1<=1'b0;
	run_multi2<=1'b0;
	run_adder2<=1'b0;
	run_multi3<=1'b0;
	run_adder3<=1'b0;
	run_multi4<=1'b1;
	next<=s11;
	end
s11:
	begin
	rEn1<=1'b0;
	wEn2<=1'b0;
	printOutput<=1'b0;
	exp_f<=1'b0;
	run_multi1<=1'b0;
	run_adder1<=1'b0;
	run_multi2<=1'b0;
	run_adder2<=1'b0;
	run_multi3<=1'b0;
	run_adder3<=1'b0;
	run_multi4<=1'b0;
	next<=s4;
	//$display("S4");
	end
s4:
	begin
	$display("S4");
	rEn1<=1'b0;
	wEn2<=1'b0;
	printOutput<=1'b0;
	exp_f<=1'b0;
	run_multi1<=1'b0;
	run_adder1<=1'b1;
	run_multi2<=1'b0;
	run_adder2<=1'b1;
	run_multi3<=1'b0;
	run_adder3<=1'b0;
	run_multi4<=1'b0;
	next<=s13;
	end
s12:
	begin
	rEn1<=1'b0;
	wEn2<=1'b0;
	printOutput<=1'b0;
	exp_f<=1'b0;
	run_multi1<=1'b0;
	run_adder1<=1'b1;
	run_multi2<=1'b0;
	run_adder2<=1'b1;
	run_multi3<=1'b0;
	run_adder3<=1'b0;
	run_multi4<=1'b0;
	next<=s13;
	//$display("S4");
	end
s13:
	begin
	rEn1<=1'b0;
	wEn2<=1'b0;
	printOutput<=1'b0;
	exp_f<=1'b0;
	run_multi1<=1'b0;
	run_adder1<=1'b0;
	run_multi2<=1'b0;
	run_adder2<=1'b0;
	run_multi3<=1'b0;
	run_adder3<=1'b0;
	run_multi4<=1'b0;
	next<=s5;
	//$display("S4");
	end
s5:
	begin
	$display("S5");
	rEn1<=1'b0;
	wEn2<=1'b0;
	printOutput<=1'b0;
	exp_f<=1'b0;
	run_multi1<=1'b0;
	run_adder1<=1'b0;
	run_multi2<=1'b0;
	run_adder2<=1'b0;
	run_multi3<=1'b0;
	run_adder3<=1'b1;
	run_multi4<=1'b0;
	next<=s6;
	end
s6:
	begin
	$display("S6");
	rEn1<=1'b0;
	wEn2<=1'b0;
	printOutput<=1'b0;
	exp_f<=1'b1;
	run_multi1<=1'b0;
	run_adder1<=1'b0;
	run_multi2<=1'b0;
	run_adder2<=1'b0;
	run_multi3<=1'b0;
	run_adder3<=1'b0;
	run_multi4<=1'b0;
	next<=s7;
	end
s7:
	begin
	rEn1<=1'b0;
	wEn2<=1'b1;
	printOutput<=1'b0;
	exp_f<=1'b0;
	run_multi1<=1'b0;
	run_adder1<=1'b0;
	run_multi2<=1'b0;
	run_adder2<=1'b0;
	run_multi3<=1'b0;
	run_adder3<=1'b0;
	run_multi4<=1'b0;
	$display("State_count= %4b",state_count);
	if(state_count<8'd203)
		begin
		state_check<=1'b1;
		next<=mem_read;
		end
	else
		next<=s8;
	//$display("S7");
	end
s8:
	begin
	$display("S8");
	rEn1<=1'b0;
	wEn2<=1'b0;
	printOutput<=1'b1;
	exp_f<=1'b0;
	run_multi1<=1'b0;
	run_adder1<=1'b0;
	run_multi2<=1'b0;
	run_adder2<=1'b0;
	run_multi3<=1'b0;
	run_adder3<=1'b0;
	run_multi4<=1'b0;
	next<=idle;
	end
endcase
end
endmodule 

module exponential(input rst, input clk);
wire[31:0] Y;
reg[31:0] X; 
wire run_adder1, run_multi1;
wire run_adder2, run_multi2;
wire run_adder3, run_multi3;
wire run_multi4;
wire except, overflow, underflow; 
reg[31:0] A,B;
wire[31:0] C,D;
wire[31:0] exp;
reg[31:0] exp_final;
reg[7:0] address1, address2;
reg[31:0] t1,t2,t3,t4;
wire[31:0] t11,t22,t33,t44;
reg[31:0] c1,c2,c3;
wire rEn1, wEn2;
wire exp_f;
reg[7:0] state_count;
wire state_check;
memory InputMemory (Y, address1, 32'd0, clk, rEn1, 1'b0, rst, 1'b0);
fl_multi M1(X,X, except, overflow, underflow, t11, run_multi1, clk);
fl_multi M2(t1, X, except, overflow, underflow, t22, run_multi2, clk);
fl_multi D1(t1, c2, except, overflow, underflow, t33, run_multi3, clk);
fl_multi D2(t2, c3, except, overflow, underflow, t44, run_multi4, clk);
fl_adder adder1(c1, t3, 1'b0, except, C, run_adder1, clk);
fl_adder adder2(X, t4, 1'b0, except, D, run_adder2, clk);
fl_adder adder3(A, B, 1'b0, except, exp, run_adder3, clk); 
control_unit cu(rEn1, wEn2, printOutput, clk, run_multi1, run_adder1, run_multi2, run_adder2, run_multi3, run_adder3, run_multi4, exp_f, state_count, state_check); 
memory storeMemory (notNeeded, address2, exp_final, clk, 1'b0, wEn2, 1'b0, printOutput);

always@(negedge run_adder1)
begin
$display("C: %h",C);
A=C;
$display("A: %h",A);
end

always@(negedge run_adder2)
begin
$display("D: %h",D);
B=D;
$display("B: %h",B);
end

always@(negedge rEn1)
begin
$display("Y: %h",Y);
X=Y;
$display("X: %h",X);
end

always@(negedge run_multi1)
begin
t1=t11;
$display("t1: %h",t1);
end

always@(negedge run_multi2)
begin
t2=t22;
$display("t2: %h",t22);
end

always@(negedge run_multi3)
begin
t3=t33;
$display("t3: %h",t33);
end

always@(negedge run_multi4)
begin
t4=t44;
$display("t4: %h",t4);
end

always@(rst)
begin
if(rst)
begin
	c1<=32'b00111111100000000000000000000000;
	c2<=32'b00111111000000000000000000000000;
	c3<=32'b00111110001010110000001000001100;
	state_count<=4'd0;
	address1<=8'd0;
	address2<=8'd0;
	X<=32'd0;
end
end

always@(negedge run_adder3)
begin
exp_final=exp;
end

always@(posedge clk)
begin
if(state_check)
	begin
	state_count=state_count+8'd1;
	address1=address1+8'd1;
	#5 address2=address2+8'd1;
	end
end

endmodule

module tb();
reg rst, clk;
exponential dut(.rst(rst), .clk(clk));
initial
		begin
		clk = 1'b0;
		forever
		#10 clk = ~clk;
		end
initial
		begin
		rst=1'b0;
		#4 rst=1'b1;
		#4 rst=1'b0;
		#50000 $finish;
		end
endmodule