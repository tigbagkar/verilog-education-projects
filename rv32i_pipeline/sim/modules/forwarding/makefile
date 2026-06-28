TOP   = fwu_tb_top
FLIST = files.f
UCDB  = fwu.ucdb

VLOG = vlog
VSIM = vsim

.PHONY: run compile sim cov clean

compile:
	$(VLOG) -sv -cover bcest -f $(FLIST)

sim: sim.do
	$(VSIM) -c -coverage -onfinish stop $(TOP) -do sim.do

sim.do:
	@echo "run -all"                                      > sim.do
	@echo "coverage save -assert -cvg -codeAll $(UCDB)"  >> sim.do
	@echo "quit -f"                                      >> sim.do

cov:
	vcover report -details -all -du=work.fwu $(UCDB)

run: compile sim cov

clean:
	rm -rf work transcript *.wlf *.ucdb vsim.wlf sim.do