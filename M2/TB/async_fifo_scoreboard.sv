/*******************************************************************************************/

// File_name : async_fifo_scoreboard.sv
// Author : Shashikirana
// Version : 1.0

/*******************************************************************************************/


 class scoreboard;

 parameter DEPTH = 2048;
 int no_trans;
 logic [11:0] fifo_mem [DEPTH-1 : 0];
 bit [11:0] wr_count;
 bit [11:0] rd_count;
 mailbox mon2scb;
  
function new(mailbox mon2scb);
	this.mon2scb = mon2scb;
   	foreach(fifo_mem[i])
	begin
     		fifo_mem[i] = 12'h0;
   	end
endfunction 
 
virtual task main();
begin   
	transaction trans_sb;
    	mon2scb.get(trans_sb);
     
        if(trans_sb.winc)
	begin
        	fifo_mem[wr_count] = trans_sb.wData;
        	wr_count = wr_count + 1;
        end
        //$display("%0h,%0h,%0h,%0h,%0h,%0h,%0h,%0h",fifo_mem[0],fifo_mem[1],fifo_mem[2],fifo_mem[3],fifo_mem[4],fifo_mem[5],fifo_mem[6],fifo_mem[7]);

	if(trans_sb.rinc)
	begin
        	if(trans_sb.rData == fifo_mem[rd_count])
		begin
          		$display("\n\n ********PASSED at address %0h - trans_sb.Data = %0h - Saved Data = %0h**********************",rd_count, trans_sb.rData,fifo_mem[rd_count]);
                   	rd_count = rd_count + 1;
      		end 
		/*else 
		begin
         		$display("\n\n ERROR at address %0h - trans_sb.Data = %0h - Saved Data = %0h",rd_count,trans_sb.rData,fifo_mem[rd_count]);
      		end*/
    	end

      // Full & Empty checks
       if(trans_sb.wFull)
       begin
       		$display("\n\n FIFO is full");
       end
       if(trans_sb.rEmpty)
       begin
      		$display("\nFIFO is empty");
       end
       $display(" \n ***************************No_of_transaction_completed =%0d *******************************************************\n\n ", no_trans);
       no_trans++;

end
endtask


endclass
