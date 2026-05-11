
iverilog.exe -g2012 -D IVERILOG -I ../rtl/ -I ../rtl/cpu/ -o tb_top.vvp tb_top.v top.v DRAM.v IROM.v ../rtl/benchmark.v ../rtl/dram_driver.v ../rtl/seven_seg.v ../rtl/cpu/*.v

pause

vvp.exe tb_top.vvp

gtkwave testbench.wave
