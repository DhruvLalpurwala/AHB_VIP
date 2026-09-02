`include "uvm_macros.svh"
import uvm_pkg::*;

`include "ahb_interface.sv"
`include "ahb_test.sv"

module tb;
  
  bit HCLK;
  bit HRESETn;
  
  always #5 HCLK = ~HCLK;
  
  initial begin
    HRESETn = 0;
    #5 HRESETn =1;
  end
  
  ahb_if vif(HCLK, HRESETn);
  
  initial begin
    uvm_config_db#(virtual ahb_if)::set(null, "*", "vif", vif);
    $dumpfile("dump.vcd"); 
    $dumpvars;
  end
  
  initial begin
    run_test("ahb_test");
  end
endmodule
