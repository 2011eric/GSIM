set DESIGN GSIM
sh mkdir -p ../report
sh mkdir -p ../work
sh mkdir -p ../netlist
define_design_lib WORK -path ../work

analyze -format verilog "$DESIGN.v"
elaborate $DESIGN

source -echo -verbose  GSIM_DC.sdc

check_design > ../report/check_design.txt
check_timing > ../report/check_timing.txt

compile_ultra


write -format ddc     -hierarchy -output "../netlist/${DESIGN}_syn.ddc"
write -format verilog -hierarchy -output "./netlist/${DESIGN}_syn.v"
write_sdf -version 2.1  -context verilog -load_delay cell ../netlist/${DESIGN}_syn.sdf
write_sdc  ../netlist/${DESIGN}_syn.sdc -version 1.8


report_area -hierarchy > "../report/$DESIGN.area"
report_timing > "../report/$DESIGN.timing"
check_design
exit