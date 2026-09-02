class ahb_s_sequencer extends uvm_sequencer#(ahb_seq_item);
  `uvm_component_utils(ahb_s_sequencer)
  
  function new(string name = "ahb_s_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
endclass
