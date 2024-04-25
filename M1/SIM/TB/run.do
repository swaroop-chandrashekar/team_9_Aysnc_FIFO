vdel -all
vlog -source -lint *.sv
vsim  work.async_fifo_TB
#vsim -coverage top -voptargs="+cover=bcesfx"
#vlog -cover bcst ece593_alu.sv
#vsim -coverage top -do "run -all; exit"
run -all
#coverage report -code bcesft
#vcover report -html coverage_results
#coverage report -codeAll
