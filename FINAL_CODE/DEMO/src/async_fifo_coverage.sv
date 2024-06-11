/********************************************************************************************
Filename:	async_fifo_coverage.sv   
Description:	 async fifo covergroups
Version:	1.0
*********************************************************************************************/


 //covergroup 
 covergroup FIFO_coverage;
 	option.per_instance = 1;

  	WRITE_DATA : coverpoint DUV_IF.wData{
		option.comment = "write data ";
	        bins low_range  = {[0:200]};
	        bins mid_range  = {[201:400]};
	        bins high_range = {[401:511]};	
	}

	WDATA_ONEHOT: coverpoint DUV_IF.wData {
		option.comment = "one hot write data ";
    		bins wdata_onehot[] = {9'h01,9'h02,9'h04,9'h08,9'h10,9'h20,9'h40,9'h80};

        }

	WDATA_BOUNDARY: coverpoint DUV_IF.wData {
		option.comment = "boundary write data ";
    		bins wdata_boundary[] = {9'h1ff,9'h00};

        }


	FULL : coverpoint DUV_IF.wFull {
		option.comment = "FULL_FLAG";
		bins full_c   = { 0  };
		bins full_c1  = { 1  };
	}

	EMPTY: coverpoint DUV_IF.rEmpty {
		option.comment = "WHEN RESET IS OFF check EMPTY";
		bins empty_c  = {0 };
		bins empty_c1 = {1 };
	}

	HALF_EMPTY: coverpoint DUV_IF.rHalf_empty {
		option.comment = "WHEN RESET IS OFF check EMPTY";
		bins empty_c  = {0 };
		bins empty_c1 = {1 };
	}


  	READ_DATA : coverpoint DUV_IF.rData{
		option.comment = "read data ";
	        bins low_range  = {[0:200]};
	        bins mid_range  = {[201:400]};
	        bins high_range = {[401:511]};	
	}

	WHALF_FULL: coverpoint DUV_IF.wHalf_full {
		option.comment = "WHEN RESET IS OFF check EMPTY";
		bins full_c  = {0 };
		bins full_c1 = {1 };
	}

	WRITE_INC : coverpoint DUV_IF.winc{
  		bins incr_s = (0 => 1);
 		bins incr_s1 = (1 => 0);
  	}

  	READ_INC : coverpoint DUV_IF.rinc{
  		bins incr_sr = (0 => 1);
  		bins incr_s1r = (1 => 0);
  	}

	WRITE_CLK: coverpoint DUV_IF.wclk {
  		option.comment = "write clock signal";
  		bins clk_low_to_high = (0 => 1);
  		bins clk_high_to_low = (1 => 0);
	}

	READ_CLK: coverpoint DUV_IF.rclk {
  		option.comment = "read clock signal";
  		bins clk_low_to_high = (0 => 1);
  		bins clk_high_to_low = (1 => 0);
	}

WRITExADDxDATA : cross WRITE_INC,WRITE_DATA;
READxADDxDATA  : cross READ_INC, READ_DATA;
READxWRITE     : cross  WRITE_DATA,READ_DATA;

endgroup



