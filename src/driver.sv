class driver extends uvm_driver#(write_xtn);
  `uvm_component_utils(driver)

  virtual fifo_if.drv_mod d_if;
  write_xtn req;

  function new(string name ="driver", uvm_component parent);
    super.new(name,parent);
  endfunction:new
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual fifo_if.drv_mod)::get(this,"","r_if",d_if))
      `uvm_fatal(get_type_name(),"Cannot get interface!")
  endfunction:build_phase
  
  task run_phase(uvm_phase phase);
    `uvm_info("WRITE_DRIVER","Entered run_phase",UVM_LOW)

    // Apply reset
    @(d_if.cb_drv);
    d_if.cb_drv.rst <= 1'b1;
    @(d_if.cb_drv);
    d_if.cb_drv.rst <= 1'b0;

    forever begin
      seq_item_port.get_next_item(req);

      if(req.wr_en) begin
        drive_write(req.data_in);
      end 
      else if(req.rd_en) begin
        drive_read();
      end

      seq_item_port.item_done();
    end
  endtask : run_phase

  // ---------------- Write with IF check ----------------
  task drive_write(bit[7:0] din);
    @(d_if.cb_drv);
    if(!d_if.cb_drv.full) begin
      d_if.cb_drv.wr_en   <= 1'b1;
      d_if.cb_drv.data_in <= din;
      `uvm_info("WRITE_DRIVER",$sformatf("WRITE data=%0d",din),UVM_LOW)
   end else begin
      `uvm_info("WRITE_DRIVER","FIFO FULL -> Write skipped",UVM_LOW)
    end

    @(d_if.cb_drv);
    d_if.cb_drv.wr_en <= 1'b0;
  endtask

  // ---------------- Read with IF check ----------------
  task drive_read();
    @(d_if.cb_drv);
    if(!d_if.cb_drv.empty) begin
      d_if.cb_drv.rd_en <= 1'b1;
      `uvm_info("WRITE_DRIVER","READ issued",UVM_LOW)
    end else begin
      `uvm_info("WRITE_DRIVER","FIFO EMPTY -> Read skipped",UVM_LOW)
    end

    @(d_if.cb_drv);
    d_if.cb_drv.rd_en <= 1'b0;
  endtask

endclass : driver
