class ahb_env extends uvm_env;
  `uvm_component_utils(ahb_env)
  
  ahb_m_agent m_agnt;
  ahb_s_agent s_agnt;
  ahb_scoreboard scob;
  
  function new(string name = "ahb_env", uvm_component parent = null);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_agnt = ahb_m_agent::type_id::create("m_agnt",this);
    s_agnt = ahb_s_agent::type_id::create("s_agnt",this);
    scob = ahb_scoreboard::type_id::create("scob", this);
  endfunction
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    /////Connect monitor and scoreboard
    m_agnt.m_mon.ahb_m_item_port.connect(scob.m_actual_imp);
//     s_agnt.s_mon.ahb_s_item_port.connect(scob.s_expected_imp);
  endfunction
  
endclass
