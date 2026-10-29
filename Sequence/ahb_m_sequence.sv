 class ahb_m_sequence extends uvm_sequence#(ahb_seq_item #(32, 32));
    ahb_seq_item #(32, 32) req;
    `uvm_object_utils(ahb_m_sequence)
 
    function new(string name = "ahb_m_sequence");
      super.new(name);
    endfunction
 
    task body();
      `uvm_info(get_type_name, "inside body", UVM_LOW);
      for (int i = 0; i<6; i++) begin
      req = ahb_seq_item #(32, 32)::type_id::create("req");
      start_item(req);
          assert(req.randomize with {HBURST == SINGLE;});  /////randomize the sequence items and send it to the driver
          req.print();
      finish_item(req); 
      end
    endtask
  endclass                 
	       ///////Write -> Read -> Write -> Read////////////////

class ahb_wr_rd extends ahb_m_sequence;
    `uvm_object_utils(ahb_wr_rd)
 
    bit[31:0] ADDR_L;
 
    function new(string name = "ahb_wr_rd");
      super.new(name);
    endfunction
 
    task body();
      `uvm_info(get_type_name, "inside body", UVM_LOW);
      for (int i = 0; i<6; i++) begin
      req = ahb_seq_item #(32, 32)::type_id::create("req");
      start_item(req);
        if(i%2 == 0)begin
          assert(req.randomize with {HWRITE == 1'b1;
				     HBURST == SINGLE;
                                     HSIZE == 2;});  /////randomize the sequence items and send it to the driver
          ADDR_L = req.HADDR;
          req.print();
          end
          else
            begin
              assert(req.randomize with {HWRITE == 1'b0; HADDR == ADDR_L; HBURST == SINGLE; HSIZE == 2;});
              req.print();
            end
        finish_item(req); 
      end
    endtask
  endclass

                  //////Same Address Write -> Write -> Read///////////////////

class ahb_wr_wr_rd extends ahb_m_sequence;
  `uvm_object_utils(ahb_wr_wr_rd)
  
  bit[31:0] ADDR_L;
  
  function new(string name = "ahb_wr_wr_rd");
    super.new(name);
  endfunction
  
  task body();
    for (int i = 0; i<4; i++) begin
      req = ahb_seq_item #(32,32)::type_id::create("req");
      start_item(req);
        if(i == 0) begin
          assert(req.randomize with {HWRITE == 1'b1;
                                     HBURST == 0;
                                     HSIZE == 2;});  /////randomize the sequence items and send it to the driver
          ADDR_L = req.HADDR;
        end
        else if (i == 1) begin
          assert(req.randomize with {HWRITE == 1'b1;
                                     HADDR == ADDR_L;HBURST == 0;
                                     HSIZE == 1;});
        end

        else if (i == 2) begin
          assert(req.randomize with {HWRITE == 1'b1;
                                     HADDR == ADDR_L;HBURST == 0;
                                     HSIZE == 1;});
        end
        else if (i == 3) begin
          assert(req.randomize with {HWRITE == 1'b0;
                                     HADDR == ADDR_L;HBURST == 0;
                                     HSIZE == 2;});
        end
	else begin
	  assert(req.randomize());
	end
      finish_item(req); 
    end
  endtask
  
endclass

                                                        //////Back to Back Write on same Address/////////////
class ahb_wr_wr extends ahb_m_sequence ;
    `uvm_object_utils(ahb_wr_wr)

    bit[31:0] ADDR_L;

    function new(string name = "ahb_wr_wr");
      super.new(name);
    endfunction
 
    task body();
      `uvm_info(get_type_name, "inside body", UVM_LOW);
      req = ahb_seq_item #(32, 32)::type_id::create("req");
      start_item(req);
        	assert(req.randomize with {HWRITE == 1'b0; HADDR == 516;
      			   	   	   HBURST == 0;
					   HSIZE == BIT_32;});
        ADDR_L = req.HADDR;
	req.print();
      finish_item(req);

      for (int i = 0; i < 8; i++) begin
      req = ahb_seq_item #(32, 32)::type_id::create("req");
      start_item(req);
        	assert(req.randomize with {HWRITE == 1'b0; HADDR == ADDR_L;
      			   	   	   HBURST == 0;
					   HSIZE == BIT_32;});
	req.print();
      finish_item(req);
      end
    endtask
endclass

// 
// 							//////Multiple writes//////////
// 
class ahb_wr extends ahb_m_sequence;
    `uvm_object_utils(ahb_wr)
     
    function new(string name = "ahb_wr");
      super.new(name);
    endfunction
 
    task body();
      `uvm_info(get_type_name, "inside body", UVM_LOW);
      //for (int i = 0; i<8; i++) begin
       // `uvm_info(get_type_name, $sformatf("inside body I = %0d", i), UVM_LOW);
      req = ahb_seq_item#(32,32)::type_id::create("req");
      start_item(req);
  //     assert(req.randomize());
         assert(req.randomize with {HWRITE == 1'b0;
				    HBURST == 3;
                                    HSIZE == 0;});  /////randomize the sequence items and send it to the driver
                                   
      finish_item(req); 
      //end
    endtask
endclass
// 
//                                                           ////////Wr -> Rd Burst////////////////////
// 
class ahb_burst_wr_rd extends ahb_m_sequence;
    `uvm_object_utils(ahb_burst_wr_rd)

    bit [31:0] ADDR_L;

    function new(string name = "ahb_burst_wr_rd");
      super.new(name);
    endfunction
 
    task body();
      `uvm_info(get_type_name, "inside body", UVM_LOW);
      req = ahb_seq_item #(32,32)::type_id::create("req");
      start_item(req);
        	assert(req.randomize with {HWRITE == 1'b1;
      			   	   	   HBURST == 3;
					   HSIZE == BIT_16;});
	ADDR_L = req.HADDR;
	req.print();
      finish_item(req);
      

      req = ahb_seq_item #(32,32)::type_id::create("req");
      start_item(req);
        	assert(req.randomize with {HWRITE == 1'b0; HADDR == ADDR_L;
      			   	   	   HBURST == 3;
					   HSIZE == BIT_32;});
	req.print();
      finish_item(req);
      //end
    endtask
endclass

                                                      //////////BURST////////////

class ahb_burst extends ahb_m_sequence ;
    `uvm_object_utils(ahb_burst)

    function new(string name = "ahb_burst");
      super.new(name);
    endfunction
 
    task body();
      `uvm_info(get_type_name, "inside body", UVM_LOW);
      req = ahb_seq_item #(32, 32)::type_id::create("req");
      start_item(req);
        	assert(req.randomize with {HWRITE == 1'b0; HADDR == 'd1020;
      			   	   	   HBURST == 2;
					   HSIZE == BIT_32;});
	req.print();
      finish_item(req);
    endtask
endclass

                                                       ////////Wr->Rd different size

class ahb_wr_rd_diff_size  extends ahb_m_sequence ;
    `uvm_object_utils(ahb_wr_rd_diff_size)

    bit[31:0] ADDR_L;

    function new(string name = "ahb_wr_rd_diff_size");
      super.new(name);
    endfunction
 
    task body();
      `uvm_info(get_type_name, "inside body", UVM_LOW);
      req = ahb_seq_item #(32, 32)::type_id::create("req");
      start_item(req);
        	assert(req.randomize with {HWRITE == 1'b1;
      			   	   	   HBURST == 0;
					   HSIZE == BIT_16;});
        ADDR_L = req.HADDR;
	req.print();
      finish_item(req);

      req = ahb_seq_item #(32, 32)::type_id::create("req");
      start_item(req);
        	assert(req.randomize with {HWRITE == 1'b0; HADDR == ADDR_L;
      			   	   	   HBURST == 0;
					   HSIZE == BIT_32;});
	req.print();
      finish_item(req);
    endtask
endclass


                                                       ////////Wr->Rd same size

class ahb_wr_rd_same_size  extends ahb_m_sequence ;
    `uvm_object_utils(ahb_wr_rd_same_size)

    bit[31:0] ADDR_L;

    function new(string name = "ahb_wr_rd_same_size");
      super.new(name);
    endfunction
 
    task body();
      `uvm_info(get_type_name, "inside body", UVM_LOW);
      req = ahb_seq_item #(32, 32)::type_id::create("req");
      start_item(req);
        	assert(req.randomize with {HWRITE == 1'b1;
      			   	   	   HBURST == 0;
					   HSIZE == BIT_32;});
        ADDR_L = req.HADDR;
	req.print();
      finish_item(req);

      req = ahb_seq_item #(32, 32)::type_id::create("req");
      start_item(req);
        	assert(req.randomize with {HWRITE == 1'b0; HADDR == ADDR_L;
      			   	   	   HBURST == 0;
					   HSIZE == BIT_32;});
	req.print();
      finish_item(req);
    endtask
endclass

                                                      /////1KB Address Boundary cross

class ahb_addr_boundary extends ahb_m_sequence;
    `uvm_object_utils(ahb_addr_boundary)

    bit [31:0] ADDR_L;

    function new(string name = "ahb_addr_boundary");
      super.new(name);
    endfunction
 
    task body();
      `uvm_info(get_type_name, "inside body", UVM_LOW);
      req = ahb_seq_item #(32,32)::type_id::create("req");
      start_item(req);
             
        	if (!(req.randomize with {HWRITE == 1'b1;
      			   	   	   HBURST == 7;
					   HSIZE == BIT_1024;})) begin
                `uvm_fatal("RND_FAIL", "Inline function randomization failed!")
                end
	req.print();
      finish_item(req);

      //end
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
