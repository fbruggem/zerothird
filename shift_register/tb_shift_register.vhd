library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_shift_register is
end entity tb_shift_register;

architecture sim of tb_shift_register is

      signal clk:  std_logic := '0';
      signal shift_input: std_logic := '0';
      signal shift_output:  std_logic;
      signal reset: std_logic := '0';
      signal enable: std_logic := '0';
      -- set: in std_logic := '0';
      -- bits: buffer std_logic_vector(7 downto 0);
      -- enable matrix
      -- inside measurment
      -- out readable whole thing
begin

  dut : entity work.shift_register
    port map (
      clk => clk,
      shift_input => shift_input,
      shift_output => shift_output,
      enable => enable,
      reset => reset
    );

  stimulus : process
  begin

    enable <= '1';
    wait for 10 ns;

    shift_input <= '1';

    clk <= '1';
    wait for 10 ns;
    clk <= '0';
    wait for 10 ns;

    shift_input <= '0';

    clk <= '1';
    wait for 10 ns;
    clk <= '0';
    wait for 10 ns;


    shift_input <= '1';

    clk <= '1';
    wait for 10 ns;
    clk <= '0';
    wait for 10 ns;


    shift_input <= '0';
    enable <= '0';

    clk <= '1';
    wait for 10 ns;
    clk <= '0';
    wait for 10 ns;

    reset <= '1';

    clk <= '1';
    wait for 10 ns;
    clk <= '0';
    wait for 10 ns;

    wait;

  end process;

end architecture sim;
