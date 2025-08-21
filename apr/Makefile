##############################
### Makefile for INNOVUS
##############################
my_design = project1

run:
	innovus

apr:	
	innovus -init ../source/$(my_design).tcl -log $(my_design).log

clean:
	rm -rf *.cmd* *.log* *.rpt save timingReports

.phony: apr run clean
