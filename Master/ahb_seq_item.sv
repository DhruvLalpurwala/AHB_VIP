typedef enum bit [2:0] {SINGLE, INCR, WRAP4, INCR4, WRAP8, INCR8, WRAP16, INCR16} burst_operation;
typedef enum bit [2:0] {BIT_8, BIT_16, BIT_32, BIT_64, BIT_128, BIT_256, BIT_512, BIT_1024} transfer_size;
typedef enum bit [1:0] {IDLE, BUSY, NONSEQ, SEQ} transfer_type;

class ahb_seq_item extends uvm_sequence_item;
  
  ////random items
  rand bit [31:0] HADDR;                                                                   
  rand bit [31:0] HWDATA;
  rand bit HWRITE;
  rand burst_operation HBURST;
  rand transfer_size HSIZE;
  rand transfer_type HTRANS;
  
  bit [31:0] HRDATA;
  bit HREADYOUT;
  bit HRESP;
  
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
  //constraint address {HADDR inside {[10:20]};}
  //constraint data {HWDATA inside {[10:20]};}
  
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
