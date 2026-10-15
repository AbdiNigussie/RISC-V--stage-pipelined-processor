import sys
import struct

def coe2bin(coe_file, bin_file):
    """
    Convert COE to BIN as the exact inverse of bin2coe.py
    bin2coe.py: little-endian BIN -> big-endian hexadecimal COE
    This conversion: big-endian hexadecimal COE -> little-endian BIN
    """
    with open(coe_file, 'r') as f:
        data = f.read()
    
    # Extract hexadecimal data
    hex_words = []
    
    # Find the start of the data
    if 'memory_initialization_vector=' in data:
        start_idx = data.find('memory_initialization_vector=')
        data_part = data[start_idx:].split('=', 1)[1]
        
        # Read up to the terminating semicolon
        if ';' in data_part:
            data_part = data_part.split(';')[0]
        
        # Remove newlines and spaces, then split on commas
        data_part = data_part.replace('\n', '').replace(' ', '')
        hex_words = [h for h in data_part.split(',') if h]
    
    # Convert to little-endian binary
    binary_data = bytearray()
    for hex_str in hex_words:
        # bin2coe.py writes big-endian hexadecimal notation, so reverse the byte order here
        if len(hex_str) != 8:
            hex_str = hex_str.zfill(8)  # Pad to 8 characters
        
        # Convert big-endian hexadecimal notation to little-endian bytes
        # Example: hex_str = "00100293" (big-endian notation)
        # Little-endian bytes: 0x93, 0x02, 0x10, 0x00
        bytes_list = []
        for i in range(0, 8, 2):
            # Read bytes from the end toward the beginning
            byte_start = 6 - i
            byte_hex = hex_str[byte_start:byte_start+2]
            bytes_list.append(int(byte_hex, 16))
        
        # Append the little-endian bytes
        for b in bytes_list:
            binary_data.append(b)
    
    # Write the binary file
    with open(bin_file, 'wb') as f:
        f.write(binary_data)
    
    print(f"Conversion complete: {len(hex_words)} words -> {bin_file}")
    return True

if __name__ == "__main__":
    if len(sys.argv) == 3:
        coe2bin(sys.argv[1], sys.argv[2])
    else:
        print("Usage: python coe2bin.py <coe_file> <bin_file>")
        print("Example: python coe2bin.py add_loop.coe add_loop.bin")