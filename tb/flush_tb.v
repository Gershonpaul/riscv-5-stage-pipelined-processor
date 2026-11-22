// Branch flush test for the 5-stage pipelined RISC-V core
// Author of this testbench: Gershon Paul Kolanti (Nov 2026)
// Design under test: open-source core by MERL-DSU (Apache License 2.0)
// Run from sim/flush_test (it contains its own memfile.hex)
// No NOP padding: the two instructions behind a taken beq write x11 and x12.
// With a working flush they must NOT change x11 and x12.
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

    // Log every register write seen in the write-back stage
    always @(posedge clk) begin
        if (rst && dut.RegWriteW === 1'b1 && dut.RDW !== 5'd0)
            $display("[t=%0t] WRITEBACK: x%0d <= %0d", $time, dut.RDW, dut.ResultW);
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
        $display("==== Branch flush test start ====");
        #2000;
        $display("==== Final register check ====");
        check_reg(5, 5);    // addi x5, x0, 5
        check_reg(6, 5);    // addi x6, x0, 5
        check_reg(7, 1);    // stays 1: both 'addi x7' after the beq are skipped
        check_reg(8, 7);    // branch target executed
        check_reg(11, 1);   // wrong-path slot 1 (addi x11,x0,11) must be flushed
        check_reg(12, 1);   // wrong-path slot 2 (addi x12,x0,12) must be flushed
        check_reg(9, 1);    // second beq NOT taken: executes
        check_reg(10, 2);   // second beq NOT taken: executes
        if (errors == 0)
            $display("==== RESULT: ALL TESTS PASSED ====");
        else
            $display("==== RESULT: %0d TEST(S) FAILED ====", errors);
        $finish;
    end
endmodule
