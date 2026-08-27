--=====================================================================
-- tb_fifo -- self checking testbench for the asynchronous fifo
--
-- What it does
--   * runs two independent clocks (write 100 MHz, read ~59 MHz) so the
--     gray code / synchroniser path is actually exercised
--   * pushes a known bit pattern in, pops it out again and compares
--   * checks rempty / wfull at the moments where they must change
--   * prints a PASS / FAIL summary at the end
--
-- What to look at in the wave view (all of it lives at the top level)
--   phase       which test step is running, see the PH_* constants
--   n_written   how many bits have been pushed so far
--   n_read      how many bits have been popped so far
--   n_errors    running error count, must stay 0
--   expected    what the next pop should return
--   got         what the pop actually returned
--   check_ok    pulses high on a good pop, low on a bad one
--
-- Test steps
--   1 PH_RESET   both domains in reset
--   2 PH_FLAGS   after reset: empty must be 1, full must be 0
--   3 PH_SINGLE  push 1 bit, it must show up, pop it, empty again
--   4 PH_FILL    push DEPTH bits, wfull must go high
--   5 PH_DRAIN   pop everything, rempty must go high
--   6 PH_STREAM  push and pop at the same time across both clocks
--   7 PH_DONE    summary
--=====================================================================

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library std;
  use std.env.all;

entity tb_fifo is
end entity tb_fifo;

