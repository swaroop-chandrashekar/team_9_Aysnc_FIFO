// File : async_fifo.sv 
// Top level Module


module ASYNC_FIFO #(parameter DATA_SIZE = 12, parameter ADDR_SIZE = 12) ( winc, wclk, wrst,  rinc, rclk, rrst,  wData, rData, wFull, rEmpty);  //Data Size is 12, ADDR_SIZE must be 12 per spec
 	
	input  logic winc, wclk, wrst;
	input  logic rinc, rclk, rrst;
	input  logic [DATA_SIZE-1:0] wData;

	output logic [DATA_SIZE-1:0] rData;
	output logic wFull;
	output logic rEmpty;
	
	//Internal Wires
	logic [ADDR_SIZE-1:0] waddr,raddr;   //Adress logics - Pointer modules to Memory array 
	logic [ADDR_SIZE:0] wptr,rptr;      //Pointers generated from Pointer modules
	logic [ADDR_SIZE:0] wptr_s,rptr_s; //Synchronized Pointers - output of Synchronizers to Full/Empty Logic Blocks
	
	//Module Instantiations
	
	//FIFO Memory
	fifo_mem #(DATA_SIZE,ADDR_SIZE) fifo_mem_inst             (.rData(rData),.wData(wData),.waddr(waddr),.raddr(raddr),.wclk(wclk),.wFull(wFull),.winc(winc),.rclk(rclk),.rinc(rinc),.rEmpty(rEmpty));
	
	//Read to Write Synchronizer
	synchronizer_r2w #(ADDR_SIZE) synchronizer_r2w_inst                         (.rptr_s(rptr_s),.rptr(rptr),.wclk(wclk),.wrst(wrst));
	
	//Write to Read Synchronizer
	synchronizer_w2r #(ADDR_SIZE) synchronizer_w2r_inst                         (.wptr_s(wptr_s),.wptr(wptr),.rclk(rclk),.rrst(rrst));
	
	//Read Pointer and Empty Flag Generation Logic
	rptr_handler #(DATA_SIZE,ADDR_SIZE) rptr_Empty_inst       (.raddr(raddr),.rEmpty(rEmpty),.rptr(rptr),.rinc(rinc), .rclk(rclk),.rrst(rrst),.wptr_s(wptr_s),.rHalf_empty(rHalf_empty));
	
	//Write Pointer and Full Flag Generation Logic
	wptr_handler #(DATA_SIZE,ADDR_SIZE) wptr_Full_inst        (.waddr(waddr),.wFull(wFull),.wptr(wptr),.winc(winc),.wclk(wclk),.wrst(wrst),.rptr_s(rptr_s),.wHalf_full(wHalf_full));
	
endmodule : ASYNC_FIFO




module fifo_mem #(parameter DATA_SIZE = 12, parameter ADDR_SIZE = 12) (rinc, rrst, wrst, winc, wclk,  wFull, rEmpty, rclk, waddr, raddr, wData, rData); //Data Size is 12
  
	input logic rinc, winc, wclk, wFull, rEmpty, rclk, rrst, wrst;
	input logic [ADDR_SIZE-1:0] waddr, raddr;
	input logic [DATA_SIZE-1:0] wData;
	output logic [DATA_SIZE-1:0] rData;

	//Memory array creation
	localparam DEPTH =1<<ADDR_SIZE-1 ; 
  	logic [DATA_SIZE-1:0] fifo_mem[0:DEPTH-1]; 

		
	/*always_ff @(posedge rinc or negedge rrst) 
	begin
    		rData = fifo_mem[raddr];
    	end*/

	always@(posedge rclk or negedge rrst)
	begin
		if(rinc && !rEmpty) 
			rData = fifo_mem[raddr];
	end 

	
	//Assign memory space the written data IF Write Pointer increment command from producer is high AND there is no full flag asserted
  	always_ff @(posedge wclk or negedge wrst) 
	begin
		if (winc && !wFull) 
		begin
          		fifo_mem[waddr] <= wData;
		end
	end
  

  
endmodule : fifo_mem


//////////********* Synchronizer read to write module*********////////////

module synchronizer_r2w #(parameter ADDR_SIZE = 12)(wclk, wrst, rptr, rptr_s);
 	
	input logic wclk, wrst;
	input logic [ADDR_SIZE:0] rptr;
	output logic [ADDR_SIZE:0] rptr_s;

	//Read pointer data storage in first flop
	logic [ADDR_SIZE:0] wq1_rptr;
	
	//checks for reset and on write clock rptr -> wq1_rptr -> rptr_s (output)
	always_ff @(posedge wclk or negedge wrst) 
	begin
		if (!wrst) 
		begin
			{rptr_s, wq1_rptr} <= 0;
		end 
		else 
		begin
			{rptr_s, wq1_rptr} <= {wq1_rptr, rptr};
		end
	end

