`define MON_IF_S vif.AHB_S_MONITOR.ahb_s_monitor_cb

class ahb_s_monitor #(int ADDR_WIDTH = 32, int DATA_WIDTH = 32) extends uvm_monitor;
  `uvm_component_utils(ahb_s_monitor #(ADDR_WIDTH, DATA_WIDTH))
  
  virtual ahb_if vif;
  event done;

  uvm_analysis_port #(ahb_seq_item #(ADDR_WIDTH, DATA_WIDTH)) ahb_s_item_port;
  ahb_seq_item #(ADDR_WIDTH, DATA_WIDTH) data_q [$], addr_q [$];
  
  function new(string name = "ahb_s_monitor", uvm_component parent = null);
    super.new(name, parent);
    ahb_s_item_port = new("ahb_m_item_port", this);
    //ahb_m_mon_item = new();
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual ahb_if)::get(this, "*", "vif", vif))
      `uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
  endfunction

  task run_phase(uvm_phase phase);
      wait_for_reset();
      //@(vif.AHB_S_MONITOR.ahb_s_monitor_cb);
      //`uvm_info(get_type_name, $sformatf("[Master Mon] After 1st clk"), UVM_NONE);
    fork
      address_phase();
      data_phase();
      monitor();
    join     
  endtask

  task address_phase();
    ahb_seq_item #(ADDR_WIDTH, DATA_WIDTH) addr_item;
    forever begin
	@(`MON_IF_S);
        addr_item = ahb_seq_item #(ADDR_WIDTH, DATA_WIDTH) :: type_id ::create("addr_item");
	if (vif.HRESETn && `MON_IF_S.HREADYOUT && (`MON_IF_M.HTRANS == NONSEQ || `MON_IF_M.HTRANS == SEQ)) begin
          addr_item.HWRITE = `MON_IF_S.HWRITE;
          addr_item.HADDR = `MON_IF_S.HADDR;
          addr_item.HTRANS = `MON_IF_S.HTRANS;
          addr_item.HSIZE = `MON_IF_S.HSIZE;
          addr_item.HBURST = `MON_IF_S.HBURST;
 	  addr_q.push_back(addr_item);
          -> done;
        end
    end
  endtask

  task data_phase();
    ahb_seq_item #(ADDR_WIDTH, DATA_WIDTH) data_item;
    wait (done.triggered);
    forever begin
        @(`MON_IF_S);
        data_item = ahb_seq_item #(ADDR_WIDTH, DATA_WIDTH) :: type_id ::create("data_item");
        if (vif.HRESETn && `MON_IF_S.HREADYOUT && (`MON_IF_M.HTRANS == NONSEQ || `MON_IF_M.HTRANS == SEQ)) begin
          if (`MON_IF_S.HWRITE) begin
             //d_queue.push_back(`MON_IF_S.HWDATA)
             data_item.HWDATA.push_back(`MON_IF_M.HWDATA);
          end
          else begin
             data_item.HRDATA = `MON_IF_S.HRDATA;
          end
	  data_q.push_back(data_item);
        end
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
             mon_item.HWDATA = temp_data_item.HWDATA;
             mon_item.HRDATA = temp_data_item.HRDATA;
             ahb_m_item_port.write(mon_item);
             `uvm_info(get_type_name, "Write Done", UVM_NONE);
     end
  endtask

  task wait_for_reset();
    wait (vif.HRESETn);
  endtask

endclass
