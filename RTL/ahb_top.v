//////////////////////////////////////////////////////////////////////////////////
// College: MNNIT Allahabad
// Ashish Kumar Kashyap
// 
// Create Date: 04.06.2026
// Design Name: ahb protoccol
// Module Name: ahb_top
// Project Name: AMBA AHB
// Target Devices: Xilinx FPGA
// Tool Versions: Vivado 2023.x
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// College: MNNIT Allahabad
// Ashish Kumar Kashyap
//
// Top module for AHB project
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module ahb_top(
    input wire hclk,
    input wire hresetn,
    input wire enable,
    input wire [31:0] data_in_a,
    input wire [31:0] data_in_b,
    input wire [31:0] addr,
    input wire wr,
    input wire [1:0] slave_sel,
    output wire read_complete
);

// internal wires
wire [1:0] sel;
wire sel_valid;

wire [31:0] haddr;
wire hwrite;

wire [3:0] hprot;
wire [2:0] hsize;
wire [2:0] hburst;
wire [1:0] htrans;

wire hmastlock;
wire [31:0] hwdata;

// slave outputs
wire [31:0] hrdata_1;
wire hreadyout_1;
wire hresp_1;

wire [31:0] hrdata_2;
wire hreadyout_2;
wire hresp_2;

wire [31:0] hrdata_3;
wire hreadyout_3;
wire hresp_3;

wire [31:0] hrdata_4;
wire hreadyout_4;
wire hresp_4;

// select lines
wire hsel_1,hsel_2,hsel_3,hsel_4;

wire [31:0] hrdata;
wire hreadyout;
wire hresp;

// ready signal feedback
wire hready;
assign hready = hreadyout;


// master block
ahb_master master (
    .hclk(hclk),
    .hresetn(hresetn),
    .enable(enable),

    .data_in_a(data_in_a),
    .data_in_b(data_in_b),
      .addr(addr),

    .wr(wr),
    .hreadyout(hreadyout),
    .hresp(hresp),

    .hrdata(hrdata),
    .slave_sel(slave_sel),

    .sel(sel),
    .sel_valid(sel_valid),

    .haddr(haddr),
    .hsize(hsize),
    .hwrite(hwrite),

    .hburst(hburst),
    .hprot(hprot),
    .htrans(htrans),

   .hwdata(hwdata),
    .hmastlock(hmastlock),

    .read_complete(read_complete)
);


// decoder generates slave select
decoder decoder (
    .sel(sel),
    .sel_valid(sel_valid),
    .hsel_1(hsel_1),
    .hsel_2(hsel_2),
   .hsel_3(hsel_3),
    .hsel_4(hsel_4)
);


// slave 1
ahb_slave slave_1(
    .hclk(hclk),
    .hresetn(hresetn),
    .hsel(hsel_1),

    .haddr(haddr),
    .hwrite(hwrite),
    .hsize(hsize),

    .hburst(hburst),
      .hprot(hprot),
    .htrans(htrans),

    .hmastlock(hmastlock),
    .hready(hready),
    .hwdata(hwdata),

    .hreadyout(hreadyout_1),
    .hresp(hresp_1),
    .hrdata(hrdata_1)
);

// slave 2
ahb_slave slave_2(
    .hclk(hclk),
    .hresetn(hresetn),
    .hsel(hsel_2),

    .haddr(haddr),
    .hwrite(hwrite),
    .hsize(hsize),

    .hburst(hburst),
    .hprot(hprot),
   .htrans(htrans),

    .hmastlock(hmastlock),
    .hready(hready),
    .hwdata(hwdata),

    .hreadyout(hreadyout_2),
    .hresp(hresp_2),
    .hrdata(hrdata_2)
);

// slave 3
ahb_slave slave_3(
    .hclk(hclk),
    .hresetn(hresetn),
    .hsel(hsel_3),

    .haddr(haddr),
    .hwrite(hwrite),
    .hsize(hsize),

    .hburst(hburst),
    .hprot(hprot),
    .htrans(htrans),

    .hmastlock(hmastlock),
     .hready(hready),
    .hwdata(hwdata),

    .hreadyout(hreadyout_3),
    .hresp(hresp_3),
    .hrdata(hrdata_3)
);

// slave 4
ahb_slave slave_4(
    .hclk(hclk),
    .hresetn(hresetn),
    .hsel(hsel_4),

    .haddr(haddr),
    .hwrite(hwrite),
    .hsize(hsize),

    .hburst(hburst),
    .hprot(hprot),
    .htrans(htrans),

    .hmastlock(hmastlock),
    .hready(hready),
    .hwdata(hwdata),

    .hreadyout(hreadyout_4),
    .hresp(hresp_4),
    .hrdata(hrdata_4)
);


// mux selects slave response
multiplexer mux(
    .hrdata_1(hrdata_1),
    .hrdata_2(hrdata_2),
    .hrdata_3(hrdata_3),
    .hrdata_4(hrdata_4),

    .hreadyout_1(hreadyout_1),
    .hreadyout_2(hreadyout_2),
   .hreadyout_3(hreadyout_3),
    .hreadyout_4(hreadyout_4),

    .hresp_1(hresp_1),
    .hresp_2(hresp_2),
    .hresp_3(hresp_3),
    .hresp_4(hresp_4),

    .sel(sel),
    .sel_valid(sel_valid),

    .hrdata(hrdata),
    .hreadyout(hreadyout),
    .hresp(hresp)
);

endmodule
