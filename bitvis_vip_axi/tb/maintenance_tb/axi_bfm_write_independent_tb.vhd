--================================================================================================================================
-- Copyright 2026 UVVM
-- Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 and in the provided LICENSE.TXT.
--
-- Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
-- an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and limitations under the License.
--================================================================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library bitvis_vip_axi;
use bitvis_vip_axi.axi_bfm_pkg.all;

--hdlregression:tb
entity axi_bfm_write_independent_tb is
  generic(
    GC_NUM_AW_PIPE_STAGES : natural := 1;
    GC_NUM_W_PIPE_STAGES  : natural := 1;
    GC_DEFER_ADDRESS      : boolean := true
  );
end entity axi_bfm_write_independent_tb;

architecture tb of axi_bfm_write_independent_tb is
  constant C_SCOPE      : string := "AXI INDEPENDENT WRITE TB";
  constant C_CLK_PERIOD : time   := 10 ns;
  constant C_DATA       : t_slv_array(0 to 3)(31 downto 0) := (x"11111111", x"22222222", x"33333333", x"44444444");

  signal clk            : std_logic := '0';
  signal num_beats      : natural := 0;
  signal address_seen   : boolean := false;
  signal axi_if         : t_axi_if(write_address_channel(awid(0 downto 0), awaddr(7 downto 0), awuser(0 downto 0)),
                                   write_data_channel(wdata(31 downto 0), wstrb(3 downto 0), wuser(0 downto 0)),
                                   write_response_channel(bid(0 downto 0), buser(0 downto 0)),
                                   read_address_channel(arid(0 downto 0), araddr(7 downto 0), aruser(0 downto 0)),
                                   read_data_channel(rid(0 downto 0), rdata(31 downto 0), ruser(0 downto 0))) := init_axi_if_signals(8, 32, 1, 1);
begin
  clock_generator(clk, C_CLK_PERIOD);

  -- Buffer the complete W burst before accepting AW. The channels are independent.
  axi_if.write_data_channel.wready     <= '1';
  axi_if.write_address_channel.awready <= '1' when not GC_DEFER_ADDRESS or num_beats = C_DATA'length else '0';
  axi_if.write_response_channel.bid    <= "0";
  axi_if.write_response_channel.buser  <= "0";
  axi_if.write_response_channel.bresp  <= "00";
  axi_if.write_response_channel.bvalid <= '1' when address_seen and num_beats = C_DATA'length else '0';

  p_subordinate : process(clk)
  begin
    if rising_edge(clk) then
      if axi_if.write_data_channel.wvalid = '1' and axi_if.write_data_channel.wready = '1' then
        check_value(num_beats < C_DATA'length, TB_FAILURE, "No extra W handshake", C_SCOPE);
        check_value(axi_if.write_data_channel.wdata, C_DATA(num_beats), "Checking W payload", C_SCOPE);
        check_value(axi_if.write_data_channel.wstrb, "1111", "Checking byte strobes", C_SCOPE);
        check_value(axi_if.write_data_channel.wuser, "0", "Checking WUSER", C_SCOPE);
        check_value(axi_if.write_data_channel.wlast = '1', num_beats = C_DATA'high, "Checking WLAST", C_SCOPE);
        num_beats <= num_beats + 1;
      end if;
      if axi_if.write_address_channel.awvalid = '1' and axi_if.write_address_channel.awready = '1' then
        check_value(not address_seen, TB_FAILURE, "No duplicate AW handshake", C_SCOPE);
        check_value(axi_if.write_address_channel.awaddr, x"20", "Checking AWADDR", C_SCOPE);
        check_value(axi_if.write_address_channel.awlen, x"03", "Checking AWLEN", C_SCOPE);
        address_seen <= true;
      end if;
    end if;
  end process;

  p_main : process
    variable v_config : t_axi_bfm_config := C_AXI_BFM_CONFIG_DEFAULT;
    variable v_buser  : std_logic_vector(0 downto 0);
    variable v_bresp  : t_xresp;
  begin
    v_config.clock_period       := C_CLK_PERIOD;
    v_config.max_wait_cycles    := 20;
    v_config.num_aw_pipe_stages := GC_NUM_AW_PIPE_STAGES;
    v_config.num_w_pipe_stages  := GC_NUM_W_PIPE_STAGES;
    wait for 2 * C_CLK_PERIOD;

    axi_write(awaddr_value => to_unsigned(16#20#, 8),
              awlen_value  => x"03",
              wdata_value  => C_DATA,
              buser_value  => v_buser,
              bresp_value  => v_bresp,
              msg          => "W burst before AW handshake",
              clk          => clk,
              axi_if       => axi_if,
              scope        => C_SCOPE,
              config       => v_config);

    check_value(num_beats = C_DATA'length and address_seen, "Both write channels completed", C_SCOPE);
    check_value(v_bresp = OKAY, "Checking write response", C_SCOPE);
    check_value(v_buser, "0", "Checking BUSER", C_SCOPE);
    wait for C_CLK_PERIOD;
    report_alert_counters(FINAL);
    log(ID_LOG_HDR, "SIMULATION COMPLETED", C_SCOPE);
    std.env.stop;
    wait;
  end process;

  p_watchdog : process
  begin
    wait for 2 us;
    tb_failure("AXI write did not return", C_SCOPE);
    wait;
  end process;
end architecture tb;
