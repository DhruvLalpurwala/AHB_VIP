  ////file name: ahb_m_sequence.sv
  ////author name: dhruv lalpurwala
  ////propetier name: asicraft technologies llp
  ////description: this file consists of different sequence which is inherit 
  //// from base sequence for different test cases
  /////////////////////////////////////////////////////

               //normal sequence ////
class ahb_m_sequence extends uvm_sequence#(ahb_seq_item #(ADDR_WIDTH, DATA_WIDTH));
    ahb_seq_item #(ADDR_WIDTH, DATA_WIDTH) req;
    `uvm_object_utils(ahb_m_sequence)
    int NO_OF_TRANS;
    int BURST_OP, SIZE;
    bit WRITE;
    bit[ADDR_WIDTH-1 :0] ADDR_L;

    function new(string name = "ahb_m_sequence");
      super.new(name);
      if ($value$plusargs("NO_OF_TRANS=%d", NO_OF_TRANS)) begin
        `uvm_info("SEQ", $sformatf("Found NO_OF_TRANS: %0d", NO_OF_TRANS), UVM_NONE)
      end
      if ($value$plusargs("WRITE=%b", WRITE)) begin
        `uvm_info("SEQ", $sformatf("Found WRITE: %b", WRITE), UVM_NONE)
      end
      if ($value$plusargs("BURST_OPERATION=%d",BURST_OP)) begin
        `uvm_info("SEQ", $sformatf("FoundBURST_OP: %0d", BURST_OP), UVM_NONE)
      end   
      if ($value$plusargs("TRANSFER_SIZE=%d", SIZE)) begin
        `uvm_info("SEQ", $sformatf("Found SIZE: %0d", SIZE), UVM_NONE)
      end 
    endfunction
 
    task body();
      `uvm_info("SEQ", "inside body", UVM_NONE);
      repeat(NO_OF_TRANS) begin
      req = ahb_seq_item #(ADDR_WIDTH, DATA_WIDTH)::type_id::create("req");
      start_item(req);
          assert(req.randomize with {HBURST == 0;});  /////randomize the sequence items and send it to the driver
          `uvm_info("SEQ", "Sequence Items", UVM_NONE);
          req.print();
      finish_item(req); 
      end
    endtask
endclass                 
	       ///////Write -> Read -> Write -> Read////////////////

class ahb_wr_rd extends ahb_m_sequence;
    `uvm_object_utils(ahb_wr_rd)
 
    function new(string name = "ahb_wr_rd");
      super.new(name);
    endfunction
 
    task body();
      `uvm_info("SEQ", "inside body", UVM_NONE);

      for (int i = 0; i<NO_OF_TRANS; i++) begin
      req = ahb_seq_item #(ADDR_WIDTH, DATA_WIDTH)::type_id::create("req");
      start_item(req);
        if(i%2 == 0)begin
          assert(req.randomize with {HWRITE == 1'b1;
				     HBURST == 0;
                                     HSIZE == SIZE;});  /////randomize the sequence items and send it to the driver
          ADDR_L = req.HADDR;
          req.print();
          end
        else begin
              assert(req.randomize with {HWRITE == 1'b0; HADDR == ADDR_L; 
                                         HBURST == 0; 
                                         HSIZE == SIZE;});
          `uvm_info("SEQ", "Sequence Items", UVM_NONE);
              req.print();
        end
        finish_item(req); 
      end
    endtask
endclass

                  //////back to back Write -> Read///////////////////

class ahb_wr_wr_rd extends ahb_m_sequence;
  `uvm_object_utils(ahb_wr_wr_rd)
  
  function new(string name = "ahb_wr_wr_rd");
    super.new(name);
  endfunction
  
  task body();
      `uvm_info("SEQ", "inside body", UVM_NONE);
      req = ahb_seq_item #(ADDR_WIDTH, DATA_WIDTH)::type_id::create("req");
      start_item(req);
        	assert(req.randomize with {HWRITE == 1;
      			   	   	   HBURST == 0;
					   HSIZE == SIZE;});
        ADDR_L = req.HADDR;
	req.print();
      finish_item(req);

      for (int i = 0; i < NO_OF_TRANS; i++) begin
      req = ahb_seq_item #(ADDR_WIDTH, DATA_WIDTH)::type_id::create("req");
      start_item(req);
        	assert(req.randomize with {HWRITE == 1; HADDR == ADDR_L;
      			   	   	   HBURST == 0;
					   HSIZE == SIZE;});
          `uvm_info("SEQ", "Sequence Items", UVM_NONE);
	req.print();
      finish_item(req);
      end

      start_item(req);
        	assert(req.randomize with {HWRITE == 0; HADDR == ADDR_L;
      			   	   	   HBURST == 0;
					   HSIZE == SIZE;});
          `uvm_info("SEQ", "Sequence Items", UVM_NONE);
	req.print();
      finish_item(req);
  endtask
  
