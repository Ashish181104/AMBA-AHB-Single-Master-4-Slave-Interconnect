//////////////////////////////////////////////////////////////////////////////////
// College: MNNIT Allahabad
// Ashish Kumar Kashyap
// 
// Create Date: 04.06.2026
// Design Name: ahb protoccol
// Module Name: ahb_top_tb
// Project Name: AMBA AHB
// Target Devices: Xilinx FPGA
// Tool Versions: Vivado 2023.x

//////////////////////////////////////////////////////////////////////////////////


`timescale 1ns/1ps

module ahb_top_tb;

reg hclk;
reg hresetn;
reg enable;

reg [31:0] data_in_a;
reg [31:0] data_in_b;
reg [31:0] addr;

reg wr;
reg [1:0] slave_sel;

wire read_complete;

// internal signals
wire [2:0] w_master_state = dut.master.state;
wire [1:0] w_htrans       = dut.htrans;
wire       w_hwrite       = dut.hwrite;

wire       w_sel_valid    = dut.sel_valid;
wire [1:0] w_active_sel   = dut.sel;

wire [31:0] w_haddr  = dut.haddr;
wire [31:0] w_hwdata = dut.hwdata;
wire [31:0] w_hrdata = dut.hrdata;

wire w_hsel_1 = dut.hsel_1;
wire w_hsel_2 = dut.hsel_2;
wire w_hsel_3 = dut.hsel_3;
wire w_hsel_4 = dut.hsel_4;

wire [31:0] w_slave1_data = dut.hrdata_1;
wire [31:0] w_slave2_data = dut.hrdata_2;
wire [31:0] w_slave3_data = dut.hrdata_3;
wire [31:0] w_slave4_data = dut.hrdata_4;

ahb_top dut(
    .hclk(hclk),
    .hresetn(hresetn),
    .enable(enable),
    .data_in_a(data_in_a),
    .data_in_b(data_in_b),
    .addr(addr),
    .wr(wr),
    .slave_sel(slave_sel),
    .read_complete(read_complete)
);

// clock generation
initial
begin
    hclk = 0;
    forever #5 hclk = ~hclk;
end

task reset_dut;
begin
    // apply reset
    hresetn = 0;
    enable = 0;
    wr = 0;
    slave_sel = 0;
    addr = 0;
    data_in_a = 0;
    data_in_b = 0;

    repeat(4) @(posedge hclk);

    @(negedge hclk);
    hresetn = 1;

    repeat(2) @(posedge hclk);
end
endtask

task write_dut;
    input [1:0] sel;
    input [31:0] address;
    input [31:0] a;
    input [31:0] b;
begin
    @(posedge hclk); #1;

    slave_sel = sel;
    addr = address;
    data_in_a = a;
    data_in_b = b;

    wr = 1'b1;
    enable = 1'b1;

    @(posedge hclk); #1;

    enable = 1'b0;
    wr = 1'b0;

    repeat(2) @(posedge hclk);

    data_in_a = 0;
    data_in_b = 0;

    $display("[WRITE DONE] t=%0t slave=%0d addr=%0h data_in_a=%h data_in_b=%h hwdata=%h",
              $time,sel,address,a,b,a+b);
end
endtask

task read_dut;
    input [1:0] sel;
    input [31:0] address;
begin
    @(posedge hclk); #1;

    slave_sel = sel;
    addr = address;

    data_in_a = 0;
    data_in_b = 0;

    wr = 1'b0;
    enable = 1'b1;

    @(posedge hclk); #1;
    enable = 1'b0;

    // wait for read
    fork
        begin
            @(posedge read_complete);
            #1;

            $display("[READ SUCCESS] t=%0t slave=%0d addr=%0h hrdata=%h",
                      $time,sel,address,w_hrdata);
        end

        begin
            repeat(5) @(posedge hclk);
        end
    join
end
endtask

initial
begin
    reset_dut();

    // slave 1
    write_dut(2'b00, 32'd1, 32'h55555555, 32'hAAAAAAAA);
    read_dut (2'b00, 32'd1);

    // slave 2
    write_dut(2'b01, 32'd2, 32'hCAFE0000, 32'h0000BABE);
    read_dut (2'b01, 32'd2);

    // slave 3
    write_dut(2'b10, 32'd3, 32'h12345678, 32'h87654321);
    read_dut (2'b10, 32'd3);

    // slave 4
    write_dut(2'b11, 32'd4, 32'hDEAD0000, 32'h0000BEEF);
    read_dut (2'b11, 32'd4);

    #100;

    $display("=== Simulation complete ===");
    $finish;
end

endmodule
