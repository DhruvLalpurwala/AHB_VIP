`define MON_IF_M vif.ahb_m_monitor_cb

class ahb_m_monitor #(int ADDR_WIDTH = 32, int DATA_WIDTH = 32) extends uvm_monitor;
  `uvm_component_utils(ahb_m_monitor #(ADDR_WIDTH, DATA_WIDTH))
  
  virtual ahb_if vif;
  semaphore done = new(0);

  uvm_analysis_port #(ahb_seq_item #(ADDR_WIDTH, DATA_WIDTH)) ahb_m_item_port;
  ahb_seq_item #(ADDR_WIDTH, DATA_WIDTH) data_q [$], addr_q [$];
  
  function new(string name = "ahb_m_monitor", uvm_component parent = null);
    super.new(name, parent);
    ahb_m_item_port = new("ahb_m_item_port", this);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual ahb_if)::get(this, "*", "vif", vif))
      `uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
  endfunction

  task run_phase(uvm_phase phase);
      wait_for_reset();
    fork
      address_phase();
      data_phase();
      monitor();
    join     
  endtask

  task address_phase();
    ahb_seq_item #(ADDR_WIDTH, DATA_WIDTH) addr_item;
    forever begin
	@(`MON_IF_M);
        addr_item = ahb_seq_item #(ADDR_WIDTH, DATA_WIDTH) :: type_id ::create("addr_item");
	if (vif.HRESETn && `MON_IF_M.HREADYOUT && (`MON_IF_M.HTRANS == NONSEQ || `MON_IF_M.HTRANS == SEQ)) begin
          addr_item.HWRITE = `MON_IF_M.HWRITE;
          addr_item.HADDR = `MON_IF_M.HADDR;
          addr_item.HTRANS = transfer_type'(`MON_IF_M.HTRANS);
          addr_item.HSIZE = transfer_size'(`MON_IF_M.HSIZE);
          addr_item.HBURST = burst_operation'(`MON_IF_M.HBURST);
          `uvm_info("Master Mon", $sformatf("Address = %0h , write = %0b",`MON_IF_M.HADDR, `MON_IF_M.HWRITE), UVM_NONE);
 	  addr_q.push_back(addr_item);
          done.put(1);
        end
    end
  endtask

  task data_phase();
    ahb_seq_item #(ADDR_WIDTH, DATA_WIDTH) data_item;
    forever begin
        done.get(1);
        @(`MON_IF_M);
        data_item = ahb_seq_item #(ADDR_WIDTH, DATA_WIDTH) :: type_id ::create("data_item");
             data_item.HWDATA.push_back(`MON_IF_M.HWDATA);
             `uvm_info("Master Mon Write", $sformatf("WData = %0h", `MON_IF_M.HWDATA), UVM_NONE);
             data_item.HRDATA = `MON_IF_M.HRDATA;
             `uvm_info("Master Mon Read", $sformatf("RData = %0h", `MON_IF_M.HRDATA), UVM_NONE);
	     data_q.push_back(data_item);
    end
  endtask

  task monitor();
     forever begin
        ahb_seq_item #(ADDR_WIDTH, DATA_WIDTH) temp_data_item, temp_addr_item, mon_item;
        wait (data_q.size() > 0);
          temp_data_item = ahb_seq_item #(ADDR_WIDTH, DATA_WIDTH) :: type_id ::create("temp_data_item");
          temp_addr_item = ahb_seq_item #(ADDR_WIDTH, DATA_WIDTH) :: type_id ::create("temp_addr_item");
             temp_data_item = data_q.pop_front();
             temp_addr_item = addr_q.pop_front();

          mon_item = ahb_seq_item #(ADDR_WIDTH, DATA_WIDTH) :: type_id ::create("mon_item");
             mon_item.HADDR = temp_addr_item.HADDR;
             mon_item.HWRITE = temp_addr_item.HWRITE;
             mon_item.HTRANS = temp_addr_item.HTRANS;
             mon_item.HSIZE = temp_addr_item.HSIZE;
             mon_item.HBURST = temp_addr_item.HBURST;
          if(temp_addr_item.HWRITE) begin
             mon_item.HWDATA = temp_data_item.HWDATA;
          end
          else begin
             mon_item.HRDATA = temp_data_item.HRDATA;
          end
             `uvm_info("Master Mon Sample", $sformatf("Addr = %0p, WData = %0p", temp_addr_item.HADDR, temp_data_item.HWDATA), UVM_NONE);
             ahb_m_item_port.write(mon_item);
             `uvm_info("Master Mon", "Write Done", UVM_NONE);
     end
  endtask

  task wait_for_reset();
    wait (vif.HRESETn);
  endtask

endclass
