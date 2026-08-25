library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_uart is
end entity tb_uart;

architecture sim of tb_uart is

      signal clk:  std_logic := '0';
      signal serial: std_logic;
      signal send: std_logic := '0';

begin

  sender : entity work.uart_sender
    port map (
      clk => clk,
      serial_out => serial,
      send => send
    );
    
  receiver : entity work.uart_receiver
    port map (
      clk => clk,
      serial_in => serial
    );

  stimulus : process
  begin
    wait for 10 ns;

    send <= '1';
    wait for 10 ns;

    for i in 0 to 300 loop
      clk <= '1';
      wait for 10 ns;
      clk <= '0';
      wait for 10 ns;
    end loop;

    wait;

  end process;

end architecture sim;
