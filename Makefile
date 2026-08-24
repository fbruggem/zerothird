GHDL = ghdl
STD = --std=08

# Change this to your testbench entity name
TB = tb_not_gate

VHDL_FILES = $(wildcard *.vhd)

all: run

analyze:
	$(GHDL) -a $(STD) $(VHDL_FILES)

elaborate: analyze
	$(GHDL) -e $(STD) $(TB)

run: elaborate
	$(GHDL) -r $(STD) $(TB) --vcd=$(TB).vcd

clean:
	$(GHDL) --clean
	rm -f *.cf
