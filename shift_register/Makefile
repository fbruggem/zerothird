GHDL = ghdl
STD = --std=08

TB = tb_shift_register

VHDL_FILES = shift_register.vhd tb_shift_register.vhd

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
