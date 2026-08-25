library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_receiver is
  port (
      clk: in std_logic;
      serial_in: in std_logic;
      shift_register_reset: buffer std_logic := '0';
      shift_register_enable: buffer std_logic := '1';
      shift_register_input: buffer std_logic;
      shift_register_output: buffer std_logic := '0'
  );
end entity uart_receiver;

architecture rtl of uart_receiver is

begin

  shift_register : entity work.shift_register
    port map (
      clk => clk,
      shift_input => serial_in, 
      shift_output => shift_register_output, 
      reset => shift_register_reset,
      enable => shift_register_enable
    );
  -- so i have 2 states
  -- State 1 -> wait for a low on the wire then sync clock and switch state
  -- State 2 -> read current bit into the shift register until you got 8 and switch an "im done bit" and go back to the state 1
  -- TODO: add your logic here

  shift_register_input <= serial_in;

end architecture rtl;
