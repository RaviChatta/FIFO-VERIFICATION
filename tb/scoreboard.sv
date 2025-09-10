class scoreboard extends uvm_scoreboard;
  `uvm_component_utils(scoreboard)

  uvm_analysis_imp #(write_xtn, scoreboard) ts;
  bit [7:0] ka[$];   // model FIFO
  write_xtn req;

covergroup fifo_covergroup;

wr_en_cp : coverpoint req.wr_en {

bins wr_en_disabled = {0};
bins rd_en_enabled = {1};

}

rd_en_cp : coverpoint req.rd_en {

bins rd_en_disabled = {0};
bins rd_en_enabled = {1};
}

full_cp : coverpoint req.full {
bins full_disabled = {0};
bins full_enabled = {1};
}

empty_cp : coverpoint req.empty {
bins empty_disabled = {0};
bins empty_enabled = {1};
}

data_in_cp : coverpoint req.data_in {
  bins bronze_range   = {[  0: 50]};   // 51 values
  bins silver_range   = {[ 51:101]};   // 51 values
  bins gold_range     = {[102:152]};   // 51 values
  bins platinum_range = {[153:203]};   // 51 values
  bins diamond_range  = {[204:255]};   // 52 values
}

data_out_cp : coverpoint req.data_out {
  bins bronze_range   = {[  0: 50]};   // 51 values
  bins silver_range   = {[ 51:101]};   // 51 values
  bins gold_range     = {[102:152]};   // 51 values
  bins platinum_range = {[153:203]};   // 51 values
  bins diamond_range  = {[204:255]};   // 52 values
}

//cross coverage 

// wr_full_cross : cross wr_en_cp,full_cp;
// rd_empty_cross : cross rd_en_cp,empty_cp;
// wr_rd_cross : cross  wr_en_cp, rd_en_cp;
// fifo_inout_cross : cross data_out_cp,data_in_cp;

endgroup

  function new(string name ="scoreboard", uvm_component parent);
    super.new(name, parent);
    ts = new("write_xtn", this);
    fifo_covergroup = new();
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction



  task write(write_xtn req);
    this.req = req;
  fifo_covergroup.sample();
    // Handle writes
    if (req.wr_en) begin
      ka.push_back(req.data_in);
      `uvm_info("SCOREBOARD", 
        $sformatf("PUSH: data_in=%0d | model_fifo=%p", req.data_in, ka), 
        UVM_LOW)
    end

    // Handle reads
    if (req.rd_en) begin
      if (ka.size == 0) begin
        `uvm_error("SCOREBOARD", "Read attempted when model FIFO is empty!")
      end
      else begin
        bit [7:0] rk = ka.pop_front();

        if (rk != req.data_out) begin
          `uvm_error("SCOREBOARD", 
            $sformatf("MISMATCH: expected=%0d, got=%0d | remaining_fifo=%p",
                      rk, req.data_out, ka))
        end
        else begin
          `uvm_info("SCOREBOARD", 
            $sformatf("MATCH: data_out=%0d | remaining_fifo=%p",
                      req.data_out, ka), 
            UVM_LOW)
        end
      end
    end
  endtask
endclass : scoreboard
