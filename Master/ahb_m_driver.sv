`define DRIVE_IF_M vif.AHB_M_DRIVER.ahb_m_driver_cb

class ahb_m_driver extends uvm_driver#(ahb_seq_item);
  `uvm_component_utils(ahb_m_driver)
  
  virtual ahb_if vif;
  event done;
  
  function new(string name = "ahb_m_driver", uvm_component parent = null);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ///Get the interface
    if(!uvm_config_db#(virtual ahb_if)::get(this, "*", "vif", vif))
      `uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
  endfunction
  
  task run_phase(uvm_phase phase);
          init();
      fork
        address_phase();
        data_phase();
      join
    
  endtask
  
  /////Drive the signals to interface
  
  task address_phase(); 
    forever begin
      seq_item_port.get(req);
//     while(`DRIVE_IF_M.HREADYOUT); 
    @(posedge vif.HCLK);
    `DRIVE_IF_M.HWRITE <= req.HWRITE;
    `DRIVE_IF_M.HADDR <= req.HADDR;
//       `uvm_info(get_type_name, $sformatf("[Master Driver] Address = %0h , write = %0b",req.HADDR, req.HWRITE), UVM_NONE);
      ->done;
    end
  endtask
  
  task data_phase();
//     @done;
    forever begin
     @done;
     @(posedge vif.HCLK);
     if(vif.HWRITE)begin
       `DRIVE_IF_M.HWDATA <= req.HWDATA;
     end
      
    `uvm_info(get_type_name, $sformatf("[Master Driver] Data = %0h, Address = %0h , write = %0b",req.HWDATA, req.HADDR, req.HWRITE), UVM_NONE);
    end
    endtask
  
  task init();
    wait (vif.HRESETn == 0);
    `DRIVE_IF_M.HWRITE <= 0;
    `DRIVE_IF_M.HADDR <= 0;
    `DRIVE_IF_M.HWDATA <= 0;
  endtask
  
endclass
