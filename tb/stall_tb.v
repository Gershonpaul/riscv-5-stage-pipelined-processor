// Load-use stall test for the 5-stage pipelined RISC-V core
// Author of this testbench: Gershon Paul Kolanti (Nov 2026)
// Design under test: open-source core by MERL-DSU (Apache License 2.0)
// Run from sim/stall_test (it contains its own memfile.hex)
// Program: x5=5; mem[0]=x5; lw x6; add x7,x6,x6 (uses x6 right after the lw);
//          lw x8; add x10,x5,x8 (uses x8 right after the lw)
// Without a load-use stall the add instructions read the load address instead of the loaded data.
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
        $display("==== Load-use stall test start ====");
        #2000;
        $display("==== Final register check ====");
        check_reg(5, 5);    // addi x5, x0, 5
        check_reg(6, 5);    // lw x6, 0(x0) after sw x5, 0(x0)
        check_reg(7, 10);   // add x7, x6, x6 right after the lw: needs the stall
        check_reg(8, 5);    // lw x8, 0(x0)
        check_reg(10, 10);  // add x10, x5, x8 right after the lw: needs the stall
        if (errors == 0)
            $display("==== RESULT: ALL TESTS PASSED ====");
        else
            $display("==== RESULT: %0d TEST(S) FAILED ====", errors);
        $finish;
    end
endmodule
