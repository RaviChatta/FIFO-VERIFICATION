`timescale 1ns/1ps

interface fifo_if(input logic clk);
  logic rst;
  logic wr_en;
  logic rd_en;
  logic [7:0] data_in;
  logic [7:0] data_out;
  logic full;
  logic empty;

clocking cb_drv @(posedge clk);
  default input #1 output #1;
    input  data_out, full, empty;   // rst is sampled only
    output data_in, wr_en, rd_en,rst;        // drive only these
endclocking

clocking cb_mon @(posedge clk);
  default input #1 output #1;
    input  data_in, data_out, wr_en, rd_en, full, empty, rst;
endclocking

  modport mon_mod(clocking cb_mon,input clk,rst);
  modport drv_mod(clocking cb_drv,input clk,rst);

endinterface