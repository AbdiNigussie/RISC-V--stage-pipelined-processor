# 程序：计算 1 到 1000 的累加和，并存入内存地址 0x90000000
# 使用的寄存器：
#   t0: 循环计数器 (i)
#   t1: 累加和 (sum)
#   t2: 常数 1000
#   t3: 地址 0x90000000

    .text
    .global _start

_start:
    # 初始化寄存器
    li t0, 1          # t0 = i = 1
    li t1, 0          # t1 = sum = 0
    li t2, 1000       # t2 = 1000 (循环上限)
    lui t3, 0x90000   # t3 = 0x90000000 (设置高20位)
    addi t3, t3, 0    # t3 = t3 + 0 (低12位为0，确保地址完整)
    lui t4, 0xffff0   # t3 = 0xffff0000 (设置高20位)

loop:
    bgt t0, t2, done  # 如果 i > 1000，跳转到 done
    add t1, t1, t0    # sum = sum + i
    addi t0, t0, 1    # i = i + 1
    j loop            # 跳转回 loop

done:
    sw t1, 0(t3)      # 将 sum 写入地址 0x90000000
    sw t3, 12(t3)      # 将 sum 写入地址 0x9000000C
    # （可选）程序结束，可通过断点或仿真器停止
    # 在实际嵌入式环境中，可能需要进入死循环或触发中断
    j done            # 停留在此处