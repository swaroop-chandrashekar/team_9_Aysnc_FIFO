##run with command :::::: do run.do




vlib work

vlog -source -lint async_fifo.sv
#vlog -source -lint +define+ERROR_INJECTION_WDATA async_fifo.sv
#vlog -source -lint +define+WFULL_CORRUPT async_fifo.sv

vlog -source -lint async_fifo_package.sv

#vlog -source -lint +define+BASE_TEST async_fifo_top.sv
vlog -source -lint  async_fifo_top.sv

vlog -source -lint  async_fifo_test1.sv
vlog -source -lint async_fifo_test2.sv

vlog -source -lint async_fifo_driver.sv
vlog -source -lint async_fifo_env.sv
vlog -source -lint async_fifo_interface.sv
vlog -source -lint async_fifo_read_agent.sv
vlog -source -lint async_fifo_scoreboard.sv
vlog -source -lint async_fifo_seq_item.sv
vlog -source -lint async_fifo_seq_base.sv
vlog -source -lint async_fifo_seq_random.sv
vlog -source -lint async_fifo_sequencer.sv
vlog -source -lint async_fifo_write_agent.sv
vlog -source -lint async_fifo_coverage.sv
vlog -source -lint async_fifo_read_monitor.sv
vlog -source -lint async_fifo_write_monitor.sv


# if you need coverage report after running all 2 tests (ensure ucdb files are created)

#vsim  -coverage -vopt work.tb_top -c -do "coverage save -onexit -directive -codeAll basetest.ucdb; run -all"
vsim -coverage -vopt work.tb_top -c -do "coverage save -onexit -directive -codeAll randomtest.ucdb; run -all"


 vcover merge output basetest.ucdb  randomtest.ucdb
 vcover report -html output

vopt tb_top -o top_optimized +acc +cover=sbfec+ASYNC_FIFO(rtl).

#vsim top_optimized -coverage
# vsim +define+BASE_TEST top_optimized -coverage

#set NoQuitOnFinish 1
#onbreak {resume}
#log






