// Copyright 2023 MERL-DSU

//    Licensed under the Apache License, Version 2.0 (the "License");
//    you may not use this file except in compliance with the License.
//    You may obtain a copy of the License at

//        http://www.apache.org/licenses/LICENSE-2.0

//    Unless required by applicable law or agreed to in writing, software
//    distributed under the License is distributed on an "AS IS" BASIS,
//    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//    See the License for the specific language governing permissions and
//    limitations under the License.

module Register_File(clk,rst,WE3,WD3,A1,A2,A3,RD1,RD2);

    input clk,rst,WE3;
    input [4:0]A1,A2,A3;
    input [31:0]WD3;
    output [31:0]RD1,RD2;

    reg [31:0] Register [31:0];

    always @ (posedge clk)
    begin
        if(WE3 & (A3 != 5'h00))
            Register[A3] <= WD3;
    end

    // Modified by Gershon Paul Kolanti, Nov 2026: write-through (WB->ID bypass).
    // If the instruction in write-back writes the register that decode reads in the
    // same cycle, return the value being written instead of the stale register content.
    assign RD1 = (rst==1'b0) ? 32'd0 :
                 ((WE3 == 1'b1) && (A3 != 5'h00) && (A3 == A1)) ? WD3 : Register[A1];
    assign RD2 = (rst==1'b0) ? 32'd0 :
                 ((WE3 == 1'b1) && (A3 != 5'h00) && (A3 == A2)) ? WD3 : Register[A2];

    initial begin
        Register[0] = 32'h00000000;
    end

endmodule