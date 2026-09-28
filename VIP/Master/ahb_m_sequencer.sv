class ahb_m_sequencer #(int ADDR_WIDTH = 32, int DATA_WIDTH = 32) extends uvm_sequencer#(ahb_seq_item #(ADDR_WIDTH, DATA_WIDTH));
  `uvm_component_utils(ahb_m_sequencer #(ADDR_WIDTH, DATA_WIDTH))
  
  function new(string name = "ahb_m_sequencer", uvm_component parent = null);
    super.new(name,parent);
  endfunction
  
endclass
