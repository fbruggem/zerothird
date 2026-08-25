library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shift_register is
  port (
      clk: in std_logic;
      shift_input: in std_logic;
      shift_output: out std_logic;
      reset: in std_logic := '0';
      enable: in std_logic := '0';
      buf: buffer std_logic_vector(7 downto 0) := (others => '0');
      set: in std_logic := '0';
      buf_in: in std_logic_vector(7 downto 0) := (others => '0');
      get: in std_logic := '0';
      buf_out: out std_logic_vector(7 downto 0) := (others => '0')
      
  );
end entity shift_register;

architecture rtl of shift_register is

begin
    process(clk)
      begin
        if rising_edge(clk) then
          if reset = '1' then
            buf <= (others => '0');
            shift_output <= '0';
          elsif set = '1' then 
            buf <= buf_in;
          elsif get = '1' then 
            buf_out <= buf;
          elsif enable = '1' then 
            buf <= buf(6 downto 0) & shift_input;
            shift_output <= buf(7);
          end if;
        end if;

      end process;

end architecture rtl;
