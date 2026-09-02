interface ahb_if (input logic HCLK, HRESETn);
  
  logic [31:0] HADDR;
  logic [31:0] HWDATA;
  logic HWRITE;
  logic [2:0] HBURST;
  logic [2:0] HSIZE;
  logic [1:0] HTRANS;
  
  logic [31:0] HRDATA;
  logic HREADYOUT;
  logic HRESP;

  clocking ahb_m_driver_cb @(posedge HCLK);
    //default input #1 output #1;
    output HADDR;
    output HWDATA;
    output HWRITE;
    output HBURST;
    output HSIZE;
    output HTRANS;
    input HRDATA;
    input HREADYOUT;
    input HRESP;
  endclocking
  
  clocking ahb_s_driver_cb @(posedge HCLK);
  //  default input #1 output #1;
    output HRDATA;
    output HREADYOUT;
    output HRESP;
    input HADDR;
    input HWDATA;
    input HWRITE;
    input HBURST;
    input HSIZE;
    input HTRANS;
  endclocking
  
  clocking ahb_m_monitor_cb @(posedge HCLK);
//     default input #1 output #0;
    input HRDATA;
    input HREADYOUT;
    input HRESP;
    input HADDR;
    input HWDATA;
    input HWRITE;
    input HBURST;
    input HSIZE;
    input HTRANS;
  endclocking
  
//     clocking ahb_s_monitor_cb @(posedge HCLK);
// //     default input #1 output #1;
//     input HRDATA;
//     input HREADYOUT;
//     input HRESP;
//     input HADDR;
//     input HWDATA;
//     input HWRITE;  
//     input HBURST;
//     input HSIZE;
//     input HTRANS;
//   endclocking
  
  modport AHB_M_DRIVER  (clocking ahb_m_driver_cb, input HCLK, HRESETn);
  modport AHB_S_DRIVER  (clocking ahb_s_driver_cb, input HCLK, HRESETn);
  modport AHB_M_MONITOR (clocking ahb_m_monitor_cb, input HCLK, HRESETn);
//   modport AHB_S_MONITOR (clocking ahb_s_monitor_cb, input HCLK, HRESETn);
  
endinterface
