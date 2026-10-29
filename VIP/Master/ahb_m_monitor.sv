  ////File Name: ahb_m_monitor.sv
  ////Author Name: Dhruv Lalpurwala
  ////Propetier Name: ASICraft Technologies LLP
  ////Description: This master monitor samples the interface signals,
  //// and broadcast via analysis port
  /////////////////////////////////////////////////////

`define MON_IF_M vif.ahb_m_monitor_cb   //define clocking block

class ahb_m_monitor #(int ADDR_WIDTH = 32, int DATA_WIDTH = 32) extends uvm_monitor;
  `uvm_component_utils(ahb_m_monitor #(ADDR_WIDTH, DATA_WIDTH))
  
  virtual ahb_if vif;      //interface handle
  semaphore done = new(0); //semaphore for handling the pipeline

  uvm_analysis_port #(ahb_seq_item #(ADDR_WIDTH, DATA_WIDTH)) ahb_m_item_port;  //analysis port for broadcasting
  ahb_seq_item #(ADDR_WIDTH, DATA_WIDTH) data_q [$], addr_q [$];       //queue for storing the pipelined address and data which helps to sync
  
  function new(string name = "ahb_m_monitor", uvm_component parent = null);
    super.new(name, parent);
    ahb_m_item_port = new("ahb_m_item_port", this);    //analysis port new constructor
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual ahb_if)::get(this, "*", "vif", vif))  //get the interface
      `uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
  endfunction

  task run_phase(uvm_phase phase);
      wait_for_reset();   //task performs wait for reset until 1 
    fork
      address_phase();    //task samples address and control signals
      data_phase();       //task samples data
      monitor();          //task sync up the address phase and data phase and broadcast it
    join     
  endtask

  task address_phase();
    ahb_seq_item #(ADDR_WIDTH, DATA_WIDTH) addr_item;   //address and control signals reconstruction 
    forever begin
	@(`MON_IF_M);     //change in clocking block
        addr_item = ahb_seq_item #(ADDR_WIDTH, DATA_WIDTH) :: type_id ::create("addr_item"); //addr_item create 
	if (vif.HRESETn && `MON_IF_M.HREADYOUT && (`MON_IF_M.HTRANS == NONSEQ || `MON_IF_M.HTRANS == SEQ)) begin  //Reset = 1, readyout = 1 and transfer type = nonseq and seq
          //sampling the address and control signals and assign to addr_item
          addr_item.HWRITE = `MON_IF_M.HWRITE;
          addr_item.HADDR = `MON_IF_M.HADDR;
          addr_item.HTRANS = transfer_type'(`MON_IF_M.HTRANS);
          addr_item.HSIZE = transfer_size'(`MON_IF_M.HSIZE);
          addr_item.HBURST = burst_operation'(`MON_IF_M.HBURST);
          `uvm_info("Master Mon", $sformatf("Address = %0h , write = %0b",`MON_IF_M.HADDR, `MON_IF_M.HWRITE), UVM_NONE);
 	  addr_q.push_back(addr_item); //push the addr_item in addr queue
          done.put(1);  //semphone put a key so that driver get the key and this two phase work as pipeline 
        end
    end
  endtask

  task data_phase();
    ahb_seq_item #(ADDR_WIDTH, DATA_WIDTH) data_item;   //data reconstruction
    forever begin
        done.get(1);    //get a key, data phase starts
        @(`MON_IF_M);   //change in clocking blocks
        data_item = ahb_seq_item #(ADDR_WIDTH, DATA_WIDTH) :: type_id ::create("data_item"); //data_item create
             data_item.HWDATA.push_back(`MON_IF_M.HWDATA); //assign hwdata from interface to data item
             `uvm_info("Master Mon Write", $sformatf("WData = %0h", `MON_IF_M.HWDATA), UVM_NONE);
             data_item.HRDATA = `MON_IF_M.HRDATA;    //assign hrdata from interface to data item
             `uvm_info("Master Mon Read", $sformatf("RData = %0h", `MON_IF_M.HRDATA), UVM_NONE);
	     data_q.push_back(data_item);       //push the data_item in data_queue
    end
  endtask

  task monitor();
     forever begin
        ahb_seq_item #(ADDR_WIDTH, DATA_WIDTH) temp_data_item, temp_addr_item, mon_item;  //store addr_item and data_item to there temp_item and then assign to mon_item
        wait (data_q.size() > 0);  //wait until data queue > 0
          temp_data_item = ahb_seq_item #(ADDR_WIDTH, DATA_WIDTH) :: type_id ::create("temp_data_item");   //temp_data_item create   
          temp_addr_item = ahb_seq_item #(ADDR_WIDTH, DATA_WIDTH) :: type_id ::create("temp_addr_item");   //temp_addr_item create
             temp_data_item = data_q.pop_front();     //pop data_item from data_q and assign to temp_data_item
             temp_addr_item = addr_q.pop_front();     //pop addr_item from addr_q and assign to temp_addr_item

          mon_item = ahb_seq_item #(ADDR_WIDTH, DATA_WIDTH) :: type_id ::create("mon_item");    //mon_item create
             //assign the temp_addr_item and temp_data_item to mon_item, addr and data sync properly
             mon_item.HADDR = temp_addr_item.HADDR;
             mon_item.HWRITE = temp_addr_item.HWRITE;
             mon_item.HTRANS = temp_addr_item.HTRANS;
             mon_item.HSIZE = temp_addr_item.HSIZE;
             mon_item.HBURST = temp_addr_item.HBURST;
          if(temp_addr_item.HWRITE) begin   //HWRITE == 1
             mon_item.HWDATA = temp_data_item.HWDATA;
          end
          else begin
             mon_item.HRDATA = temp_data_item.HRDATA;
          end
             `uvm_info("Master Mon Sample", $sformatf("Addr = %0p, WData = %0p", temp_addr_item.HADDR, temp_data_item.HWDATA), UVM_NONE);
             ahb_m_item_port.write(mon_item);     //write the mon_item to analysis port
             `uvm_info("Master Mon", "Write Done", UVM_NONE);
     end
  endtask

  task wait_for_reset();
    wait (vif.HRESETn);   //wait reset == 1
  endtask

endclass
