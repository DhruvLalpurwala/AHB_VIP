import ahb_pkg::*;
import uvm_pkg::*;
`include "../Interface/ahb_if.sv"

module tb;
  //localparam int ADDR_WIDTH = 32;
  //localparam int DATA_WIDTH = 32;
  bit HCLK;
  bit HRESETn;
 
  always #5 HCLK = ~HCLK;
  
  initial begin
    //HRESETn = 1;
    //#3 
    HRESETn = 0;
    #20 HRESETn =1;
    //#20 HRESETn = 0;
    //#5 HRESETn = 1;
  end
  
  ahb_if #(ADDR_WIDTH,DATA_WIDTH) vif (HCLK, HRESETn);
  
  initial begin
    uvm_config_db#(virtual ahb_if)::set(null, "*", "vif", vif);
    $dumpfile("dump.vcd"); 
    $dumpvars;
  end
  
  initial begin
    run_test("ahb_test");
  end
endmodule
