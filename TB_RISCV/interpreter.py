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
    'c.addi':  {'type': 'CI',  'op': 0b01, 'funct3': 0b000},


    
    'c.li':    {'type': 'CI',  'op': 0b01, 'funct3': 0b010},
    'c.add':   {'type': 'CR',  'op': 0b10, 'funct4': 0b1001},
    'c.mv':    {'type': 'CR',  'op': 0b10, 'funct4': 0b1000},
    'c.j':     {'type': 'CJ',  'op': 0b101, 'funct3': 0b101},
    'c.beqz':  {'type': 'CB',  'op': 0b110, 'funct3': 0b110},
    'c.sw':    {'type': 'CSS', 'op': 0b110, 'funct3': 0b110},
    # Adicione mais instruções aqui
    'c.sub':   {'type': 'CR',  'op': 0b10, 'funct4': 0b100011},
    'c.lw':    {'type': 'CI',  'op': 0b010, 'funct3': 0b010},
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

def encode_cr(opcode, funct4, rd, rs):
    """Codifica formato CR (Register-Register)"""
    return (opcode << 13) | (funct4 << 9) | (rs << 2) | (rd << 7)

def encode_instruction(instr, operands):
    """Codifica uma instrução completa"""
    parts = [s.strip() for s in re.split(r'[, ]+', operands)]
    
    if instr == 'c.addi':
        rd = REGISTERS[parts[0]]
        imm = parse_immediate(parts[1])
        return encode_ci(INSTRUCTIONS[instr]['op'], INSTRUCTIONS[instr]['funct3'], rd, imm)
    
    elif instr == 'c.add':
        rd = REGISTERS[parts[0]]
        rs = REGISTERS[parts[1]]
        return encode_cr(INSTRUCTIONS[instr]['op'], INSTRUCTIONS[instr]['funct4'], rd, rs)
    
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