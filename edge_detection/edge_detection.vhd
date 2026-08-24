library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity edge_detection is
  port (
    clk: in std_logic;
    input: in std_logic := '0';
    safe: buffer std_logic := '0';
    bang: out std_logic := '0';
    hehe: out std_logic := '0'
  );
end entity edge_detection;

architecture rtl of edge_detection is

begin

  process (clk)
    begin
      if rising_edge(clk) then 
        safe <= input;
        bang <= not safe and input;
      end if;
      
  end process;
  
  hehe <= input xor clk;

end architecture rtl;
