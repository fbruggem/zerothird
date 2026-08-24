library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_edge_detection is
end entity tb_edge_detection;

architecture sim of tb_edge_detection is
  signal clk:  std_logic := '0';
  signal input:  std_logic := '0';
  signal bang: std_logic := '0';

begin

  dut : entity work.edge_detection
    port map (
      clk => clk,
      input => input,
      bang => bang
    );

  stimulus : process
  begin

    wait for 10 ns;

    for i in 0 to 3 loop
      -- button is pressed 
      input <= '1';
      wait for 10 ns;
      clk <= '1';
      wait for 10 ns;
      -- now we should se bang be active 
      clk <= '0';
      wait for 10 ns;
      clk <= '1';
      wait for 10 ns;
      -- now we should se bang be inactive 
      clk <= '0';
      wait for 10 ns;
      clk <= '1';
      wait for 10 ns;
      -- now we should se bang be inactive 
      clk <= '0';
      wait for 10 ns;
      clk <= '1';
      wait for 10 ns;
      -- now we should se bang be inactive 
      clk <= '0';
      wait for 10 ns;

      input <= '0';
      wait for 10 ns;
      clk <= '1';
      wait for 10 ns;
      clk <= '0';
      wait for 10 ns;

    end loop;

    wait;

  end process;

end architecture sim;
