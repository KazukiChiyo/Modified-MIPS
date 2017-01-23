transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+D:/ece385/final_project {D:/ece385/final_project/float_add_sub.sv}
vlog -sv -work work +incdir+D:/ece385/final_project {D:/ece385/final_project/global_bus.sv}
vlog -sv -work work +incdir+D:/ece385/final_project {D:/ece385/final_project/sext.sv}
vlog -sv -work work +incdir+D:/ece385/final_project {D:/ece385/final_project/reg_32.sv}
vlog -sv -work work +incdir+D:/ece385/final_project {D:/ece385/final_project/MUX.sv}
vlog -sv -work work +incdir+D:/ece385/final_project {D:/ece385/final_project/ISDU.sv}
vlog -sv -work work +incdir+D:/ece385/final_project {D:/ece385/final_project/int_mult.sv}
vlog -sv -work work +incdir+D:/ece385/final_project {D:/ece385/final_project/int_div.sv}
vlog -sv -work work +incdir+D:/ece385/final_project {D:/ece385/final_project/ALU.sv}
vlog -sv -work work +incdir+D:/ece385/final_project {D:/ece385/final_project/reg_file.sv}
vlog -sv -work work +incdir+D:/ece385/final_project {D:/ece385/final_project/INTALU.sv}
vlog -sv -work work +incdir+D:/ece385/final_project {D:/ece385/final_project/slc3pp.sv}

vlog -sv -work work +incdir+D:/ece385/final_project {D:/ece385/final_project/testbench.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  cds

add wave *
view structure
view signals
run 2000 ns
