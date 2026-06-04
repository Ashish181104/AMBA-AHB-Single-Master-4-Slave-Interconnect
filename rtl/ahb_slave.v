//////////////////////////////////////////////////////////////////////////////////
// College: MNNIT Allahabad
// Ashish Kumar Kashyap
// 
// Create Date: 04.06.2026
// Design Name: ahb protoccol
// Module Name: ahb_slave
// Project Name: AMBA AHB
// Target Devices: Xilinx FPGA
// Tool Versions: Vivado 2023.x
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module ahb_slave(
    input  wire        hclk,
    input  wire        hresetn,
    input  wire        hsel,

    input  wire [31:0] haddr,
    input  wire        hwrite,
    input  wire [2:0]  hsize,
    input  wire [2:0]  hburst,
    input  wire [3:0]  hprot,
    input  wire [1:0]  htrans,
    input  wire        hmastlock,
    input  wire [31:0] hwdata,
    input  wire        hready,

    output reg         hreadyout,
    output reg         hresp,
    output reg  [31:0] hrdata
);

// memory
reg [31:0] mem [0:31];
integer ii;

// initialize memory
initial begin
    for (ii = 0; ii < 32; ii = ii + 1)
        mem[ii] = 32'd0;
end

// address registers
reg [4:0] waddr, raddr, base_addr;
reg hwrite_reg;

// burst type flags
reg single_flag, incr_flag, wrap4_flag, incr4_flag;
reg wrap8_flag, incr8_flag, wrap16_flag, incr16_flag;

// fsm states
reg [1:0] state;

parameter IDLE = 2'd0;
parameter ADDR = 2'd1;
parameter DATA = 2'd2;

// valid transfer check
wire valid_transfer = hsel && (htrans == 2'b10 || htrans == 2'b11);


// main slave logic
always @(posedge hclk or negedge hresetn)
begin

    if(!hresetn)
    begin
        state <= IDLE;

        hreadyout <= 1'b1;
        hresp <= 1'b0;
        hrdata <= 32'd0;

        waddr <= 5'd0;
        raddr <= 5'd0;
        base_addr <= 5'd0;

        hwrite_reg <= 1'b0;

        single_flag <= 1'b0;
        incr_flag <= 1'b0;

        wrap4_flag <= 1'b0;
        incr4_flag <= 1'b0;

        wrap8_flag <= 1'b0;
        incr8_flag <= 1'b0;

        wrap16_flag <= 1'b0;
        incr16_flag <= 1'b0;
    end

    else begin

        case(state)

        // wait for transfer
        IDLE:
        begin
            hreadyout <= 1'b1;
            hresp <= 1'b0;

            if(valid_transfer)
                state <= ADDR;
        end

        // capture control info
        ADDR:
        begin
            hreadyout <= 1'b1;
            hresp <= 1'b0;

            hwrite_reg <= hwrite;
            base_addr <= haddr[4:0];

            single_flag <= (hburst == 3'b000);
            incr_flag   <= (hburst == 3'b001);

            wrap4_flag <= (hburst == 3'b010);
            incr4_flag <= (hburst == 3'b011);

            wrap8_flag <= (hburst == 3'b100);
            incr8_flag <= (hburst == 3'b101);

            wrap16_flag <= (hburst == 3'b110);
            incr16_flag <= (hburst == 3'b111);

            waddr <= haddr[4:0];
            raddr <= haddr[4:0];

            state <= DATA;
        end

        // read/write operation
        DATA:
        begin

            hreadyout <= 1'b1;
            hresp <= 1'b0;

            if(hwrite_reg)
            begin

                case({single_flag,incr_flag,wrap4_flag,incr4_flag,
                      wrap8_flag,incr8_flag,wrap16_flag,incr16_flag})

                // single write
                8'b1000_0000:
                begin
                    mem[haddr[4:0]] <= hwdata;
                    $display("SLAVE WRITE time=%0t addr=%0d data=%0h",
                              $time,haddr[4:0],hwdata);
                end

                8'b0100_0000:
                begin
                    mem[waddr] <= hwdata;
                    waddr <= waddr + 1;
                end

                8'b0010_0000:
                begin
                    mem[waddr] <= hwdata;
                    waddr <= (waddr < base_addr+5'd3) ? waddr+1 : base_addr;
                end

                8'b0000_1000:
                begin
                    mem[waddr] <= hwdata;
                    waddr <= (waddr < base_addr+5'd7) ? waddr+1 : base_addr;
                end

                8'b0000_0100:
                begin
                    mem[waddr] <= hwdata;
                    waddr <= waddr + 1;
                end

                8'b0000_0010:
                begin
                    mem[waddr] <= hwdata;
                    waddr <= (waddr < base_addr+5'd15) ? waddr+1 : base_addr;
                end

                8'b0000_0001:
                begin
                    mem[waddr] <= hwdata;
                    waddr <= waddr + 1;
                end

                default: ;

                endcase

            end

            else begin

                case({single_flag,incr_flag,wrap4_flag,incr4_flag,
                      wrap8_flag,incr8_flag,wrap16_flag,incr16_flag})

                // single read
                8'b1000_0000:
                begin
                    hrdata <= mem[haddr[4:0]];

                    $display("SLAVE READ time=%0t addr=%0d mem=%0h",
                             $time,haddr[4:0],mem[haddr[4:0]]);
                end

                8'b0100_0000:
                begin
                    hrdata <= mem[raddr];
                    raddr <= raddr + 1;
                end

                8'b0010_0000:
                begin
                    hrdata <= mem[raddr];
                    raddr <= (raddr < base_addr+5'd3) ? raddr+1 : base_addr;
                end

                8'b0001_0000:
                begin
                    hrdata <= mem[raddr];
                    raddr <= raddr + 1;
                end

                8'b0000_1000:
                begin
                    hrdata <= mem[raddr];
                    raddr <= (raddr < base_addr+5'd7) ? raddr+1 : base_addr;
                end

                8'b0000_0100:
                begin
                    hrdata <= mem[raddr];
                    raddr <= raddr + 1;
                end

                8'b0000_0010:
                begin
                    hrdata <= mem[raddr];
                    raddr <= (raddr < base_addr+5'd15) ? raddr+1 : base_addr;
                end

                8'b0000_0001:
                begin
                    hrdata <= mem[raddr];
                    raddr <= raddr + 1;
                end

                default: ;

                endcase

            end

            if(single_flag)
                state <= IDLE;

        end

        default:
            state <= IDLE;

        endcase

    end

end

endmodule
