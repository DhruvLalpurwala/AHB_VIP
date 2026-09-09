typedef enum bit [2:0] {SINGLE, INCR, WRAP4, INCR4, WRAP8, INCR8, WRAP16, INCR16} burst_operation;
typedef enum bit [2:0] {BIT_8, BIT_16, BIT_32, BIT_64, BIT_128, BIT_256, BIT_512, BIT_1024} transfer_size;
typedef enum bit [1:0] {IDLE, BUSY, NONSEQ, SEQ} transfer_type;

class ahb_seq_item extends uvm_sequence_item;
  
  ////random items
  rand bit [31:0] HADDR;      ////ADDRESS_WIDTH-1:0
  rand bit [31:0] HWDATA;     ////DATA_WIDTH-1:0
  rand bit HWRITE;
  rand burst_operation HBURST;
  rand transfer_size HSIZE;
  rand transfer_type HTRANS;
  rand bit [3:0] HWSTRB;      ////(DATA_WIDTH/8)-1:0
  
  bit [31:0] HRDATA;
  bit HREADYOUT;
  bit HRESP;
  
  int burst_length;
  
  `uvm_object_utils(ahb_seq_item)

//   `uvm_object_utils_begin(ahb_seq_item)
//   ///field macros
//   `uvm_field_int(HWDATA, UVM_DEFAULT)
//   `uvm_field_int(HADDR, UVM_DEFAULT)
//   `uvm_field_int(HWRITE, UVM_DEFAULT)
//   `uvm_object_utils_end
  
  function new(string name = "ahb_seq_item");
    super.new(name);
  endfunction
  
  function void do_print(uvm_printer printer);
    super.do_print(printer);
    printer.print_field_int("HADDR", HADDR, $bits(HADDR), UVM_HEX);
    printer.print_field_int("HWDATA", HWDATA, $bits(HWDATA), UVM_HEX);
    printer.print_field_int("HWRITE", HWRITE, $bits(HWRITE), UVM_HEX);
    printer.print_field_int("HRDATA", HWRITE, $bits(HRDATA), UVM_HEX);
    printer.print_field_int("HREADYOUT", HWRITE, $bits(HREADYOUT), UVM_HEX);
  endfunction
  
  ////Constraints
  //constraint data {HWDATA inside {[10:20]};}
  
//   constraint size{HSIZE == BIT_8 -> HWSTRB == 4'h0;
//                   HSIZE == BIT_16 -> HWSTRB == 4'h1;
//                   HSIZE == BIT_32 -> HWSTRB == 4'h2;
//                  }
//   constraint transfer_type {HTRANS dist {IDLE:=10, BUSY:=10, NONSEQ:=20, SEQ:=60};
                           
  
  constraint transfer_type2 { HTRANS == IDLE -> 
                               HADDR == 32'h0;
//                             	HWDATA == 32'h0;
                            }
  
  constraint size_datawidth {HSIZE inside {BIT_8, BIT_16, BIT_32};}
  
//   constraint size {HSIZE == BIT_8 -> HADDR[0] == 0;
//                    HSIZE == BIT_16 -> HADDR[1:0] == 2'b0;
//                    HSIZE == BIT_32 -> HADDR[2:0] == 3'b0;
//                    HSIZE == BIT_64 -> HADDR[3:0] == 4'b0;
//                    HSIZE == BIT_128 -> HADDR[4:0] == 5'b0;
//                    HSIZE == BIT_256 -> HADDR[5:0] == 6'b0;
//                    HSIZE == BIT_512 -> HADDR[6:0] == 7'b0;}
  
  constraint burst{HBURST == SINGLE -> HTRANS == NONSEQ;
                   HBURST inside {SINGLE, INCR};}
  
//   constraint burst_beat { HBURST == INCR -> burst_length == 1;
//                           HBURST == INCR4 -> burst_length == 4;
//                           HBURST == INCR8 -> burst_length == 8;
//                           HBURST == INCR16 -> burst_length == 16;}
  
  
  
//   function post_randomize();
//     static bit[31:0] ADDR_L;
//     if (HWRITE == 1'b1) begin
//       ADDR_L = HADDR;
//     end
//     else begin
//       HADDR = ADDR_L;
//     end
//     `uvm_info(get_type_name, $sformatf(" HADDR = %0h, Address = %0h, Write = %0b", HADDR, ADDR_L, HWRITE), UVM_NONE);
//   endfunction

endclass 
