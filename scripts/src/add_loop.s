# Program: sum the integers from 1 to 1000 and store the result at memory address 0x90000000
# Registers used:
#   t0: Loop counter (i)
#   t1: Running sum (sum)
#   t2: Constant 1000
#   t3: Address 0x90000000

    .text
    .global _start

_start:
    # Initialize registers
    li t0, 1          # t0 = i = 1
    li t1, 0          # t1 = sum = 0
    li t2, 1000       # t2 = 1000 (Loop limit)
    lui t3, 0x90000   # t3 = 0x90000000 (Set the upper 20 bits)
    addi t3, t3, 0    # t3 = t3 + 0 (The lower 12 bits are zero, completing the address)
    lui t4, 0xffff0   # t4 = 0xffff0000 (Set the upper 20 bits)

loop:
    bgt t0, t2, done  # If i > 1000, branch to done
    add t1, t1, t0    # sum = sum + i
    addi t0, t0, 1    # i = i + 1
    j loop            # Jump back to loop

done:
    sw t1, 0(t3)      # Store sum at address 0x90000000
    sw t3, 12(t3)      # Store t3 at address 0x9000000C
    # (Optional) Stop the program using a breakpoint or the simulator
    # On embedded hardware, an infinite loop or an interrupt may be needed
    j done            # Remain here