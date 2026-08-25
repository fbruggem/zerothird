library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_receiver is
  port (
      clk: in std_logic;
      serial_in: in std_logic;
      shift_register_reset: buffer std_logic := '0';
      shift_register_enable: buffer std_logic := '0';
      shift_register_input: buffer std_logic;
      shift_register_output: buffer std_logic := '0';
      done: out std_logic := '0'
  );
end entity uart_receiver;

architecture rtl of uart_receiver is

  type state_t is (IDLE, START, DATA, STOP);
  signal state: state_t := IDLE;
  signal time_counter: unsigned(7 downto 0) := (others => '0');
  signal bits_sent_counter: unsigned(7 downto 0) := (others => '0');

begin

  shift_register : entity work.shift_register
    port map (
      clk => clk,
      shift_input => serial_in, 
      shift_output => shift_register_output, 
      reset => shift_register_reset,
      enable => shift_register_enable
    );

    process(clk)
      begin

        if rising_edge(clk) then
        if state = IDLE then

          done <= '0';
          if serial_in = '0' then
            state <= START;
            shift_register_reset <= '1';
            time_counter <= (others => '0');
          end if;

        elsif state = START then

          if time_counter = 12 then 
            time_counter <= (others => '0');
            state <= DATA;
          else 
            shift_register_reset <= '0';
            time_counter <= time_counter + 1;
          end if;

        elsif state = DATA then

            time_counter <= time_counter +1;

            if bits_sent_counter < 8 then 
              if time_counter = 0 then
                shift_register_enable <= '1';
                shift_register_input <= serial_in;

              elsif time_counter >= 10 then
                bits_sent_counter <= bits_sent_counter + 1;
                time_counter <= (others => '0');
              else
                shift_register_enable <= '0';
              end if;

            else
                state <= STOP;
                time_counter <= (others => '0');
            end if;

        elsif state = STOP then

          if time_counter = 5 then 
            time_counter <= (others => '0');
            state <= IDLE;
            done <= '1';
          else 
            time_counter <= time_counter + 1;
          end if;
        end if;
        -- so i have 2 states
        -- State 1 -> wait for a low on the wire then sync clock and switch state
        -- State 2 -> read current bit into the shift register until you got 8 and switch an "im done bit" and go back to the state 1

      end if;

    end process;
end architecture rtl;