endclass

                                                        //////Back to Back Write or read on same Address/////////////
class ahb_wr_wr extends ahb_m_sequence ;
    `uvm_object_utils(ahb_wr_wr)

    function new(string name = "ahb_wr_wr");
      super.new(name);
    endfunction
 
    task body();
      `uvm_info("SEQ", "inside body", UVM_NONE);
      req = ahb_seq_item #(ADDR_WIDTH, DATA_WIDTH)::type_id::create("req");
      start_item(req);
        	assert(req.randomize with {HWRITE == WRITE;
      			   	   	   HBURST == BURST_OP;
					   HSIZE == SIZE;});
        ADDR_L = req.HADDR;
          `uvm_info("SEQ", "Sequence Items", UVM_NONE);
	req.print();
      finish_item(req);

      for (int i = 0; i < NO_OF_TRANS; i++) begin
      req = ahb_seq_item #(ADDR_WIDTH, DATA_WIDTH)::type_id::create("req");
      start_item(req);
        	assert(req.randomize with {HWRITE == WRITE; HADDR == ADDR_L;
      			   	   	   HBURST == BURST_OP;
					   HSIZE == SIZE;});
          `uvm_info("SEQ", "Sequence Items", UVM_NONE);
	req.print();
      finish_item(req);
      end
    endtask
endclass

                                              ////Multiple reads on preload memory

class ahb_rd extends ahb_m_sequence;
    `uvm_object_utils(ahb_rd)
     
    function new(string name = "ahb_rd");
      super.new(name);
    endfunction
 
    task body();
      `uvm_info("SEQ", "inside body", UVM_LOW);
      for (int i = 0; i<NO_OF_TRANS; i++) begin
       // `uvm_info("SEQ", $sformatf("inside body I = %0d", i), UVM_LOW);
      req = ahb_seq_item #(ADDR_WIDTH, DATA_WIDTH)::type_id::create("req");
      start_item(req);
        assert(req.randomize with {HWRITE == 1'b0; HADDR inside {[0:1023]};
				   HBURST == 0;
                                   HSIZE == SIZE;});  /////randomize the sequence items and send it to the driver
          `uvm_info("SEQ", "Sequence Items", UVM_NONE);
          req.print();
                                   
      finish_item(req); 
      end
    endtask
endclass

// 
// 							//////Multiple WRITEs or reads//////////
// 
class ahb_wr extends ahb_m_sequence;
    `uvm_object_utils(ahb_wr)
     
    function new(string name = "ahb_wr");
      super.new(name);
    endfunction
 
    task body();
      `uvm_info("SEQ", $sformatf( "inside body NO_OF_TRANS: %d",NO_OF_TRANS), UVM_NONE);
      for (int i = 0; i<NO_OF_TRANS; i++) begin
       // `uvm_info("SEQ", $sformatf("inside body I = %0d", i), UVM_NONE);
      req = ahb_seq_item#(ADDR_WIDTH, DATA_WIDTH)::type_id::create("req");
      start_item(req);
  //     assert(req.randomize());
         assert(req.randomize with {HWRITE == WRITE;
				    HBURST ==BURST_OP;
                                    HSIZE == SIZE;});  /////randomize the sequence items and send it to the driver
          `uvm_info("SEQ", "Sequence Items", UVM_NONE);
          req.print();
      finish_item(req); 
      end
    endtask
endclass
// 
//                                                           ////////Wr -> Rd Burst////////////////////
// 
class ahb_burst_wr_rd extends ahb_m_sequence;
    `uvm_object_utils(ahb_burst_wr_rd)

    function new(string name = "ahb_burst_wr_rd");
      super.new(name);
    endfunction
 
    task body();
      `uvm_info("SEQ", "inside body", UVM_NONE);
      req = ahb_seq_item #(ADDR_WIDTH, DATA_WIDTH)::type_id::create("req");
      start_item(req);
        	assert(req.randomize with {HWRITE == 1'b1;
      			   	   	   HBURST ==BURST_OP;
					   HSIZE == SIZE;});
	ADDR_L = req.HADDR;
          `uvm_info("SEQ", "Sequence Items", UVM_NONE);
	req.print();
      finish_item(req);
      

      req = ahb_seq_item #(ADDR_WIDTH, DATA_WIDTH)::type_id::create("req");
      start_item(req);
        	assert(req.randomize with {HWRITE == 1'b0; HADDR == ADDR_L;
      			   	   	   HBURST ==BURST_OP;
					   HSIZE == SIZE;});
          `uvm_info("SEQ", "Sequence Items", UVM_NONE);
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
      `uvm_info("SEQ", "inside body", UVM_NONE);
      req = ahb_seq_item #(ADDR_WIDTH, DATA_WIDTH)::type_id::create("req");
      start_item(req);
        	assert(req.randomize with {HWRITE == WRITE;
      			   	   	   HBURST ==BURST_OP;
					   HSIZE == SIZE;});
          `uvm_info("SEQ", "Sequence Items", UVM_NONE);
	req.print();
      finish_item(req);
    endtask
endclass

                                                      //////////RandomizedBURST_OP////////////

class ahb_random_burst extends ahb_m_sequence ;
    `uvm_object_utils(ahb_random_burst)

    function new(string name = "ahb_random_burst");
      super.new(name);
    endfunction
 
    task body();
      `uvm_info("SEQ", "inside body", UVM_NONE);
      req = ahb_seq_item#(ADDR_WIDTH, DATA_WIDTH)::type_id::create("req");
      repeat(NO_OF_TRANS) begin
      start_item(req);
        	assert(req.randomize);
          `uvm_info("SEQ", "Sequence Items", UVM_NONE);
	req.print();
      finish_item(req);
      end
    endtask
