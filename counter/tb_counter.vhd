library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_counter is
end entity tb_counter;

architecture sim of tb_counter is

  signal clk: std_logic := '0';
  signal reset: std_logic := '0';
  signal enable: std_logic := '0';
  signal counter : std_logic_vector(7 downto 0);

begin

  dut : entity work.counter
    port map (
      clk => clk,
      number => counter,
      reset => reset,
      enable => enable
    );

  stimulus : process
  begin
    enable <= '1';
    wait for 10 ns;

    for i in 0 to 30 loop
      clk <= '1';
      wait for 10 ns;
      clk <= '0';
      wait for 10 ns;
    end loop;

    reset <= '1';
    clk <= '1';
    wait for 10 ns;
    clk <= '0';
    wait for 10 ns;
    reset <= '0';

    for i in 0 to 30 loop
      clk <= '1';
      wait for 10 ns;
      clk <= '0';
      wait for 10 ns;
    end loop;

    wait;

  end process;


end architecture sim;
