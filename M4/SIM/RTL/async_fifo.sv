/********************************************************************************************
Filename:	async_fifo.sv   
Description:	RTL file for async fifo testbench 
Version:	1.0
*********************************************************************************************/ 


//////////*********TOP MODULE*********////////////

module ASYNC_FIFO #(parameter DATA_SIZE = 12, parameter ADDR_SIZE = 12 ) ( winc, wclk, wrst,  rinc, rclk, rrst,  wData, rData, wFull, rEmpty);  //Data Size is 12, ADDR_SIZE must be 12 per spec
  
	input  logic winc, wclk, wrst;
  	input  logic rinc, rclk, rrst;
  	input  logic [DATA_SIZE-1:0] wData;

  	output logic [DATA_SIZE-1:0] rData;
  	output logic wFull;
  	output logic rEmpty;


  	logic [ADDR_SIZE-1:0] 	waddr, raddr;  //Address logics - Pointer modules to Memory array 
  	logic [ADDR_SIZE:0] 	wptr, rptr;    //Pointers generated from Pointer modules 
	logic [ADDR_SIZE:0] 	wptr_s, rptr_s;    //Synchronized Pointers - output of Synchronizers to Full/Empty Logic Blocks

  	synchronizer_r2w                    synchronizer_r2w_inst	(.rptr_s(rptr_s),.rptr(rptr),.wclk(wclk),.wrst(wrst));
  	synchronizer_w2r                    synchronizer_w2r_inst       (.wptr_s(wptr_s),.wptr(wptr),.rclk(rclk),.rrst(rrst));
  	fifo_mem #(DATA_SIZE, ADDR_SIZE)    fifo_mem_inst     		(.rData(rData),.wData(wData),.waddr(waddr),.raddr(raddr),.wclk(wclk),.wFull(wFull),.winc(winc),.rclk(rclk),.rinc(rinc),.rEmpty(rEmpty));
  	rptr_handler #(ADDR_SIZE)           rptr_handler_inst 		(.raddr(raddr),.rEmpty(rEmpty),.rptr(rptr),.rinc(rinc), .rclk(rclk),.rrst(rrst),.wptr_s(wptr_s),.rHalf_empty(rHalf_empty));
  	wptr_handler #(ADDR_SIZE)           wptr_Full_inst    		(.waddr(waddr),.wFull(wFull),.wptr(wptr),.winc(winc),.wclk(wclk),.wrst(wrst),.rptr_s(rptr_s),.wHalf_full(wHalf_full) );

endmodule : ASYNC_FIFO


//////////********* FIFO MEM MODULE*********////////////

module fifo_mem#( parameter DATA_SIZE = 12, parameter ADDR_SIZE = 12) (rinc, winc, wclk,  wFull, rEmpty, rclk, waddr, raddr, wData, rData);

	input  logic winc, wFull, wclk, rinc, rEmpty, rclk;
  	input  logic [ADDR_SIZE-1:0] waddr, raddr;
  	input  logic [DATA_SIZE-1:0] wData;
  	output logic [DATA_SIZE-1:0] rData;

  	// memory model
  	localparam DEPTH = 1<<ADDR_SIZE;

  	logic [DATA_SIZE-1:0] fifo_mem1 [0:DEPTH-1];

  	always @(posedge rclk)
	begin
		if (rinc && !rEmpty)
      			rData = fifo_mem1[raddr];
	end

  	always @(posedge wclk)
    	begin
		if (winc && !wFull)
      			fifo_mem1[waddr] <= wData;
	end

endmodule :fifo_mem



//////////********* Synchronizer read to write module*********////////////

module synchronizer_r2w #(parameter ADDR_SIZE = 12) (wclk, wrst, rptr, rptr_s);

	input  logic wclk, wrst;
  	input  logic [ADDR_SIZE:0] rptr;
  	output logic [ADDR_SIZE:0] rptr_s;


  	logic [ADDR_SIZE:0] w1_rptr;

  	always_ff @(posedge wclk or negedge wrst) //2 cycle sync
	begin
    		if (!wrst) 
			{rptr_s,w1_rptr} <= 0;
   		 else 
			 {rptr_s,w1_rptr} <= {w1_rptr,rptr};
	end

endmodule: synchronizer_r2w

//////////********* Synchronizer write to read module*********////////////

