library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter is
  port (
    clk : in  std_logic;
    reset : in std_logic;
    enable : in std_logic;
    number: out std_logic_vector(7 downto 0)
  );
end entity counter;

architecture rtl of counter is
  signal num: unsigned(7 downto 0) := (others => '0');

begin
  process (clk)
    begin
      if rising_edge(clk) then
        if reset = '1' then
          num <= (others => '0');
        elsif enable = '1' then
          num <= num + 1;
        end if;
      end if;

  end process;

  number <= std_logic_vector(num);

end architecture rtl;
