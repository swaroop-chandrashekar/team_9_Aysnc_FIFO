import async_fifo_pkg::*;

program test(intf in);
  environment env;
  
initial begin
  
   $display("TEST START");
        
    env = new(in);
    env.gen.trans_count =100;    
    env.no_of_transactions=100;
    
    env.run();
    $display("TEST FINISH");
    $finish;
  end
endprogram
