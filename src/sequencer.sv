class sequencer extends uvm_sequencer#(write_xtn);
  
  `uvm_component_utils(sequencer)
  
  function new (string name="sequencer", uvm_component parent);
    super.new(name,parent);
  endfunction:new
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction:build_phase
  
endclass:sequencer

