`timescale 1ns / 1ps

module instruction_memory(
    input clk, reset,
    input [31:0]read_address,
    output reg [31:0]instruction
);

    reg [31:0]mem[63:0];
    integer i;

    initial begin
        for (i=0; i<64; i=i+1)
            mem[i] = 32'h00000000;

        mem[0]  = 32'h20080005; // addi $t0, $zero, 4
        mem[1]  = 32'h20090003; // addi $t1, $zero, 3
        mem[2]  = 32'h01095020; // add $t2, $t0, $t1
        mem[3]  = 32'h012A5822; // sub $t3, $t1, $t2
        mem[4]  = 32'hAC0A0004; // sw $t2, 4($zero)
        mem[5]  = 32'h8C0C0004; // lw $t4, 4($zero)
        mem[6]  = 32'h110C0002; // beq $t0, $t4, label (2 offset)///branching inst branch=1 zero =0..next inst not skipped
        mem[7]  = 32'h200D0001; // addi $t5, $zero, 1
        mem[8]  = 32'h200D0002; // addi $t5, $zero, 2
        mem[9]  = 32'h11AD0001; // beq $t5, $t5, label (1 offset)///branching branch=1 and zero=1
        mem[10] = 32'h200E00FF; // addi $t6, $zero, 255////////////////Skipped Instruction
        mem[11] = 32'h200E0001; // addi $t6, $zero, 1
        mem[12] = 32'h200E0002; // addi $t6, $zero, 2
        mem[13] = 32'h200E0003; // addi $t6, $zero, 3
        mem[14] = 32'h08000011; // j 0x00000044 (jump to mem[17])
        mem[15] = 32'h200F000A; // addi $t7, $zero, 10   (should be skipped)
        mem[16] = 32'h200F000B; // addi $t7, $zero, 11   (should be skipped)
        mem[17] = 32'h200F000C; // addi $t7, $zero, 12   (should be executed)
    end

    always @(*) begin
        instruction=mem[read_address>>2]; //might have to divide  by 4 here...depending onn value initialization
    end

endmodule
