`define DRIVE_IF_M vif/*.AHB_M_DRIVER.ahb_m_driver_cb*/

class ahb_m_driver #(int ADDR_WIDTH = 32, int DATA_WIDTH = 32) extends uvm_driver#(ahb_seq_item #(ADDR_WIDTH, DATA_WIDTH));
  `uvm_component_utils(ahb_m_driver #(ADDR_WIDTH, DATA_WIDTH))
  
  virtual ahb_if vif;
  event done;
  
  bit [DATA_WIDTH-1:0] data_q [$];
  bit [ADDR_WIDTH-1:0] current_addr;
  int i;

  bit [ADDR_WIDTH-1:0] wrap_boundary;
  bit [ADDR_WIDTH-1:0] upper_boundary;
  
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
    wait_for_reset();
    
    fork
      address_phase();
      data_phase();
    join
    
  endtask
  
  /////Drive the signals to interface
  
  task address_phase(); 
    forever begin
      seq_item_port.get(req);
      data_q = req.HWDATA;
      current_addr = req.HADDR;
      


      if(!vif.HRESETn) begin
        `DRIVE_IF_M.HWRITE <= 0;
        `DRIVE_IF_M.HADDR <= 0;
      end
      else begin
	if (req.HBURST == SINGLE) begin
		@(posedge vif.HCLK);
		`DRIVE_IF_M.HBURST <= req.HBURST;
		`DRIVE_IF_M.HTRANS <= NONSEQ;
		`DRIVE_IF_M.HWRITE <= req.HWRITE;
	        `DRIVE_IF_M.HADDR <= req.HADDR;
		`DRIVE_IF_M.HSIZE <= req.HSIZE;
		`DRIVE_IF_M.burst_length <= req.burst_length;
		->done;
	end
	else if (req.HBURST == INCR || req.HBURST == INCR4 || req.HBURST == INCR8 || req.HBURST == INCR16) begin
		for(i=0; i < req.burst_length; i++) begin
        	@(posedge vif.HCLK);
		`uvm_info(get_type_name, $sformatf("I = %0d", i), UVM_LOW);
		   
		   `DRIVE_IF_M.HTRANS <= (i == 0)? NONSEQ : SEQ;
		   `DRIVE_IF_M.HBURST <= req.HBURST;
		   `DRIVE_IF_M.HSIZE <= req.HSIZE;
		   `DRIVE_IF_M.HADDR <= current_addr;
		   `DRIVE_IF_M.HWRITE <= req.HWRITE;
		   `DRIVE_IF_M.burst_length <= req.burst_length;
		   `uvm_info(get_type_name, $sformatf("[Master Driver 1] Address = %0h , write = %0b", current_addr, req.HWRITE), UVM_NONE);
		   
		   current_addr = current_addr + (1 << req.HSIZE);
		   ->done;
		end
	end
	else if (req.HBURST == WRAP4 || req.HBURST == WRAP8 || req.HBURST == 16) begin

		wrap_boundary = (current_addr/((1 << req.HSIZE)*req.burst_length))*((1 << req.HSIZE)*req.burst_length);
		`uvm_info(get_type_name, $sformatf("[Master Driver 0] Wrap Boundary = %0h, Address = %0h", wrap_boundary, current_addr), UVM_NONE);
		upper_boundary = wrap_boundary + ((1 << req.HSIZE)*req.burst_length);
		`uvm_info(get_type_name, $sformatf("[Master Driver 1] upper boundary = %0h", upper_boundary), UVM_NONE);
		
		for(i=0; i < req.burst_length; i++) begin 
wait(`DRIVE_IF_M.HREADYOUT == 1);
		@(posedge vif.HCLK);
		`uvm_info(get_type_name, $sformatf("I = %0d", i), UVM_LOW);
		   `DRIVE_IF_M.HTRANS <= (i == 0)? NONSEQ : SEQ;
		   `DRIVE_IF_M.HBURST <= req.HBURST;
		   `DRIVE_IF_M.HSIZE <= req.HSIZE;
		   `DRIVE_IF_M.HADDR <= current_addr; 
		   `DRIVE_IF_M.HWRITE <= req.HWRITE;
		   `DRIVE_IF_M.burst_length <= req.burst_length;

		   `uvm_info(get_type_name, $sformatf("[Master Driver 1] Address = %0h , write = %0b", current_addr, req.HWRITE), UVM_NONE);

		   current_addr = current_addr + (1 << req.HSIZE);
		   if (current_addr >= upper_boundary) begin
			current_addr = wrap_boundary;
		   end

		   -> done;
		end
	end
      end
    end
  endtask
  
  task data_phase();
      forever begin
        wait(done.triggered);      
	wait(`DRIVE_IF_M.HREADYOUT == 1);
        if(!vif.HRESETn) begin
         `DRIVE_IF_M.HWDATA <= 0; 
        end
        else begin
         @(posedge vif.HCLK);
         if(vif.HWRITE)begin
	  `DRIVE_IF_M.HWDATA <= data_q.pop_front();
	  `uvm_info("QUEUE_PRINT", $sformatf("Queue contents: %p", data_q), UVM_LOW)
         end
        end

       // `uvm_info(get_type_name, $sformatf("[Master Driver 1] Data = %0h, Address = %0h , write = %0b",req.HWDATA, req.HADDR, req.HWRITE), UVM_NONE);
      end
  endtask
  
  task wait_for_reset();
    wait (vif.HRESETn);
  endtask
  
  task init();
    wait(vif.HRESETn == 0);
    `DRIVE_IF_M.HWRITE <= 0;
    `DRIVE_IF_M.HADDR <= 0;
    `DRIVE_IF_M.HWDATA <= 0; 
    `DRIVE_IF_M.HTRANS <= IDLE;
  endtask
  
endclass
