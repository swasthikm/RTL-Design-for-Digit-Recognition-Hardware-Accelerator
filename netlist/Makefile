#####################################################################
### Makefile to convert a Verilog from APR to a netlist for LVS
### THis is for a digital block using standard cells
### Not for top-level integration 
#####################################################################

##----------------------
## Setup parameters
##----------------------
my_design	= MLP_no_sram
apr_pg_v	= $(my_design).apr.pg.v
std_cdl		= /bgfs/ece2192-2020f/kit/standardcell/lib/files/cells_vtl.cdl

##----------------------
## v2lvs command
##----------------------
v2lvs:
	cp ../apr/save/$(my_design).apr.pg.v .
	v2lvs -i -v $(apr_pg_v) \
	-lsr $(std_cdl) \
	-s $(std_cdl) \
	-o $(my_design).cdl \
	-sn \
	-addpin VDD \
	-addpin VSS

	vim -O ${my_design}.cdl '+windo silent! 5,$$s/\//_/g' '+silent! wqa'
	
