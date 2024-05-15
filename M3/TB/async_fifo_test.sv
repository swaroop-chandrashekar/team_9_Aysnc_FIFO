
`include "async_fifo_environment.sv"

program test(intf in);
  environment env;
  
initial begin
  
   $display("TEST START");
        
    env = new(in);
    env.gen.trans_count =5000;    
    env.no_of_transactions=5000;
    
    env.run();
    $display("TEST FINISH");
    $finish;
  end
endprogram
