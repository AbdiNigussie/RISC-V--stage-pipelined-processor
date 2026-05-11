import sys
import struct

def coe2bin(coe_file, bin_file):
    """
    与bin2coe.py完全对称的COE转BIN转换
    bin2coe.py的逻辑：小端BIN -> 大端十六进制COE
    所以这里要：大端十六进制COE -> 小端BIN
    """
    with open(coe_file, 'r') as f:
        data = f.read()
    
    # 提取十六进制数据
    hex_words = []
    
    # 查找数据开始
    if 'memory_initialization_vector=' in data:
        start_idx = data.find('memory_initialization_vector=')
        data_part = data[start_idx:].split('=', 1)[1]
        
        # 取到分号结束
        if ';' in data_part:
            data_part = data_part.split(';')[0]
        
        # 移除换行和空格，按逗号分割
        data_part = data_part.replace('\n', '').replace(' ', '')
        hex_words = [h for h in data_part.split(',') if h]
    
    # 转换为小端序二进制
    binary_data = bytearray()
    for hex_str in hex_words:
        # bin2coe.py中是大端存储，所以这里要反转字节顺序
        if len(hex_str) != 8:
            hex_str = hex_str.zfill(8)  # 填充到8个字符
        
        # 将大端十六进制转为小端字节
        # 例如: hex_str = "00100293" (大端表示)
        # 小端应该是: 0x93, 0x02, 0x10, 0x00
        bytes_list = []
        for i in range(0, 8, 2):
            # 从后向前取字节
            byte_start = 6 - i
            byte_hex = hex_str[byte_start:byte_start+2]
            bytes_list.append(int(byte_hex, 16))
        
        # 写入小端字节
        for b in bytes_list:
            binary_data.append(b)
    
    # 写入二进制文件
    with open(bin_file, 'wb') as f:
        f.write(binary_data)
    
    print(f"转换完成: {len(hex_words)} 个字 -> {bin_file}")
    return True

if __name__ == "__main__":
    if len(sys.argv) == 3:
        coe2bin(sys.argv[1], sys.argv[2])
    else:
        print("用法: python coe2bin.py <coe文件> <bin文件>")
        print("示例: python coe2bin.py add_loop.coe add_loop.bin")