architecture sim of tb_fifo is

  -- ------------------------------------------------------------------
  -- knobs
  -- ------------------------------------------------------------------
  constant WCLK_PERIOD : time    := 10 ns;              -- write domain
  constant RCLK_PERIOD : time    := 17 ns;              -- read domain, on purpose not a multiple
  constant DEPTH       : natural := 8;                  -- entries fifo.vhd can hold
  constant STREAM_N    : natural := 24;                 -- bits pushed in the streaming step
  constant POP_TIMEOUT : time    := 60 * RCLK_PERIOD;   -- how long a single pop may take
  constant SIM_TIMEOUT : time    := 100 us;             -- hard stop, keeps a broken dut from hanging

  -- test data, bit i of the stream is stream_bit(i)
  constant PATTERN : std_logic_vector(0 to 15) := "1011000111010010";

  function stream_bit (i : natural) return std_logic is
  begin
    return PATTERN(i mod PATTERN'length);
  end function stream_bit;

  -- ------------------------------------------------------------------
  -- phase codes, shown as a number in the wave view
  -- ------------------------------------------------------------------
  constant PH_RESET  : unsigned(3 downto 0) := x"1";
  constant PH_FLAGS  : unsigned(3 downto 0) := x"2";
  constant PH_SINGLE : unsigned(3 downto 0) := x"3";
  constant PH_FILL   : unsigned(3 downto 0) := x"4";
  constant PH_DRAIN  : unsigned(3 downto 0) := x"5";
  constant PH_STREAM : unsigned(3 downto 0) := x"6";
  constant PH_DONE   : unsigned(3 downto 0) := x"7";

  -- ------------------------------------------------------------------
  -- dut connections
  -- ------------------------------------------------------------------
  signal wclk   : std_logic := '0';
  signal wrst_n : std_logic := '0';
  signal wr_en  : std_logic := '0';
  signal wvalue : std_logic := '0';
  signal wfull  : std_logic;
  signal wdrop  : std_logic;

  signal rclk   : std_logic := '0';
  signal rrst_n : std_logic := '0';
  signal rd_en  : std_logic := '0';
  signal rempty : std_logic;
  signal rvalue : std_logic;

  -- ------------------------------------------------------------------
  -- observation / scoreboard, this is the stuff you want on screen
  -- ------------------------------------------------------------------
  signal phase     : unsigned(3 downto 0) := (others => '0');
  signal n_written : unsigned(7 downto 0) := (others => '0');
  signal n_read    : unsigned(7 downto 0) := (others => '0');
  signal n_errors  : unsigned(7 downto 0) := (others => '0');

  signal expected  : std_logic := 'U';
  signal got       : std_logic := 'U';
  signal check_ok  : std_logic := 'U';

  -- two error counters so that no signal has two drivers, summed below
  signal err_main  : unsigned(7 downto 0) := (others => '0');
  signal err_check : unsigned(7 downto 0) := (others => '0');

  -- handshake between the two halves of the testbench
  signal rd_active : std_logic := '0';   -- 1 = reader is allowed to pop
  signal clocks_on : boolean   := true;

begin

  -- ==================================================================
  -- clocks, two unrelated frequencies
  -- ==================================================================
  wclk <= not wclk after WCLK_PERIOD / 2 when clocks_on else '0';
  rclk <= not rclk after RCLK_PERIOD / 2 when clocks_on else '0';

  n_errors <= err_main + err_check;

  -- ==================================================================
  -- device under test
  -- ==================================================================
  dut : entity work.fifo
    port map (
      wclk   => wclk,
      wrst_n => wrst_n,
      wr_en  => wr_en,
      wfull  => wfull,
      wdrop  => wdrop,
      wvalue => wvalue,

      rclk   => rclk,
      rrst_n => rrst_n,
      rd_en  => rd_en,
      rempty => rempty,
      rvalue => rvalue
    );

  -- ==================================================================
  -- write side, this process owns the test flow
  -- ==================================================================
  stimulus : process

    -- push one bit, index decides the value so the reader knows it too.
    -- wr_en is held until the dut actually takes the write: reading wfull
    -- right after the wait gives the value the dut sampled at that edge, so
    -- wfull = '0' there means this write landed. without this the fifo can
    -- fill up between the check and the edge and the bit is lost silently.
    procedure push (i : natural) is
    begin
      wait until rising_edge(wclk);
      wvalue <= stream_bit(i);
      wr_en  <= '1';
      loop
        wait until rising_edge(wclk);
        exit when wfull = '0';
      end loop;
      wr_en  <= '0';
      n_written <= n_written + 1;
    end procedure push;

    procedure check (cond : boolean; msg : string) is
    begin
      if not cond then
        err_main <= err_main + 1;
        report "CHECK FAILED at " & time'image(now) & ": " & msg severity error;
      end if;
    end procedure check;

  begin

    ---------------------------------------------------------------- 1
    phase <= PH_RESET;
    report "phase 1: reset";
    wrst_n <= '0';
    rrst_n <= '0';
    wait for 5 * WCLK_PERIOD;
    wrst_n <= '1';
    rrst_n <= '1';
    wait for 5 * WCLK_PERIOD;

    ---------------------------------------------------------------- 2
    phase <= PH_FLAGS;
    report "phase 2: flags after reset";
    check(rempty = '1', "rempty should be 1 after reset, is " & std_logic'image(rempty));
    check(wfull  = '0', "wfull should be 0 after reset, is "  & std_logic'image(wfull));

    ---------------------------------------------------------------- 3
    phase <= PH_SINGLE;
    report "phase 3: single bit in, single bit out";
    push(0);
    wait for 4 * RCLK_PERIOD;                       -- let the pointer cross over
    check(rempty = '0', "rempty should drop after one write");

    rd_active <= '1';                               -- let the reader take it
    wait until n_read = 1 for POP_TIMEOUT;
    check(n_read = 1, "reader did not pop the first bit in time");
    rd_active <= '0';

    wait for 4 * RCLK_PERIOD;
    check(rempty = '1', "rempty should be 1 again after the fifo was drained");

    ---------------------------------------------------------------- 4
    phase <= PH_FILL;
    report "phase 4: fill it up, wfull must rise";
    for i in 1 to DEPTH loop
      push(i);
    end loop;
    wait for 2 * WCLK_PERIOD;
    check(wfull = '1', "wfull should be 1 after DEPTH writes");

    -- a write while full must not be swallowed silently
    wait until rising_edge(wclk);
    wvalue <= '1';
    wr_en  <= '1';
    wait until rising_edge(wclk);
    wr_en  <= '0';
    check(wfull = '1', "wfull must stay 1 while the fifo is full");

    ---------------------------------------------------------------- 5
    phase <= PH_DRAIN;
    report "phase 5: drain it, rempty must rise";
    rd_active <= '1';
    wait until n_read = DEPTH + 1 for DEPTH * POP_TIMEOUT;
    check(n_read = DEPTH + 1, "reader did not drain the fifo in time");
    rd_active <= '0';

    wait for 4 * RCLK_PERIOD;
    check(rempty = '1', "rempty should be 1 after the drain");
    check(wfull  = '0', "wfull should be 0 after the drain");

    ---------------------------------------------------------------- 6
    phase <= PH_STREAM;
    report "phase 6: writing and reading at the same time";
    rd_active <= '1';
    for i in DEPTH + 1 to DEPTH + STREAM_N loop
      push(i);   -- push blocks by itself while the fifo is full
    end loop;

    wait until n_read = n_written for STREAM_N * POP_TIMEOUT;
    check(n_read = n_written,
          "reader lost data: wrote " & integer'image(to_integer(n_written)) &
          ", read " & integer'image(to_integer(n_read)));
    rd_active <= '0';

    ---------------------------------------------------------------- 7
    phase <= PH_DONE;
    wait for 10 * RCLK_PERIOD;

    report "----------------------------------------------------";
    report "bits written : " & integer'image(to_integer(n_written));
    report "bits read    : " & integer'image(to_integer(n_read));
    report "errors       : " & integer'image(to_integer(n_errors));
    if n_errors = 0 then
      report "RESULT: PASS" severity note;
    else
      report "RESULT: FAIL" severity error;
    end if;
    report "----------------------------------------------------";

    clocks_on <= false;
    wait for 1 ns;
    finish;

  end process stimulus;

  -- ==================================================================
  -- read side, pops whenever it is allowed to and scores every bit
  -- ==================================================================
  checker : process
    variable idx : natural := 0;   -- how many bits we have popped
  begin

    wait until rrst_n = '1';

    loop
      wait until rising_edge(rclk);

      if rd_active = '1' and rempty = '0' then

        expected <= stream_bit(idx);

        rd_en <= '1';
        wait until rising_edge(rclk);     -- dut samples rd_en here
        rd_en <= '0';
        wait until rising_edge(rclk);     -- rvalue is registered by now

        got <= rvalue;

        if rvalue = stream_bit(idx) then
          check_ok <= '1';
        else
          check_ok <= '0';
          err_check <= err_check + 1;
          report "DATA MISMATCH at " & time'image(now) &
                 ": bit " & integer'image(idx) &
                 " expected " & std_logic'image(stream_bit(idx)) &
                 " got " & std_logic'image(rvalue) severity error;
        end if;

        idx    := idx + 1;
        n_read <= to_unsigned(idx, n_read'length);
      end if;

    end loop;

  end process checker;

  -- ==================================================================
  -- watchdog, so a stuck dut still ends the simulation
  -- ==================================================================
  watchdog : process
  begin
    wait for SIM_TIMEOUT;
    report "WATCHDOG: simulation did not finish within " & time'image(SIM_TIMEOUT) &
           " -- the dut is most likely stuck" severity failure;
    wait;
  end process watchdog;

end architecture sim;
