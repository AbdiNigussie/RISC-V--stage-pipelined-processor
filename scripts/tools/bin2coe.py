import sys

def bin2coe(bin_file, coe_file):
    with open(bin_file, 'rb') as f:
        data = f.read()

    # 每4字节小端转为十六进制字符串
    words = [data[i:i+4] for i in range(0, len(data), 4)]
    hex_words = []
    for idx, w in enumerate(words):
        if len(w) < 4:
            w = w.ljust(4, b'\x00')
        # 小端转大端
        hex_str = ''.join(['{:02x}'.format(b) for b in w[::-1]])
        hex_words.append(hex_str)

    with open(coe_file, 'w') as f:
        f.write('memory_initialization_radix=16;\n')
        f.write('memory_initialization_vector=\n')
        for i, word in enumerate(hex_words):
            if i != len(hex_words)-1:
                f.write(word + ',\n')
            else:
                f.write(word + ';\n')

if __name__ == "__main__":
    if len(sys.argv) == 3:
        print('Usage: python bin2coe.py <bin_file> <coe_file>')
        bin2coe(sys.argv[1], sys.argv[2])
    else:
        bin2coe('add-riscv64-nemu.bin', 'add-riscv64-nemu.coe')