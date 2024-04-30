//monitor is dynamic in nature so we use virtual interface 
//handle is something when you don't give memory when you give memory then it
//is called object........
class monitor
int w_count;
int r_count;
int trans_count_write;
int trans_count_read;

	virtual intf vif;		//virtual interface declaration

	mailbox mon2scb_write;		//declare mailbox for write
	mailbox mon2scb_read;		//declare mailbox for read 

	function new_read(virtual intf vif, mailbox mon2scb_read, mailbox mon2scb_write);
		this.vif = vif;
		this.mon2scb_read = mon2scb_read;
		this.mon2scb_write = mon2scb_write;
	endfunction

	//sampling for write
	task mon_write;
		begin
			transcation_write trans_w;
			trans_w = new();			//constructor handle or creating object for trans
			trans_W.winc =  vif.winc;
			trans_w.wData = vif.wData;
			trans_w.wFull = vif.wFull;
			mon2scb_write.put(trans_w);
			w_count = w_count + 1;
			trans_w.display("display_write");
		end
	endtask
	
	//sampling for read
	task mon_read;
		begin
			transcation_read trans_r;
	       		trans_r = new();
	 		trans_r.rinc = vif.rinc;
			trans_r.rData = vif.rData;
			trans_r.rEmpty = vif.rEmpty;
			mon2scb_read.put(trans_r);
			r_count = r_count +1;
			trans_r.display("display_read");
		end
	endtask
	

	//main task used in the environment 
	task main();
		bit write_completed = 0;
		transcation_read trans_read;
		transcation_write trans_write;
		trans_read = new();
		trans_write = new();

		fork
										
		begin : write_mon
			forever @(posedge vif.wclk) begin
			       mon_write();
		       end
	       	end
 		
		begin
			forever @(posedge vif.wclk)
				wait (w_count == trans_count_write);
				disable write_mon
				write_completed = 1;
		end

		join_any

	if(write_completed == 1) 
	begin
		fork 
			begin : read_mon
				forever @(posedge vif.rclk)
				begin
	       			mon_read();
				end
			end

			begin : completed_read
				@(posedge vif.rclk)
				wait(r_count == trans_count_read);
				disable read_mon;
			end
		join_any
	end
	
	@(posedge vif.rclk);
 	trans_read.rEmpty = vif.rEmpty;
  	mon2scb_read.put(trans_read.rEmpty);
  
  	@(posedge vif.wclk);
  	trans_write.wFull = vif.wFull;
  	mon2scb_write.put(trans_write.wFull);
			
	endtask

endclass
 
