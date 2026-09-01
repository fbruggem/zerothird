GHDL = ghdl
STD = --std=08

TB = tb_axi4_lite

VHDL_FILES = axi4_lite.vhd tb_axi4_lite.vhd

all: run

analyze:
	$(GHDL) -a $(STD) $(VHDL_FILES)

elaborate: analyze
	$(GHDL) -e $(STD) $(TB)

run: elaborate
	$(GHDL) -r $(STD) $(TB) --vcd=$(TB).vcd

show: run
	surfer -c $(TB).surfer $(TB).vcd

clean:
	$(GHDL) --clean
	rm -f *.cf
	rm -f *.vcd
