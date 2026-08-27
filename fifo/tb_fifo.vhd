library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_fifo is
end entity tb_fifo;

architecture sim of tb_fifo is

  signal read: std_logic;
begin

  -- fifo : entity work.fifo
  --   port map (
  --     -- read => read
  --   );
    

  stimulus : process
  begin
    
    wait for 10 ns;


    wait;

  end process;

end architecture sim;
