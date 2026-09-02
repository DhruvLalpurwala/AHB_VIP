// `uvm_analysis_imp_decl(_ahb_m_item_port)
// `uvm_analysis_imp_decl(_ahb_s_item_port)

class ahb_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(ahb_scoreboard)
  
  uvm_analysis_imp #(ahb_seq_item, ahb_scoreboard) m_actual_imp; 
//   uvm_analysis_imp_ahb_m_item_port #(ahb_seq_item, ahb_scoreboard) m_actual_imp;  
//   uvm_analysis_imp_ahb_s_item_port #(ahb_seq_item, ahb_scoreboard) s_expected_imp;
  
  ahb_seq_item req_q[$];
  
//   Reference memory
  bit [31:0] sco_mem [logic[31:0]];
  
  int match_count, mismatch_count;
  
  function new(string name = "ahb_scoreboard", uvm_component parent);
    super.new(name, parent);
    m_actual_imp = new("m_actual_imp", this);
//     s_expected_imp = new("s_expected_imp", this);
//     foreach (sco_mem[i])
//       sco_mem[i] = 32'hFFFF;
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction
  
//   function void write_ahb_m_item_port(ahb_seq_item m_tx);
    
//   endfunction
  
//   function void write_ahb_s_item_port(ahb_seq_item s_tx);
    
//   endfunction
  
  
  virtual function void write(ahb_seq_item tx);
    /////get seq_item from monitor
    req_q.push_back(tx);
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    forever begin
     ahb_seq_item ahb_req;
    `uvm_info(get_type_name(),$sformatf("RUN_PHASE started size : %0d",req_q.size()),UVM_LOW)
    /////Compare 
   
    
    wait(req_q.size() > 0);
    `uvm_info(get_type_name(),$sformatf("size : %0d",req_q.size()),UVM_LOW)
    ahb_req = req_q.pop_front();
    
    if(ahb_req.HWRITE) begin
      sco_mem[ahb_req.HADDR] = ahb_req.HWDATA;
      `uvm_info(get_type_name(),$sformatf(" WRITE DATA"),UVM_LOW)
      `uvm_info(get_type_name(),$sformatf("Addr: %0h and Data: %0h",ahb_req.HADDR, ahb_req.HWDATA),UVM_LOW) 
    end
    else if(!ahb_req.HWRITE) begin
      if(sco_mem[ahb_req.HADDR] == ahb_req.HRDATA) begin
        match_count++;
        `uvm_info(get_type_name(),$sformatf("READ DATA Match"),UVM_LOW)
          `uvm_info(get_type_name(),$sformatf("Addr: %0h",ahb_req.HADDR),UVM_LOW)
          `uvm_info(get_type_name(),$sformatf("Expected Data: %0h Actual Data: %0h",sco_mem[ahb_req.HADDR],ahb_req.HRDATA),UVM_LOW)
      end
      else begin
        mismatch_count++;
          `uvm_error(get_type_name(),"READ DATA MisMatch")
          `uvm_info(get_type_name(),$sformatf("Addr: %0h",ahb_req.HADDR),UVM_LOW)
          `uvm_info(get_type_name(),$sformatf("Expected Data: %0h Actual Data: %0h",sco_mem[ahb_req.HADDR],ahb_req.HRDATA),UVM_LOW)
      end
    end
    end
  endtask
  
  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info(get_type_name(), $sformatf("Total Matches: %0d", match_count), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("Total Mismatches: %0d", mismatch_count), UVM_LOW)
    
    if (mismatch_count > 0) begin
      `uvm_error(get_type_name(), "Protocol verification FAILED with mismatches!")
    end else begin
      `uvm_info(get_type_name(), "Protocol verification PASSED!", UVM_LOW)
    end
  endfunction

endclass
