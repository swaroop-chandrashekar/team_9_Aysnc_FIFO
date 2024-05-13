/********************************************************************************************
Filename:	async_fifo_top.sv   
Description:	Top module for ASYNC_FIFO testbench
Version:	1.0

*********************************************************************************************/

  // Include the test.sv 
`include "async_fifo_test.sv"
`include "aysnc_fifo_interface.sv"


module async_fifo_top;
 parameter DATA_SIZE = 12;
  parameter ADDR_SIZE = 12;
  environment env;
  logic winc;
	logic rinc;
	logic [DATA_SIZE-1:0] wData;

	logic [DATA_SIZE-1:0] rData;
	logic wFull;
	logic rEmpty;
	
	//Internal Wires
	logic [ADDR_SIZE-1:0] waddr,raddr;   
	logic [ADDR_SIZE:0] wptr,rptr;      
	logic [ADDR_SIZE:0] wptr_s,rptr_s;

  
bit rclk,wclk,rrst,wrst;
  
always #5 wclk = ~wclk;
always #5 rclk = ~rclk;
  
initial 
begin
	wclk =0;
    	rclk=0;
    	wrst =0;
    	rrst=0;
    	#10
    	rrst =1;
    	wrst=1;
end
  

intf in (wclk,rclk,wrst,rrst);
test t1 (in);

ASYNC_FIFO DUT (.wData(in.wData),
            .wFull(in.wFull),
            .rEmpty(in.rEmpty),
            .winc(in.winc),
            .rinc(in.rinc),
            .wclk(in.wclk),
            .rclk(in.rclk),
            .rrst(in.rrst),
            .wrst(in.wrst),
            .rData(in.rData));
  

  //coverage start
 covergroup async_fifo_cover;
  option.per_instance = 1;

  // Coverpoints for data inputs and outputs
  WRITE_DATA : coverpoint in.wData{
		option.comment = "write data ";
	        bins low_range  = {[1:511]};
	        bins mid_range  = {[512:1023]};
	        bins high_range = {[1023:2048]};	
	}
  // Coverpoints for flags
	/*FULL : coverpoint in.wFull {
		option.comment = "FULL_FLAG";
		bins full_c   = ( 0 => 1 );
		bins full_c1  = ( 1 => 0 );
	}*/

	EMPTY: coverpoint in.rEmpty {
		option.comment = "WHEN RESET IS OFF check EMPTY";
		bins empty_c  = (0 => 1);
		bins empty_c1 = (1 => 0);
	}

  READ_DATA : coverpoint in.rData{
		option.comment = "read data ";
	        bins low_range  = {[1:511]};
	        bins mid_range  = {[512:1023]};
	        bins high_range = {[1023:2048]};	
	}


  // Coverpoints for increment signals
  INCREMENT : coverpoint in.winc{
  bins incr_s = (0 => 1);
  bins incr_s1 = (1 => 0);
  }

  INCREMENTread : coverpoint in.rinc{
  bins incr_sr = (0 => 1);
  bins incr_s1r = (1 => 0);
  }

endgroup

  async_fifo_cover async_fifo_cov_inst;
  initial begin 
    async_fifo_cov_inst = new();
    forever begin @(posedge wclk or posedge rclk)
      async_fifo_cov_inst.sample();
    end
  end

  
endmodule


