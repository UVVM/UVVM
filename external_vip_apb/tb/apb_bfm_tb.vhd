--HDLRegression:tb

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;
library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

library external_vip_apb;

use external_vip_apb.apb_bfm_pkg.all;
use external_vip_apb.vvc_methods_pkg.all;

entity apb_bfm_tb is
end apb_bfm_tb;

architecture tb of apb_bfm_tb is

  constant C_ADDR_WIDTH : integer := 32;
  constant C_DATA_WIDTH : integer := 32;
  constant C_REG_ADDR   : unsigned(C_ADDR_WIDTH-1 downto 0) := x"00001000";

  signal clk                    : std_logic := '0';
  signal presetn                : std_logic := '1';
  signal paddr                  : std_logic_vector(C_ADDR_WIDTH - 1 downto 0);
  signal pprot                  : std_logic_vector(2 downto 0);
  signal psel                   : std_logic;
  signal penable                : std_logic;
  signal pwrite                 : std_logic;
  signal pwdata                 : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
  signal pstrb                  : std_logic_vector(3 downto 0);
  signal prdata                 : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
  signal pready                 : std_logic;
  signal pslverr                : std_logic;
  signal number_of_wait_states  : integer;
  signal terminate_loop         : std_logic := '0';

begin

  clk <= not clk after 5 ns;

  i_dut : entity work.apb_register
    generic map (
      GC_ADDR_WIDTH => C_ADDR_WIDTH,
      GC_DATA_WIDTH => C_DATA_WIDTH
    )
    port map (
      -- APB Interface
      PCLK                  => clk,
      PRESETn               => presetn,
      PADDR                 => paddr,
      PSEL                  => psel,
      PENABLE               => penable,
      PWRITE                => pwrite,
      PWDATA                => pwdata,
      PRDATA                => prdata,
      PREADY                => pready,
      PSLVERR               => pslverr,
      -- Control signals
      number_of_wait_states => number_of_wait_states
    );


  main_test : process
    variable v_data : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
  begin
    wait for 100 ns;
    presetn <= '0';
    wait for 100 ns;
    presetn <= '1';

    -- Test sequence
    log(ID_LOG_HDR, "Testing APB write/read/check with zero waitstates");
    number_of_wait_states <= 0;
    apb_write(C_REG_ADDR, X"01234567", "1111", "000", "Test", clk, paddr, pprot, psel, penable, pwrite, pwdata, pstrb, pready, pslverr);
    apb_read(C_REG_ADDR, v_data, "000", "Test", clk, paddr, pprot, psel, penable, pwrite, prdata, pstrb, pready, pslverr);
    check_value(v_data, X"01234567", ERROR, "Data verification");
    apb_check(C_REG_ADDR, X"01234567", "000", "Test", clk, paddr, pprot, psel, penable, pwrite, prdata, pstrb, pready, pslverr);

    log(ID_LOG_HDR, "Testing APB write/read/check with one waitstate");
    number_of_wait_states <= 1;
    apb_write(C_REG_ADDR, X"89ABCDEF", "1111", "000", "Test", clk, paddr, pprot, psel, penable, pwrite, pwdata, pstrb, pready, pslverr);
    apb_read(C_REG_ADDR, v_data, "000", "Test", clk, paddr, pprot, psel, penable, pwrite, prdata, pstrb, pready, pslverr);
    check_value(v_data, X"89ABCDEF", ERROR, "Data verification");
    apb_check(C_REG_ADDR, X"89ABCDEF", "000", "Test", clk, paddr, pprot, psel, penable, pwrite, prdata, pstrb,  pready, pslverr);
    
    log(ID_LOG_HDR, "Testing APB write/read/check with ten waitstates");
    number_of_wait_states <= 10;
    apb_write(C_REG_ADDR, X"AABBCCDD", "1111", "000", "Test", clk, paddr, pprot, psel, penable, pwrite, pwdata, pstrb, pready, pslverr);
    apb_read(C_REG_ADDR, v_data, "000", "Test", clk, paddr, pprot, psel, penable, pwrite, prdata, pstrb, pready, pslverr);
    check_value(v_data, X"AABBCCDD", ERROR, "Data verification");
    apb_check(C_REG_ADDR, X"AABBCCDD", "000", "Test", clk, paddr, pprot, psel, penable, pwrite, prdata, pstrb, pready, pslverr);

    log(ID_LOG_HDR, "Testing APB check with don't care values");
    apb_write(C_REG_ADDR, X"00112233", "1111", "000", "Test", clk, paddr, pprot, psel, penable, pwrite, pwdata, pstrb, pready, pslverr);
    apb_check(C_REG_ADDR, X"0011--33", "000", "Test", clk, paddr, pprot, psel, penable, pwrite, prdata, pstrb, pready, pslverr);

    log(ID_LOG_HDR, "Testing APB poll until");
    apb_poll_until(C_REG_ADDR, X"0011--33", "000", 1, 1 ms, "Testing apb_poll_until", clk, paddr, pprot, psel, penable, pwrite, prdata, pstrb, pready, pslverr, terminate_loop);
    
    report_alert_counters(FINAL);
    std.env.stop;
  end process;

end architecture tb;
