interface ahb_if (input logic HCLK, HRESETn);
  
  logic [31:0] HADDR;
  logic [31:0] HWDATA;
  logic HWRITE;
  logic [2:0] HBURST;
  logic [2:0] HSIZE;
  logic [1:0] HTRANS;
  logic [3:0] HWSTRB;
  
  logic [31:0] HRDATA;
  logic HREADYOUT;
  logic HRESP;

  clocking ahb_m_driver_cb @(posedge HCLK);
    default input #1step output #0;
    output HADDR;
    output HWDATA;
    output HWRITE;
    output HBURST;
    output HSIZE;
    output HTRANS;
    output HWSTRB;
    input HRDATA;
    input HREADYOUT;
    input HRESP;
  endclocking
  
  clocking ahb_s_driver_cb @(posedge HCLK);
    default input #1step output #1step;
    output HRDATA;
    output HREADYOUT;
    output HRESP;
    input HADDR;
    input HWDATA;
    input HWRITE;
    input HBURST;
    input HSIZE;
    input HTRANS;
    input HWSTRB;
  endclocking

  clocking ahb_m_monitor_cb @(posedge HCLK);
    default input #1step;
    input HRDATA;
    input HREADYOUT;
    input HRESP;
    input HADDR;
    input HWDATA;
    input HWRITE;
    input HBURST;
    input HSIZE;
    input HTRANS;
    input HWSTRB;
  endclocking
  
  clocking ahb_s_monitor_cb @(posedge HCLK);
    default input #1step;
    input HRDATA;
    input HREADYOUT;
    input HRESP;
    input HADDR;
    input HWDATA;
    input HWRITE;  
    input HBURST;
    input HSIZE;
    input HTRANS;
    input HWSTRB;
  endclocking
  
  modport AHB_M_DRIVER  (clocking ahb_m_driver_cb, input HCLK, HRESETn);
  modport AHB_S_DRIVER  (clocking ahb_s_driver_cb, input HCLK, HRESETn);
  modport AHB_M_MONITOR (clocking ahb_m_monitor_cb, input HCLK, HRESETn);
  modport AHB_S_MONITOR (clocking ahb_s_monitor_cb, input HCLK, HRESETn);

                                                     //////--ASSERTIONS--////////
  property stable_addr;
     @(posedge HCLK) disable iff (!HRESETn)
      (!HREADYOUT && HTRANS inside {10, 11}) |=> $stable(HADDR) && $stable(HWRITE) && $stable(HSIZE) && $stable(HBURST);
  endproperty
  
  hready_low: assert property(stable_addr) 
                   else $error("Protocol violation: Address and control signal not stable during HREADY low"); 
  
 // property incr_burst;
 //    
 //    @(posedge HCLK) disable iff (!HRESETn)
 //     (HREADYOUT && HTRANS inside {10} && ((HBURST == INCR) || (HBURST == INCR4) || (HBURST == INCR8) || (HBURST == 16) )

endinterface


