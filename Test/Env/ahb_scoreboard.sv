`uvm_analysis_imp_decl(_ahb_m_item_port)
`uvm_analysis_imp_decl(_ahb_s_item_port)

class ahb_scoreboard #(int ADDR_WIDTH = 32, int DATA_WIDTH = 32) extends uvm_scoreboard;
  `uvm_component_utils(ahb_scoreboard #(ADDR_WIDTH, DATA_WIDTH))
  
//  uvm_analysis_imp #(ahb_seq_item #(ADDR_WIDTH, DATA_WIDTH), ahb_scoreboard #(ADDR_WIDTH, DATA_WIDTH)) m_imp; 
   uvm_analysis_imp_ahb_m_item_port #(ahb_seq_item #(ADDR_WIDTH, DATA_WIDTH), ahb_scoreboard #(ADDR_WIDTH, DATA_WIDTH)) m_imp;
   uvm_analysis_imp_ahb_s_item_port #(ahb_seq_item #(ADDR_WIDTH, DATA_WIDTH), ahb_scoreboard #(ADDR_WIDTH, DATA_WIDTH)) s_imp;
  
  ahb_seq_item #(ADDR_WIDTH, DATA_WIDTH) m_queue[$];
  ahb_seq_item #(ADDR_WIDTH, DATA_WIDTH) s_queue[$];
  
//   Reference memory
  bit [7:0] sco_mem [bit [ADDR_WIDTH-1:0]] = '{default: 0};
  
  int match_count, mismatch_count;
  //bit [ADDR_WIDTH -1:0] current_addr;
  //int byte_lane;
  
  function new(string name = "ahb_scoreboard", uvm_component parent);
    super.new(name, parent);
    m_imp = new("m_imp", this);
    s_imp = new("s_imp", this);
//     foreach (sco_mem[i])
//       sco_mem[i] = 32'hFFFF;
  endfunction
  
//  function void build_phase(uvm_phase phase);
//    super.build_phase(phase);
//  endfunction
  
  function void write_ahb_m_item_port(ahb_seq_item #(ADDR_WIDTH, DATA_WIDTH) m_tx);
    m_queue.push_back(m_tx);
    
  endfunction
  
  function void write_ahb_s_item_port(ahb_seq_item #(ADDR_WIDTH, DATA_WIDTH) s_tx);
    s_queue.push_back(s_tx);
  endfunction
  
virtual task run_phase(uvm_phase phase);
  forever begin
    ahb_seq_item #(ADDR_WIDTH, DATA_WIDTH) ahb_m_req;
    ahb_seq_item #(ADDR_WIDTH, DATA_WIDTH) ahb_s_req;

    // Wait until both monitors provide a transaction
    wait (m_queue.size() > 0 && s_queue.size() > 0);

    ahb_m_req = m_queue.pop_front();
    ahb_s_req = s_queue.pop_front();

    `uvm_info("SCOB", $sformatf("MASTER: ADDR=%h HWRITE=%0b HTRANS=%0b HWDATA=%p | SLAVE: ADDR=%h HWRITE=%0b HTRANS=%0b HWDATA=%p HRDATA=%h",
      		 ahb_m_req.HADDR, ahb_m_req.HWRITE, ahb_m_req.HTRANS, ahb_m_req.HWDATA,
      	 	 ahb_s_req.HADDR, ahb_s_req.HWRITE, ahb_s_req.HTRANS, ahb_s_req.HWDATA, ahb_s_req.HRDATA),UVM_MEDIUM)

    // Compare address
    if (ahb_m_req.HADDR !== ahb_s_req.HADDR) begin
      mismatch_count++;
      `uvm_error("SCB_ADDR", $sformatf("Address mismatch: Master=%h Slave=%h",ahb_m_req.HADDR, ahb_s_req.HADDR))
    end

    //  Compare read/write control
    else if (ahb_m_req.HWRITE !== ahb_s_req.HWRITE) begin
      mismatch_count++;
      `uvm_error("SCB_HWRITE", $sformatf("HWRITE mismatch: Master=%0b Slave=%0b", ahb_m_req.HWRITE, ahb_s_req.HWRITE))
    end

    //  Compare transfer type
    else if (ahb_m_req.HTRANS !== ahb_s_req.HTRANS) begin
      mismatch_count++;
      `uvm_error("SCB_HTRANS", $sformatf("HTRANS mismatch: Master=%0b Slave=%0b", ahb_m_req.HTRANS, ahb_s_req.HTRANS))
    end

    else begin

      // Write transaction
      if (ahb_m_req.HWRITE) begin

        if (ahb_m_req.HWDATA[0] !== ahb_s_req.HWDATA[0]) begin
          mismatch_count++;
          `uvm_error("SCB_WDATA",$sformatf("Write data mismatch at ADDR=%h: Master=%h Slave=%h", ahb_m_req.HADDR, ahb_m_req.HWDATA[0], ahb_s_req.HWDATA[0]))
        end
        else begin
          for (int i = 0; i < (1 << ahb_m_req.HSIZE); i++) begin
          sco_mem[ahb_m_req.HADDR + i] = ahb_m_req.HWDATA[0][8*i +: 8];
          end
          match_count++;
          `uvm_info("SCB_WRITE", $sformatf("WRITE MATCH: ADDR=%h DATA=%h", ahb_m_req.HADDR, ahb_m_req.HWDATA[0]), UVM_MEDIUM)
        end
      end

      // Read transaction
      else begin
          for (int i = 0; i < (1 << ahb_m_req.HSIZE); i++) begin
            if (sco_mem[ahb_m_req.HADDR + i] === ahb_s_req.HRDATA[8*i +: 8]) begin
              match_count++;
              `uvm_info("SCB_READ", $sformatf("READ MATCH: ADDR=%h EXPECTED=%h ACTUAL=%h", ahb_m_req.HADDR+i, sco_mem[ahb_m_req.HADDR+i], ahb_s_req.HRDATA[8*i +: 8]), UVM_MEDIUM)
            end
            else begin
              mismatch_count++;
              `uvm_info("SCB_READ", $sformatf("READ MISMATCH: ADDR=%h EXPECTED=%h ACTUAL=%h", ahb_m_req.HADDR+i, sco_mem[ahb_m_req.HADDR+i], ahb_s_req.HRDATA[8*i +: 8]), UVM_MEDIUM)
            end
          end
      end
    end
  end
endtask
        
 // virtual task run_phase(uvm_phase phase);
 //   forever begin
 //    ahb_seq_item #(ADDR_WIDTH, DATA_WIDTH) ahb_m_req;
 //    ahb_seq_item #(ADDR_WIDTH, DATA_WIDTH) ahb_s_req;
 //   `uvm_info(get_type_name(),$sformatf("RUN_PHASE started size : %0d and %0d",m_queue.size(), s_queue.size()),UVM_LOW)
 //   /////Compare 
 //   
 //   wait(s_queue.size() > 0 && m_queue.size() > 0);
 //   `uvm_info(get_type_name(),$sformatf("size : %0d",m_queue.size()),UVM_LOW)
 //   ahb_m_req = m_queue.pop_front();
 //   ahb_s_req = s_queue.pop_front();
 //   `uvm_info("SCB_TRACE",
 // $sformatf("MASTER: HADDR=%h HWRITE=%0b HWDATA=%p | SLAVE: HADDR=%h HWRITE=%0b",
 //   ahb_m_req.HADDR,
 //   ahb_m_req.HWRITE,
 //   ahb_m_req.HWDATA,
 //   ahb_s_req.HADDR,
 //   ahb_s_req.HWRITE),
 // UVM_LOW)
 //   
 //   if(ahb_m_req.HWRITE) begin
 //     sco_mem[ahb_m_req.HADDR] = ahb_m_req.HWDATA[0];
 //     `uvm_info(get_type_name(),$sformatf(" WRITE DATA"),UVM_LOW)
 //     //`uvm_info(get_type_name(),$sformatf("Addr: %0h and Data: %0h",ahb_m_req.HADDR, ahb_m_req.HWDATA),UVM_LOW) 
 //   end
 //   else if(!ahb_m_req.HWRITE) begin
 //     if(sco_mem[ahb_m_req.HADDR] == ahb_s_req.HRDATA) begin
 //       match_count++;
 //       `uvm_info(get_type_name(),$sformatf("READ DATA Match"),UVM_LOW)
 //         `uvm_info(get_type_name(),$sformatf("Addr: %0h",ahb_m_req.HADDR),UVM_LOW)
 //         `uvm_info(get_type_name(),$sformatf("Expected Data: %0h Actual Data: %0h",sco_mem[ahb_m_req.HADDR],ahb_m_req.HRDATA),UVM_LOW)
 //     end
 //     else begin
 //       mismatch_count++;
 //         `uvm_error(get_type_name(),"READ DATA MisMatch")
 //         `uvm_info(get_type_name(),$sformatf("Addr: %0h",ahb_m_req.HADDR),UVM_LOW)
 //         `uvm_info(get_type_name(),$sformatf("Expected Data: %0h Actual Data: %0h",sco_mem[ahb_m_req.HADDR],ahb_s_req.HRDATA),UVM_LOW)
 //     end
 //   end
 //   end
 // endtask
 
//	logic [31:0] aligned_addr;
//	int byte_lane;
//	
//	for (int i = 0; i < number_of_bytes; i++) begin
//	    // 1. Calculate the actual absolute address for this specific byte
//	    aligned_addr = ahb_m_req.HADDR + i;
//	    
//	    // 2. Find which byte lane on the AHB bus this address maps to (for 32-bit bus: % 4)
//	    byte_lane = aligned_addr % 4; 
//	    
//	    // 3. Store the correct byte lane into your scoreboard memory
//	    sco_mem[aligned_addr] = ahb_m_req.HWDATA[8*byte_lane +: 8];
//	end
//        else begin
//          for (int i = 0; i < (1 << ahb_m_req.HSIZE); i++) begin
//          current_addr = ahb_m_req.HADDR + i;
//          byte_lane = current_addr % 4;
//          sco_mem[ahb_m_req.HADDR + i] = ahb_m_req.HWDATA[8*(byte_lane) +: 8];
//          end
//          match_count++;
//          `uvm_info("SCB_WRITE", $sformatf("WRITE MATCH: ADDR=%h DATA=%h", ahb_m_req.HADDR, ahb_m_req.HWDATA[0]), UVM_MEDIUM)
//        end
//      end
  
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
