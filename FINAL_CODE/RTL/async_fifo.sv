/********************************************************************************************
Filename:	async_fifo.sv   
Description:	RTL file for async fifo testbench 
Version:	1.0
*********************************************************************************************/ 


//////////*********TOP MODULE*********////////////

module ASYNC_FIFO #(parameter DATA_SIZE = 9, parameter ADDR_SIZE = 9 ) ( winc, wclk, wrst,  rinc, rclk, rrst,  wData, rData, wFull, rEmpty, wHalf_full, rHalf_empty);  //Data Size is 9, ADDR_SIZE must be 9 per spec
  
	input  logic winc, wclk, wrst;          // write_enable, write clock, write reset
  	input  logic rinc, rclk, rrst;          // read_enable, read_clock, read reset
  	input  logic [DATA_SIZE-1:0] wData;     // data_in to fifo
  	output logic [DATA_SIZE-1:0] rData;  	// data_out to fifo
  	output logic wFull;                  	// fifo full
  	output logic rEmpty;                 	// fif0 empty
	output logic wHalf_full, rHalf_empty;	 // fifo half full and half empty


  	logic [ADDR_SIZE-1:0] 	waddr, raddr;      // write and read address 
  	logic [ADDR_SIZE:0] 	wptr, rptr;        // Pointers generated from Pointer modules 
	logic [ADDR_SIZE:0] 	wptr_s, rptr_s;    // Synchronized binary Pointers 

  	synchronizer_r2w                    synchronizer_r2w_inst	(.rptr_s(rptr_s),.rptr(rptr),.wclk(wclk),.wrst(wrst));
  	synchronizer_w2r                    synchronizer_w2r_inst       (.wptr_s(wptr_s),.wptr(wptr),.rclk(rclk),.rrst(rrst));
  	fifo_mem #(DATA_SIZE, ADDR_SIZE)    fifo_mem_inst     		(.rData(rData),.wData(wData),.waddr(waddr),.raddr(raddr),.wclk(wclk),.wFull(wFull),.winc(winc),.rclk(rclk),.rinc(rinc),.rEmpty(rEmpty));
  	rptr_handler #(ADDR_SIZE)           rptr_handler_inst 		(.raddr(raddr),.rEmpty(rEmpty),.rptr(rptr),.rinc(rinc), .rclk(rclk),.rrst(rrst),.wptr_s(wptr_s),.rHalf_empty(rHalf_empty));
  	wptr_handler #(ADDR_SIZE)           wptr_Full_inst    		(.waddr(waddr),.wFull(wFull),.wptr(wptr),.winc(winc),.wclk(wclk),.wrst(wrst),.rptr_s(rptr_s),.wHalf_full(wHalf_full) );

endmodule : ASYNC_FIFO


//////////********* FIFO MEM MODULE*********////////////

