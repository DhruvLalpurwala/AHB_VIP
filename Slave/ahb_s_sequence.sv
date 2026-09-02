class ahb_s_sequence extends uvm_sequence#(ahb_seq_item);
  ahb_seq_item req;
  `uvm_object_utils(ahb_s_sequence)
  
  function new(string name = "ahb_s_sequence");
    super.new(name);
  endfunction
  
  task body();
    repeat(4) begin
    req = ahb_seq_item::type_id::create("req");
    start_item(req);
    assert(req.randomize());
//       `uvm_info("SLAVE_SEQ", $sformatf("SLAVE_PACKET_PRINTED"), UVM_LOW);
//       req.print();
    finish_item(req);
    end
  endtask
  
endclass
