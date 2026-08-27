library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity synchronizer is
  port (
    input   : in    std_logic;
    between   : inout    std_logic;
    output   : out    std_logic;
    clk     : in    std_logic
end entity synchronizer;

architecture rtl of synchronizer is

begin

    process(clk)
      begin
        if rising_edge(clk)
          between <= input;
          output <= between;
        end if;
        

      end process;

end architecture rtl;
