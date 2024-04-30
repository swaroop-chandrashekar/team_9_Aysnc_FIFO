class driver;
int trans_count_read;
int trans_count_write;

   
virtual intf intf_vi;
   	
mailbox gen2driv_write;
mailbox gen2driv_read;


   
function new(virtual intf intf_vi, mailbox gen2driv_write,mailbox gen2driv_read);
        
	this.intf_vi = intf_vi;
        this.gen2driv_write = gen2driv_write;
	this.gen2driv_read = gen2driv_read;
   
endfunction

     
task reset;
       
	$display("Driver Reset Initiated");
	
        intf_vi.wData = 0;
        intf_vi.winc = 0;
      
		intf_vi.rinc = 0;

        $display("Driver Reset is Complete");
   
endtask
  

  
task drive_write();

     	transaction_write txw;
		txw=new();
  
      	gen2driv_write.get(txw);
	
	
  	intf_vi.winc = txw.winc;
    intf_vi.wData = txw.wData;;
     @(posedge intf_vi.wclk);
  	 @(posedge intf_vi.wclk);
  
  
           
endtask
       
    
task drive_read();
    
     transaction_read txr;
	 txr=new();
  
     gen2driv_read.get(txr);
     	
	intf_vi.rinc = txr.rinc;
  	@(posedge intf_vi.rclk);
  	@(posedge intf_vi.rclk);

	
  
endtask   

     
task  main();

	fork
		begin
          repeat(10) @(posedge intf_vi.wclk);
          for (integer i = 0; i < trans_count_write ; i++) begin
            $display("Write transaction count= %0d--------------------",i+1); 	
            
            drive_write();
            
            
    			end
				intf_vi.winc=0;
				intf_vi.wData=0;

        	end


		begin
			repeat(10) @(posedge intf_vi.rclk);
          for (integer j = 0; j < trans_count_read ; j++) begin
            $display("Read transaction count= %0d--------------------",j+1);
				drive_read(); 
    			end
			intf_vi.rinc=0;

        	end

	join

		


endtask
         
endclass
