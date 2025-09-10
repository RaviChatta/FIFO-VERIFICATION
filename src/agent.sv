class agent extends uvm_agent;
  `uvm_component_utils(agent)
  
  monitor monh;
  driver drvh;
  sequencer seqh;
  
  function new(string name="agent", uvm_component parent=null);
    super.new(name,parent);
  endfunction:new
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    monh=monitor::type_id::create("monh",this);
    drvh=driver::type_id::create("drvh",this);
    seqh=sequencer::type_id::create("seqh",this);
    
  endfunction:build_phase
function void connect_phase(uvm_phase phase);
super.connect_phase(phase);
drvh.seq_item_port.connect(seqh.seq_item_export);
endfunction
  
endclass:agent
  
  
