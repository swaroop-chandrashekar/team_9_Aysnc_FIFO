interface intf(input logic wclk,rclk,wrst,rrst);
logic [7:0] wData;
logic winc;
logic rinc;
    
logic [7:0] rData;
logic rEmpty;
logic wFull;

clocking driver_cb @(posedge wclk);
default input #1 output #1; 
output wData;                
output winc, rinc;
                     
input wFull, rEmpty;               
endclocking

    
 clocking monitor_cb @(posedge rclk);
 default input #1 output #1; 

 input winc, rinc;
 input rData; 
 input wFull, rEmpty;               
 endclocking
      
 modport DRIVER(clocking driver_cb,input wclk,wrst);
 modport MONITOR(clocking monitor_cb,input rclk,rrst);
    
endinterface: intf
