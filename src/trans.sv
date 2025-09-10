class write_xtn extends uvm_sequence_item; 


rand bit wr_en,rd_en;
bit rst;
rand bit [7:0]data_in;
bit [7:0]data_out;

bit full,empty;

constraint x {if (wr_en)data_in inside {[0:255]};}
function new (string name="write_xtn");
super.new(name);
endfunction:new

`uvm_object_utils_begin(write_xtn)
  `uvm_field_int(data_in, UVM_ALL_ON)
  `uvm_field_int(wr_en, UVM_ALL_ON)
  `uvm_field_int(rd_en, UVM_ALL_ON)
  `uvm_field_int(full, UVM_ALL_ON)
  `uvm_field_int(empty, UVM_ALL_ON)
  `uvm_field_int(data_out, UVM_ALL_ON)
  `uvm_object_utils_end

  function string convert2string();
    return $sformatf("data_in=%0d wr_en=%0b rd_en=%0b full=%0d empty=%0d data_out=%0d",
                     data_in, wr_en, rd_en, full, empty, data_out);
  endfunction


endclass



 
