--HDLRegression:tb

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

library external_vip_apb;
use external_vip_apb.vvc_methods_pkg.all;
use external_vip_apb.td_vvc_framework_common_methods_pkg.all;
use external_vip_apb.apb_bfm_pkg.all;

entity apb_vvc_tb is
end apb_vvc_tb;

architecture tb of apb_vvc_tb is

  constant GC_ADDR_WIDTH : integer := 32;
  constant GC_DATA_WIDTH : integer := 32;

  signal presetn : std_logic := '1';
  signal apb_if  : t_apb_if(paddr(GC_ADDR_WIDTH-1 downto 0),
                            pwdata(GC_DATA_WIDTH-1 downto 0),
                            prdata(GC_DATA_WIDTH-1 downto 0),
                            pstrb(GC_DATA_WIDTH/8-1 downto 0)
                            );

begin

  --apb_if <= not clk after 5 ns;
  clock_generator(apb_if.pclk, 10 ns);

  i_dut : entity work.apb_register
  port map (
    PCLK    => apb_if.pclk,
    PRESETn => presetn,
    PADDR   => apb_if.paddr,
    PSEL    => apb_if.psel,
    PENABLE => apb_if.penable,
    PWRITE  => apb_if.pwrite,
    PWDATA  => apb_if.pwdata,
    PRDATA  => apb_if.prdata,
    PREADY  => apb_if.pready,
    PSLVERR => apb_if.pslverr
  );

  i_apb_vvc_inst : entity external_vip_apb.apb_vvc
    generic map(
      GC_ADDR_WIDTH => GC_ADDR_WIDTH,
      GC_DATA_WIDTH => GC_DATA_WIDTH
    )
    port map (
      apb_vvc_master_if => apb_if
    );

    i_ti_uvvm_engine : entity uvvm_vvc_framework.ti_uvvm_engine;

  main_test : process
    variable v_data : std_logic_vector(GC_DATA_WIDTH - 1 downto 0);
  begin
    await_uvvm_initialization(VOID);

    wait for 100 ns;
    presetn <= '0';
    wait for 100 ns;
    presetn <= '1';

    -- Test sequence
    for i in 1 to 100 loop
      v_data := random(GC_DATA_WIDTH);
      apb_write(APB_VVCT, 0, x"00001000", v_data, "1111", "000", "APB WRITE");
      apb_check(APB_VVCT, 0, x"00001000", v_data, "000", "APB CHECK");
    end loop;
    await_completion(APB_VVCT, 0, 1 ms);

    -- Testing without protection in the VVC command
    for i in 1 to 100 loop
      v_data := random(GC_DATA_WIDTH);
      apb_write(APB_VVCT, 0, x"00001000", v_data, "APB WRITE without protection in the VVC command");
      apb_check(APB_VVCT, 0, x"00001000", v_data, "APB CHECK without protection in the VVC command");
    end loop;

    -- Testing poll until
    apb_poll_until(APB_VVCT, 0, x"00001000", v_data, "APB CHECK without protection in the VVC command");

    await_completion(APB_VVCT, 0, 1 ms);

    -----------------------------------------------------------------------------
    -- Ending the simulation
    -----------------------------------------------------------------------------
    wait for 1 ns;                   -- to allow some time for completion
    report_alert_counters(FINAL);  -- Report final counters and print conclusion for simulation (Success/Fail)
    log(ID_LOG_HDR, "SIMULATION COMPLETED", C_SCOPE);
    -- Finish the simulation
    std.env.stop;
    wait;                               -- to stop completely

  end process;

end architecture tb;