class ahb_m_agent extends uvm_agent;
  `uvm_component_utils(ahb_m_agent)
  
  ahb_m_driver m_drv;
  ahb_m_sequencer m_seqr;
  ///Monitor
  ahb_m_monitor m_mon;
  
  function new(string name = "ahb_m_agent", uvm_component parent = null);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_drv = ahb_m_driver::type_id::create("m_drv",this);
    m_seqr = ahb_m_sequencer::type_id::create("m_seqr",this);
    /////Monitor create
    m_mon = ahb_m_monitor::type_id::create("m_mon",this);
  endfunction
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    m_drv.seq_item_port.connect(m_seqr.seq_item_export);
  endfunction
  
endclass
