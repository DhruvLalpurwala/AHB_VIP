`define DRIVE_IF_S vif/*.AHB_S_DRIVER.ahb_s_driver_cb*/

class ahb_s_driver extends uvm_driver#(ahb_seq_item);
  `uvm_component_utils(ahb_s_driver)
  
  virtual ahb_if vif;
  
  logic [31:0] mem [2**10];
  //int i;
  
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
     // for (i = 0; i < vif.burst_length; i++) begin
         `DRIVE_IF_M.HRDATA <= 0; 
    //  end
      end
      
      else begin
        `DRIVE_IF_S.HREADYOUT <= 1'b1;

       //`uvm_info(get_type_name, $sformatf( "[Slave Driver 0] Address = %0h, write = %0b", vif.HADDR,  vif.HWRITE), UVM_NONE);

        @(posedge vif.HCLK);
        //`uvm_info(get_type_name, $sformatf( "[Slave Driver 1] Data = %0h, Address = %0h, write = %0b",vif.HWDATA, vif.HADDR,  vif.HWRITE), UVM_NONE);

        if( `DRIVE_IF_S.HWRITE) begin
	//for (i = 0; i < vif.burst_length; i++) begin
          @(negedge vif.HCLK); 
         // `uvm_info(get_type_name, $sformatf( "[Slave Driver] Address = %0h, write = %0b, wdata[%d] = %d", `DRIVE_IF_S.HADDR, `DRIVE_IF_S.HWRITE, vif.HWDATA[i]), UVM_NONE);
          mem[ `DRIVE_IF_S.HADDR] <=  vif.HWDATA;
         // `uvm_info(get_type_name, $sformatf( "[Slave Driver 5] RDATA %p", mem), UVM_NONE);
//	end
        end

        else if(!`DRIVE_IF_S.HWRITE) begin
//	for (i = 0; i < vif.burst_length; i++) begin
          `DRIVE_IF_S.HRDATA <= mem[`DRIVE_IF_S.HADDR];
//	end        
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
   // for (i = 0; i < vif.burst_length; i++) begin
      `DRIVE_IF_M.HRDATA <= 0; 
   // end

  endtask
  
endclass
