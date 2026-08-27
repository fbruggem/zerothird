library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_uart is
end entity tb_uart;

architecture sim of tb_uart is

      signal clk:  std_logic := '0';
      signal serial: std_logic;
      signal done: std_logic := '0';
      signal send: std_logic := '0';

      signal set:  std_logic := '0';
      signal buf_sender: std_logic_vector(7 downto 0);
      signal buf_receiver: std_logic_vector(7 downto 0);
begin

  sender : entity work.uart_sender
    port map (
      clk => clk,
      serial_out => serial,
      send => send,
      buf_in => buf_sender,
      set => set
    );
    
  receiver : entity work.uart_receiver
    port map (
      clk => clk,
      serial_in => serial,
      done => done
    );

  stimulus : process
  begin
    
    buf_sender <= "10111011";
    set <= '1';

    wait for 10 ns;
    clk <= '1';
    wait for 10 ns;
    clk <= '0';

    wait for 10 ns;
    set <= '0';

    wait for 10 ns;

    send <= '1';
    wait for 10 ns;
    clk <= '1';
    wait for 10 ns;
    clk <= '0';
    wait for 10 ns;
    send <= '0';

    while done = '0' loop
      clk <= '1';
      wait for 10 ns;
      clk <= '0';
      wait for 10 ns;
    end loop;


    wait;

  end process;

end architecture sim;
