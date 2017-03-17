transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+E:/matlab/lesson/8.SDR/VERILOG {E:/matlab/lesson/8.SDR/VERILOG/out_da_data.v}
vlog -vlog01compat -work work +incdir+E:/matlab/lesson/8.SDR/VERILOG {E:/matlab/lesson/8.SDR/VERILOG/rom.v}
vlog -vlog01compat -work work +incdir+E:/matlab/lesson/8.SDR/VERILOG {E:/matlab/lesson/8.SDR/VERILOG/sin_dds.v}
vlog -vlog01compat -work work +incdir+E:/matlab/lesson/8.SDR/VERILOG {E:/matlab/lesson/8.SDR/VERILOG/radix_fir_65.v}
vlog -vlog01compat -work work +incdir+E:/matlab/lesson/8.SDR/VERILOG/fir {E:/matlab/lesson/8.SDR/VERILOG/fir/hdec_1_Verilog.v}
vlog -vlog01compat -work work +incdir+E:/matlab/lesson/8.SDR/VERILOG/fir {E:/matlab/lesson/8.SDR/VERILOG/fir/hdec_2_Verilog.v}
vlog -vlog01compat -work work +incdir+E:/matlab/lesson/8.SDR/VERILOG/fir {E:/matlab/lesson/8.SDR/VERILOG/fir/hdec_3_Verilog.v}
vlog -vlog01compat -work work +incdir+E:/matlab/lesson/8.SDR/VERILOG/fir {E:/matlab/lesson/8.SDR/VERILOG/fir/hdec_4_Verilog.v}
vlog -vlog01compat -work work +incdir+E:/matlab/lesson/8.SDR/VERILOG/fir {E:/matlab/lesson/8.SDR/VERILOG/fir/hdec_5_Verilog.v}
vlog -vlog01compat -work work +incdir+E:/matlab/lesson/8.SDR/VERILOG/fir {E:/matlab/lesson/8.SDR/VERILOG/fir/hdec_6_Verilog.v}
vlog -vlog01compat -work work +incdir+E:/matlab/lesson/8.SDR/VERILOG/fir {E:/matlab/lesson/8.SDR/VERILOG/fir/hdec_7_Verilog.v}
vlog -vlog01compat -work work +incdir+E:/matlab/lesson/8.SDR/VERILOG/fir {E:/matlab/lesson/8.SDR/VERILOG/fir/hdec_8_Verilog.v}
vlog -vlog01compat -work work +incdir+E:/matlab/lesson/8.SDR/VERILOG {E:/matlab/lesson/8.SDR/VERILOG/wave_add.v}
vlog -vlog01compat -work work +incdir+E:/matlab/lesson/8.SDR/VERILOG {E:/matlab/lesson/8.SDR/VERILOG/data_fir.v}
vlog -vlog01compat -work work +incdir+E:/matlab/lesson/8.SDR/VERILOG {E:/matlab/lesson/8.SDR/VERILOG/decimation.v}
vlog -vlog01compat -work work +incdir+E:/matlab/lesson/8.SDR/VERILOG {E:/matlab/lesson/8.SDR/VERILOG/polypase_fir.v}
vlog -vlog01compat -work work +incdir+E:/matlab/lesson/8.SDR/VERILOG {E:/matlab/lesson/8.SDR/VERILOG/interpolation.v}

vlog -vlog01compat -work work +incdir+E:/matlab/lesson/8.SDR/VERILOG/simulation/modelsim {E:/matlab/lesson/8.SDR/VERILOG/simulation/modelsim/out_da_data.vt}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneiii_ver -L rtl_work -L work -voptargs="+acc"  out_da_data_vlg_tst

add wave *
view structure
view signals
run 1 ms