endclass
                                                       ////////Wr->Rd different SIZE

class ahb_wr_rd_diff_size extends ahb_m_sequence ;
    `uvm_object_utils(ahb_wr_rd_diff_size)

    function new(string name = "ahb_wr_rd_diff_size");
      super.new(name);
    endfunction
 
    task body();
      `uvm_info("SEQ", "inside body", UVM_NONE);
      req = ahb_seq_item #(ADDR_WIDTH, DATA_WIDTH)::type_id::create("req");
      start_item(req);
        	assert(req.randomize with {HWRITE == 1'b1;
      			   	   	   HBURST ==BURST_OP;
					   HSIZE == BIT_32;});
        ADDR_L = req.HADDR;
          `uvm_info("SEQ", "Sequence Items", UVM_NONE);
	req.print();
      finish_item(req);

      req = ahb_seq_item #(ADDR_WIDTH, DATA_WIDTH)::type_id::create("req");
      start_item(req);
        	assert(req.randomize with {HWRITE == 1'b0; HADDR == ADDR_L;
      			   	   	   HBURST ==BURST_OP;
					   HSIZE == SIZE;});
          `uvm_info("SEQ", "Sequence Items", UVM_NONE);
	req.print();
      finish_item(req);
    endtask
endclass


                                                       ////////Wr->Rd same SIZE

class ahb_wr_rd_same_size extends ahb_m_sequence ;
    `uvm_object_utils(ahb_wr_rd_same_size)

    bit[ADDR_WIDTH-1 :0] ADDR_L;

    function new(string name = "ahb_wr_rd_same_size");
      super.new(name);
    endfunction
 
    task body();
      `uvm_info("SEQ", "inside body", UVM_NONE);
      req = ahb_seq_item #(ADDR_WIDTH, DATA_WIDTH)::type_id::create("req");
      start_item(req);
        	assert(req.randomize with {HWRITE == 1'b1;
      			   	   	   HBURST == 0;
					   HSIZE == BIT_32;});
        ADDR_L = req.HADDR;
          `uvm_info("SEQ", "Sequence Items", UVM_NONE);
	req.print();
      finish_item(req);

      req = ahb_seq_item #(ADDR_WIDTH, DATA_WIDTH)::type_id::create("req");
      start_item(req);
        	assert(req.randomize with {HWRITE == 1'b0; HADDR == ADDR_L;
      			   	   	   HBURST == 0;
					   HSIZE == BIT_32;});
          `uvm_info("SEQ", "Sequence Items", UVM_NONE);
	req.print();
      finish_item(req);
    endtask
