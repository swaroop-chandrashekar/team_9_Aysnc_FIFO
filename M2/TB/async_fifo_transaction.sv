class transaction_write;
	rand bit winc;
	//rand bit rinc;
	rand bit [11:0] wData;
	//bit [11:0] rData;
	bit wFull;
	//bit rEmpty;
	
	function void display_write(string details1);
		$display("----------------------");
		$display("%s", details1);
		$display("----------------------");
		$display("winc = %d, wfull = %d, wData = %d",winc,wFull,wData);
		//$display("rData = %d, rinc = %d, rEmpty = %d",rData,rinc,rEmpty);
	endfunction
endclass


class transcation_read;
	//rand bit winc;
	rand bit rinc;
	//rand bit [11:0] wData;
	bit [11:0] rData;
//	bit wFull;
	bit rEmpty;
	
	function void display_read(string details2);
		$display("----------------------");
		$display("%s", details2);
		$display("----------------------");
		//$display("winc = %d, wfull = %d, wData = %d",winc,wFull,wData);
		$display("rData = %d, rinc = %d, rEmpty = %d",rData,rinc,rEmpty);
	endfunction
endclass