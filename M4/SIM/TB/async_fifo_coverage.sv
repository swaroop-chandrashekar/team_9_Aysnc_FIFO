


covergroup FIFO_coverage;
  //option.per_instance = 1;

  // Coverpoints for wData
	coverpoint DUV_IF.wData {
   	 bins data_bin[] = {[0:255]}; // Assuming 8-bit data size
  	}

  	// Coverpoints for rData
  	coverpoint DUV_IF.rData {
    	bins data_bin[] = {[0:255]}; // Assuming 8-bit data size
  	}

  	// Coverpoints for wFull flag
  	coverpoint DUV_IF.wFull {
    	bins full_bin[] = {0, 1};
  	}

  	// Coverpoints for rEmpty flag
  	coverpoint DUV_IF.rEmpty {
    	bins empty_bin[] = {0, 1};
  	}

  	// Cross coverage between wData and rData
  	cross DUV_IF.wData, DUV_IF.rData;
	
  	// Cross coverage between wData and wFull
  	cross DUV_IF.wData, DUV_IF.wFull;

  	// Cross coverage between rData and rEmpty
  	cross DUV_IF.rData, DUV_IF.rEmpty;


endgroup



