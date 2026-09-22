`define DRIVE_IF_S vif/*.AHB_S_DRIVER.ahb_s_driver_cb*/

class ahb_s_driver extends uvm_driver#(ahb_seq_item);
  `uvm_component_utils(ahb_s_driver)
  
  virtual ahb_if vif;
  
  logic [31:0] mem [2**10];
  int i;
  bit [31:0] addr_q [$];
  bit [31:0] current_addr;
  
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
    init();
    wait_for_reset();
    @(posedge vif.HCLK);
    drive();
    
  endtask
  
  task drive();
    forever begin
      seq_item_port.get(req);
      
      if(!vif.HRESETn) begin
        `DRIVE_IF_S.HREADYOUT <= 0;
        `DRIVE_IF_M.HRDATA <= 0; 
      end
      
      else begin
        `DRIVE_IF_S.HREADYOUT <= 1'b1;
        	
	for (i = 0; i < vif.burst_length; i++) begin
	// `uvm_info(get_type_name, $sformatf( "[Slave Driver 0] Address = %0h, write = %0b", vif.HADDR,  vif.HWRITE), UVM_NONE);
       	 @(posedge vif.HCLK);
	 addr_q.push_back(`DRIVE_IF_S.HADDR);
	 `uvm_info(get_type_name, $sformatf( "[Slave Driver +edge] Address = %0h, write = %0b", vif.HADDR,  vif.HWRITE), UVM_NONE);

       	 if( `DRIVE_IF_S.HWRITE) begin
       	   @(negedge vif.HCLK); 
       	   `uvm_info(get_type_name, $sformatf( "[Slave Driver -edge] Address = %0h, write = %0b, wdata = %0h", `DRIVE_IF_S.HADDR, `DRIVE_IF_S.HWRITE, vif.HWDATA), UVM_NONE);
       	   current_addr = addr_q.pop_front();
	   mem[current_addr] <=  vif.HWDATA;
       	   `uvm_info(get_type_name, $sformatf( "[Slave Driver Mem] mem[%0h] = %0h", current_addr, vif.HWDATA), UVM_NONE);
       	 end

       	 else if(!`DRIVE_IF_S.HWRITE) begin
	   current_addr = addr_q.pop_front();
       	   `DRIVE_IF_S.HRDATA <= mem[current_addr];
	   `uvm_info(get_type_name, $sformatf( "[Slave Driver Mem1] mem[%0h] = %0h", current_addr, vif.HRDATA), UVM_NONE);
       	 end
	end

       // `uvm_info(get_type_name, $sformatf( "[Slave Driver 0] Address = %0h, write = %0b", `DRIVE_IF_S.HADDR,  `DRIVE_IF_S.HWRITE), UVM_NONE);
       //`uvm_info(get_type_name, $sformatf( "[Slave Driver 0] RDATA = %0h", `DRIVE_IF_S.HRDATA), UVM_NONE);
       // `uvm_info(get_type_name, $sformatf( "[Slave Driver 0] RDATA %p", mem), UVM_NONE);
      end
    end
  endtask
  
  task wait_for_reset();
    wait(vif.HRESETn);
  endtask
  
  task init();
    wait(vif.HRESETn == 0);
    `DRIVE_IF_S.HREADYOUT <= 0;
    `DRIVE_IF_M.HRDATA <= 0; 
  endtask
  
endclass
