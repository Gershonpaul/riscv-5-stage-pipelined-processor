// FPGA wrapper for the 5-stage pipelined RISC-V core (Digilent Basys 3, Artix-7)
// Author of this wrapper: Gershon Paul Kolanti (Nov 2026)
// Core: open-source design by MERL-DSU (Apache License 2.0)
//
// The core has an active-low reset and no board I/O of its own. This wrapper:
//   - turns the board button (active high) into the core's active-low reset
//   - registers the write-back result onto 16 LEDs, so the synthesis tool keeps the whole core
`include "Pipeline_Top.v"

module fpga_top (
    input  wire        clk,         // 100 MHz board clock
    input  wire        btn_reset,   // press = reset the core
    output reg  [15:0] led
);
    wire [31:0] result;

    Pipeline_top core (
        .clk(clk),
        .rst(~btn_reset),
        .Result_out(result)
    );

    // Fold the upper half into the lower half so every result bit influences an output
    always @(posedge clk) begin
        led <= result[15:0] ^ result[31:16];
    end
endmodule
