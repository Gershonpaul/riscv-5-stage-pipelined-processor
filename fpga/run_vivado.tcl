# Vivado batch flow: synthesis + implementation + reports for the RISC-V core (Artix-7, Basys 3)
# Run from the repository root:  vivado -mode batch -source fpga/run_vivado.tcl
set root   [file normalize [file join [file dirname [info script]] ..]]
set rtl    [file join $root rtl]
set outdir [file join $root fpga reports]
file mkdir $outdir

# Instruction_Memory.v loads "memfile.hex" by relative path, so run inside the report folder
file copy -force [file join $root sim memfile.hex] [file join $outdir memfile.hex]
cd $outdir

set_part xc7a35tcpg236-1
read_verilog [file join $root fpga fpga_top.v]
read_xdc     [file join $root fpga constraints.xdc]
set_property include_dirs [list $rtl] [current_fileset]

synth_design -top fpga_top -part xc7a35tcpg236-1 -include_dirs [list $rtl]
report_utilization -file [file join $outdir utilization_synth.rpt]

opt_design
place_design
route_design

report_utilization                -file [file join $outdir utilization_impl.rpt]
report_utilization -hierarchical  -file [file join $outdir utilization_hierarchical.rpt]
report_timing_summary             -file [file join $outdir timing_summary.rpt]
puts "DONE: reports written to $outdir"
