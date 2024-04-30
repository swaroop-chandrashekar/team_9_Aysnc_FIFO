import fifo_pkg::*;

class generator;                       
	rand transcation_write trans_w;	 			//declaring transcation class
	rand transcation_read trans_r;
	mailbox gen2driv_read,gen2driv_write;
	int trans_count_write ;
	int trans_count_read ;


	
	function new(mailbox gen2driv_write,mailbox gen2driv_read);
	this.gen2driv_write = gen2driv_write;
	this.gen2driv_read = gen2driv_read;
	endfunction

	
	task trans_write();
		repeat(trans_count_write)
			begin
				trans_w = new();
				trans_w.randomize();
				if( !trans_w.randomize() ) $fatal("Gen:: trans randomization failed");
				trans_w.display("Generator");						//to check values of inputs
				gen2driv_write.put(trans_w);
			end
	endtask
    
    
    	task trans_read();
		repeat(trans_count_read)
			begin
				trans_r = new();
				trans_r.randomize();
				if( !trans_r.randomize() ) $fatal("Gen:: trans randomization failed");
				trans_r.display("Generator");						//to check values of inputs
				gen2driv_read.put(trans_r);
			end
	endtask

endclass

