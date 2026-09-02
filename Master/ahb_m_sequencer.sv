class ahb_m_sequencer extends uvm_sequencer#(ahb_seq_item);
  `uvm_component_utils(ahb_m_sequencer)
  
  function new(string name = "ahb_m_sequencer", uvm_component parent = null);
    super.new(name,parent);
  endfunction
  
endclass
