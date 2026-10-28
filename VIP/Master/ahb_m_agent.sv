  ////File Name: ahb_m_agent.sv
  ////Author Name: Dhruv Lalpurwala
  ////Propetier Name: ASICraft Technologies LLP
  ////Description: This master agents which encapsulate 
  //// master driver, sequencer and monitor 
  /////////////////////////////////////////////////////

class ahb_m_agent #(int ADDR_WIDTH = 32, int DATA_WIDTH = 32) extends uvm_agent;
  `uvm_component_utils(ahb_m_agent #(ADDR_WIDTH, DATA_WIDTH))
  
  ahb_m_driver #(ADDR_WIDTH, DATA_WIDTH) m_drv;      ////instance of master driver
  ahb_m_sequencer #(ADDR_WIDTH, DATA_WIDTH) m_seqr;  ////instance of master sequencer
  ///Monitor
  ahb_m_monitor #(ADDR_WIDTH, DATA_WIDTH) m_mon;     ////instance of master monitor
  
  function new(string name = "ahb_m_agent", uvm_component parent = null);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_drv = ahb_m_driver #(ADDR_WIDTH, DATA_WIDTH)::type_id::create("m_drv",this);      //create an instance for master driver
    m_seqr = ahb_m_sequencer #(ADDR_WIDTH, DATA_WIDTH)::type_id::create("m_seqr",this); //create an instance for master sequencer
    /////Monitor create
    m_mon = ahb_m_monitor #(ADDR_WIDTH, DATA_WIDTH)::type_id::create("m_mon",this);     //create an instance for master monitor
  endfunction
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    m_drv.seq_item_port.connect(m_seqr.seq_item_export);    //Connection of sequencer and driver
  endfunction
  
endclass
