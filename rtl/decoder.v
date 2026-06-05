`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// College: MNNIT Allahabad
// Ashish Kumar Kashyap
// 
// Create Date: 04.06.2026
// Design Name: ahb protoccol
// Module Name: decoder
// Project Name: AMBA AHB
// Target Devices: Xilinx FPGA
// Tool Versions: Vivado 2023.x
//////////////////////////////////////////////////////////////////////////////////
module decoder(
    input wire [1:0] sel,
    input wire sel_valid,

    output reg hsel_1,
    output reg hsel_2,
    output reg hsel_3,
    output reg hsel_4
);

always @(*)
begin
    // default values
    hsel_1 = 1'b0;
    hsel_2 = 1'b0;
    hsel_3 = 1'b0;
    hsel_4 = 1'b0;

    if(sel_valid)
    begin
       // select slave
       case(sel)

       2'b00: hsel_1 = 1'b1;
        2'b01: hsel_2 = 1'b1;
       2'b10: hsel_3 = 1'b1;
       2'b11: hsel_4 = 1'b1;

       endcase
    end
end

endmodule
