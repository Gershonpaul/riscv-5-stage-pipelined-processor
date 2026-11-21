// Self-checking testbench for the 5-stage pipelined RISC-V core
// Author of this testbench: Gershon Paul Kolanti (Nov 2026)
// Design under test: open-source core by MERL-DSU (Apache License 2.0)

`timescale 1ns/1ps

module tb;

    reg clk = 1'b0;
    reg rst = 1'b0;

    integer errors = 0;

    Pipeline_top dut (.clk(clk), .rst(rst));

    always #50 clk = ~clk;

    initial begin
        rst = 1'b0;
        #200;
        rst = 1'b1;
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0);
    end

    always @(posedge clk) begin
        if (rst && dut.RegWriteW === 1'b1 && dut.RDW !== 5'd0) begin
            $display("[t=%0t] WRITEBACK: x%0d <= %0d (0x%08h)",
                     $time, dut.RDW, dut.ResultW, dut.ResultW);
        end
    end

    task check_reg;
        input integer idx;
        input [31:0] expected;
        reg [31:0] actual;
        begin
            actual = dut.Decode.rf.Register[idx];
            if (actual === expected)
                $display("PASS: x%0d = %0d (expected %0d)", idx, actual, expected);
            else begin
                $display("FAIL: x%0d = %0d (expected %0d)", idx, actual, expected);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        $display("==== Simulation start ====");
        #1300;
        $display("==== Final register check ====");
        check_reg(5,  32'd5);
        check_reg(6,  32'd3);
        check_reg(7,  32'd8);
        check_reg(8,  32'd0);
        check_reg(9,  32'd1);
        check_reg(10, 32'd1);
        if (errors == 0)
            $display("==== RESULT: ALL TESTS PASSED ====");
        else
            $display("==== RESULT: %0d TEST(S) FAILED ====", errors);
        $finish;
    end

endmodule