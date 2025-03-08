import re
import sys

# Mapeamento de registradores para números (incluindo ABI names)
REGISTERS = {
    'zero': 0, 'ra': 1, 'sp': 2, 'gp': 3, 'tp': 4,
    't0': 5, 't1': 6, 't2': 7, 's0': 8, 's1': 9,
    'a0': 10, 'a1': 11, 'a2': 12, 'a3': 13, 'a4': 14, 'a5': 15,
    **{f'x{i}': i for i in range(32)}
}

# Formato das instruções e campos (C Extension RV32C)
INSTRUCTIONS = {
    'c.addi':  {'op': 0b01, 'funct3': 0b000},    
    'c.li':    {'op': 0b01, 'funct3': 0b010},

    'c.sub':   {'op': 0b01, 'funct2': 0b00, 'funct4': 0b100011},
    'c.xor':   {'op': 0b01, 'funct2': 0b01, 'funct4': 0b100011},
    'c.or' :   {'op': 0b01, 'funct2': 0b10, 'funct4': 0b100011},
    'c.and':   {'op': 0b01, 'funct2': 0b11, 'funct4': 0b100011},

    'c.swsp':  {'op': 0b10, 'funct3': 0b110},
    'c.lwsp':  {'op': 0b10, 'funct3': 0b010},

    'c.add':   {'op': 0b10, 'funct4': 0b1001},
    'c.mv':    {'op': 0b10, 'funct4': 0b1000},
    'c.j':     {'op': 0b101, 'funct3': 0b101},
    'c.beqz':  {'op': 0b110, 'funct3': 0b110},
    # Adicione mais instruções aqui
    
}

def parse_immediate(imm_str):
    """Analisa valores imediatos em diferentes formatos"""
    if imm_str.startswith('0x'):
        return int(imm_str, 16)
    return int(imm_str)

def encode_ci(opcode, funct3, rd, imm):
    """Codifica formato CI (Immediate Arithmetic)"""
    imm = imm & 0b111111 
    return ((funct3 << 13) |((imm & 0b100000) << 12) | (rd << 7) | ((imm & 0b011111) << 2) | (opcode))

def encode_cr(opcode, funct4, rd, funct2, rs):
    """Codifica formato CR (Register-Register)"""
    return ((funct4 << 10) | (rd << 7) | (funct2 << 5) | (rs << 2) | (opcode))

def encode_add(opcode, funct4, rd, rs):
    """Codifica formato CR (Register-Register)"""
    return ((funct4 << 12) | (rd << 7) | (rs << 2) | (opcode))

def encode_memory_lw(opcode, funct3, rd, imm):
    """Codifica formato CI (Immediate Arithmetic)"""
    print(((imm & 0b011111) << 2) | (opcode))
    return ((funct3 << 13) | ((imm & 0b100000) << 12) | (rd << 7) | ((imm & 0b011111) << 2) | (opcode))

def encode_memory_sw(opcode, funct3, rd, imm):
    """Codifica formato CI (Immediate Arithmetic)"""
    print(((imm & 0b011111) << 2) | (opcode))
    return ((funct3 << 13) | ((imm & 0b111100) << 9) | ((imm & 0b11000000) << 7) | ((rd & 0b11111) << 2) | (opcode))

def encode_instruction(instr, operands):
    """Codifica uma instrução completa"""
    parts = [s.strip() for s in re.split(r'[, ]+', operands)]
    
    if instr == 'c.addi':
        rd = REGISTERS[parts[0]]
        imm = parse_immediate(parts[1])
        return encode_ci(INSTRUCTIONS[instr]['op'], INSTRUCTIONS[instr]['funct3'], rd, imm)

    elif instr == 'c.li':
        rd = REGISTERS[parts[0]]
        imm = parse_immediate(parts[1])
        print('c.li', encode_ci(INSTRUCTIONS[instr]['op'], INSTRUCTIONS[instr]['funct3'], rd, imm))
        return encode_ci(INSTRUCTIONS[instr]['op'], INSTRUCTIONS[instr]['funct3'], rd, imm)

    elif instr == 'c.sub':
        rd = REGISTERS[parts[0]]
        rs = REGISTERS[parts[1]]
        return encode_cr(INSTRUCTIONS[instr]['op'], INSTRUCTIONS[instr]['funct4'], rd, INSTRUCTIONS[instr]['funct2'], rs)
        
    elif instr == 'c.xor':
        rd = REGISTERS[parts[0]]
        rs = REGISTERS[parts[1]]
        return encode_cr(INSTRUCTIONS[instr]['op'], INSTRUCTIONS[instr]['funct4'], rd, INSTRUCTIONS[instr]['funct2'], rs)

    elif instr == 'c.or':
        rd = REGISTERS[parts[0]]
        rs = REGISTERS[parts[1]]
        return encode_cr(INSTRUCTIONS[instr]['op'], INSTRUCTIONS[instr]['funct4'], rd, INSTRUCTIONS[instr]['funct2'], rs)

    elif instr == 'c.and':
        rd = REGISTERS[parts[0]]
        rs = REGISTERS[parts[1]]
        return encode_cr(INSTRUCTIONS[instr]['op'], INSTRUCTIONS[instr]['funct4'], rd, INSTRUCTIONS[instr]['funct2'], rs)

    elif instr == 'c.add':
        rd = REGISTERS[parts[0]]
        rs = REGISTERS[parts[1]]
        return encode_add(INSTRUCTIONS[instr]['op'], INSTRUCTIONS[instr]['funct4'], rd, rs)

    elif instr == 'c.lwsp':
        rd = REGISTERS[parts[0]]
        imm = parse_immediate(parts[1])
        return encode_memory_lw(INSTRUCTIONS[instr]['op'], INSTRUCTIONS[instr]['funct3'], rd, imm)

    elif instr == 'c.swsp':
        rd = REGISTERS[parts[0]]
        imm = parse_immediate(parts[1])
        return encode_memory_sw(INSTRUCTIONS[instr]['op'], INSTRUCTIONS[instr]['funct3'], rd, imm)
    
    # Adicionar mais instruções aqui...
    
    else:
        raise ValueError(f"Instrução não suportada: {instr}")

def assemble_line(line):
    """Processa uma linha de assembly"""
    line = line.split('#')[0].strip().lower()  # Remove comentários
    if not line:
        return None
    
    parts = line.split(maxsplit=1)
    if not parts:
        return None

    mnemonic = parts[0]
    operands = parts[1] if len(parts) > 1 else ''
    
    if mnemonic not in INSTRUCTIONS:
        raise ValueError(f"Instrução não suportada: {mnemonic}")
    
    machine_code = encode_instruction(mnemonic, operands)
    return machine_code.to_bytes(2, 'big')

def assembler(input_file, output_file):
    """Função principal do montador"""
    with open(input_file, 'r') as f:
        lines = f.readlines()
    
    binary = bytearray()
    for line in lines:
        bytes = assemble_line(line)
        if bytes:
            binary.extend(bytes)
    
    with open(output_file, 'wb') as f:
        f.write(binary)

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Uso: python riscv_c_assembler.py input.asm output.bin")
        sys.exit(1)
    
    assembler(sys.argv[1], sys.argv[2])