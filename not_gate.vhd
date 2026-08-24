-- not_gate.vhd
--
-- THE DESIGN. This is the circuit itself. It has no main(), no stdin, no
-- printing. It is a description of a piece of hardware: one input wire, one
-- output wire, and an inverter between them. That is genuinely all.

library ieee;
use ieee.std_logic_1164.all;   -- gives us the std_logic type
use ieee.numeric_std.all;

entity not_gate is
  port (
    clk : in  std_logic;
    counter: out std_logic_vector(7 downto 0)
  );
end entity not_gate;

architecture rtl of not_gate is
  signal cnt: unsigned(7 downto 0) := (others => '0');

begin
  process (clk)
    begin
      if rising_edge(clk) then
        cnt <= cnt + 1;
      end if;

  end process;

  counter <= std_logic_vector(cnt);
  
end architecture rtl;
