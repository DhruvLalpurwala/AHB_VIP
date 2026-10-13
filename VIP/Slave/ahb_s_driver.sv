`define DRIVE_IF_S vif.ahb_s_driver_cb

class ahb_s_driver #(int ADDR_WIDTH = 32, int DATA_WIDTH = 32) extends uvm_driver#(ahb_seq_item #(ADDR_WIDTH, DATA_WIDTH));
  `uvm_component_utils(ahb_s_driver #(ADDR_WIDTH, DATA_WIDTH))
  
  virtual ahb_if vif;
  event done;
  
  logic [DATA_WIDTH-1:0] mem [bit]; 
  bit [ADDR_WIDTH-1:0] addr_q [$];
  bit [ADDR_WIDTH-1:0] current_addr;
  
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
    //@(vif.AHB_S_DRIVER.ahb_s_driver_cb);
    fork
       address_phase();
       data_phase();
    join
    
  endtask

  task address_phase();
    forever begin
      if(!vif.HRESETn) begin
        `DRIVE_IF_S.HREADYOUT <= 1;
        `DRIVE_IF_S.HRDATA <= 0; 
	`DRIVE_IF_S.HRESP <= 0;
      end
      else begin
        @(`DRIVE_IF_S);
        if (`DRIVE_IF_S.HTRANS == NONSEQ || `DRIVE_IF_S.HTRANS == SEQ) begin
          addr_q.push_back(`DRIVE_IF_S.HADDR);
          `uvm_info(get_type_name, $sformatf( "[Slave Driver +edge] Address = %0h, write = %0b", `DRIVE_IF_S.HADDR,  `DRIVE_IF_S.HWRITE), UVM_NONE);
          `DRIVE_IF_S.HREADYOUT <= 1'b1;
          -> done;
        end
        else begin
          `DRIVE_IF_S.HRESP <= 1'b0;
        end
      end
    end
  endtask
  
  task data_phase();
    forever begin
      wait(done.triggered);
      if(!vif.HRESETn) begin
        `DRIVE_IF_S.HREADYOUT <= 1;
        `DRIVE_IF_S.HRDATA <= 0; 
        `DRIVE_IF_S.HRESP <= 0;
      end
      else begin
        @(`DRIVE_IF_S);
        //if (`DRIVE_IF_S.HTRANS == NONSEQ || `DRIVE_IF_S.HTRANS == SEQ) begin
            if (`DRIVE_IF_S.HWRITE && addr_q.size() > 0) begin
               current_addr = addr_q.pop_front();
	       mem[current_addr] =  `DRIVE_IF_S.HWDATA;
               `uvm_info(get_type_name, $sformatf( "[Slave Driver Mem] mem[%0h] = %0h", current_addr, `DRIVE_IF_S.HWDATA), UVM_NONE);
            end
            else begin
               while(!vif.HREADYOUT) begin
                   @(`DRIVE_IF_S);
               end
	       current_addr = addr_q.pop_front();
       	       `DRIVE_IF_S.HRDATA <= mem[current_addr];
               `uvm_info(get_type_name, $sformatf( "[Slave Driver Mem1] mem[%0h] = %0h", current_addr, vif.HRDATA), UVM_NONE);
            end
        //end
        //else begin
          //`DRIVE_IF_S.HRESP <= 1'b0;
        //end
      end
    end
  endtask
  
  task wait_for_reset();
    wait(vif.HRESETn);
  endtask
  
  task init();
    wait(vif.HRESETn == 0);
    `DRIVE_IF_S.HREADYOUT <= 1;
    `DRIVE_IF_S.HRDATA <= 0; 
    `DRIVE_IF_S.HRESP <= 0;
  endtask
  
endclass

  
//  task run_phase(uvm_phase phase);    
//    init();
//    wait_for_reset();
//    //@(vif.AHB_S_DRIVER.ahb_s_driver_cb);
//    drive();
//    
//  endtask
//  
//  task drive();
//    forever begin
//      if(!vif.HRESETn) begin
//        `DRIVE_IF_S.HREADYOUT <= 0;
//        `DRIVE_IF_M.HRDATA <= 0; 
//      end
//
//      else begin
//
//	 //`uvm_info(get_type_name, $sformatf( "[Slave Driver 0] Inside Slave else"), UVM_NONE);
//
//	`DRIVE_IF_S.HREADYOUT <= 1'b1;
//       	 //@(posedge vif.HCLK);
//	 @(`DRIVE_IF_S);
//
//        if (`DRIVE_IF_S.HTRANS == NONSEQ || `DRIVE_IF_S.HTRANS == SEQ) begin
//	 addr_q.push_back(`DRIVE_IF_S.HADDR);
//	 `uvm_info(get_type_name, $sformatf( "[Slave Driver +edge] Address = %0h, write = %0b", `DRIVE_IF_S.HADDR,  `DRIVE_IF_S.HWRITE), UVM_NONE);
//
//       	 if( `DRIVE_IF_S.HWRITE) begin
//       	   //@(negedge vif.HCLK); 
//	   //@(vif.AHB_S_DRIVER.ahb_s_drv_neg_cb);
//	   @(`DRIVE_IF_S);
//       	   `uvm_info(get_type_name, $sformatf( "[Slave Driver -edge] Address = %0h, write = %0b, wdata = %0h", `DRIVE_IF_S.HADDR, `DRIVE_IF_S.HWRITE, `DRIVE_IF_S.HWDATA), UVM_NONE);
//       	   current_addr = addr_q.pop_front();
//	   mem[current_addr] =  `DRIVE_IF_S.HWDATA;
//       	   `uvm_info(get_type_name, $sformatf( "[Slave Driver Mem] mem[%0h] = %0h", current_addr, `DRIVE_IF_S.HWDATA), UVM_NONE);
//       	 end
//
//       	 else if(!`DRIVE_IF_S.HWRITE) begin
//           while(!`DRIVE_IF_S.HREADYOUT) begin
//               @(`DRIVE_IF_S);
//           end
//	   current_addr = addr_q.pop_front();
//       	   `DRIVE_IF_S.HRDATA <= mem[current_addr];
//	   `uvm_info(get_type_name, $sformatf( "[Slave Driver Mem1] mem[%0h] = %0h", current_addr, vif.HRDATA), UVM_NONE);
//       	 end
//	//`DRIVE_IF_S.HREADYOUT <= 1'b1;
//	end
//      end
//    end
//  endtask

  
