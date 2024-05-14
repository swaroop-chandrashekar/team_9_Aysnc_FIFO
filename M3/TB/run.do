#vdel -all
#vlog -source -lint *.sv
#vsim  work.async_fifo_TB
#vsim -coverage top -voptargs="+cover=bcesfx"
#vlog -cover bcst ece593_alu.sv
#vsim -coverage top -do "run -all; exit"
#run -all
#coverage report -code bcesft
#vcover report -html coverage_results
#coverage report -codeAll

##run with command :::::: do run.do




vlib work
# Compile all necessary source files
vlog async_fifo.sv
vlog async_fifo_package.sv
vlog async_fifo_top.sv
vlog async_fifo_test.sv
vlog async_fifo_environment.sv
vlog async_fifo_scoreboard.sv
vlog async_fifo_transaction.sv
vlog async_fifo_interface.sv
vlog async_fifo_monitor.sv
vlog async_fifo_generator.sv
vlog async_fifo_driver.sv

#run test
vsim -coverage -vopt work.async_fifo_top -c -do "coverage save -onexit -directive -codeAll basetest.ucdb; run -all"


# if you need coverage report (ensure ucdb file was created)

# vcover report -html basetest.ucdb


