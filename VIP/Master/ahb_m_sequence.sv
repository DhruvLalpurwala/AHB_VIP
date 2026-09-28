                  
	       ///////Write -> Read -> Write -> Read////////////////

class ahb_m_sequence extends uvm_sequence#(ahb_seq_item #(32, 32));
    ahb_seq_item #(32, 32) req;
    `uvm_object_utils(ahb_m_sequence)
 
    bit[31:0] ADDR_L;
 
    function new(string name = "ahb_m_sequence");
      super.new(name);
    endfunction
 
    task body();
      `uvm_info(get_type_name, "inside body", UVM_LOW);
      for (int i = 0; i<8; i++) begin
       // `uvm_info(get_type_name, $sformatf("inside body I = %0d", i), UVM_LOW);
      req = ahb_seq_item #(32, 32)::type_id::create("req");
      start_item(req);
  //     assert(req.randomize());
        if(i%2 == 0)begin
          assert(req.randomize with {HWRITE == 1'b1;
				     HBURST == SINGLE;});  /////randomize the sequence items and send it to the driver

          ADDR_L = req.HADDR;
          req.print();
          end
          else
            begin
              assert(req.randomize with {HWRITE == 1'b0; HADDR == ADDR_L; HBURST == SINGLE;});
              req.print();
            end
        finish_item(req); 
      end
    endtask
  endclass

                  //////Same Address Write -> Write -> Read///////////////////

// class ahb_wr_wr_rd extends ahb_m_sequence;
//   ahb_seq_item req;
//   `uvm_object_utils(ahb_wr_wr_rd)
//   
//   bit[31:0] ADDR_L;
//   
//   function new(string name = "ahb_wr_wr_rd");
//     super.new(name);
//   endfunction
//   
//   task body();
//     for (int i = 0; i<8; i++) begin
//       req = ahb_seq_item::type_id::create("req");
//       start_item(req);
//         if(i == 0) begin
//           assert(req.randomize with {HWRITE == 1'b1;
//                                      HTRANS inside {IDLE, NONSEQ};});  /////randomize the sequence items and send it to the driver
//           ADDR_L = req.HADDR;
//         end
//         else if (i == 1) begin
//           assert(req.randomize with {HWRITE == 1'b1;
//                                      HADDR == ADDR_L;});
//         end
// 
//         else if (i == 2) begin
//           assert(req.randomize with {HWRITE == 1'b1;
//                                      HADDR == ADDR_L;});
//         end
//         else if (i == 3) begin
//           assert(req.randomize with {HWRITE == 1'b0;
//                                      HADDR == ADDR_L;});
//         end
// 	else begin
// 	  assert(req.randomize());
// 	end
//       finish_item(req); 
//     end
//   endtask
//   
// endclass
// 
// 							//////Only Write SINGLE Burst//////////
// 
// class ahb_single_burst extends ahb_m_sequence;
//     ahb_seq_item req;
//     `uvm_object_utils(ahb_single_burst)
//      
//     function new(string name = "ahb_single_burst");
//       super.new(name);
//     endfunction
//  
//     task body();
//       `uvm_info(get_type_name, "inside body", UVM_LOW);
//       for (int i = 0; i<8; i++) begin
//        // `uvm_info(get_type_name, $sformatf("inside body I = %0d", i), UVM_LOW);
//       req = ahb_seq_item::type_id::create("req");
//       start_item(req);
//   //     assert(req.randomize());
//          assert(req.randomize with {HWRITE == 1'b1;
// 				    HBURST == SINGLE;});  /////randomize the sequence items and send it to the driver
//       finish_item(req); 
//       end
//     endtask
// endclass
// 
//                                                           ////////Wr -> Rd Burst////////////////////
// 
// class ahb_burst_wr_rd extends ahb_m_sequence #(32, 32);
//     ahb_seq_item req;
//     `uvm_object_utils(ahb_burst_wr_rd #(32, 32))
// 
//     bit [31:0] ADDR_L;
// 
//     function new(string name = "ahb_burst_wr_rd");
//       super.new(name);
//     endfunction
//  
//     task body();
//       `uvm_info(get_type_name, "inside body", UVM_LOW);
//       //for (int i = 0; i<8; i++) begin
//        // `uvm_info(get_type_name, $sformatf("inside body I = %0d", i), UVM_LOW);
//       req = ahb_seq_item::type_id::create("req");
//       start_item(req);
//         	assert(req.randomize with {HWRITE == 1'b1;
//       			   	   	   HBURST == 2;
// 					   HSIZE == BIT_32;});
// 	ADDR_L = req.HADDR;
// 	req.print();
//       finish_item(req);
//       
// 
//       req = ahb_seq_item::type_id::create("req");
//       start_item(req);
//         	assert(req.randomize with {HWRITE == 1'b0; HADDR == ADDR_L;
//       			   	   	   HBURST == 2;
// 					   HSIZE == BIT_32;});
// 	req.print();
//       finish_item(req);
//       //end
//     endtask
// endclass

                                                      //////////BURST////////////

class ahb_incr_burst  extends ahb_m_sequence ;
    //ahb_seq_item #(32, 32) req;
    `uvm_object_utils(ahb_incr_burst)

    function new(string name = "ahb_incr_burst");
      super.new(name);
    endfunction
 
    task body();
      `uvm_info(get_type_name, "inside body", UVM_LOW);
      req = ahb_seq_item #(32, 32)::type_id::create("req");
      start_item(req);
        	assert(req.randomize with {HWRITE == 1'b1;
      			   	   	   HBURST == 2;
					   HSIZE == BIT_32;});
	req.print();
      finish_item(req);
         endtask
endclass

//class ahb_incr_burst extends ahb_m_sequence;
//  ahb_seq_item req;
//  `uvm_object_utils(ahb_incr_burst)
//
//  bit[31:0] ADDR_L;
//
//  function new(string name = "ahb_incr_burst");
//    super.new(name);
//  endfunction
//
//  task body();
//    `uvm_info(get_type_name, "inside body", UVM_LOW);
//    for (int i = 0; i<8; i++) begin
//      `uvm_info(get_type_name, $sformatf("inside body I = %0d", i), UVM_LOW);
//    req = ahb_seq_item::type_id::create("req");
//    start_item(req);
//	if(i%2 == 0)begin
//		if(i == 0) begin
//			assert(req.randomize with {HWRITE == 1'b1;
//						   HTRANS inside {NONSEQ};});  /////randomize the sequence items and send it to the driver
//          		ADDR_L = req.HADDR;
//          		req.print();
//          	end
//          	else begin
//              		assert(req.randomize with {HWRITE == 1'b1;
//						   HTRANS inside {SEQ};});
//			ADDR_L = req.HADDR;
//              		req.print();
//            	end
//        end
//        else begin
//            assert(req.randomize with {HWRITE == 1'b0; HADDR == ADDR_L;
//                                       HTRANS inside {SEQ};});  /////randomize the sequence items and send it to the driver
//            req.print();
//	end
//      finish_item(req); 
//    end
//  endtask
//endclass
