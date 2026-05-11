
@echo off
echo Building add_loop...

REM Create build directory if it doesn't exist
if not exist "build" mkdir build

REM Assemble source file
riscv64-unknown-elf-as.exe -c src\add_loop.s -o build\add_loop.o

REM Convert to binary
riscv64-unknown-elf-objcopy.exe -O binary build\add_loop.o build\add_loop.bin

REM Generate disassembly
riscv64-unknown-elf-objdump.exe -d build\add_loop.o > build\add_loop.txt

REM Convert to COE format
python tools\bin2coe.py build\add_loop.bin build\add_loop.coe 

REM Convert to DAT format
python tools\bin2dat.py build\add_loop.bin build\add_loop.dat

echo Build complete! Output files are in the build\ directory.
