`default_nettype none
module Core (CLOCK_50, KEY, SW, LEDR, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0 
      );
  
  input   logic                    CLOCK_50;
  
  //////////// LED //////////
  output     logic      [9:0]      LEDR;
  
  //////////// KEY //////////
  input   logic         [3:0]      KEY;
  
  //////////// SW //////////
  input    logic        [9:0]      SW;
  
  //////////// SEG7 //////////
  output      logic     [6:0]      HEX0;
  output  logic         [6:0]      HEX1;
  output   logic        [6:0]      HEX2;
  output    logic       [6:0]      HEX3;
  output    logic       [6:0]      HEX4;
  output    logic       [6:0]      HEX5;
  
  //hex display inputs
  logic [3:0]inHEX0;
  logic [3:0]inHEX1;
  logic [3:0]inHEX2;
  logic [3:0]inHEX3;
  logic [3:0]inHEX4;
  logic [3:0]inHEX5;
  logic reset;
  logic start_done1, start_done2, start_done3, start_done4;

//clock i used to debug
  wire debug_clk;
  Clock_divider debugclk(
    .clock_in(CLOCK_50),
    .reset(1'b0),
    .DIVISOR(32'd50000), 
    .clock_out(debug_clk)
    );
	 
  
  //Seven Segment 
SevenSegmentDisplayDecoder U0(HEX0, inHEX0);
SevenSegmentDisplayDecoder U1(HEX1, inHEX1);
SevenSegmentDisplayDecoder U2(HEX2, inHEX2);
SevenSegmentDisplayDecoder U3(HEX3, inHEX3);
SevenSegmentDisplayDecoder U4(HEX4, inHEX4);
SevenSegmentDisplayDecoder U5(HEX5, inHEX5);
//internal wires
logic no_key1,no_key2,no_key3,no_key4;
reg start1, start2, start3,start4;
logic finish1,finish2,finish3,finish4;
logic [23:0] secret_key1,secret_key2,secret_key3,secret_key4;
logic keyfound1,keyfound2,keyfound3,keyfound4;
logic reset_core1,reset_core2,reset_core3,reset_core4;
//Display key on HEX display
assign inHEX0 = ((keyfound1)?secret_key1[3:0]:(keyfound2)?secret_key2[3:0]:(keyfound3)?secret_key3[3:0]:(keyfound4)?secret_key4[3:0]:secret_key2[3:0]);
assign inHEX1 = ((keyfound1)?secret_key1[7:4]:(keyfound2)?secret_key2[7:4]:(keyfound3)?secret_key3[7:4]:(keyfound4)?secret_key4[7:4]:secret_key2[7:4]);
assign inHEX2 = ((keyfound1)?secret_key1[11:8]:(keyfound2)?secret_key2[11:8]:(keyfound3)?secret_key3[11:8]:(keyfound4)?secret_key4[11:8]:secret_key2[11:8]);
assign inHEX3 = ((keyfound1)?secret_key1[15:12]:(keyfound2)?secret_key2[15:12]:(keyfound3)?secret_key3[15:12]:(keyfound4)?secret_key4[15:12]:secret_key2[15:12]);
assign inHEX4 = ((keyfound1)?secret_key1[19:16]:(keyfound2)?secret_key2[19:16]:(keyfound3)?secret_key3[19:16]:(keyfound4)?secret_key4[19:16]:secret_key2[19:16]);
assign inHEX5 = ((keyfound1)?secret_key1[23:20]:(keyfound2)?secret_key2[23:20]:(keyfound3)?secret_key3[23:20]:(keyfound4)?secret_key4[23:20]:secret_key2[23:20]);


  //reset
  assign reset = ~KEY[3];
  
  //logic CLK_50M;
  logic CLK_50M;
  logic  [9:0] LED;
  assign CLK_50M =  CLOCK_50;
  assign LEDR[9:0] = LED[9:0];

//min and max declerations for each core secret keys
parameter [23:0] max_key4 = 24'h3FFFFF;
parameter [23:0] max_key3 = 24'h2FFFFF;
parameter [23:0] max_key2 = 24'h1FFFFF;
parameter [23:0] max_key1 = 24'h0FFFFF;
parameter [23:0] min_key4 = 24'h300000;
parameter [23:0] min_key3 = 24'h200000;
parameter [23:0] min_key2 = 24'h100000;
parameter [23:0] min_key1 = 24'h000000;
//LED assignments, LED 0 and 1 light up when key is found
assign LED[0] = (keyfound1||keyfound2||keyfound3||keyfound4);
assign LED[1] = (keyfound1||keyfound2||keyfound3||keyfound4);
// LED 9 lights up when no key is found and all processes finish
assign LED[9] = ((no_key1&&secret_key1==max_key1)||(no_key2&&secret_key2==max_key2)||(no_key3&&secret_key3==max_key3)||(no_key4&&secret_key4==max_key4));


//first core
SubCore core1 (
  .start(start1),
  .reset(reset_core1),
  .finish(finish1),

   .CLOCK_50(CLK_50M), // inputs

   .secret_key(secret_key1),
	.keyfound(keyfound1),
	.start_done(start_done1)
   );
//second core 
	SubCore core2 (
  .start(start2),
  .reset(reset_core2),
  .finish(finish2),

   .CLOCK_50(CLK_50M), // inputs

   .secret_key(secret_key2),
	.keyfound(keyfound2),
	.start_done(start_done2)
   );
//third core
	SubCore core3 (
  .start(start3),
  .reset(reset_core3),
  .finish(finish3),

   .CLOCK_50(CLK_50M), // inputs

   .secret_key(secret_key3),
	.keyfound(keyfound3),
	.start_done(start_done3)
   );
//fourth core
	SubCore core4 (
  .start(start4),
  .reset(reset_core4),
  .finish(finish4),

   .CLOCK_50(CLK_50M), // inputs

   .secret_key(secret_key4),
	.keyfound(keyfound4),
	.start_done(start_done4)
   );
//state wire for each core
	reg[3:0] state1,state2,state3,state4;
	//state decleration
   parameter [3:0] initial_state_core1= 4'b0000;
   parameter [3:0] start_next_key1= 4'b0001;
   parameter [3:0] start_search1= 4'b0010;
   parameter [3:0] wait_for_depress1= 4'b0011;
   parameter [3:0] check_for_success1= 4'b0100;
   parameter [3:0] check_max_secret_key1= 4'b0101;
   parameter [3:0] increment_secret_key1= 4'b0110;
   parameter [3:0] failed_key_core1= 4'b0111;
   parameter [3:0] depress_reset1 = 4'b1000;
	parameter [3:0] success_key_state1 = 4'b1001;

	//core handler
	always_ff @(posedge CLK_50M, posedge reset) begin
	if (reset) begin
	state1 <= initial_state_core1;
	start1<= 1'b0;
	secret_key1 <= min_key1;
	reset_core1 <=1'b1;
   no_key1 <=1'b0;
   end

	else begin 
		case (state1)
			initial_state_core1: begin
			start1<= 1'b0;
			secret_key1 <= min_key1;
			state1 <= depress_reset1;//assign secret key to the minimum value of secret key for core
         reset_core1 <=1'b1; //resets sub core
         no_key1 <=1'b0;//initialize no key
			end
			
         start_next_key1: begin 
            start1<= 1'b0;
            state1<= depress_reset1;//state to jump to when iteration done
            reset_core1 <=1'b1;
       
         end

         depress_reset1: begin
            state1<= start_search1; //lower reset core flag
            reset_core1 <=1'b0;
         end

			start_search1: begin 
			if ( keyfound1 || keyfound2 || keyfound3 || keyfound4 ) start1<= 1'b0; //if the key is found in any state then stop search
         else start1 <= 1'b1; //start core iteration for the current secret key 
         state1 <= wait_for_depress1;
			end
			
         wait_for_depress1: begin
         if (start_done1) begin state1 <= check_for_success1; //when the core has started then depress start
			start1<=1'b0;
			end
         else begin state1 <= wait_for_depress1; //if core not start then stay in wait for depress
			end
         end

         check_for_success1: begin
            if (keyfound1 && finish1) state1 <= success_key_state1; // if the core is finished and key is found then go to success state 
            else if (!keyfound1 && finish1) state1 <= check_max_secret_key1; //else go to the state that checks if we are at the max secret key
            else state1 <= check_for_success1;

         end

         check_max_secret_key1:  begin
            if (secret_key1 == max_key1) state1 <= failed_key_core1; // if at max key and no key found then this core failed and did not find a key
            else state1 <= increment_secret_key1;
         end
         increment_secret_key1: begin
            secret_key1 <=secret_key1 + 24'h1; //increment key 
            state1 <= start_next_key1;
         end

         failed_key_core1: begin
            state1 <= failed_key_core1; //if core failed then make no key = 1
            no_key1 <=1'b1;
         end
			
			success_key_state1: begin
			state1 <= success_key_state1;
			end
         default: state1 <= initial_state_core1;
      endcase
   end
end
///////////////////////////////////////////////////////////core 2
parameter [3:0] initial_state_core2= 4'b0000;
   parameter [3:0] start_next_key2= 4'b0001;
   parameter [3:0] start_search2= 4'b0010;
   parameter [3:0] wait_for_depress2= 4'b0011;
   parameter [3:0] check_for_success2= 4'b0100;
   parameter [3:0] check_max_secret_key2= 4'b0101;
   parameter [3:0] increment_secret_key2= 4'b0110;
   parameter [3:0] failed_key_core2= 4'b0111;
   parameter [3:0] depress_reset2 = 4'b1000;
	parameter [3:0] success_key_state2 = 4'b1001;

	
	always_ff @(posedge CLK_50M, posedge reset) begin
	if (reset) begin
	state2 <= initial_state_core2;
	start2<= 1'b0;
	secret_key2 <= min_key2;
	reset_core2 <=1'b1;
   no_key2 <=1'b0;
   end

	else begin 
		case (state2)
			initial_state_core2: begin
			start2<= 1'b0;
			secret_key2 <= min_key2;
			state2 <= depress_reset2;
         reset_core2 <=1'b1;
         no_key2 <=1'b0;
			end
			
         start_next_key2: begin 
            start2<= 1'b0;
            state2<= depress_reset1;
            reset_core2 <=1'b1;
       
         end

         depress_reset2: begin
            state2<= start_search2;
            reset_core2 <=1'b0;
         end

			start_search2: begin 
			if ( keyfound1 || keyfound2 || keyfound3 || keyfound4 ) start2<= 1'b0;
         else start2 <= 1'b1;
         state2 <= wait_for_depress2;
			end
			
         wait_for_depress2: begin
         if (start_done2) begin state2 <= check_for_success2;
			start2<=1'b0;
			end
         else begin state2 <= wait_for_depress2;
			
			end
         end

         check_for_success2: begin
            if (keyfound2 && finish2) state2 <= success_key_state2;
            else if (!keyfound2 && finish2) state2 <= check_max_secret_key2;
            else state2 <= check_for_success2;

         end

         check_max_secret_key2:  begin
            if (secret_key2 == max_key2) state2 <= failed_key_core2;
            else state2 <= increment_secret_key2;
         end
         increment_secret_key2: begin
            secret_key2 <=secret_key2 + 24'h1;
            state2 <= start_next_key2;
         end

         failed_key_core2: begin
            state2 <= failed_key_core2;
            no_key2 <=1'b1;
         end
			
			success_key_state2: begin
			state2 <= success_key_state2;
			end
         default: state2 <= initial_state_core2;
      endcase
   end
end

////////////////////////////////////////////////////////////////core 3

parameter [3:0] initial_state_core3= 4'b0000;
   parameter [3:0] start_next_key3= 4'b0001;
   parameter [3:0] start_search3= 4'b0010;
   parameter [3:0] wait_for_depress3= 4'b0011;
   parameter [3:0] check_for_success3= 4'b0100;
   parameter [3:0] check_max_secret_key3= 4'b0101;
   parameter [3:0] increment_secret_key3= 4'b0110;
   parameter [3:0] failed_key_core3= 4'b0111;
   parameter [3:0] depress_reset3 = 4'b1000;
	parameter [3:0] success_key_state3 = 4'b1001;

	
	always_ff @(posedge CLK_50M, posedge reset) begin
	if (reset) begin
	state3 <= initial_state_core3;
	start3<= 1'b0;
	secret_key3 <= min_key3;
	reset_core3 <=1'b1;
   no_key3 <=1'b0;
   end

	else begin 
		case (state3)
			initial_state_core3: begin
			start3<= 1'b0;
			secret_key3 <= min_key3;
			state3 <= depress_reset3;
         reset_core3 <=1'b1;
         no_key3 <=1'b0;
			end
			
         start_next_key3: begin 
            start3<= 1'b0;
            state3<= depress_reset3;
            reset_core3 <=1'b1;
       
         end

         depress_reset3: begin
            state3<= start_search3;
            reset_core3 <=1'b0;
         end

			start_search3: begin 
			if ( keyfound1 || keyfound2 || keyfound3 || keyfound4 ) start3<= 1'b0;
         else start3 <= 1'b1;
         state3 <= wait_for_depress3;
			end
			
         wait_for_depress3: begin
         if (start_done3) begin state3 <= check_for_success3;
			start3<=1'b0;
			end
         else begin state3 <= wait_for_depress3;
			
			end
         end

         check_for_success3: begin
            if (keyfound3 && finish3) state3 <= success_key_state3;
            else if (!keyfound3 && finish3) state3 <= check_max_secret_key3;
            else state3 <= check_for_success3;

         end

         check_max_secret_key3:  begin
            if (secret_key3 == max_key3) state3 <= failed_key_core3;
            else state3 <= increment_secret_key3;
         end
         increment_secret_key3: begin
            secret_key3 <=secret_key3 + 24'h1;
            state3 <= start_next_key3;
         end

         failed_key_core3: begin
            state3 <= failed_key_core3;
            no_key3 <=1'b1;
         end
			
			success_key_state3: begin
			state3 <= success_key_state3;
			end
         default: state3 <= initial_state_core3;
      endcase
   end
end
//////////////////////////////////////////////////////////core4
parameter [3:0] initial_state_core4= 4'b0000;
   parameter [3:0] start_next_key4= 4'b0001;
   parameter [3:0] start_search4= 4'b0010;
   parameter [3:0] wait_for_depress4= 4'b0011;
   parameter [3:0] check_for_success4= 4'b0100;
   parameter [3:0] check_max_secret_key4= 4'b0101;
   parameter [3:0] increment_secret_key4= 4'b0110;
   parameter [3:0] failed_key_core4= 4'b0111;
   parameter [3:0] depress_reset4 = 4'b1000;
	parameter [3:0] success_key_state4 = 4'b1001;
	
	always_ff @(posedge CLK_50M, posedge reset) begin
	if (reset) begin
	state4 <= initial_state_core4;
	start4<= 1'b0;
	secret_key4 <= min_key4;
	reset_core4 <=1'b1;
   no_key4 <=1'b0;
   end

	else begin 
		case (state4)
			initial_state_core4: begin
			start4<= 1'b0;
			secret_key4 <= min_key4;
			state4 <= depress_reset4;
         reset_core4 <=1'b1;
         no_key4 <=1'b0;
			end
			
         start_next_key4: begin 
            start4<= 1'b0;
            state4<= depress_reset4;
            reset_core4 <=1'b1;
       
         end

         depress_reset4: begin
            state4<= start_search4;
            reset_core4 <=1'b0;
         end

			start_search4: begin 
			if ( keyfound1 || keyfound2 || keyfound3 || keyfound4 ) start4<= 1'b0;
         else start4 <= 1'b1;
         state4 <= wait_for_depress4;
			end
			
         wait_for_depress4: begin
         if (start_done4) begin state4 <= check_for_success4;
			start4<=1'b0;
			end
         else begin state4 <= wait_for_depress4;
			
			end
         end

         check_for_success4: begin
            if (keyfound4 && finish4) state4 <= success_key_state4;
            else if (!keyfound4 && finish4) state4 <= check_max_secret_key4;
            else state4 <= check_for_success4;

         end

         check_max_secret_key4:  begin
            if (secret_key4 == max_key4) state4 <= failed_key_core4;
            else state4 <= increment_secret_key4;
         end
         increment_secret_key4: begin
            secret_key4 <=secret_key4 + 24'h1;
            state4 <= start_next_key4;
         end

         failed_key_core4: begin
            state4 <= failed_key_core4;
            no_key4 <=1'b1;
         end
			
			success_key_state4: begin
			state4 <= success_key_state4;
			end
         default: state4 <= initial_state_core4;
      endcase
   end
end

endmodule 