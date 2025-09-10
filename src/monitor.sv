 class monitor extends uvm_monitor;
  `uvm_component_utils(monitor)

  // single transaction type that carries both write/read info
  write_xtn               req;
  uvm_analysis_port #(write_xtn) ap;
  virtual fifo_if.mon_mod m_if;

  // 2-stage pipeline to model data_out valid after rd_en (2-cycle latency)
  bit [2:0] rd_en_pipeline;
  // track whether FIFO was empty at the moment read was asserted (to ignore spurious reads)
  bit was_empty;

  function new(string name = "monitor", uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
    rd_en_pipeline = 2'b00;
    was_empty = 1'b1;
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual fifo_if.mon_mod)::get(this, "", "r_if", m_if)) begin
      `uvm_fatal(get_type_name(), "Cannot get interface! Did you set it in uvm_config_db?")
    end
  endfunction : build_phase

  task run_phase(uvm_phase phase);
    `uvm_info("MON", "Entered run_phase", UVM_LOW)

    // optional small delay to let interface stabilize (match your ref monitors)
  //  repeat (3) @(m_if.cb_mon);

    forever begin
      // sample on the interface clocking event to avoid race conditions
      @(m_if.cb_mon);

      // treat active-low or active-high reset depending on your interface naming;
      // here assume 'reset' bit: if asserted, clear pipeline/state
      if (m_if.cb_mon.rst) begin
        rd_en_pipeline = 2'b00;
        was_empty = 1'b1;
        continue;
      end

      // ---------- write sampling ----------
      // When write enable is asserted on the sampled clocking event,
      // create a transaction and publish immediately.
      if (m_if.cb_mon.wr_en) begin
        req = write_xtn::type_id::create("req", this);
        req.data_in  = m_if.cb_mon.data_in;
        req.wr_en    = 1'b1;
        req.rd_en    = 1'b0;
	@(m_if.cb_mon.wr_en);
        req.full     = m_if.cb_mon.full;
        req.empty    = m_if.cb_mon.empty;
        req.data_out = 'hx; // not valid for write
        req.rst      = m_if.cb_mon.rst;
       // `uvm_info("MON", $sformatf("WRITE observed: data=%0d full=%0b empty=%0b", req.data_in, req.full, req.empty), UVM_LOW);
          `uvm_info("MON", $sformatf("WRITE observed: din=%0d wr_en=%0d rd_en=%0d full=%0d empty=%0d",req.data_in, req.wr_en, req.rd_en, req.full, req.empty), UVM_LOW);
	  req.print();

        ap.write(req);
      end

      // ---------- read sampling (2-cycle latency) ----------
      // Keep pipeline of rd_en samples: rd_en_pipeline[0] holds previous rd_en,
      // [1] holds rd_en from two cycles ago when data_out becomes valid.
      // Update pipeline before checking (so index [1] corresponds to a rd_en asserted 2 cycles earlier)
  //    rd_en_pipeline = { rd_en_pipeline[0], m_if.cb_mon.rd_en };

      // If rd_en was asserted 2 cycles ago AND that read was not started when FIFO was empty,
      // then data_out should now be valid — publish the read transaction.
// update pipeline (shift register)
rd_en_pipeline = { rd_en_pipeline[1:0], m_if.cb_mon.rd_en };

// check 3 cycles old rd_en
if (rd_en_pipeline[2] && !was_empty) begin
  req = write_xtn::type_id::create("req", this);
  req.wr_en    = 1'b0;
  req.rd_en    = 1'b1;
  req.data_in  = 'hx;
  req.data_out = m_if.cb_mon.data_out;
  req.full     = m_if.cb_mon.full;
  req.empty    = m_if.cb_mon.empty;
  req.rst      = m_if.cb_mon.rst;
 // `uvm_info("MON",$sformatf("READ observed: data_out=%0d",req.data_out),UVM_LOW)
`uvm_info("MON", $sformatf("READ observed: data_out =%0d wr_en=%0d rd_en=%0d full=%0d empty=%0d", req.data_out, req.wr_en, req.rd_en, req.full, req.empty), UVM_LOW); 
 req.print();
  ap.write(req);
end


      // Store whether FIFO was empty at the instant a read was initiated.
      // This is used to avoid publishing reads that were started when FIFO was empty.
      if (m_if.cb_mon.rd_en) begin
        was_empty = m_if.cb_mon.empty;
      end
      else begin
        // if no read being asserted now, do not change was_empty (it is only meaningful
        // at the moment of read assertion)
      end
    end
  endtask : run_phase
endclass : monitor  


/*
class monitor extends uvm_monitor;
  `uvm_component_utils(monitor)

  // single transaction type that carries both write/read info
  write_xtn               req;
  uvm_analysis_port #(write_xtn) ap;
  virtual fifo_if.mon_mod m_if;

  // 3-stage pipeline to model data_out valid after rd_en (2-cycle latency)
  bit [2:0] rd_en_pipeline;  // [0]=current, [1]=1 cycle ago, [2]=2 cycles ago
  // track whether FIFO was empty at the moment read was asserted
  bit was_empty;

  function new(string name = "monitor", uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
    rd_en_pipeline = 3'b000;
    was_empty = 1'b1;
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual fifo_if.mon_mod)::get(this, "", "r_if", m_if)) begin
      `uvm_fatal(get_type_name(), "Cannot get interface! Did you set it in uvm_config_db?")
    end
  endfunction : build_phase

  task run_phase(uvm_phase phase);
    `uvm_info("MON", "Entered run_phase", UVM_LOW)

    forever begin
      @(m_if.cb_mon);

      // Reset handling
      if (m_if.cb_mon.rst) begin
        rd_en_pipeline = 3'b000;
        was_empty = 1'b1;
        continue;
      end

      // ---------- write sampling ----------
      if (m_if.cb_mon.wr_en) begin
        req = write_xtn::type_id::create("req", this);
        req.data_in  = m_if.cb_mon.data_in;
        req.wr_en    = 1'b1;
        req.rd_en    = 1'b0;
        req.full     = m_if.cb_mon.full;
        req.empty    = m_if.cb_mon.empty;
        req.data_out = 'hx;
        `uvm_info("MON", $sformatf("WRITE observed: din=%0d wr_en=%0d rd_en=%0d full=%0d empty=%0d",
                  req.data_in, req.wr_en, req.rd_en, req.full, req.empty), UVM_LOW);
        req.print();
        ap.write(req);
      end

      // ---------- read sampling (2-cycle latency) ----------
      // Update pipeline (shift register)
      rd_en_pipeline = {rd_en_pipeline[1:0], m_if.cb_mon.rd_en};

      // Check if rd_en was asserted 2 cycles ago AND FIFO wasn't empty at that time
      if (rd_en_pipeline[2] && !was_empty) begin
        req = write_xtn::type_id::create("req", this);
        req.wr_en    = 1'b0;
        req.rd_en    = 1'b1;
        req.data_in  = 'hx;
        req.data_out = m_if.cb_mon.data_out;
        req.full     = m_if.cb_mon.full;
        req.empty    = m_if.cb_mon.empty;
        `uvm_info("MON", $sformatf("READ observed: data_out=%0d wr_en=%0d rd_en=%0d full=%0d empty=%0d",
                  req.data_out, req.wr_en, req.rd_en, req.full, req.empty), UVM_LOW);
        req.print();
        ap.write(req);
      end

      // Store empty status when read is initiated
      if (m_if.cb_mon.rd_en) begin
        was_empty = m_if.cb_mon.empty;
      end
    end
  endtask : run_phase
endclass : monitor
*/