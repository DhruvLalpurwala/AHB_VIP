`define DRIVE_IF_S vif.AHB_S_DRIVER.ahb_s_driver_cb

class ahb_s_driver extends uvm_driver#(ahb_seq_item);
  `uvm_component_utils(ahb_s_driver)
  
  virtual ahb_if vif;
  
  bit [31:0] mem [logic[31:0]];
  
  function new(string name = "ahb_s_driver", uvm_component parent = null);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ///Get the interface
    if(!uvm_config_db#(virtual ahb_if)::get(this, "*", "vif", vif))
      `uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
  endfunction
  
  task run_phase(uvm_phase phase);
    forever begin
      seq_item_port.get(req);
      drive(); 
    end
  endtask
  
  task drive();
//     @(posedge vif.HCLK);
//     forever begin
    wait (vif.HRESETn == 1'b1);
    `DRIVE_IF_S.HREADYOUT <= 1'b1;
    
    @(`DRIVE_IF_S.HADDR or `DRIVE_IF_S.HWRITE);
    `uvm_info(get_type_name, $sformatf( "[Slave Driver 1] Address = %0h, write = %0b", `DRIVE_IF_S.HADDR,  `DRIVE_IF_S.HWRITE), UVM_NONE);

//     @(negedge vif.HCLK);
    if( `DRIVE_IF_S.HWRITE) begin
      @(negedge vif.HCLK); 
      `uvm_info(get_type_name, $sformatf( "[Slave Driver] Address = %0h, write = %0b, wdata = %h", `DRIVE_IF_S.HADDR,  `DRIVE_IF_S.HWRITE, vif.HWDATA), UVM_NONE);
      mem[ `DRIVE_IF_S.HADDR] <=  vif.HWDATA;
    end
    else if(!`DRIVE_IF_S.HWRITE) begin
      `DRIVE_IF_S.HRDATA <= mem[`DRIVE_IF_S.HADDR];
    end
    
    `uvm_info(get_type_name, $sformatf( "[Slave Driver] Address = %0h, write = %0b", `DRIVE_IF_S.HADDR,  `DRIVE_IF_S.HWRITE), UVM_NONE);
    `uvm_info(get_type_name, $sformatf( "[Slave Driver] RDATA %p", mem), UVM_NONE);
//     end
  endtask
  
endclass
