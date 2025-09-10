`timescale 1ns/1ps
  import uvm_pkg::*;
  import fifo_pkg::*;
  `include "uvm_macros.svh" 

module top();  
  bit clk;
  fifo_if r_if(.clk(clk));
   fifo DUT (
    .clk     (r_if.clk),
    .rst     (r_if.rst),
    .wr_en   (r_if.wr_en),
    .rd_en   (r_if.rd_en),
    .data_in (r_if.data_in),
    .data_out(r_if.data_out),
    .full    (r_if.full),
    .empty   (r_if.empty)
  );  

  initial begin
    clk=0;
    forever
      #5 clk = ~ clk;
  end
  initial
    begin
      
      uvm_config_db#(virtual fifo_if.drv_mod)::set(null,"*","r_if",r_if);
      uvm_config_db#(virtual fifo_if.mon_mod)::set(null,"*","r_if",r_if);
      run_test();

   end



// Assertions 

//property write_no_overflow;
//  @(posedge clk) disable iff(r_if.rst)
//(r_if.full == 0) || (r_if.wr_en == 0);
//endproperty

property read_no_underflow;
  @(posedge clk) disable iff(r_if.rst)
(r_if.empty == 0) || (r_if.rd_en == 0);
endproperty

property empty_read_disable;
  @(posedge clk) disable iff(r_if.rst)
(r_if.empty) |-> (r_if.rd_en == 0);
endproperty

property full_write_disable;
  @(posedge clk) disable iff(r_if.rst)
(r_if.full) |-> (r_if.wr_en == 0);
endproperty

property stable_data_outs;
  @(posedge clk) disable iff(r_if.rst)
(!r_if.rd_en) |=> $stable(r_if.data_out);
endproperty

//Assert properties
//A1: assert property (write_no_overflow)
//  $display("write_no_overflow success");
//else
//  $display("write_no_overflow failed: Write attempted when FIFO full.");


A2: assert property (read_no_underflow)
  $display("read_no_underflow success");
else
  $display("read_no_underflow failed: Read attempted when FIFO empty.");


A3: assert property (empty_read_disable)
  $display("empty_read_disable success");
else
  $display("empty_read_disable failed: Read enabled when FIFO empty.");


A4: assert property (full_write_disable)
  $display("full_write_disable success");
else
  $display("full_write_disable failed: Write enabled when FIFO full.");


//A5: assert property (stable_data_outs)
//  $display("stable_data_out success");
//else
//  $display("stable_data_out failed: Data output changed without read.");

//Assertions cover property
//c1:cover property (write_no_overflow)
//$display("C1:write_no_overflow success");


c2:cover property (read_no_underflow)
$display("C2:read_no_underflow success");

c3:cover property (empty_read_disable)
$display("C3:empty_read_disable success");


c4:cover property (full_write_disable)
$display("C4:full_write_disable success");


//c5:cover property (stable_data_outs)
//$display("C5:stable_data_out success");

endmodule:top
