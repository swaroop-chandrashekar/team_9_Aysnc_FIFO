class transaction_write;
	rand bit winc;
	rand bit [11:0] wData;
	bit wFull;
	
	function void display_write(string details1);
		$display("----------------------");
		$display("%s", details1);
		$display("----------------------");
		$display("winc = %d, wfull = %d, wData = %d",winc,wFull,wData);
	endfunction
endclass


class transcation_read;
	rand bit rinc;
	bit [11:0] rData;
	bit rEmpty;
	
	function void display_read(string details2);
		$display("----------------------");
		$display("%s", details2);
		$display("----------------------");
		$display("rData = %d, rinc = %d, rEmpty = %d",rData,rinc,rEmpty);
	endfunction
endclass