endclass

                                                      /////1KB Address Boundary cross 
                                                        //burst 16 and SIZE 1024

class ahb_addr_boundary extends ahb_m_sequence;
    `uvm_object_utils(ahb_addr_boundary)

    function new(string name = "ahb_addr_boundary");
      super.new(name);
    endfunction
 
    task body();
      `uvm_info("SEQ", "inside body", UVM_NONE);
      req = ahb_seq_item #(ADDR_WIDTH, DATA_WIDTH)::type_id::create("req");
      start_item(req);
             
        	if (!(req.randomize with {HWRITE == 1'b1;
      			   	   	   HBURST ==BURST_OP;
					   HSIZE == SIZE;})) begin
                `uvm_fatal("RND_FAIL", "Inline function randomization failed!")
                end
          `uvm_info("SEQ", "Sequence Items", UVM_NONE);
	req.print();
      finish_item(req);
      //end
    endtask
endclass

class ahb_boundary extends ahb_m_sequence;
    `uvm_object_utils(ahb_boundary)
    
    function new(string name = "ahb_boundary");
      super.new(name);
    endfunction

    task body();
      `uvm_info("SEQ", "Inside Body", UVM_NONE);
      req = ahb_seq_item#(ADDR_WIDTH, DATA_WIDTH)::type_id::create("req");
      start_item(req);
         	assert(req.randomize with {HWRITE == WRITE;
      			   	   	   HBURST == 0;
					   HSIZE == 2;});
        ADDR_L = req.HADDR;
          `uvm_info("SEQ", "Sequence Items", UVM_NONE);
	req.print();
      finish_item(req);

      for (int i = 0; i < NO_OF_TRANS; i++) begin
      req = ahb_seq_item#(ADDR_WIDTH, DATA_WIDTH)::type_id::create("req");
      start_item(req);
        	if (!(req.randomize with {HWRITE == 1'b1; HADDR == ADDR_L + i;
      			   	   	   HBURST ==BURST_OP;
					   HSIZE == SIZE;})) begin
                `uvm_fatal("RND_FAIL", "Inline function randomization failed!")
                end
          `uvm_info("SEQ", "Sequence Items", UVM_NONE);
	req.print();
      finish_item(req);
      end
    endtask
endclass
               


//class ahb_incr_burst extends ahb_m_sequence;
//  ahb_seq_item req;
//  `uvm_object_utils(ahb_incr_burst)
//
//  bit[ADDR_WIDTH-1 :0] ADDR_L;
//
//  function new(string name = "ahb_incr_burst");
//    super.new(name);
//  endfunction
//
//  task body();
//    `uvm_info("SEQ", "inside body", UVM_NONE);
//    for (int i = 0; i<8; i++) begin
//      `uvm_info("SEQ", $sformatf("inside body I = %0d", i), UVM_NONE);
//    req = ahb_seq_item::type_id::create("req");
//    start_item(req);
//	if(i%2 == 0)begin
//		if(i == 0) begin
//			assert(req.randomize with {HWRITE == 1'b1;
//						   HTRANS inside {NON"SEQ"};});  /////randomize the sequence items and send it to the driver
//          		ADDR_L = req.HADDR;
//          		req.print();
//          	end
//          	else begin
//              		assert(req.randomize with {HWRITE == 1'b1;
//						   HTRANS inside {"SEQ"};});
//			ADDR_L = req.HADDR;
//              		req.print();
//            	end
//        end
//        else begin
//            assert(req.randomize with {HWRITE == 1'b0; HADDR == ADDR_L;
//                                       HTRANS inside {"SEQ"};});  /////randomize the sequence items and send it to the driver
//            req.print();
//	end
//      finish_item(req); 
//    end
//  endtask
//endclass
