
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_axi4_lite is
end entity tb_axi4_lite;

architecture sim of tb_axi4_lite is

      signal clk:  std_logic := '0';

begin

  slave : entity work.axi_lite_slave
    port map (

    );

  stimulus : process
  begin

    wait for 10 ns;
    clk <= '1';
    wait for 10 ns;
    clk <= '0';

    wait;

  end process;

end architecture sim;
