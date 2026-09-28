//`include "../Interface/ahb_if.sv"
package ahb_pkg;
`include "uvm_macros.svh"
  import uvm_pkg::*;

typedef virtual ahb_if vif;
`include "../Seq_Item/ahb_seq_item.sv"
`include "../../Sequence/ahb_m_sequence.sv"
`include "../../VIP/Master/ahb_m_sequencer.sv"
`include "../../VIP/Master/ahb_m_driver.sv"
//`include "../../VIP/Master/ahb_m_monitor.sv"
`include "../../VIP/Master/ahb_m_agent.sv"
`include "../../Sequence/ahb_s_sequence.sv"
`include "../../VIP/Slave/ahb_s_sequencer.sv"
`include "../../VIP/Slave/ahb_s_driver.sv"
`include "../../VIP/Slave/ahb_s_agent.sv"
//`include "../../Test/Env/ahb_scoreboard.sv"
`include "../../Test/Env/ahb_env.sv"
`include "../../Test/ahb_test.sv"

endpackage
