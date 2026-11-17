class ahb_test extends uvm_test;
  `uvm_component_utils(ahb_test)
  
  ahb_env #(ADDR_WIDTH, DATA_WIDTH) e;
  ahb_m_sequence seq;
  //ahb_s_sequence seq1;

  string mem_file_path;
  bit [7:0] temp_fixed_mem [1024];
  
  function new(string name = "ahb_test",uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    e = ahb_env#(ADDR_WIDTH, DATA_WIDTH)::type_id::create("e",this);
    
    if ($value$plusargs("MEM_INIT_FILE=%s", mem_file_path)) begin
      `uvm_info("TEST", $sformatf("Found MEM_INIT_FILE plusarg: %s", mem_file_path), UVM_LOW)
    end
    //uvm_config_db#(string)::set(this, "*", "mem_init_file", mem_file_path);
  endfunction

  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    if (mem_file_path != "") begin
      $readmemh(mem_file_path, temp_fixed_mem);
      `uvm_info("Test", "Local memory model preloaded successfully", UVM_LOW)
       foreach (temp_fixed_mem[i]) begin
         e.s_agnt.s_drv.mem[i] = temp_fixed_mem[i];
         e.scob.sco_mem[i] = temp_fixed_mem[i];
       end
    end

  endfunction : end_of_elaboration_phase
  
  task run_phase(uvm_phase phase);
    //uvm_objection  l_obj = phase.get_objection();
    phase.raise_objection(this);
    //l_obj.display_objections();
    seq = ahb_m_sequence::type_id::create("seq");
    //seq1 = ahb_s_sequence::type_id::create("seq1");
    
    //fork
      
        seq.start(e.m_agnt.m_seqr);
        //seq1.start(e.s_agnt.s_seqr);
     
    //join
//         seq.start(e.s_agnt.s_seqr);
    phase.get_objection().set_drain_time(this, 200ps);
    phase.drop_objection(this);
    //l_obj.display_objections();
  endtask

endclass
