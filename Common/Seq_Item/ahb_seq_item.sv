typedef enum bit [2:0] {SINGLE, INCR, WRAP4, INCR4, WRAP8, INCR8, WRAP16, INCR16} burst_operation;
typedef enum bit [2:0] {BIT_8, BIT_16, BIT_32, BIT_64, BIT_128, BIT_256, BIT_512, BIT_1024} transfer_size;
typedef enum bit [1:0] {IDLE, BUSY, NONSEQ, SEQ} transfer_type;

class ahb_seq_item #(int ADDR_WIDTH = 32, int DATA_WIDTH = 32) extends uvm_sequence_item;
  
  ////random items
  rand bit [(ADDR_WIDTH-1):0] HADDR;      ////ADDRESS_WIDTH-1:0
  rand bit [(DATA_WIDTH-1):0] HWDATA[];     ////DATA_WIDTH-1:0
  rand bit HWRITE;
  rand burst_operation HBURST;
  rand transfer_size HSIZE;
  rand transfer_type HTRANS;
  rand bit [(DATA_WIDTH/8)-1:0] HWSTRB;      ////(DATA_WIDTH/8)-1:0
  rand int burst_length;

  rand bit [3:0] number_of_wait_states;

  bit [DATA_WIDTH-1:0] HRDATA;
  bit HREADYOUT;
  bit HRESP;
    
  `uvm_object_param_utils(ahb_seq_item #(ADDR_WIDTH, DATA_WIDTH))
  
  function new(string name = "ahb_seq_item");
    super.new(name);
  endfunction
  
  function void do_print(uvm_printer printer);
    super.do_print(printer);
    printer.print_field_int("HADDR", HADDR, $bits(HADDR), UVM_HEX);
    printer.print_field_int("HWRITE", HWRITE, $bits(HWRITE), UVM_HEX);
    printer.print_field_int("HBURST", HBURST, $bits(HBURST), UVM_HEX);
    printer.print_field_int("HTRANS", HTRANS, $bits(HTRANS), UVM_HEX);

    printer.print_field_int("HSIZE", HSIZE, $bits(HSIZE), UVM_HEX);
    printer.print_field_int("burst_length", burst_length, $bits(burst_length), UVM_HEX);
    printer.print_field_int("HRDATA", HRDATA, $bits(HRDATA), UVM_HEX);
//    printer.print_field_int("HREADYOUT", HREADYOUT, $bits(HREADYOUT), UVM_HEX);

    foreach (HWDATA[i]) begin
      printer.print_field_int(
        .name($sformatf("HWDATA[%0d]", i)), 
        .value(HWDATA[i]),                  
        .size($bits(HWDATA[i])),            
        .radix(UVM_HEX)                       
      );
    end

//    foreach (HRDATA[i]) begin
//      printer.print_field_int(
//        .name($sformatf("HRDATA[%0d]", i)), 
//        .value(HRDATA[i]),                  
//        .size($bits(HRDATA[i])),            
//        .radix(UVM_HEX)                       
//      );
//    end


  endfunction
  
  ////Constraints
  
//   constraint size{HSIZE == BIT_8 -> HWSTRB == 4'h0;
//                   HSIZE == BIT_16 -> HWSTRB == 4'h1;
//                   HSIZE == BIT_32 -> HWSTRB == 4'h2;
//                  }
//   constraint transfer_type {HTRANS dist {IDLE:=10, BUSY:=10, NONSEQ:=20, SEQ:=60};
                           
  constraint address {HADDR inside {[0:1023]};}

  constraint data_size {HWDATA.size() inside {[1:64]};}

  constraint size_datawidth {HSIZE inside {BIT_8, BIT_16, BIT_32};}
  
   constraint size_aligned_add_boundary {HSIZE == BIT_16 -> HADDR[0] == 0;
                    			 HSIZE == BIT_32 -> HADDR[1:0] == 2'b0;
                   			 HSIZE == BIT_64 -> HADDR[2:0] == 3'b0;
                   			 HSIZE == BIT_128 -> HADDR[3:0] == 4'b0;
                   			 HSIZE == BIT_256 -> HADDR[4:0] == 5'b0;
                   			 HSIZE == BIT_512 -> HADDR[5:0] == 6'b0;
                   			 HSIZE == BIT_1024 -> HADDR[6:0] == 7'b0;}
  
  //constraint burst{HBURST inside {SINGLE, INCR, INCR4, INCR8, INCR16};}
  
  constraint burst_beat {HBURST == SINGLE -> {burst_length == 1; HWDATA.size() == 1;}
			 HBURST == INCR -> HWDATA.size() == burst_length;
			 (HBURST == INCR4) || (HBURST == WRAP4) -> {burst_length == 4; HWDATA.size() == 4;}
                         (HBURST == INCR8) || (HBURST == WRAP8) -> {burst_length == 8; HWDATA.size() == 8;}
                         (HBURST == INCR16) || (HBURST == WRAP16) -> {burst_length == 16; HWDATA.size() == 16;}}

endclass 
