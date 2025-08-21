############################################################
# TCL script for Innovus (FSM)                                                     
# ASIC Physical Design Flow for Standard-cell Design 
# Modified from documentation from Prof. Victor P. Nelson
# eng.auburn.edu/~nelson/courses/elec5250_6250
############################################################
set my_design MLP_no_sram
set std_name gscl45nm
set process_node 45
setDesignMode -process ${process_node}

set lef_file /bgfs/ece2193-2024s/kit/standardcell/lib/files/gscl45nm.lef 
set lib_file /bgfs/ece2193-2024s/kit/standardcell/lib/files/gscl45nm.lib
set map_file /bgfs/ece2193-2024s/kit/standardcell/lib/files/gds2_encounter.map
set verilog_file /bgfs/ece2193-2024s/swm58/Project/source/MLP_no_sram_syn.v
set sdc_file /bgfs/ece2193-2024s/swm58/Project/source/MLP_no_sram.sdc
set mmmc_file /bgfs/ece2193-2024s/swm58/Project/source/MLP_no_sram.mmmc
#set io_file ../source/${my_design}.io
#set cpf_file ../source/${my_design}.cpf

###-----------------------------------------------------
### Design Import 
###-----------------------------------------------------

### Netlist Files
set design_netlisttype verilog
set init_verilog ${verilog_file}
set init_design_set_top 1 ;# 0 to auto-assign top cell 
set init_top_cell ${my_design} ;# specify if above = 1

### Physical/Technology Library
set init_lef_file ${lef_file}

###Floorplan I/O assignment file
#set init_io_file ${io_file}
#--> We are using a command 'editPin' later to place pins

### Power planning
set init_pwr_net {VDD}
set init_gnd_net {VSS}
# set init_cpf_file ${cpf_file}
### Analysis configuration
#set init_mmmc_file ${mmmc_file} 

init_design

###-----------------------------------------------------
### Floor planning a standard cell block 
### Assume no hand-placed blocks
###-----------------------------------------------------

### Specify floorplan
setDrawView fplan ;# Display floorplan view
floorPlan -flip s -r 1.2 0.7 5 5 5 5 
### -flip s: specifyies that the 2nd row flips from the bottom up
### -r: aspect ratio(h/w), density, core-to-IO spacing (left, bottom, right, top)

###-----------------------------------------------------
### Power planning
###-----------------------------------------------------
# Global Net Connection
globalNetConnect VDD -type pgpin -pin vdd -all
globalNetConnect VSS -type pgpin -pin gnd -all
globalNetConnect VDD -type tiehi
globalNetConnect VSS -type tielo
applyGlobalNets

### Add power rings
setAddRingMode -stacked_via_top_layer metal3 -stacked_via_bottom_layer metal1

set pspace 1
set pwidth 1
set poffset 1
addRing -nets {VDD VSS} \
	-type core_rings \
	-around user_defined \
	-center 0 \
	-spacing ${pspace} \
	-width ${pwidth} \
	-offset ${poffset} \
	-threshold auto \
	-layer {top metal1 bottom metal1 left metal2 right metal2} 

### Add stripes
#set swidth 1
#set sspace 1
#set sstart 10
#set sstop 0
#set ssetnum 1

#addStripe -nets {VDD VSS} \
	-layer metal2 \
	-direction vertical \
	-width ${swidth} \
	-spacing ${sspace} \
	-start_offset ${sstart} \
	-stop_offset ${sstop} \
	-number_of_sets ${ssetnum} \
	-block_ring_top_layer_limit metal3 \
	-block_ring_bottom_layer_limit metal1 \
	-padcore_ring_top_layer_limit metal3 \
	-padcore_ring_bottom_layer_limit metal1 \
	-max_same_layer_jog_length 3.0 \
	-snap_wire_center_to_grid Grid \
	-merge_stripes_value 1.5
	
