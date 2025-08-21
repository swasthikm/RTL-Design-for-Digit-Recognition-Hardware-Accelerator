#######################################################
#                                                     
#  Innovus Command Logging File                     
#  Created on Mon Dec  9 22:59:43 2024                
#                                                     
#######################################################

#@(#)CDS: Innovus v19.12-s087_1 (64bit) 11/11/2019 17:32 (Linux 2.6.32-431.11.2.el6.x86_64)
#@(#)CDS: NanoRoute 19.12-s087_1 NR191024-1807/19_12-UB (database version 18.20, 485.7.1) {superthreading v1.51}
#@(#)CDS: AAE 19.12-s033 (64bit) 11/11/2019 (Linux 2.6.32-431.11.2.el6.x86_64)
#@(#)CDS: CTE 19.12-s033_1 () Oct 24 2019 14:09:28 ( )
#@(#)CDS: SYNTECH 19.12-s008_1 () Oct  6 2019 23:25:36 ( )
#@(#)CDS: CPE v19.12-s079
#@(#)CDS: IQuantus/TQuantus 19.1.3-s095 (64bit) Fri Aug 30 18:16:09 PDT 2019 (Linux 2.6.32-431.11.2.el6.x86_64)

set_global _enable_mmmc_by_default_flow      $CTE::mmmc_default
suppressMessage ENCEXT-2799
setDesignMode -process 45
set init_verilog /bgfs/ece2193-2024s/swm58/Project/source/MLP_no_sram_syn.v
set init_top_cell MLP_no_sram
set init_lef_file /bgfs/ece2193-2024s/kit/standardcell/lib/files/gscl45nm.lef
set init_pwr_net VDD
set init_gnd_net VSS
win
