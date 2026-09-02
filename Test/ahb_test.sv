`include "ahb_pkg.sv"

class ahb_test extends uvm_test;
  `uvm_component_utils(ahb_test)
  
  ahb_env e;
  ahb_m_sequence seq;
  ahb_s_sequence seq1;
  
  function new(string name = "ahb_test",uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    e = ahb_env::type_id::create("e",this);
  endfunction
  
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    seq = ahb_m_sequence::type_id::create("seq");
    seq1 = ahb_s_sequence::type_id::create("seq1");
    
    fork
      
        seq.start(e.m_agnt.m_seqr);
        seq1.start(e.s_agnt.s_seqr);
     
    join
//         seq.start(e.s_agnt.s_seqr);
    #65;

    phase.drop_objection(this);
  endtask
  
endclass
