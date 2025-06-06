`timescale 1ns / 1ps

module MIPS32_TOP(
    input clk,
    input rst
);

// Wires
wire [31:0]pc_wire,pc_out_wire,pc_next_wire,decode_wire,read_data1,read_data2,reg_mux_alu_out,sign_extension_out,ALU_result,read_data,write_data,Adder_result;
wire [4:0]write_reg_mux;
wire [1:0]ALUOp;
wire [3:0]operation;
wire RegDst,RegWrite,ALUSrc,MemRead,MemWrite, MemToReg,Branch,Zero;

/////////////////////////////////////Program Counter
program_counter PC(
    .clk(clk),.reset(rst),.pc(pc_wire),.next_pc(pc_out_wire)
);

////////////////////////////////PC Adder
pc_add PC_Adder(
    .pc_in(pc_out_wire),.pc_out(pc_next_wire)
);

/////////////////////////////////PC mux
mux2x1 pc_mux(
    .in0(pc_next_wire),.in1(Adder_result),.sel(Branch & Zero),.out(pc_wire)
);

/////////////////////////////////instruction memory
instruction_memory Instr_Mem(
    .reset(rst),.clk(clk),.read_address(pc_out_wire),.instruction(decode_wire)
);

/////////////////////////////////Write register mux
mux2x1_5b wr_reg_mux(
    .in0(decode_wire[20:16]),.in1(decode_wire[15:11]),.sel(RegDst),.out(write_reg_mux)
);

////////////////////////////////Register memory
registerts Reg_mem(
    .clk(clk),.reg_write(RegWrite),.write_data(write_data),.write_register(write_reg_mux),.read_register1(decode_wire[25:21]),
    .read_register2(decode_wire[20:16]),.read_data1(read_data1),.read_data2(read_data2)
);

////////////////////////////////Sign extend
sign_extend sign_ext(
    .in(decode_wire[15:0]),.out(sign_extension_out)
);

//////////////////////////////ALU input mux
mux2x1 reg_mux_alu(
    .in0(read_data2),.in1(sign_extension_out),.sel(ALUSrc),.out(reg_mux_alu_out)
);

/////////////////////////// Control unit
control control(
    .opcode(decode_wire[31:26]),.RegWrite(RegWrite),.MemRead(MemRead),.MemWrite(MemWrite),
    .MemToReg(MemToReg),.ALUSrc(ALUSrc),.Branch(Branch),.RegDst(RegDst),.ALUOp(ALUOp)
);

///////////////////////////// ALU control
ALUControl alu_control(
    .funct(decode_wire[5:0]),.ALUOp(ALUOp),.operation(operation)
);

///////////////////////////// ALU
ALU alu_block(
    .A(read_data1),.B(reg_mux_alu_out), .operation(operation),.Result(ALU_result),.Zero(Zero)
);

/////////////////////// data memory
data_memory dat_mem(
    .clk(clk),.rst(rst),.MemRead(MemRead),.MemWrite(MemWrite),.address(ALU_result),
    .write_data(read_data2),.read_data(read_data)
);

/////////////////////Mem to Reg Mux
mux2x1 datmem_mux_regmem(
    .in0(ALU_result),.in1(read_data),
    .sel(MemToReg),.out(write_data)
);

/////////////////////branch address adder 
adder_branch adder(
    .pc(pc_next_wire),.branch_jump(sign_extension_out << 2),.destination(Adder_result)
);

endmodule
