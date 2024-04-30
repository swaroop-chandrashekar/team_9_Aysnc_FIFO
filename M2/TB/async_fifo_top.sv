/********************************************************************************************
Filename:	async_fifo_top.sv   
Description:	Top module for ASYNC_FIFO testbench
Version:	1.0

*********************************************************************************************/

  // Include the test.sv 
`include "async_fifo_test.sv"

`include "async_fifo_interface.sv"


module async_fifo_top;

bit rclk,wclk;
bit rrst,wrst;

always #4 wclk = ~wclk;
always #10 rclk = ~rclk;
  
//Instantiate the interface	
intf DUV_IF (wclk,rclk,wrst,rrst);

// Declare an handle for the test as testcase1
test testcase1 (in);

// instantiate the DUV
AYNC_FIFO DUT (.wData(in.wData), .wFull(in.wFull), .rEmpty(in.rEmpty), .winc(in.winc), .rinc(in.rinc), .wclk(in.wclk), .rclk(in.rclk), .rrst(in.rrst), .wrst(in.wrst), .rData(in.rData));
  
  

initial 
begin
	wclk =0;
    	rclk=0;
    	wrst =0;
    	rrst=0;
    	in.rinc=0;
    	in.winc=0;
    	#1
    	rrst =1;
    	wrst=1;
    

end

   
endmodule

