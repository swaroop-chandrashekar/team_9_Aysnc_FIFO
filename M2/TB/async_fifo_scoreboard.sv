/*******************************************************************************************/

// File_name : async_fifo_scoreboard.sv
// Author : Shashikirana
// Version : 1.0

/*******************************************************************************************/
import fifo_pkg::*;

class async_scoreboard;

// Declare 4 int datatypes for counting
// number of write transaction count
// number of read transaction count
// number of write data 
// number of read data
parameter DATA_SIZE = 12;

int trans_count_write = 0;
int trans_count_read = 0;
int w_count = 0;
int r_count = 0;

// Declare queues and array to hold the wData & rData	
logic [DATA_SIZE:0] hold_wData[$];
logic [DATA_SIZE:0] verif_wData;

logic [DATA_SIZE:0] hold_rData[$];
logic [DATA_SIZE:0] verif_rData;
 
// Declare transaction class handles for read and write 
transaction_write trans_w;
transaction_read trans_r;

transaction_write cov_data;
transaction_read cov_data1;

//Instantiate 2 mailboxes as 'mon2scb_write','mon2scb_read' parameterized by  

mailbox #(transaction_write)mon2scb_write; //write mon to sb
mailbox #(transaction_read)mon2scb_read;   //Read mon to sb

logic detect_rEmpty, detect_wFull;


//create instance     
function new(mailbox #(transaction_write) mon2scb_write, mailbox #(transaction_read) mon2scb_read);
	this.mon2scb_write = mon2scb_write;
   	this.mon2scb_read = mon2scb_read;
	//mem_coverage = new();
endfunction: new

//In main task 
//Within fork join_none  begin end

task main();
	fork
		while(1)
		begin
			// Process write transactions
    			repeat (trans_count_write) 
			begin
        			wait (mon2scb_write.num() > 0);
        			scoreboard_write();
    			end

    			// Process read transactions
    			repeat (trans_count_read) 
			begin
        			wait (mon2scb_read.num() > 0);
        			scoreboard_read();
    			end
                       
		//Call check task
		check();
		end
	join_none
endtask: main

task scoreboard_write;

	transaction_write trans_w; 
    	trans_w = new(); 
    	mon2scb_write.get(trans_w);
    	$display("\t scoreboard winc = %0h \t wData = %0h", trans_w.winc, trans_w.wData);

    	hold_wData.push_back(trans_w.wData);
   	$display("\t scoreboard write push: wData = %0h \t", trans_w.wData);
    	w_count++; 
   	if (trans_w.wFull == 1)
    	detect_wFull = 1;
   
endtask

task scoreboard_read;

	transaction_read trans_r;
    	trans_r = new(); 
    	mon2scb_read.get(trans_r);  
  	hold_rData.push_back(trans_r.rData);
  	$display("\t scoreboard read push: rData = %0h \t", trans_r.rData);
    	r_count++; 

endtask

// Compare the result

task check();
	transaction_read trans_r;
   	transaction_write trans_w;
   	trans_r = new();
   	trans_w = new(); 
   	mon2scb_read.get(trans_r.rEmpty);
   	mon2scb_write.get(trans_w.wFull);

   	for (int i=0; i < hold_wData.size; i++) 
	begin
     		verif_wData = hold_wData[i];
     		verif_rData = hold_rData[i];
    
		$display("scoreboard :: expected wData = %h, rData = %h", verif_wData, verif_rData);
      		if (verif_wData != verif_rData)
        		$error("scoreboard check failed :: expected wData = %0h, rData = %0h", verif_wData, verif_rData);
   	end

   	if (trans_w.wFull == 1)
     		$display("FIFO was detected FULL");
   	else 
		$display("FIFO is not FULL");
   
   	if (trans_r.rEmpty == 1)
     		$display("FIFO was detected EMPTY");
   	else 
		$display("FIFO is not EMPTY");
   
endtask 

//In the report method
//Display gen_data_count, rcvd_data_count, data_verified 
	
function void report();
	$display(" ------------------------ SCOREBOARD REPORT ----------------------- \n ");
	$display(" %0d Read Data Generated, %0d Read Data Recevied, %0d \n",verif_wData, verif_rData);
	$display(" ------------------------------------------------------------------ \n ");
endfunction: report

endclass
