module pipelined_processor(
    input clk,                
    input reset,             
    input [31:0] instruction, 
    input [31:0] data_in,     
    output [31:0] result  );

    reg [31:0] registers [0:31];
    reg [31:0] pc;  // Program counter

    // Pipeline registers
    reg [31:0] if_pc, id_pc, ex_pc, mem_pc;
    reg [31:0] if_inst, id_inst, ex_inst, mem_inst;
    reg [31:0] id_operand1, id_operand2, ex_operand1, ex_operand2;
    reg [31:0] ex_alu_result, mem_alu_result;
    reg [31:0] mem_data_out, wb_data_out;

    // Control signals
    reg [3:0] op_code;     
    reg [4:0] rs, rt, rd;  
    
	parameter ADD=4'b0000,
			  SUB=4'b0001,
			  AND=4'b0010,
			  LOAD=4'b0011;
			  
    assign op_code = id_inst[31:28]; // Assuming 4-bit opcode
    assign rs = id_inst[25:21];
    assign rt = id_inst[20:16];
    assign rd = id_inst[15:11];

    // Instruction Fetch (IF) Stage
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc = 0;
        end else begin
            if_pc = pc;
            pc = pc + 4;
            if_inst = instruction;
        end
    end

    // Instruction Decode (ID) Stage
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            id_pc = 0;
            id_inst = 0;
            id_operand1 = 0;
            id_operand2 = 0;
        end else begin
            id_pc = if_pc;
            id_inst = if_inst;
            id_operand1 = registers[rs]; 
            id_operand2 = registers[rt]; 
        end
    end

    // Execute (EX) Stage
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ex_pc = 0;
            ex_inst = 0;
            ex_operand1 = 0;
            ex_operand2 = 0;
            ex_alu_result = 0;
        end else begin
            ex_pc = id_pc;
            ex_inst = id_inst;
            ex_operand1 = id_operand1;
            ex_operand2 = id_operand2;

            // ALU operation based on opcode
            case (op_code)
                ADD: ex_alu_result = ex_operand1 + ex_operand2;  // ADD
                SUB: ex_alu_result = ex_operand1 - ex_operand2;  // SUB
                AND: ex_alu_result = ex_operand1 & ex_operand2;  // AND
                LOAD: ex_alu_result = ex_operand1; // Pass for Load
                default: ex_alu_result = 0;
            endcase
        end
    end

    // Memory Access (MEM) Stage
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            mem_pc = 0;
            mem_inst = 0;
            mem_data_out = 0;
        end else begin
            mem_pc = ex_pc;
            mem_inst = ex_inst;
           
            if (op_code == 4'b0011) begin
                mem_data_out = data_in; // Load data from input
            end 
			else 
			if(op_code == 4'b0000 | 4'b0001 | 4'b0010) begin
                mem_data_out 	= ex_alu_result;
            end
        end
    end

    // Write Back (WB) Stage
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            wb_data_out = 0;
        end else begin
            wb_data_out = mem_data_out;
        end
    end

    // Write result back to register file
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            registers[rd] = 0;
        end else if (mem_inst[31:28] != 4'b0011) begin // Exclude LOAD instructions
            registers[rd] = wb_data_out;
        end
    end
    assign result = wb_data_out;
endmodule
