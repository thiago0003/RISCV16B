// COMPRESS INSTRUCTION 

`define C_ADDI (opcode == 2'b01 && funct3 == 3'b000)
`define C_JAL  (opcode == 2'b01 && funct3 == 3'b001)
`define C_LI   (opcode == 2'b01 && funct3 == 3'b010)
`define C_LUI  (opcode == 2'b01 && funct3 == 3'b011)


`define C_SRLI (opcode == 2'b01 && funct3 == 3'b100 && funct2 == 2'b00)
`define C_SRAI (opcode == 2'b01 && funct3 == 3'b100 && funct2 == 2'b01)
`define C_ANDI (opcode == 2'b01 && funct3 == 3'b100 && funct2 == 2'b10)

`define C_SUB  (opcode == 2'b01 && funct3 == 3'b100 && funct2 == 2'b11 && rfunct2 == 2'b00 && instruction[12] == 1'b0)
`define C_XOR  (opcode == 2'b01 && funct3 == 3'b100 && funct2 == 2'b11 && rfunct2 == 2'b01 && instruction[12] == 1'b0)
`define C_OR   (opcode == 2'b01 && funct3 == 3'b100 && funct2 == 2'b11 && rfunct2 == 2'b10 && instruction[12] == 1'b0)
`define C_AND  (opcode == 2'b01 && funct3 == 3'b100 && funct2 == 2'b11 && rfunct2 == 2'b11 && instruction[12] == 1'b0)

`define C_J    (opcode == 2'b01 && funct3 == 3'b101)
`define C_BEQZ (opcode == 2'b01 && funct3 == 3'b110)
`define C_BNEZ (opcode == 2'b01 && funct3 == 3'b111)

`define C_SLLI (opcode == 2'b10 && funct3 == 3'b000)
`define C_JALR (opcode == 2'b10 && funct3 == 3'b100 && instruction[12] == 1'b1 && instruction[6:2] == 5'b0)
`define C_ADD  (opcode == 2'b10 && funct3 == 3'b100 && instruction[12] == 1'b1 && instruction[6:2] != 5'b0)

`define C_LW   (opcode == 2'b10 && funct3 == 3'b010)
`define C_SW   (opcode == 2'b10 && funct3 == 3'b110)
