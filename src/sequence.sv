class sequences  extends uvm_sequence#(write_xtn);
`uvm_object_utils(sequences)

function new(string name = "sequences");
super.new(name);
endfunction:new

virtual task body();
write_xtn req;
repeat(16)
begin
req=write_xtn::type_id::create("req");
start_item(req);
assert(req.randomize() with {req.wr_en==1;req.rd_en==0;})
finish_item(req);
end 
#100;
repeat(16)
begin
req=write_xtn::type_id::create("req");
start_item(req);
assert(req.randomize() with {req.wr_en==0;req.rd_en==1;})
finish_item(req);
end

endtask:body

endclass






//

class full_sequence  extends sequences ;


`uvm_object_utils(full_sequence)

write_xtn req;

function new (string name ="full_sequence");
super.new(name);
endfunction:new 


task body();


repeat(4)
begin
req=write_xtn::type_id::create("req");
start_item(req);
assert(req.randomize() with {req.wr_en==1;req.rd_en==0;})
finish_item(req);
end
repeat(8)
begin
req=write_xtn::type_id::create("req");
start_item(req);
assert(req.randomize() with {req.wr_en==1;req.rd_en==0;})
finish_item(req);
end
endtask 
endclass:full_sequence


class fullinout_seq extends sequences;

`uvm_object_utils(fullinout_seq)

write_xtn req;

function new (string name = "fullinout_seq");
super.new(name);
endfunction

task body();

// req=write_xtn::type_id::create("req");

repeat(3)
begin
req=write_xtn::type_id::create("req_bronze");
start_item(req);
assert(req.randomize() with {wr_en==1 ; rd_en==0; data_in inside  {[0:50]};});
finish_item(req);
end

repeat(3)
begin
req=write_xtn::type_id::create("req_si;ver");
start_item(req);
assert(req.randomize() with {wr_en==1; rd_en==0; data_in inside {[51:101]};});
finish_item(req);
end

repeat(3)
begin
req=write_xtn::type_id::create("req_gold");
start_item(req);
assert(req.randomize() with {wr_en==1 ; rd_en ==0 ; data_in inside {[102:152]};});
finish_item(req);
end

repeat(3)
begin
req=write_xtn::type_id::create("req_platinum");
start_item(req);
assert(req.randomize() with {wr_en ==1 ; rd_en ==0 ; data_in inside {[153:203]};});
finish_item(req);
end

repeat(3)
begin
req=write_xtn::type_id::create("req_diamond");
start_item(req);
assert(req.randomize() with {wr_en ==1; rd_en ==0; data_in inside  {[204:255]};});
finish_item(req);
end

//read

repeat(15)
begin
req=write_xtn::type_id::create("req_read");
start_item(req);
assert(req.randomize() with {wr_en == 0 ; rd_en ==1;})
finish_item(req);
end

endtask 
endclass : fullinout_seq

class stable_data_out extends sequences;

`uvm_object_utils(stable_data_out)

write_xtn req;

function new (string name  = "stable_data_out");
super.new(name);
endfunction:new 

task body();

repeat(4)
begin
req=write_xtn::type_id::create("stable_req");
start_item(req);
assert(req.randomize() with {wr_en==1 ; rd_en==0;})
finish_item(req);
end

#100;
endtask
endclass
