//monitor is dynamic in nature so we use virtual interface 
//handle is something when you don't give memory when you give memory then it
//is called object........

class monitor;

virtual intf mon_if;
mailbox mon2scb;
 
function new(virtual intf mon_if,mailbox mon2scb);
	this.mon_if = mon_if;
  	this.mon2scb = mon2scb;
endfunction
 
virtual task drive();
begin
     
	transaction trans_mon;
   	trans_mon = new(); 	  
     	@(posedge mon_if.rclk);   
    	trans_mon.rinc = mon_if.rinc;
    	trans_mon.winc = mon_if.winc;
    	trans_mon.wData = mon_if.wData;  
    	trans_mon.wFull = mon_if.wFull;
    	trans_mon.rEmpty = mon_if.rEmpty;
    	trans_mon.rData = mon_if.rData; 
    	mon2scb.put(trans_mon);
end
endtask
    
    
    
task  main();
begin
	for (int i = 0; i < 1; i++) 
	begin
        	drive(); 
	end
end
endtask

endclass
  
 
