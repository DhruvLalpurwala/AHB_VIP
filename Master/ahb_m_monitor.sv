`define MON_IF_M vif//.AHB_M_MONITOR.ahb_m_monitor_cb

class ahb_m_monitor extends uvm_monitor;
  `uvm_component_utils(ahb_m_monitor)
  
  virtual ahb_if vif;
  event done;
  
  uvm_analysis_port #(ahb_seq_item) ahb_m_item_port;
  ahb_seq_item ahb_m_mon_item;
  
  function new(string name = "ahb_m_monitor", uvm_component parent = null);
    super.new(name, parent);
    ahb_m_item_port = new("ahb_m_item_port", this);
    ahb_m_mon_item = new();
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual ahb_if)::get(this, "*", "vif", vif))
      `uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
  endfunction

task run_phase(uvm_phase phase);
   forever begin
     
     wait(vif.HRESETn == 1'b1);
     @(posedge vif.HCLK);
        ahb_m_mon_item.HWRITE = `MON_IF_M.HWRITE;
        ahb_m_mon_item.HADDR = `MON_IF_M.HADDR;
     `uvm_info(get_type_name, $sformatf("[Master Mon] Ready = %0b, Address = %0h , write = %0b",`MON_IF_M.HREADYOUT, `MON_IF_M.HADDR, `MON_IF_M.HWRITE), UVM_NONE);

       if(`MON_IF_M.HWRITE) begin
         @(negedge vif.HCLK);
         ahb_m_mon_item.HWDATA = `MON_IF_M.HWDATA;
         `uvm_info(get_type_name, $sformatf("[Master Mon Write] WData = %0h", `MON_IF_M.HWDATA), UVM_NONE);
       end
       else if(!`MON_IF_M.HWRITE) begin
         @(negedge vif.HCLK);
         ahb_m_mon_item.HRDATA = `MON_IF_M.HRDATA;
         `uvm_info(get_type_name, $sformatf("[Master Mon READ] RData = %0h", `MON_IF_M.HRDATA), UVM_NONE);
       end
     `uvm_info(get_type_name, $sformatf("[Master Mon 888] Ready = %0b, Data = %0h, RData = %0h, Address = %0h , write = %0b",`MON_IF_M.HREADYOUT, `MON_IF_M.HWDATA, `MON_IF_M.HRDATA, `MON_IF_M.HADDR, `MON_IF_M.HWRITE), UVM_NONE);
//      @(negedge vif.HCLK);
       ahb_m_item_port.write(ahb_m_mon_item);
     `uvm_info(get_type_name, "Write Done", UVM_NONE);
     
//       `uvm_info(get_type_name, $sformatf("[Master Mon 888] Ready = %0b, Data = %0h, Address = %0h , write = %0b",`MON_IF_M.HREADYOUT, `MON_IF_M.HWDATA, `MON_IF_M.HADDR, `MON_IF_M.HWRITE), UVM_NONE);
    end
endtask
endclass
