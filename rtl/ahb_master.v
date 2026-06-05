////////////////////////////////////////////////////////////////////////////////// 
// College: MNNIT Allahabad // Ashish Kumar Kashyap // 
// Create Date: 04.06.2026
// Design Name: ahb protoccol
// Module Name: ahb_master 
// Project Name: AMBA AHB
// Target Devices: Xilinx FPGA
// Tool Versions: Vivado 2023.x 
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module ahb_master(
    input wire hclk,
    input wire hresetn,
    input wire enable,
    input wire [31:0] data_in_a,
    input wire [31:0] data_in_b,
    input wire [31:0] addr,
    input wire wr,
    input wire hreadyout,
    input wire hresp,
    input wire [31:0] hrdata,
    input wire [1:0] slave_sel,

    output reg [1:0] sel,
    output reg sel_valid,
    output reg [31:0] haddr,
    output reg hwrite,
    output reg [2:0] hsize,
    output reg [2:0] hburst,
    output reg [3:0] hprot,
    output reg [1:0] htrans,
    output reg [31:0] hwdata,
    output reg hmastlock,
    output reg read_complete
);

parameter IDLE = 3'd0;
parameter ADDR = 3'd1;
parameter DATA = 3'd2;

reg [2:0] state;
reg wr_reg;

always @(posedge hclk or negedge hresetn)
begin
   if(!hresetn)
   begin
      // reset values
      state <= IDLE;

      sel <= 2'b00;
      sel_valid <= 1'b0;

      haddr <= 32'd0;
      hwrite <= 1'b0;
      hsize <= 3'b000;
      hburst <= 3'b000;
      hprot <= 4'b0000;

      htrans <= 2'b00;
      hwdata <= 32'd0;
      hmastlock <= 1'b0;

      read_complete <= 1'b0;
      wr_reg <= 1'b0;
   end
   else
   begin
      case(state)

      IDLE:
      begin
         // idle state
         sel_valid <= 1'b0;
         htrans <= 2'b00;
         hwrite <= 1'b0;
         read_complete <= 1'b0;

         if(enable)
         begin
            // start transfer
            sel <= slave_sel;
            haddr <= addr;

            hwrite <= wr;
            wr_reg <= wr;

            hwdata <= data_in_a + data_in_b;

            hsize <= 3'b000;
            hburst <= 3'b000;
            hprot <= 4'b0000;

            htrans <= 2'b10;
            hmastlock <= 1'b0;

            sel_valid <= 1'b1;
            state <= ADDR;
         end
      end

       ADDR:
       begin
          // address phase
          read_complete <= 1'b0;
          state <= DATA;
       end

      DATA:
      begin
         // wait for slave
         if(hreadyout)
         begin
            if(!wr_reg)
               read_complete <= 1'b1;   // read done
            else
               read_complete <= 1'b0;

            sel_valid <= 1'b0;
            htrans <= 2'b00;
            hwrite <= 1'b0;

            state <= IDLE;   // back to idle
         end
         else
         begin
            read_complete <= 1'b0;
         end
      end

      default:
      begin
         state <= IDLE;
         read_complete <= 1'b0;
      end

      endcase
   end
end

endmodule
