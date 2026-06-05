//////////////////////////////////////////////////////////////////////////////////
// College: MNNIT Allahabad
// Ashish Kumar Kashyap
// 
// Create Date: 04.06.2026
// Design Name: ahb protoccol
// Module Name: multiplexer
// Project Name: AMBA AHB
// Target Devices: Xilinx FPGA

// Tool Versions: Vivado 2023.x
//////////////////////////////////////////////////////////////////////////////////


`timescale 1ns / 1ps

module multiplexer(
    input [31:0] hrdata_1,
    input [31:0] hrdata_2,
    input [31:0] hrdata_3,
    input [31:0] hrdata_4,

    input hreadyout_1,
    input hreadyout_2,
    input hreadyout_3,
    input hreadyout_4,

    input hresp_1,
    input hresp_2,
    input hresp_3,
    input hresp_4,

    input [1:0] sel,
    input sel_valid,

    output reg [31:0] hrdata,
    output reg hreadyout,
    output reg hresp
);

always @(*)
begin
    if(!sel_valid)
    begin
        // no slave selected
        hrdata = 32'd0;
        hreadyout = 1'b1;
        hresp = 1'b0;
    end
    else
    begin
        case(sel)

        2'b00:
        begin
            // slave 1
            hrdata = hrdata_1;
            hreadyout = hreadyout_1;
            hresp = hresp_1;
        end

        2'b01:
        begin
            hrdata = hrdata_2;
            hreadyout = hreadyout_2;
            hresp = hresp_2;
        end

         2'b10:
         begin
            hrdata = hrdata_3;
            hreadyout = hreadyout_3;
            hresp = hresp_3;
         end

        2'b11:
        begin
            hrdata = hrdata_4;
            hreadyout = hreadyout_4;
            hresp = hresp_4;
        end

        default:
        begin
            // default response
            hrdata = 32'd0;
            hreadyout = 1'b1;
            hresp = 1'b0;
        end

        endcase
    end
end

endmodule
