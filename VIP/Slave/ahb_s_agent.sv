class ahb_s_agent #(int ADDR_WIDTH = 32, int DATA_WIDTH = 32) extends uvm_agent;
  `uvm_component_utils(ahb_s_agent #(ADDR_WIDTH, DATA_WIDTH))
  
  ahb_s_driver #(ADDR_WIDTH, DATA_WIDTH) s_drv;
  ahb_s_sequencer #(ADDR_WIDTH, DATA_WIDTH) s_seqr;
  ////Monitor///
//   ahb_m_monitor s_mon;
  
  function new(string name = "ahb_s_agent", uvm_component parent = null);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    s_drv = ahb_s_driver #(ADDR_WIDTH, DATA_WIDTH)::type_id::create("s_drv",this);
    s_seqr = ahb_s_sequencer #(ADDR_WIDTH, DATA_WIDTH)::type_id::create("s_seqr",this);
    /////Monitor Create
//     s_mon = ahb_m_monitor::type_id::create("s_mon",this);
  endfunction
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    s_drv.seq_item_port.connect(s_seqr.seq_item_export);
  endfunction
  
endclass
