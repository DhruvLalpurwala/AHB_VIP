
                  //////Same Address Write -> Write -> Read///////////////////

class ahb_m_sequence extends uvm_sequence#(ahb_seq_item);
  ahb_seq_item req;
  `uvm_object_utils(ahb_m_sequence)
  
  bit[31:0] ADDR_L;
  virtual ahb_if vif;
  
  function new(string name = "ahb_m_sequence");
    super.new(name);
  endfunction
  
  task body();
    if(!uvm_config_db#(virtual ahb_if)::get(null, "*", "vif", vif))
      `uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
    
  endtask
  
  task start_seq();
    for (int i = 0; i<4; i++) begin
      req = ahb_seq_item::type_id::create("req");
      start_item(req);
        if(i == 0) begin
          assert(req.randomize with {HWRITE == 1'b1;
                                     HTRANS inside {IDLE, NONSEQ};});  /////randomize the sequence items and send it to the driver
          ADDR_L = req.HADDR;
        end
        else if (i == 1) begin
          assert(req.randomize with {HWRITE == 1'b1;
                                     HADDR == ADDR_L;});
        end

        else if (i == 2) begin
          assert(req.randomize with {HWRITE == 1'b1;
                                     HADDR == ADDR_L;});
        end
        else if (i == 3) begin
          assert(req.randomize with {HWRITE == 1'b0;
                                     HADDR == ADDR_L;});
        end
      finish_item(req); 
    end
  endtask
  
endclass




                                  ///////Write -> Read -> Write -> Read////////////////


// class ahb_m_sequence extends uvm_sequence#(ahb_seq_item);
//   ahb_seq_item req;
//   `uvm_object_utils(ahb_m_sequence)
  
//   bit[31:0] ADDR_L;
  
//   function new(string name = "ahb_m_sequence");
//     super.new(name);
//   endfunction
  
//   task body();
//     `uvm_info(get_type_name, "inside body", UVM_LOW);
//     for (int i = 0; i<4; i++) begin
//       `uvm_info(get_type_name, $sformatf("inside body I = %0d", i), UVM_LOW);
//     req = ahb_seq_item::type_id::create("req");
//     start_item(req);
// //     assert(req.randomize());
//       if(i%2 == 0)begin
//         assert(req.randomize with {HWRITE == 1'b1;});  /////randomize the sequence items and send it to the driver
//         ADDR_L = req.HADDR;
//         req.print();
//         end
//         else
//           begin
//             assert(req.randomize with {HWRITE == 1'b0; HADDR == ADDR_L;});
//             req.print();
//           end
//       finish_item(req); 
//     end
//   endtask
// endclass


                                                      //////Transfer Type////////////////

// class ahb_m_sequence extends uvm_sequence#(ahb_seq_item);
//   ahb_seq_item req;
//   `uvm_object_utils(ahb_m_sequence)
  
  
//   function new(string name = "ahb_m_sequence");
//     super.new(name);
//   endfunction
  
//   task body();
//     `uvm_info(get_type_name, "inside body", UVM_LOW);
//     for (int i = 0; i<30; i++) begin
//       `uvm_info(get_type_name, $sformatf("inside body I = %0d", i), UVM_LOW);
//     req = ahb_seq_item::type_id::create("req");
//     start_item(req);
//         if(i == 0) begin
//           assert(req.randomize with {/*HWRITE == 1'b1;*/
//                                      HTRANS inside {IDLE, NONSEQ};});  /////randomize the sequence items and send it to the driver
//           req.print();
//         end
//         else
//           begin
//             assert(req.randomize with {/*HWRITE == 1'b1;*/
//                                        HTRANS inside {SEQ};});  /////randomize the sequence items and send it to the driver
//             req.print();
//           end
//       finish_item(req); 
//     end
//   endtask
// endclass
