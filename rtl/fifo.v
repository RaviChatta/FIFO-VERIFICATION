`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:40:03 08/21/2025 
// Design Name: 
// Module Name:    Fifo 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module fifo(input clk,rst,wr_en,rd_en, [7:0] data_in, output full , empty,output  reg [7:0] data_out);
   
	reg[7:0]mem[15:0];
	reg[3:0] wr_ptr,rd_ptr;
	integer i;
	reg [7:0] data_out_next;

	always@(posedge clk)
	begin
	if(rst)
	begin
		for(i=0;i<16;i=i+1)
		mem[i]<=0;
		wr_ptr<=0;
		rd_ptr<=0;
		data_out<=0;
	end
	else
	begin
	if(wr_en && !full)
	begin
	mem[wr_ptr]<=data_in;
	wr_ptr<=wr_ptr+1'b1;
	end
	if(rd_en && !empty)
	begin
	
 	data_out_next<=mem[rd_ptr];
	rd_ptr<=rd_ptr+1'b1;
	end
        data_out <= data_out_next; // valid in next clock

	end
	end
	assign full = (wr_ptr+1'b1)==rd_ptr;
	assign empty = (wr_ptr==rd_ptr);
	
	


endmodule
