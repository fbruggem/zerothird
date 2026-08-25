GHDL = ghdl
STD = --std=08

TB = tb_uart

VHDL_FILES = shift_register.vhd uart_sender.vhd uart_receiver.vhd tb_uart.vhd

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
