class transaction;
  	
bit wrst, rrst, wclk, rclk;
rand bit [11:0] wData;
rand bit winc;
rand bit rinc;

//outputs 
  	
logic [11:0] rData;
bit rEmpty;
bit wFull;

// Constraints


endclass
