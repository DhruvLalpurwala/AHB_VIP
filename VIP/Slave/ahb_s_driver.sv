  ////File Name: ahb_s_driver.sv
  ////Author Name: Dhruv Lalpurwala
  ////Propetier Name: ASICraft Technologies LLP
  ////Description: This Slave driver same the address, control signals and data and store it in memory
  //// at the time of read it drives the read data, readyout and response signal 
  /////////////////////////////////////////////////////

`define DRIVE_IF_S vif.ahb_s_driver_cb  //define clocking block

class ahb_s_driver #(int ADDR_WIDTH = 32, int DATA_WIDTH = 32) extends uvm_driver#(ahb_seq_item #(ADDR_WIDTH, DATA_WIDTH));
  `uvm_component_utils(ahb_s_driver #(ADDR_WIDTH, DATA_WIDTH))
  
  virtual ahb_if vif;    //interface handle
  semaphore done = new(0);//semaphore for handling the pipeline
  
  logic [7:0] mem [bit[ADDR_WIDTH-1:0]];  //Memory to store the data at address
  bit [ADDR_WIDTH-1:0] addr_q [$];     //Address queue for sync the data and address
  bit [ADDR_WIDTH-1:0] current_addr;   //current address
  int bytes;                          
  bit [7:0] temp_fixed_mem [1024];

  function new(string name = "ahb_s_driver", uvm_component parent = null);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);

    super.build_phase(phase);
    ///Get the interface
    if(!uvm_config_db#(virtual ahb_if)::get(this, "*", "vif", vif))   //Get the interface through config db
      `uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".vif"});

    $readmemh("memory_data.txt", temp_fixed_mem);
                      //`uvm_info("Slave Driver Mem Read", $sformatf("mem = %0p", temp_fixed_mem), UVM_NONE);

    foreach (temp_fixed_mem[i]) begin
      mem[i] = temp_fixed_mem[i];
    end

  endfunction

  task run_phase(uvm_phase phase);    
    init();     //task performs the initialization of signals
    wait_for_reset(); //task performs wait for reset until 1
    fork
       address_phase(); //task to drive address and control signals
       data_phase();    //task to drive the wdata signal
    join
    
  endtask

  task address_phase();
    forever begin
      if(!vif.HRESETn) begin    //Reset = 0
        `DRIVE_IF_S.HREADYOUT <= 1;
	`DRIVE_IF_S.HRESP <= 0;
      end
      else begin
        @(`DRIVE_IF_S);  //change in clocking block
        if (`DRIVE_IF_S.HTRANS == NONSEQ || `DRIVE_IF_S.HTRANS == SEQ) begin   //if Transfer type is nonseq and seq
          addr_q.push_back(`DRIVE_IF_S.HADDR);   //the address get from interface pushed in addr queue
          `uvm_info(get_type_name, $sformatf( "[Slave Driver +edge] Address = %0h, write = %0b", `DRIVE_IF_S.HADDR,  `DRIVE_IF_S.HWRITE), UVM_NONE);
          `DRIVE_IF_S.HREADYOUT <= 1'b1;        //HReadyout is 1
           //repeat(1) begin
           //   @(`DRIVE_IF_S);
           //   `DRIVE_IF_S.HREADYOUT <= 1'b0;
           //end
          done.put(1);   //Once signal drives at interface, semphone put a key so that driver get the key and this two phase work as pipeline    

        end
        else begin
          `DRIVE_IF_S.HRESP <= 1'b0;   //Response is okay
        end
      end
    end
  endtask
  
  task data_phase();
    forever begin
      done.get(1);       //once get the key it start the data phase for driving the HWDATA 

      if(!vif.HRESETn) begin     //Reset = 0
        `DRIVE_IF_S.HRDATA <= 0; 
      end
      else begin

            if (`DRIVE_IF_S.HWRITE && addr_q.size() > 0) begin    //Write = 1 and address queue > 0
               bytes = 1 << `DRIVE_IF_S.HSIZE;     //bytes for storing the data in little endian form acc. to Hsize 
               @(`DRIVE_IF_S);    //change in clocking block
               current_addr = addr_q.pop_front();  //pop the address from queue and assign to current address for sync with data
               for (int i = 0; i < bytes; i++) begin   //loop for storing the data acc. to HSIZE 
                      mem[current_addr + i] =  `DRIVE_IF_S.HWDATA[8*i +: 8]; //logic for storing data in little endian
                      `uvm_info("Slave Driver Mem", $sformatf( "mem[%0h + %0d] = %h", current_addr, i, `DRIVE_IF_S.HWDATA[8*i +:8]), UVM_NONE);
               end
            end
            else if (!`DRIVE_IF_S.HWRITE && addr_q.size() > 0) begin  //if write = 0 and address queue > 0
               while(!vif.HREADYOUT) begin //Hreadyout is 0 -> insert the wait cycles
                   @(`DRIVE_IF_S);
               end
               bytes = 1 << `DRIVE_IF_S.HSIZE;  //retrieve the data from memory according to HSIZE
               `uvm_info(get_type_name, $sformatf( "Bytes = %0d", bytes), UVM_NONE);
               current_addr = addr_q.pop_front(); //pop the address from queue and assign to current address
               for (int i = 0; i < bytes; i++) begin //loop for retrieving the data acc. to hsize
       	              `DRIVE_IF_S.HRDATA[8*i +: 8] <= mem[current_addr + i]; //logic for retrieving in little endian
                      //#0;
                      //`uvm_info("Slave Driver Mem", $sformatf( "mem[%0h + %0d] = %h | Memory = %0h", current_addr, i, vif.HRDATA, mem[current_addr+i]), UVM_NONE);
               end
                      //`uvm_info("Slave Driver Mem Read", $sformatf("mem = %0p", mem), UVM_NONE);
            end
      end
    end
  endtask
  
  task wait_for_reset();
    wait(vif.HRESETn);    //wait for reset = 1
  endtask
  
  task init(); //initialize the signals
    wait(vif.HRESETn == 0);
    `DRIVE_IF_S.HREADYOUT <= 1;
    `DRIVE_IF_S.HRDATA <= 0; 
    `DRIVE_IF_S.HRESP <= 0;
  endtask
  
endclass
