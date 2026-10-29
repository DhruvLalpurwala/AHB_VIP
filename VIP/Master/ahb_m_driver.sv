  ////File Name: ahb_m_driver.sv
  ////Author Name: Dhruv Lalpurwala
  ////Propetier Name: ASICraft Technologies LLP
  ////Description: This master driver drives the signals to interface  
  /////////////////////////////////////////////////////

`define DRIVE_IF_M vif.ahb_m_driver_cb //define clocking block 

class ahb_m_driver #(int ADDR_WIDTH = 32, int DATA_WIDTH = 32) extends uvm_driver#(ahb_seq_item #(ADDR_WIDTH, DATA_WIDTH));
  `uvm_component_utils(ahb_m_driver #(ADDR_WIDTH, DATA_WIDTH))
  
  virtual ahb_if vif;    //interface handle
  semaphore done = new(0); //semaphore for handling the pipeline
  
  bit [DATA_WIDTH-1:0] data_q [$];   // Data queue for sync the data with address
  bit [ADDR_WIDTH-1:0] current_addr; // current address for burst operation
  int i;

  bit [ADDR_WIDTH-1:0] wrap_boundary; //Wrap boundary (lower boundary) for WRAP burst operation address restart from wrap boundary
  bit [ADDR_WIDTH-1:0] upper_boundary;//Upper boundary for WRAP burst operation so that address should not cross the upper boundary
  
  function new(string name = "ahb_m_driver", uvm_component parent = null);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ///Get the interface
	    if(!uvm_config_db#(virtual ahb_if)::get(this, "*", "vif", vif))  //Get the interface through config db
      `uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
  endfunction
  
  task run_phase(uvm_phase phase);
    
    init();  //task performs the initialization of signals
    wait_for_reset(); //task performs wait for reset to be 1
    fork
      address_phase(); //task to drive address and control signals
      data_phase();    //task to drive the wdata signal
    join
  endtask
  
  /////Drive the signals to interface
  
  task address_phase(); 
    forever begin
   	 if (seq_item_port.has_do_available()) begin //if next req is available
   	       seq_item_port.get(req);               //get is called, it completes the handshake to get another req
   	  	 foreach (req.HWDATA[i]) begin
   	  	   data_q.push_back(req.HWDATA[i]);  //push req.data into data_q
   	  	 end
   	  	 current_addr = req.HADDR;           //assign req.HADDR to current_addr
   	  	 
   	  	 if(!vif.HRESETn) begin              //Reset is 0 -> drive 0 to interface for address and control signals
   	  	   `DRIVE_IF_M.HWRITE <= 0;
   	  	   `DRIVE_IF_M.HADDR <= 0;
   	  	   `DRIVE_IF_M.HTRANS <= IDLE;
   	  	   `DRIVE_IF_M.HBURST <= 0;
   	  	   `DRIVE_IF_M.HSIZE <= 0;
   	  	 end
   	  	 else begin
   	  	   if (req.HBURST == SINGLE) begin   //HBurst is single
   	  	   	@(`DRIVE_IF_M);              //change in clocking block
   	  	   	while (!`DRIVE_IF_M.HREADYOUT) begin //Hreadyout is 0 -> insert the wait cycles
   	  	   	    @(`DRIVE_IF_M); 
   	  	   	end
                       //Drive req of Address and control signals to interface
   	  	   	`DRIVE_IF_M.HBURST <= req.HBURST;
   	  	   	`DRIVE_IF_M.HTRANS <= NONSEQ;
   	  	   	`DRIVE_IF_M.HWRITE <= req.HWRITE;
   	  	        `DRIVE_IF_M.HADDR <= req.HADDR;
   	  	   	`DRIVE_IF_M.HSIZE <= req.HSIZE;
   	  	   	`uvm_info("Master Driver 1" , $sformatf("Address = %0h , write = %0b", current_addr, req.HWRITE), UVM_NONE);
   	  	   	done.put(1);   //Once signal drives at interface, semphone put a key so that driver get the key and this two phase work as pipeline
   	  	   end

                       //Burst is INCR, INCR4, INCR8, INCR16
   	  	   else if (req.HBURST == INCR || req.HBURST == INCR4 || req.HBURST == INCR8 || req.HBURST == INCR16) begin 
   	  	   	for(i=0; i < req.burst_length; i++) begin  //according burst length the loop increments for driving the beats acc. to incr, incr4, incr8, incr16
   	  	   	@(`DRIVE_IF_M);                            //change in clocking block
   	  	   	`uvm_info(get_type_name, $sformatf("I = %0d", i), UVM_LOW);
   	  	           while (!`DRIVE_IF_M.HREADYOUT) begin  //Hreadyout is 0 -> insert the wait cycles
   	  	   	    @(`DRIVE_IF_M);
   	  	   	end
                       //Drive req of address and control signals to interface
   	  	   	   `DRIVE_IF_M.HTRANS <= (i == 0)? NONSEQ : SEQ;  //First beat transfer type should be NONSEQ and then SEQ
   	  	   	   `DRIVE_IF_M.HBURST <= req.HBURST;          
   	  	   	   `DRIVE_IF_M.HSIZE <= req.HSIZE;
   	  	   	   `DRIVE_IF_M.HADDR <= current_addr;
   	  	   	   `DRIVE_IF_M.HWRITE <= req.HWRITE;
   	  	   	   `uvm_info("Master Driver 1", $sformatf("Address = %0h , write = %0b", current_addr, req.HWRITE), UVM_NONE);
   	  	   	   
   	  	   	   current_addr = current_addr + (1 << req.HSIZE);    //HADDR[i] = HADDR[i-1] + HSIZE
   	  	   	   done.put(1);  //Once signal drives at interface, semphone put a key so that driver get the key and this two phase work as pipeline
   	  	   	end
   	  	   end

                       //Burst is WRAP4, WRAP8, WRAP16
   	  	   else if (req.HBURST == WRAP4 || req.HBURST == WRAP8 || req.HBURST == WRAP16) begin
                        // Wrap boundary/ lower boundary calculation
   	  	   	wrap_boundary = (current_addr/((1 << req.HSIZE)*req.burst_length))*((1 << req.HSIZE)*req.burst_length);
   	  	     	`uvm_info(get_type_name, $sformatf("[Master Driver 0] Wrap Boundary = %0h, Address = %0h", wrap_boundary, current_addr), UVM_NONE);
   	  	   	upper_boundary = wrap_boundary + ((1 << req.HSIZE)*req.burst_length); //upper boundary calculation
   	  	   	`uvm_info(get_type_name, $sformatf("[Master Driver 1] upper boundary = %0h", upper_boundary), UVM_NONE);
   	  	   	
   	  	   	for(i=0; i < req.burst_length; i++) begin //according burst length the loop increments for driving the beats acc. wrap4, wrap8, wrap16
   	  	   	@(`DRIVE_IF_M);  //change in clocking block
   	  	   	while (!`DRIVE_IF_M.HREADYOUT) begin     //Hreadyout is 0 -> insert the wait cycles
   	  	   		@(`DRIVE_IF_M);
   	  	   	end
   	  	           `uvm_info(get_type_name, $sformatf("I = %0d", i), UVM_LOW); 
                       //Drive req of address and control signals to interface
   	  	   	   `DRIVE_IF_M.HTRANS <= (i == 0)? NONSEQ : SEQ;  //First beat transfer type should be NONSEQ and then SEQ
   	  	   	   `DRIVE_IF_M.HBURST <= req.HBURST;
   	  	   	   `DRIVE_IF_M.HSIZE <= req.HSIZE;
   	  	   	   `DRIVE_IF_M.HADDR <= current_addr; 
   	  	   	   `DRIVE_IF_M.HWRITE <= req.HWRITE;
   	  	   	   `uvm_info("Master Driver 1", $sformatf("Address = %0h , write = %0b", current_addr, req.HWRITE), UVM_NONE);

   	  	   	   current_addr = current_addr + (1 << req.HSIZE);    //HADDR[i] = HADDR[i-1] + HSIZE
   	  	   	   if (current_addr >= upper_boundary) begin          //HADDR[i] >= upper boundary
   	  	   		current_addr = wrap_boundary;                 //HADDR[i] = lower boundary
   	  	   	   end
   	  	   	   done.put(1);  //Once signal drives at interface, semphone put a key so that driver get the key and this two phase work as pipeline
   	  	   	end
   	  	   end
   	  	 end
   	 end
   	 else begin              //if next req is not available
   	    @(`DRIVE_IF_M);      //change in clocking block
            while (!`DRIVE_IF_M.HREADYOUT) begin   //Hreadyout is 0 -> insert the wait cycles
   	  	  @(`DRIVE_IF_M);
   	    end
   	    `DRIVE_IF_M.HTRANS <= IDLE;    //Transfer type is IDLE
   	 end
    end
  endtask
  
  task data_phase();
      forever begin
        done.get(1);     //once get the key it start the data phase for driving the HWDATA 
	
        if(!vif.HRESETn) begin  //reset is 0 -> HWDATA is 0
         `DRIVE_IF_M.HWDATA <= 0; 
        end
        else begin
	 @(`DRIVE_IF_M); //change in clocking block         
         while (`DRIVE_IF_M.HREADYOUT==0) begin    //Hreadyout is 0 -> insert the wait cycles
		@(`DRIVE_IF_M);
	 end
           if(vif.HWRITE)begin   //Write is 1 
	    `DRIVE_IF_M.HWDATA <= data_q.pop_front();  //pop the data from data queue and drive to interface
	    `uvm_info("QUEUE_PRINT", $sformatf("Queue contents: %p", data_q), UVM_LOW)
           end
           else begin
            req.HRDATA <= `DRIVE_IF_M.HRDATA;
            `uvm_info("Master Driver", $sformatf("Read Data: %h", `DRIVE_IF_M.HRDATA), UVM_LOW)
           end
        end
      end
  endtask
  
  task wait_for_reset();
    wait (vif.HRESETn);   //wait for reset = 1
  endtask
  
  task init();   //initialize the signals
    wait(vif.HRESETn == 0);
    `DRIVE_IF_M.HWRITE <= 0;
    `DRIVE_IF_M.HADDR <= 0;
    `DRIVE_IF_M.HWDATA <= 0; 
    `DRIVE_IF_M.HTRANS <= IDLE;
    `DRIVE_IF_M.HBURST <= 0;
    `DRIVE_IF_M.HSIZE <= 0;
  endtask
  
endclass
