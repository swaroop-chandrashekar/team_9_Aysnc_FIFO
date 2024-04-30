`include "async_fifo_environment.sv"

program test(intf in);
  environment env;
  logic [5:0] read_request;
  logic [5:0] write_request;
  initial begin
    $display("test environment start");
    read_request = 5;
    write_request = 5;
    
    env = new(in);
    env.gen.tx_count_read =5;
    env.gen.tx_count_write =5;
    
    env.driv.trans_count_read=5;
    env.driv.trans_count_write=5;
    
    env.mon.trans_count_write=5;
    env.mon.trans_count_read=5;
    
    env.scb.trans_count_write=5;
    env.scb.trans_count_read=5;

    env.run();
    $display("TEST FINISH");
    $finish;
  end
endprogram

