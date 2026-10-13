`define MON_IF_M vif.AHB_M_MONITOR.ahb_m_monitor_cb

class ahb_m_monitor #(int ADDR_WIDTH = 32, int DATA_WIDTH = 32) extends uvm_monitor;
  `uvm_component_utils(ahb_m_monitor #(ADDR_WIDTH, DATA_WIDTH))
  
  virtual ahb_if vif;
  event done;

  uvm_analysis_port #(ahb_seq_item #(ADDR_WIDTH, DATA_WIDTH)) ahb_m_item_port;
  ahb_seq_item #(ADDR_WIDTH, DATA_WIDTH) data_q [$], addr_q [$];
  
  function new(string name = "ahb_m_monitor", uvm_component parent = null);
    super.new(name, parent);
    ahb_m_item_port = new("ahb_m_item_port", this);
    //ahb_m_mon_item = new();
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual ahb_if)::get(this, "*", "vif", vif))
      `uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
  endfunction

  task run_phase(uvm_phase phase);
      wait_for_reset();
      //@(vif.AHB_M_MONITOR.ahb_m_monitor_cb);
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
	@(`MON_IF_M);
        addr_item = ahb_seq_item #(ADDR_WIDTH, DATA_WIDTH) :: type_id ::create("addr_item");
	if (vif.HRESETn && `MON_IF_M.HREADYOUT && (`MON_IF_M.HTRANS == NONSEQ || `MON_IF_M.HTRANS == SEQ)) begin
          addr_item.HWRITE = `MON_IF_M.HWRITE;
          addr_item.HADDR = `MON_IF_M.HADDR;
          addr_item.HTRANS = `MON_IF_M.HTRANS;
          addr_item.HSIZE = `MON_IF_M.HSIZE;
          addr_item.HBURST = `MON_IF_M.HBURST;
 	  addr_q.push_back(addr_item);
          -> done;
        end
    end
  endtask

  task data_phase();
    ahb_seq_item #(ADDR_WIDTH, DATA_WIDTH) data_item;
    wait (done.triggered);
    forever begin
        @(`MON_IF_M);
        data_item = ahb_seq_item #(ADDR_WIDTH, DATA_WIDTH) :: type_id ::create("data_item");
        if (vif.HRESETn && `MON_IF_M.HREADYOUT && (`MON_IF_M.HTRANS == NONSEQ || `MON_IF_M.HTRANS == SEQ)) begin
          if (`MON_IF_M.HWRITE) begin
             //d_queue.push_back(`MON_IF_M.HWDATA)
             data_item.HWDATA.push_back(`MON_IF_M.HWDATA);
          end
          else begin
             data_item.HRDATA = `MON_IF_M.HRDATA;
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


//  task run_phase(uvm_phase phase);
//      wait_for_reset();
//      @(vif.AHB_M_MONITOR.ahb_m_monitor_cb);
//      `uvm_info(get_type_name, $sformatf("[Master Mon] After 1st clk"), UVM_NONE);
//      monitor();     
//  endtask
//
//  task monitor();
//     forever begin
//       
//       //if (vif.HRESETn && vif.HREADYOUT) begin
//	//wait(vif.HRESETn);
//
//       	//@(posedge vif.HCLK);
//        //wait (`MON_IF_M.HREADYOUT); 
//
//	@(vif.AHB_M_MONITOR.ahb_m_monitor_cb);
//	 // while(!vif.HREADYOUT) begin
//	 // 	@(vif.AHB_M_MONITOR.ahb_m_monitor_cb);
//	 // end
//	if (vif.HRESETn && `MON_IF_M.HREADYOUT && `MON_IF_M.HTRANS == NONSEQ || `MON_IF_M.HTRANS == SEQ) begin 
//	  ahb_m_mon_item.HWRITE = `MON_IF_M.HWRITE;
//          ahb_m_mon_item.HADDR = `MON_IF_M.HADDR;
//          ahb_m_mon_item.HBURST = `MON_IF_M.HBURST;
//          ahb_m_mon_item.HSIZE = `MON_IF_M.HSIZE;
//          `uvm_info(get_type_name, $sformatf("[Master Mon] Address = %0h , write = %0b",`MON_IF_M.HADDR, `MON_IF_M.HWRITE), UVM_NONE);
//	 
//  
//         if(`MON_IF_M.HWRITE) begin
//           @(vif.AHB_M_MONITOR.ahb_mon_neg_cb);
//	   //@(negedge vif.HCLK);
//	   data_q.push_back(vif.AHB_M_MONITOR.ahb_mon_neg_cb.HWDATA);
//           ahb_m_mon_item.HWDATA = data_q;
//           `uvm_info(get_type_name, $sformatf("[Master Mon Write] WData = %0h", vif.AHB_M_MONITOR.ahb_mon_neg_cb.HWDATA), UVM_NONE);
//         end
//         else if(!`MON_IF_M.HWRITE) begin
//           @(vif.AHB_M_MONITOR.ahb_mon_neg_cb);
//	   //@(negedge vif.HCLK);
//           ahb_m_mon_item.HRDATA = vif.AHB_M_MONITOR.ahb_mon_neg_cb.HRDATA;
//           `uvm_info(get_type_name, $sformatf("[Master Mon READ] RData = %0h", vif.AHB_M_MONITOR.ahb_mon_neg_cb.HRDATA), UVM_NONE);
//         end
//  //      `uvm_info(get_type_name, $sformatf("[Master Mon 888] Ready = %0b, Data = %0h, RData = %0h, Address = %0h , write = %0b",`MON_IF_M.HREADYOUT, `MON_IF_M.HWDATA, `MON_IF_M.HRDATA, `MON_IF_M.HADDR, `MON_IF_M.HWRITE), UVM_NONE);
//         ahb_m_item_port.write(ahb_m_mon_item);
//        `uvm_info(get_type_name, "Write Done", UVM_NONE);
//        end
//     end
//  endtask
//
//  task wait_for_reset();
//    wait (vif.HRESETn);
//  endtask
