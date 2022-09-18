vlib work
vmap work work

vcom -93 ../tb/uart_core_tb.vhd
vcom -93 ../hdl/uart_core_top.vhd
vcom -93 ../hdl/uart_core_tx_module.vhd
vcom -93 ../hdl/uart_core_rx_module.vhd

vsim -t 1ps -voptargs=+acc=lprn -lib work uart_core_tb

do wave_test.do 
view wave
run 2000 ms