library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axi_lite_slave is
  port (
    aclk          : in  std_logic;
    aresetn       : in  std_logic;

    s_axi_araddr  : in  std_logic_vector(3 downto 0);
    s_axi_arprot  : in  std_logic_vector(2 downto 0);
    s_axi_arvalid : in  std_logic;
    s_axi_arready : out std_logic;
    s_axi_rdata   : out std_logic_vector(31 downto 0);
    s_axi_rresp   : out std_logic_vector(1 downto 0);
    s_axi_rvalid  : out std_logic;
    s_axi_rready  : in  std_logic
  );

end entity axi_lite_slave;


architecture rtl of axi_lite_slave is

  type state_t is (IDLE, DATA);
  signal state: state_t := IDLE;
  signal cnt: unsigned(31 downto 0) := (others => '0');

begin


    process(aclk)
      begin
        if rising_edge(aclk) then

          if aresetn = '0' then 
            s_axi_arready <= '0';
            s_axi_rvalid <= '0';
            cnt <= (others => '0');
            s_axi_rdata <= (others => '0');
            state <= IDLE;
          else 
          cnt <= cnt + 1;
          if state = IDLE then
            if s_axi_arvalid = '1' then 
              state <= DATA;

              s_axi_arready <= '1';

              if s_axi_araddr = x"0" then 
                s_axi_rdata <= x"5A544852";
                s_axi_rresp <= "00";
              elsif s_axi_araddr = x"4" then 
                s_axi_rdata <= x"00000100";
                s_axi_rresp <= "00";
              elsif s_axi_araddr = x"8" then 
                s_axi_rdata <= std_logic_vector(cnt);
                s_axi_rresp <= "00";
              elsif s_axi_araddr = x"C" then 
                s_axi_rdata <= x"00000003";
                s_axi_rresp <= "00";
              else 
                s_axi_rresp <= "11"
              end if;

            end if;
          elsif state = DATA then 
            if s_axi_rready = '1' and s_axi_rvalid = '1' then
              s_axi_rvalid <= '0';
              state <= IDLE;
            else 
              -- i read the value 
              s_axi_arready <= '0';
              -- hey you can read data now
              s_axi_rvalid <= '1';
            end if;

          end if;
          end if;
          -- wait for command to read something
          -- then waiting for confirmation 
          -- now you are in the send back state 
          -- switch to waiting state again

        end if;

    end process;

end architecture rtl;