module fifo_mem#( parameter DATA_SIZE = 9, parameter ADDR_SIZE = 9) (rinc, winc, wclk,  wFull, rEmpty, rclk, waddr, raddr, wData, rData);

	input  logic winc, wclk, rinc, rclk;        // Write enable, write clock, read enable, read clock
	input  logic wFull, rEmpty;                 // Fifo full and empty conditions
  	input  logic [ADDR_SIZE-1:0] waddr, raddr;  // Binary write and read pointers 
  	input  logic [DATA_SIZE-1:0] wData;	    // Data_in to fifo
  	output logic [DATA_SIZE-1:0] rData;         // Data_out to fifo

  	// fifo depth
  	localparam DEPTH = 1<<ADDR_SIZE;

	// Fifo memory array
  	logic [DATA_SIZE-1:0] fifo_mem1 [0:DEPTH-1];

	// FIFO write operation
	always @(posedge wclk)
    	begin
		if (winc && !wFull)
		begin
			`ifdef ERROR_INJECTION_WDATA
				fifo_mem1[waddr] <= wData ^ 9'hFF;  // Inject the incorrect data to wdata 
			`else	
      				fifo_mem1[waddr] <= wData;
			`endif
		end
	end

	//FIFO Read operation
  	always @(posedge rclk)
	begin
		if (rinc && !rEmpty)
      			rData = fifo_mem1[raddr];
	end

  
endmodule :fifo_mem



//////////********* Synchronizer read to write module*********////////////

module synchronizer_r2w #(parameter ADDR_SIZE = 9) (wclk, wrst, rptr, rptr_s);

	input  logic wclk, wrst;   // write clock and write reset
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

module synchronizer_w2r #(parameter ADDR_SIZE = 9) (rclk, rrst, wptr, wptr_s);

	input  logic rclk, rrst;              // Read clock and read reset
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
module rptr_handler #( parameter ADDR_SIZE = 9) ( rinc, rclk, rrst, wptr_s, rEmpty, rHalf_empty, raddr, rptr);

	input  logic rinc, rclk, rrst;      		  // Read enable , read clock , read reset
  	input  logic [ADDR_SIZE :0] wptr_s; 		  // Synchronized gray-coded write pointer
 	output logic rEmpty, rHalf_empty;	          // fifo empty and halfempty flag
  	output logic [ADDR_SIZE-1:0] raddr;
  	output logic [ADDR_SIZE :0] rptr;     		  
	
	logic [ADDR_SIZE:0] rbin;
  	logic [ADDR_SIZE:0] rgraynext, rbinnext;	  // Next Binary and gray-coded read pointers
	logic rEmpty_reg; 				  // Intermediate empty and half-empty flags

	// assign pointers the incremented value on clock transition
  	always_ff @(posedge rclk or negedge rrst) 
	begin
    		if (!rrst)
      			{rbin, rptr} <= '0;
    		else
      			{rbin, rptr} <= {rbin + (rinc & ~rEmpty), rgraynext};
	end

	//Set the Read address to the value in the First Read Pointer, truncate MSB
  	assign raddr = rbin[ADDR_SIZE-1:0];

	// Calculate next Read pointers 
  	assign rbinnext = rbin + (rinc & ~rEmpty);

	// Convert gray-coded write pointer to binary
  	assign rgraynext = (rbinnext>>1) ^ rbinnext;

  
  	// FIFO Empty and Half empry Logic generation 
  	assign rEmpty_reg = (rgraynext == wptr_s);
	assign rHalf_empty = (rptr >= (1 << (ADDR_SIZE-1)));

	// Update read pointers and flags on clock edge or reset
  	always_ff @(posedge rclk or negedge rrst)
	begin
    		if (!rrst)
      			rEmpty <= 1'b1;
    		else
      			rEmpty <= rEmpty_reg;
	end

endmodule:rptr_handler

//////////****************************wptr handlermodule************************/////////////////////////

module wptr_handler #(parameter ADDR_SIZE = 9) (winc, wclk, wrst, rptr_s, wFull, wHalf_full, waddr, wptr);

	input  logic winc, wclk, wrst;           // Write enable, write clk, write reset
  	input  logic [ADDR_SIZE :0] rptr_s;      // Synchronized gray-coded write pointer
  	output logic wFull, wHalf_full;		 // fifo full and half full logic
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

  	
	//Set the write address to the value in the First Read Pointer, truncate MSB
	assign waddr = wbin[ADDR_SIZE-1:0];
	
	//Increment First Pointer IF winc and Full flag is not asserted and save it in Second Pointer
  	assign wbinnext = wbin + (winc & ~wFull);

	//Convert the value in the Second Internal Pointer to greycode and output it as wptr
  	assign wgraynext = (wbinnext>>1) ^ wbinnext;

	//Full Flag Logic generation
	`ifdef WFULL_CORRUPT
		assign wFull_reg = (wgraynext=={~rptr_s[ADDR_SIZE:ADDR_SIZE-1]});
	`else
 		assign wFull_reg = (wgraynext=={~rptr_s[ADDR_SIZE:ADDR_SIZE-1], rptr_s[ADDR_SIZE-2:0]});  //We must Negate the 2MSB for proper Full Flag Detection
	`endif

  	assign wHalf_full = (wptr >= (1 << (ADDR_SIZE-1)));					  //left shifting 1 by the ADDR_SIZE  and comparing with wptr if greater than then will be 1

 	 always_ff @(posedge wclk or negedge wrst)
	 begin
    		if (!wrst)
      			wFull <= 1'b0;
    		else
      			wFull <= wFull_reg; 
	end

endmodule:wptr_handler