module synchronizer_w2r #(parameter ADDR_SIZE = 12) (rclk, rrst, wptr, wptr_s);

	input  logic rclk, rrst;
  	input  logic [ADDR_SIZE:0] wptr;
  	output logic [ADDR_SIZE:0] wptr_s;


  	logic [ADDR_SIZE:0] r1_wptr;

  	always_ff @(posedge rclk or negedge rrst) //2 cycle sync
	begin
    		if (!rrst)
      			{wptr_s,r1_wptr} <= 0;
    		else
      			{wptr_s,r1_wptr} <= {r1_wptr,wptr};
	end
endmodule: synchronizer_w2r



//
// Read pointer and empty generation
//
module rptr_handler #( parameter ADDR_SIZE = 12) ( rinc, rclk, rrst, wptr_s, rEmpty, rHalf_empty, raddr, rptr);

	input  logic rinc, rclk, rrst;
  	input  logic [ADDR_SIZE :0] wptr_s;
 	output logic rEmpty;
	output logic rHalf_empty;
  	output logic [ADDR_SIZE-1:0] raddr;
  	output logic [ADDR_SIZE :0] rptr;

	logic [ADDR_SIZE:0] rbin;
  	logic [ADDR_SIZE:0] rgraynext, rbinnext;
	logic rEmpty_reg;

  	always_ff @(posedge rclk or negedge rrst) 
	begin
    		if (!rrst)
      			{rbin, rptr} <= '0;
    		else
      			{rbin, rptr} <= {rbin + (rinc & ~rEmpty), rgraynext};
	end


  	assign raddr = rbin[ADDR_SIZE-1:0];
  	assign rbinnext = rbin + (rinc & ~rEmpty);
  	assign rgraynext = (rbinnext>>1) ^ rbinnext;

  
  	//FIFO Empty Logic generation 
  	assign rEmpty_reg = (rgraynext == wptr_s);

  	always_ff @(posedge rclk or negedge rrst)
	begin
    		if (!rrst)
      			rEmpty <= 1'b1;
    		else
      			rEmpty <= rEmpty_reg;
	end

endmodule:rptr_handler

//////////*********wptr handler module**********///////////

module wptr_handler #(parameter ADDR_SIZE = 12) (winc, wclk, wrst, rptr_s, wFull, wHalf_full, waddr, wptr);

	input  logic winc, wclk, wrst;
  	input  logic [ADDR_SIZE :0] rptr_s;
  	output logic wFull;
	output logic wHalf_full;
  	output logic [ADDR_SIZE-1:0] waddr;
  	output logic [ADDR_SIZE :0] wptr;

	//Intermediary Pointer signals used for incrementing and grey code conversion
  	logic [ADDR_SIZE:0] wbin;
  	logic [ADDR_SIZE:0] wgraynext, wbinnext;
	logic wFull_reg;

  	//assign pointers the incremented value on clock transition
  	always_ff @(posedge wclk or negedge wrst)
	begin
    		if (!wrst)
      			{wbin, wptr} <= '0;
    		else
      			{wbin, wptr} <= {wbin + (winc & ~wFull), wgraynext};
	end

  	// Memory write-address pointer (okay to use binary to address memory)
  	
	//Set the write address to the value in the First Read Pointer, truncate MSB
	assign waddr = wbin[ADDR_SIZE-1:0];
	
	//Increment First Pointer IF winc and Full flag is not asserted and save it in Second Pointer
  	assign wbinnext = wbin + (winc & ~wFull);

	//Convert the value in the Second Internal Pointer to greycode and output it as wptr
  	assign wgraynext = (wbinnext>>1) ^ wbinnext;

	//Full Flag Logic generation
 	assign wFull_reg = (wgraynext=={~rptr_s[ADDR_SIZE:ADDR_SIZE-1], rptr_s[ADDR_SIZE-2:0]});  //We must Negate the 2MSB for proper Full Flag Detection
  	assign wHalf_full = (wptr >= (1 << (ADDR_SIZE-1)));					  //left shifting 1 by the ADDR_SIZE  and comparing with wptr if greater than then will be 1

 	 always_ff @(posedge wclk or negedge wrst)
	 begin
    		if (!wrst)
      			wFull <= 1'b0;
    		else
      			wFull <= wFull_reg; 
	end

endmodule:wptr_handler





