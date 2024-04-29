TSMC13=/home/raid7_2/course/cvsd/CBDK_IC_Contest/CIC/Verilog/tsmc13.v
PATTERN := 1
CYCLE   := 10
syn:
	dc_shell-t -f syn.tcl
run_rtl:
	vcs  testfixture$(PATTERN).v  GSIM.v -full64 -R -debug_access+all +v2k -v $(TSMC13)  +define+CYCLE=$(CYCLE)
run_syn:
	vcs  testfixture$(PATTERN).v  GSIM_syn.v -full64 -R -debug_access+all +v2k  -v  $(TSMC13) +define+SDF +neg_tchk +define+CYCLE=$(CYCLE)