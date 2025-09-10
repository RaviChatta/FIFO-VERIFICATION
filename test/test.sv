class test extends uvm_test;

`uvm_component_utils(test)

env envh;
scoreboard sb;
agent agt;
sequences seqsh;
sequencer seqrh;
function new(string name = "test" , uvm_component parent=null);
super.new(name,parent);
endfunction:new
    
function void build_phase(uvm_phase phase);
super.build_phase(phase);
      
envh=env::type_id::create("envh",this);
                
endfunction:build_phase
    
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    

    
    seqsh = sequences::type_id::create("seqsh");
    seqsh.start(envh.agt.seqh);
    
    // Wait for sequence to complete
   // wait(envh.agt.seqh.num_reqs == 32);
    
    phase.drop_objection(this);
  endtask

  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology;
  endfunction:end_of_elaboration_phase


endclass:test
        


//



class full_test extends test;

`uvm_component_utils(full_test)

write_xtn req;

function new (string name = "full_test" , uvm_component parent=null);
super.new(name,parent);
endfunction:new 



task run_phase(uvm_phase phase);

full_sequence req;

phase.raise_objection(this);
req=full_sequence::type_id::create("req");
req.start(envh.agt.seqh);

phase.drop_objection(this);


endtask

endclass:full_test


class fullinout_test extends test;

`uvm_component_utils(fullinout_test)

write_xtn req;

function new (string name = "fullinout_test" , uvm_component parent = null);
super.new(name,parent);
endfunction:new

task run_phase(uvm_phase phase);

fullinout_seq req;

phase.raise_objection(this);

req=fullinout_seq::type_id::create("req");

req.start(envh.agt.seqh);

phase.drop_objection(this);
endtask
endclass:fullinout_test

class stable_test extends test;

`uvm_component_utils(stable_test)

write_xtn req;

function new(string name = "stable_test" , uvm_component parent);
super.new(name,parent);
endfunction

task run_phase(uvm_phase phase);

stable_data_out req;

phase.raise_objection(this);

req=stable_data_out::type_id::create("req");

req.start(envh.agt.seqh);

phase.drop_objection(this);

endtask
endclass:stable_test
