bit [31:0] addr_q [$];
bit [31:0] current_addr;
int count;

current_addr = req.addr

if (req.HBURST == SINGLE) begin
	`DRIVE_IF_M.HBURST <= req.HURST;
	`DRIVE_IF_M.HTRANS <= NONSEQ;
	`DRIVE_IF_M.HWRITE <= req.HWRITE;
        `DRIVE_IF_M.HADDR <= req.HADDR;
	`DRIVE_IF_M.HSIZE <= req.HSIZE;
end
else if (req.HBURST == INCR) begin
current_addr = req.HADDR;
	for(i=0; i<10; i++) begin
	   if(i == 0) begin
	   	`DRIVE_IF_M.HTRANS <= NONSEQ;
	   end
	   else begin
		`DRIVE_IF_M.HTRANS <= SEQ;
	   end	
	   `DRIVE_IF_M.HBURST <= req.HBURST;
	   `DRIVE_IF_M.HSIZE <= req.HSIZE;
	   `DRIVE_IF_M.HADDR <= current_addr;
	   `DRIVE_IF_M.HWRITE <= req.HWRITE;
	   
	   current_addr = current_addr + (1 << HSIZE);
	end
end





