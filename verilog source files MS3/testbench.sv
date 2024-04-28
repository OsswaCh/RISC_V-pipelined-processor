
module top_tb;

  initial begin
    $dumpfile("dump.vcd"); 
    $dumpvars;
 	end
  
  reg clk, rst;
  top cpu (clk, rst);

  
  always begin
    clk = 0;
    forever #1 clk = ~clk;
  end

  initial begin
    rst = 1;
    #10;
    rst = 0;
    #100;
    
  	$finish;
  end
  
endmodule