### Special route - VDD/VSS wires between rings and core powe rails 
sroute -connect {blockPin padPin padRing corePin floatingStripe} \
	-allowJogging true \
	-allowLayerChange true \
	-blockPin useLef \
	-targetViaLayerRange {metal1 metal5}

###-----------------------------------------------------
### Place 
###-----------------------------------------------------

### Pin Editing
editPin -side TOP \
	-layer metal4 \
	-fixedPin 1 \
	-spreadType CENTER \
	-spacing 0.75 \
	-pin { weight_bias_mem_addr_o[*] weight_i[*] }
#--> Space by 4, Begin in center

editPin -side left \
	-layer metal4 \
	-fixedPin 1 \
	-spreadType CENTER \
	-spacing 0.75 \
	-pin { img_mem_addr_o[*] image_i[*]  }
#--> Space by 4, Begin in center

editPin -side RIGHT \
	-layer metal4 \
	-fixedPin 1 \
	-spreadType CENTER \
	-spacing 0.75 \
	-pin { dout_o[*] }
#--> Space by 4, Begin in center

editPin -side BOTTOM \
	-layer metal4 \
	-fixedPin 1 \
	-spreadType RANGE \
	-start {5 0} \
	-end {22 0} \
	-spreadDirection CounterClockwise \
	-pin { clk rst_b start_layer1_i start_layer2_i weight_bias_mem_req_o weight_bias_mem_ack_i img_mem_req_o img_mem_ack_i layer1_done_o layer2_done_o}
#--> Spread out evenly between end points

### Place standard cells setup 	
setPlaceMode -timingDriven true \
	-congEffort auto \
	-ignoreScan true

specifyCellPad BUF* -left 2 -right 2

place_design
setDrawView place

###-----------------------------------------------------
### Route
###-----------------------------------------------------
globalDetailRoute

###-----------------------------------------------------
### Physical
###-----------------------------------------------------

### Add Filler cells
set fillerCells [list FILL]
setFillerMode -corePrefix ${my_design}_FILL -core ${fillerCells}
addFiller -cell ${fillerCells} -prefix ${my_design}_FILL -markFixed 

###-----------------------------------------------------
### Design verification 
###-----------------------------------------------------

### Verify connectivity, looking for antennas, opens, loops, and unconnected pins
verifyConnectivity -type regular -error 50 -warning 50 -report ./save/Conn_regular.rpt
verifyConnectivity -type special -error 50 -warning 50 -report ./save/Conn_special.rpt

### Verify geometry with data from LEF file by checking widths, spacings, internal geometries of wires/objects 
verifyGeometry -allowSameCellViols -noSameNet -noOverlap -report ./save/Geom.rpt


###-----------------------------------------------------
### Write results  
### Export the def, lef, v, spef, sdf, and gds files
###-----------------------------------------------------

### def, lef
set lefDefOutVersion 5.8
defOut -floorplan -netlist -routing ./save/${my_design}.def
write_lef_abstract ./save/${my_design}.lef

### Verilog 
puts "--- Outputs ${my_design}.apr.v & ${my_design}.apr.pg.v files ---"
saveNetlist -excludeLeafCell ./save/${my_design}.apr.v
saveNetlist -excludeLeafCell -includePowerGround ./save/${my_design}.apr.pg.v

### spef, spf
puts "--- Save models for hierarchical flow ---"
saveModel -cts -sdf -spef -dir ./save/${my_design}_hier_data

extractRC -outfile ${my_design}.cap
rcOut -spf ./save/${my_design}.spf
rcOut -spef ./save/${my_design}.spef

### sdf
# delayCal -sdf ${my_deisgn}.sdf -idealclock
write_sdf ./save/${my_design}.apr.sdf

### gds
setStreamOutMode -snapToMGrid true
streamOut ./save/${my_design}.gds \
	-structureName ${my_design} \
	-mode ALL \
	-outputMacro \
	-mapFile ${map_file} 

win
