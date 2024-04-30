//async_fifo_environment.sv - smit patel 

import fifo_pkg::*;

class environment;
generator gen;
driver driv;
monitor mon;
scoreboard scb;

mailbox gen2driv_read;
mailbox gen2driv_write;

mailbox mon2scb_read;
mailbox mon2scb_write;
//event gen_ended;

virtual intf vif;

	function new(virtual intf vif);
		this.vif = vif;

		gen2driv_read = new();
		gen2driv_write = new();

		mon2scb_write = new();
		mon2scb_read = new();

		gen = new(gen2driv_write, gen2driv_read);
		scb = new(mon2scb_write, mon2scb_read);
		driv = new(vif,gen2driv_write,gen2driv_read);
		mon = new(vif,mon2scb_write,mon2scb_read);
	endfunction

	task pre_test();
		driv.reset();
	endtask

	task test();
		$display("Write data requested",gen.trans_count_write);  
		$display("read data requested", gen.trans_count_read); 
		gen.main();
		fork
			driv.main();   //driv started
			mon.main();	//mon started
			scb.main();	//scoreboard started
		join

		$display("Data check Initiated");
		scb.check();
		$display("Data check has completed");
	endtask
	
	task run;
		pre_test();
		test();
	endtask

endclass
	
	
