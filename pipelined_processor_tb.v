module pipelined_processor_tb;

    reg clk;
    reg reset;
    reg [31:0] instruction;
    reg [31:0] data_in;
    wire [31:0] result;
	
	reg [31:0] out;
	reg [3:0] op_code;  

	parameter ADD=4'b0000,
			  SUB=4'b0001,
			  AND=4'b0010,
			  LOAD=4'b0011;
			  
   
    pipelined_processor uut (.clk(clk), .reset(reset),  .instruction(instruction), .data_in(data_in),  .result(result));
     
    always 
	 begin
        #5 clk = ~clk;  
     end

	always@(*)
	 begin 
	  case(op_code)
	   ADD : out = "ADD";
	   SUB : out = "SUB";
	   AND : out = "AND";
	   LOAD : out = "LOAD";
	  endcase
	 end
	 
    initial begin
        clk = 0;
        reset = 1;
        #10 reset = 0;
		
		
		#10 instruction=32'b000000_000000_000000_000000_00001001;op_code=ADD;
		#10 instruction=32'b000000_000000_000000_000000_00000011;op_code=SUB;
		#10 instruction=32'b000000_000000_000000_000000_0000101;op_code=AND;
		#10 instruction=32'b000000_000000_000000_000000_00001000;data_in = 32'd10;op_code=LOAD;
		
        #100 $finish;
    end

   
    initial 
	 begin

	    $monitor($time,"inputs reset=%d, instruction =%d, data_in=%h,opcode=%s output result=%d",reset,instruction,data_in,out,result);
      
     end
endmodule
