GHDL = ghdl
STD = --std=08

# Change this to your testbench entity name
TB = tb_counter

VHDL_FILES = counter.vhd tb_counter.vhd

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
