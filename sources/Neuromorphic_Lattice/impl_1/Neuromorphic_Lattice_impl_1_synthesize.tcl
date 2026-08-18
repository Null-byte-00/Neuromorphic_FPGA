if {[catch {

# define run engine funtion
source [file join {D:/lscc/radiant/2026.1} scripts tcl flow run_engine.tcl]
# define global variables
global para
set para(gui_mode) "1"
set para(prj_dir) "D:/programs/Neuromophic_FPGA/sources/Neuromorphic_Lattice"
if {![file exists {D:/programs/Neuromophic_FPGA/sources/Neuromorphic_Lattice/impl_1}]} {
  file mkdir {D:/programs/Neuromophic_FPGA/sources/Neuromorphic_Lattice/impl_1}
}
cd {D:/programs/Neuromophic_FPGA/sources/Neuromorphic_Lattice/impl_1}
# synthesize IPs
# synthesize VMs
# propgate constraints
file delete -force -- Neuromorphic_Lattice_impl_1_cpe.ldc
::radiant::runengine::run_engine_newmsg cpe -syn lse -f "Neuromorphic_Lattice_impl_1.cprj" -a "LIFCL"  -o Neuromorphic_Lattice_impl_1_cpe.ldc
# synthesize top design
file delete -force -- Neuromorphic_Lattice_impl_1.vm Neuromorphic_Lattice_impl_1.ldc
::radiant::runengine::run_engine_newmsg synthesis -f "D:/programs/Neuromophic_FPGA/sources/Neuromorphic_Lattice/impl_1/Neuromorphic_Lattice_impl_1_lattice.synproj" -logfile "Neuromorphic_Lattice_impl_1_lattice.srp"
::radiant::runengine::run_postsyn [list -a LIFCL -p LIFCL-40 -t CABGA400 -sp 9_High-Performance_1.0V -oc Commercial -top -w -o Neuromorphic_Lattice_impl_1_syn.udb Neuromorphic_Lattice_impl_1.vm] [list Neuromorphic_Lattice_impl_1.ldc]

} out]} {
   ::radiant::runengine::runtime_log $out
   exit 1
}
