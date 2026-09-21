//`include "../Interface/ahb_if.sv"
package ahb_pkg;
`include "uvm_macros.svh"
  import uvm_pkg::*;

typedef virtual ahb_if vif;
`include "../Master/ahb_seq_item.sv"
`include "../Master/ahb_m_sequence.sv"
`include "../Master/ahb_m_sequencer.sv"
`include "../Master/ahb_m_driver.sv"
`include "../Master/ahb_m_monitor.sv"
`include "../Master/ahb_m_agent.sv"
`include "../Slave/ahb_s_sequence.sv"
`include "../Slave/ahb_s_sequencer.sv"
`include "../Slave/ahb_s_driver.sv"
`include "../Slave/ahb_s_agent.sv"
`include "../Env/ahb_scoreboard.sv"
`include "../Env/ahb_env.sv"
`include "../Test/ahb_test.sv"

endpackage
