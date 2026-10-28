  ////File Name: ahb_seq_item.sv
  ////Author Name: Dhruv Lalpurwala
  ////Propetier Name: ASICraft Technologies LLP
  ////Description: This sequence item holds the signals  
  //// of AHB Protocol required to drive stimulus
  /////////////////////////////////////////////////////

typedef enum bit [2:0] {SINGLE, INCR, WRAP4, INCR4, WRAP8, INCR8, WRAP16, INCR16} burst_operation; //burst operations
typedef enum bit [2:0] {BIT_8, BIT_16, BIT_32, BIT_64, BIT_128, BIT_256, BIT_512, BIT_1024} transfer_size; //transfer size
typedef enum bit [1:0] {IDLE, BUSY, NONSEQ, SEQ} transfer_type; //transfer type

class ahb_seq_item #(int ADDR_WIDTH = 32, int DATA_WIDTH = 32) extends uvm_sequence_item;
  
  ////random items
  rand bit [(ADDR_WIDTH-1):0] HADDR;      ////Address -> ADDRESS_WIDTH-1:0
  rand bit [(DATA_WIDTH-1):0] HWDATA[$];  ////WData -> DATA_WIDTH-1:0, Queue for generating multiple data on single randomization
  rand bit HWRITE;                        ////Write operation -> "1" for write and "0" for read
  rand burst_operation HBURST;            ////Burst signal for select burst operation
  rand transfer_size HSIZE;               ////Size signal for select transfer size
  rand transfer_type HTRANS;              ////Trans signal for select transfer type
  rand bit [(DATA_WIDTH/8)-1:0] HWSTRB;   ////Write Strobe -> (DATA_WIDTH/8)-1:0
  rand int burst_length;                  ////burst length used to select the length according to burst operation

  bit [DATA_WIDTH-1:0] HRDATA;            ////Read data stored from slave
  bit HREADYOUT;                          ////Ready signal for inserting the wait states send by slave
  bit HRESP;                              ////Response signal -> "0" for okay and "1" for error send by slave
    
  `uvm_object_param_utils(ahb_seq_item #(ADDR_WIDTH, DATA_WIDTH)) ///register ahb_seq_item at factory
  
  function new(string name = "ahb_seq_item");
    super.new(name);
  endfunction
 
  //Function do_print method 
  //Print method is added to display the data members values
  //Parameter: printer - uvm_printer 
 
  function void do_print(uvm_printer printer); 
    super.do_print(printer);
    printer.print_field_int("HADDR", HADDR, $bits(HADDR), UVM_HEX);
    printer.print_field_int("HWRITE", HWRITE, $bits(HWRITE), UVM_HEX);
    printer.print_field_int("HBURST", HBURST, $bits(HBURST), UVM_HEX);
    printer.print_field_int("HTRANS", HTRANS, $bits(HTRANS), UVM_HEX);

    printer.print_field_int("HSIZE", HSIZE, $bits(HSIZE), UVM_HEX);
    printer.print_field_int("burst_length", burst_length, $bits(burst_length), UVM_HEX);
    printer.print_field_int("HRDATA", HRDATA, $bits(HRDATA), UVM_HEX);
    printer.print_field_int("HREADYOUT", HREADYOUT, $bits(HREADYOUT), UVM_HEX);

    foreach (HWDATA[i]) begin
      printer.print_field_int(
        .name($sformatf("HWDATA[%0d]", i)), 
        .value(HWDATA[i]),                  
        .size($bits(HWDATA[i])),            
        .radix(UVM_HEX)                       
      );
    end

  endfunction
  
  ///////////////////////////Constraints/////////////////////////////
     
  constraint data_size {HWDATA.size() inside {[1:64]};}    //WData queue size is inside [1:64]

  //constraint size_datawidth {HSIZE inside {BIT_8, BIT_16, BIT_32};} // Size <= Data_width of Wdata
  
  //// Aligned address boundary according to transfer size
  constraint size_aligned_add_boundary {HSIZE == BIT_16 -> HADDR[0] == 0;         
                    			HSIZE == BIT_32 -> HADDR[1:0] == 2'b0;
                   			HSIZE == BIT_64 -> HADDR[2:0] == 3'b0;
                   			HSIZE == BIT_128 -> HADDR[3:0] == 4'b0;
                   			HSIZE == BIT_256 -> HADDR[4:0] == 5'b0;
                   			HSIZE == BIT_512 -> HADDR[5:0] == 6'b0;
                   			HSIZE == BIT_1024 -> HADDR[6:0] == 7'b0;}
  
  //// Burst length and size of wdata queue depend on the burst operation 
  constraint burst_beat {HBURST == SINGLE -> {burst_length == 1; HWDATA.size() == 1;}
			 HBURST == INCR -> HWDATA.size() == burst_length;
			 (HBURST == INCR4) || (HBURST == WRAP4) -> {burst_length == 4; HWDATA.size() == 4;}
                         (HBURST == INCR8) || (HBURST == WRAP8) -> {burst_length == 8; HWDATA.size() == 8;}
                         (HBURST == INCR16) || (HBURST == WRAP16) -> {burst_length == 16; HWDATA.size() == 16;}}

  //// Address should be in 1kb boundary for burst operation
  constraint ahb_1kb_boundary {soft HADDR/1024 == ((HADDR + (burst_length * (1 << HSIZE)) - 1) / 1024);}

endclass 
