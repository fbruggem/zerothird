library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
  use work.gray_pkg.all;

entity fifo is
  port (
    wclk   : in    std_logic;
    wrst_n : in    std_logic;
    wr_en  : in    std_logic;
    wfull  : out   std_logic := '0';
    wdrop  : out   std_logic;
    wvalue : in std_logic;

    

    rclk   : in    std_logic;
    rrst_n : in    std_logic;
    rd_en  : in    std_logic;
    rempty : out   std_logic := '1';
    rvalue : out   std_logic
  );

end entity fifo;

architecture rtl of fifo is
    signal data: std_logic_vector(7 downto 0) := (others => '0');

    signal wptr: unsigned(3 downto 0) := (others => '0');

    signal rptr: unsigned(3 downto 0) := (others => '0');

    -- sync for the write half
    signal gray_wptr_desync: unsigned(3 downto 0) := (others => '0');
  
    signal w_sync: unsigned(3 downto 0) := (others => '0');
    signal gray_wptr_sync: unsigned(3 downto 0) := (others => '0');
-- sync for the read half
    signal gray_rptr_desync: unsigned(3 downto 0) := (others => '0');
  
    signal r_sync: unsigned(3 downto 0) := (others => '0');
    signal gray_rptr_sync: unsigned(3 downto 0) := (others => '0');

    signal r_sync_meta : unsigned(3 downto 0) := (others => '0');
    signal w_sync_meta : unsigned(3 downto 0) := (others => '0');

begin

    gray_wptr_desync <= to_gray((wptr));
    gray_rptr_desync <= to_gray((rptr));

    -- Write part
    process(wclk)
      begin

        if rising_edge(wclk) then
          -- Sync wirering write
          w_sync <= gray_wptr_desync;

          -- Sync wirering read
          r_sync_meta <= r_sync;
          gray_rptr_sync <= r_sync_meta;

          if wfull = '1' then
            if wr_en = '1' then
              wdrop <= '1';
            else
              wdrop <= '0';
            end if;
            if (to_gray(wptr)(3) /= gray_rptr_sync(3)) and (to_gray(wptr)(2) /= gray_rptr_sync(2)) and (to_gray(wptr)(1 downto 0) = gray_rptr_sync(1 downto 0)) then
              wfull <= '1';
            else
              wfull <= '0';
            end if;

          elsif wr_en = '1' then
            wdrop <= '0';
            data(to_integer(wptr(2 downto 0))) <= wvalue;
            wptr <= wptr +1;

            if (to_gray(wptr + 1)(3) /= gray_rptr_sync(3)) and (to_gray(wptr + 1)(2) /= gray_rptr_sync(2)) and (to_gray(wptr + 1)(1 downto 0) = gray_rptr_sync(1 downto 0)) then
              wfull <= '1';
            else
              wfull <= '0';
            end if;
          end if;
        end if;

    end process;

    -- Read part
    process(rclk)
      begin

        if rising_edge(rclk) then
          r_sync <= gray_rptr_desync;

          w_sync_meta <= w_sync;
          gray_wptr_sync <= w_sync_meta;

          if rempty = '1' then
            if gray_rptr_desync = gray_wptr_sync then
              rempty <= '1';
            else
              rempty <= '0';
            end if;
          elsif rd_en = '1' then 
            rvalue <= data(to_integer(rptr(2 downto 0)));
            rptr <= rptr + 1;

              if to_gray(rptr +1) = gray_wptr_sync then
                rempty <= '1';
              else
                rempty <= '0';
              end if;
        end if;

    end process;

end architecture rtl;
