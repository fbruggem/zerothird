library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity uart_sender is
  port (
      clk: in std_logic;
      serial_out: out std_logic := '1';
      send: in std_logic;
      shift_register_reset: buffer std_logic := '0';
      shift_register_enable: buffer std_logic := '0';
      shift_register_input: buffer std_logic := '0';
      shift_register_output: buffer std_logic
      
  );
end entity uart_sender;

architecture rtl of uart_sender is

  type state_t is (IDLE, START, DATA, STOP);
  signal state: state_t := IDLE;
  signal time_counter: unsigned(7 downto 0) := (others => '0');
  signal bits_sent_counter: unsigned(7 downto 0) := (others => '0');
  -- State 1 - make it possible to read values into you - when you get the signal to send something switch into state 2
  -- State 2 - send over the bits one by one and go back to state 1
begin

      -- clk: in std_logic;
      -- shift_input: in std_logic;
      -- shift_output: out std_logic;
      -- reset: in std_logic := '0';
      -- enable: in std_logic := '0';

  shift_register : entity work.shift_register
    port map (
      clk => clk,
      shift_input => shift_register_input, 
      shift_output => shift_register_output, 
      reset => shift_register_reset,
      enable => shift_register_enable
    );

    process(clk)
      begin
        if rising_edge(clk) then
          if state = IDLE then
            serial_out <= '1';
            if send = '1' then 
              state <= START;
              time_counter <= (others => '0');
            end if;

          elsif state = START then
            if time_counter = 0 then
              serial_out <= '0';
              time_counter <= time_counter +1;
            elsif time_counter >= 9 then  
              state <= DATA;
              time_counter <= (others => '0');
              bits_sent_counter <= (others => '0');
              shift_register_enable <= '1';
            else 
              time_counter <= time_counter +1;
            end if;


          elsif state = DATA then 

            time_counter <= time_counter +1;

            if bits_sent_counter < 8 then 

              if time_counter = 0 then
                shift_register_enable <= '0';
              elsif time_counter >= 10 then
                -- bit sent here 
                bits_sent_counter <= bits_sent_counter + 1;
                shift_register_enable <= '1';
                time_counter <= (others => '0');
              else
                serial_out <= shift_register_output;
              end if;

            else
                state <= STOP;
            end if;



          elsif state = STOP then 
            serial_out <= '1';
            time_counter <= time_counter +1;
            if time_counter >= 10 then 
              state <= IDLE;
            end if;
          end if ;
          

        end if;

      end process;

end architecture rtl;
