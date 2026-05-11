
import sys

def coe_to_disassembly(coe_file, txt_file):
    """将COE文件转换为反汇编文本"""
    
    # 读取COE文件
    with open(coe_file, 'r') as f:
        lines = f.readlines()
    
    # 提取指令
    instructions = []
    in_vector = False
    
    for line in lines:
        line = line.strip()
        if 'memory_initialization_vector=' in line:
            in_vector = True
            parts = line.split('=')
            if len(parts) > 1:
                for inst in parts[1].strip().rstrip(',').split(','):
                    if inst.strip():
                        instructions.append(int(inst.strip(), 16))
        elif in_vector and line:
            if line.endswith(';'):
                line = line.rstrip(';')
                in_vector = False
            for inst in line.rstrip(',').split(','):
                if inst.strip():
                    instructions.append(int(inst.strip(), 16))
    
    # 简单的反汇编表
    reg_names = [
        'zero', 'ra', 'sp', 'gp', 'tp', 't0', 't1', 't2',
        's0', 's1', 'a0', 'a1', 'a2', 'a3', 'a4', 'a5',
        'a6', 'a7', 's2', 's3', 's4', 's5', 's6', 's7',
        's8', 's9', 's10', 's11', 't3', 't4', 't5', 't6'
    ]
    
    with open(txt_file, 'w') as f:
        f.write("Address  | Machine Code | Assembly\n")
        f.write("---------+--------------+----------\n")
        
        for addr, inst in enumerate(instructions):
            pc = addr * 4
            inst_hex = f"{inst:08x}"
            
            # 解码
            opcode = inst & 0x7F
            rd = (inst >> 7) & 0x1F
            rs1 = (inst >> 15) & 0x1F
            rs2 = (inst >> 20) & 0x1F
            funct3 = (inst >> 12) & 0x7
            funct7 = (inst >> 25) & 0x7F
            imm_i = (inst >> 20) & 0xFFF
            if imm_i & 0x800:  # 符号扩展
                imm_i -= 0x1000
            
            # 识别指令
            assembly = "unknown"
            
            if opcode == 0x13:  # I-type
                if funct3 == 0:
                    assembly = f"addi {reg_names[rd]}, {reg_names[rs1]}, {imm_i}"
                elif funct3 == 1:
                    shamt = inst >> 20
                    assembly = f"slli {reg_names[rd]}, {reg_names[rs1]}, {shamt}"
                elif funct3 == 6:
                    assembly = f"ori {reg_names[rd]}, {reg_names[rs1]}, {imm_i}"
                elif funct3 == 7:
                    assembly = f"andi {reg_names[rd]}, {reg_names[rs1]}, {imm_i}"
            
            elif opcode == 0x33:  # R-type
                if funct3 == 0:
                    if funct7 == 0x20:
                        assembly = f"sub {reg_names[rd]}, {reg_names[rs1]}, {reg_names[rs2]}"
                    else:
                        assembly = f"add {reg_names[rd]}, {reg_names[rs1]}, {reg_names[rs2]}"
                elif funct3 == 4:
                    assembly = f"xor {reg_names[rd]}, {reg_names[rs1]}, {reg_names[rs2]}"
                elif funct3 == 6:
                    assembly = f"or {reg_names[rd]}, {reg_names[rs1]}, {reg_names[rs2]}"
                elif funct3 == 7:
                    assembly = f"and {reg_names[rd]}, {reg_names[rs1]}, {reg_names[rs2]}"
            
            elif opcode == 0x63:  # B-type
                imm_b = ((inst >> 31) & 0x1) << 12 | \
                        ((inst >> 7) & 0x1) << 11 | \
                        ((inst >> 25) & 0x3F) << 5 | \
                        ((inst >> 8) & 0xF) << 1
                if imm_b & 0x1000:
                    imm_b -= 0x2000
                target = pc + imm_b
                
                if funct3 == 0:
                    assembly = f"beq {reg_names[rs1]}, {reg_names[rs2]}, 0x{target:x}"
                elif funct3 == 1:
                    assembly = f"bne {reg_names[rs1]}, {reg_names[rs2]}, 0x{target:x}"
            
            elif opcode == 0x37:  # LUI
                imm_u = inst & 0xFFFFF000
                assembly = f"lui {reg_names[rd]}, 0x{imm_u >> 12:x}"
            
            elif opcode == 0x23:  # S-type
                imm_s = ((inst >> 25) & 0x7F) << 5 | ((inst >> 7) & 0x1F)
                if imm_s & 0x800:
                    imm_s -= 0x1000
                if funct3 == 2:
                    assembly = f"sw {reg_names[rs2]}, {imm_s}({reg_names[rs1]})"
            
            f.write(f"{pc:08x} | {inst_hex} | {assembly}\n")

if __name__ == "__main__":
    coe_to_disassembly("build/all_test.coe", "build/all_test.txt")
    print("Conversion complete!")