endmodule : synchronizer_r2w


//////////********* Synchronizer write to read module*********////////////

module synchronizer_w2r #(parameter ADDR_SIZE = 12)  (rclk, rrst, wptr, wptr_s);
	
	input logic rclk, rrst;
	input logic [ADDR_SIZE:0] wptr;
	output logic [ADDR_SIZE:0] wptr_s;
	
	//Write pointer data storage in first flop
	logic [ADDR_SIZE:0] r1_wptr;
	
	//checks for reset and on read clock wptr -> r1_wptr -> wptr_s (output)
	always_ff @(posedge rclk or negedge rrst) 
	begin
		if (!rrst)
		begin
			{wptr_s, r1_wptr} <= 0;
		end 
		else 
		begin
			{wptr_s, r1_wptr} <= {r1_wptr,wptr};
		end
	end

endmodule : synchronizer_w2r


//////////*********rptr handler module**********///////////

module rptr_handler #(parameter DATA_SIZE = 12, parameter ADDR_SIZE = 12) ( rinc, rclk, rrst, wptr_s, rEmpty, rHalf_empty, raddr, rptr); 
        
	input  logic rinc, rclk , rrst;
	input  logic [ADDR_SIZE :0] wptr_s;
	output logic rEmpty;
	output logic rHalf_empty;
	output logic [ADDR_SIZE-1:0] raddr;
	output logic [ADDR_SIZE :0] rptr;
	
	logic [ADDR_SIZE:0] rbin, rbinnext, rgraynext;
	logic rEmpty_reg;

	always_ff @(posedge rclk) 
	begin
      		if (!rrst) 
		begin
			{rbin,rptr} <= 0;
		end 
		else 
		begin
			{rbin,rptr} <= {rbinnext,rgraynext};
		end
	end
	
   	assign raddr = rbin[ADDR_SIZE-1:0]; //MSB Truncated

  	assign rbinnext = (rinc && !rEmpty) ? rbin + 1 : rbin;

   	assign rgraynext = (rbinnext >> 1) ^ rbinnext;
   
   	//FIFO Empty Logic generation
  	assign rEmpty_reg = (rgraynext == wptr_s);
   
   	always_ff @(posedge rclk) 
	begin
     		if (!rrst) 
		begin
			rEmpty <= 1;
		end 
		else 
		begin
			rEmpty <= rEmpty_reg;
		end
	end

endmodule : rptr_handler

//////*********wptr handler module*************///////

module wptr_handler #(parameter DATA_SIZE = 12, parameter ADDR_SIZE = 12) (winc, wclk, wrst, rptr_s, wFull, wHalf_full, waddr, wptr);

	input logic winc, wclk, wrst;
	input logic [ADDR_SIZE :0] rptr_s;
	output logic wFull;
	output logic wHalf_full;
	output logic [ADDR_SIZE-1:0] waddr;
	output logic [ADDR_SIZE :0] wptr;	

	//Intermediary Pointer signals used for incrementing and grey code conversion
	logic [ADDR_SIZE:0] wbin, wbinnext, wgraynext;
	logic WFull_reg;
	
	//assign pointers the incremented value on clock transition
	always_ff @(posedge wclk or negedge wrst) 
	begin
      		if (!wrst) 
		begin
			{wptr,wbin} <= 0;
		end 
		else 
		begin
			{wptr,wbin} <=  {wgraynext,wbinnext};
		end
	end
	
	//Set the write address to the value in the First Read Pointer, truncate MSB 
	assign waddr = wbin[ADDR_SIZE-1:0];
	
	//Increment First Pointer IF winc and Full flag is not asserted and save it in Second Pointer
	assign wbinnext= wbin + (winc & ~wFull);

    	//Convert the value in the Second Internal Pointer to greycode and output it as wptr
    	assign wgraynext = (wbinnext>>1) ^ wbinnext;
	
	//Full Flag Logic generation
	assign wFull_reg = (wgraynext == {~rptr_s[ADDR_SIZE:ADDR_SIZE-1],rptr_s[ADDR_SIZE-2:0]}); //We must Negate the 2MSB for proper Full Flag Detection
	assign wHalf_full = (wptr >= (1 << (ADDR_SIZE-1)));					  //left shifting 1 by the ADDR_SIZE  and comparing with wptr if greater than then will be 1 
	

	always_ff @(posedge wclk or negedge wrst) 
	begin
		if (!wrst) 
		begin
			wFull <= 0;
		end 
		else 
		begin
			wFull <= wFull_reg;
		end
	end

endmodule : wptr_handler







