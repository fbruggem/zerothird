-- tb_not_gate.vhd
--
-- THE TESTBENCH. This is the part that "runs".
--
-- Note the empty port list: `entity tb_not_gate is end;`. A testbench connects
-- to nothing, because it IS the outside world. It manufactures the input
-- signals, waits, and checks what came back.
--
-- Mental model: your design is a chip on a bench, and the testbench is the
-- lab technician poking it with a signal generator.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_not_gate is
end entity tb_not_gate;

architecture sim of tb_not_gate is

  signal clk: std_logic := '0';
  signal counter : std_logic_vector(7 downto 0);

begin

  dut : entity work.not_gate
    port map (
      clk => clk,
      counter => counter 
    );

  stimulus : process
  begin
    wait for 10 ns;

    for i in 0 to 30 loop
      clk <= '1';
      wait for 10 ns;                 -- let it settle, then look
      clk <= '0';
      wait for 10 ns;                 -- let it settle, then look
    end loop;
    --
    -- ------------------------------------------------------------------------
    -- -- Hold at the end. Without this the simulation stops the instant the
    -- -- last check passes, the final state has zero width, and the waveform
    -- -- appears to just fall off the edge. Small thing, endlessly confusing
    -- -- the first time.
    -- ------------------------------------------------------------------------
    -- wait for 20 ns;
    --
    -- report "all checks passed";
    wait;                           -- stop forever; ends the simulation

  end process;


end architecture sim;
