--================================================================================================================================
-- Copyright 2024 UVVM
-- Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 and in the provided LICENSE.TXT.
--
-- Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
-- an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and limitations under the License.
--================================================================================================================================
-- Note : Any functionality not explicitly described in the documentation is subject to change at any time
----------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-- Description   : See library quick reference (under 'doc') and README-file(s)
------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library bitvis_vip_axi;
use bitvis_vip_axi.axi_bfm_pkg.all;
use bitvis_vip_axi.axi_slave_model_pkg.all;

--hdlregression:tb
entity axi_bfm_tb is
  generic(
    GC_TESTCASE : string := "UVVM"
  );
end entity axi_bfm_tb;

architecture tb of axi_bfm_tb is

  component axi_slave_model is
    generic(
      C_MEMORY_SIZE  : integer               := 4096; -- size in bytes
      C_MEMORY_START : unsigned(31 downto 0) := x"00000000" -- address offset to start on
    );
    port(
      aclk        : in  std_logic;
      aresetn     : in  std_logic;
      wr_port_in  : in  t_axi_wr_slave_in_if;
      wr_port_out : out t_axi_wr_slave_out_if;
      rd_port_in  : in  t_axi_rd_slave_in_if;
      rd_port_out : out t_axi_rd_slave_out_if
    );
  end component axi_slave_model;

  constant C_SCOPE      : string := "AXI TB";
  constant C_CLK_PERIOD : time   := 10 ns;

  signal clk     : std_logic := '0';
  signal aresetn : std_logic := '0';

  signal axi_if : t_axi_if(write_address_channel(awid(8 - 1 downto 0),
                                                 awaddr(32 - 1 downto 0),
                                                 awuser(8 - 1 downto 0)),
                           write_data_channel(wdata(32 - 1 downto 0),
                                              wstrb(4 - 1 downto 0),
                                              wuser(8 - 1 downto 0)),
                           write_response_channel(bid(8 - 1 downto 0),
                                                  buser(8 - 1 downto 0)),
                           read_address_channel(arid(8 - 1 downto 0),
                                                araddr(32 - 1 downto 0),
                                                aruser(8 - 1 downto 0)),
                           read_data_channel(rid(8 - 1 downto 0),
                                             rdata(32 - 1 downto 0),
                                             ruser(8 - 1 downto 0)));

begin

  clock_generator(clk, C_CLK_PERIOD);

  i_axi_slave_model : axi_slave_model
    generic map(
      C_MEMORY_SIZE  => 4096,           -- size in bytes
      C_MEMORY_START => x"00000000"     -- address offset to start on
    )
    port map(
      aclk                => clk,
      aresetn             => aresetn,
      -- Inputs
      -- write address channel
      wr_port_in.awid     => axi_if.write_address_channel.awid,
      wr_port_in.awaddr   => axi_if.write_address_channel.awaddr,
      wr_port_in.awlen    => axi_if.write_address_channel.awlen,
      wr_port_in.awsize   => axi_if.write_address_channel.awsize,
      wr_port_in.awburst  => axi_if.write_address_channel.awburst,
      wr_port_in.awlock   => axi_if.write_address_channel.awlock,
      wr_port_in.awcache  => axi_if.write_address_channel.awcache,
      wr_port_in.awprot   => axi_if.write_address_channel.awprot,
      wr_port_in.awqos    => axi_if.write_address_channel.awqos,
      wr_port_in.awregion => axi_if.write_address_channel.awregion,
      wr_port_in.awuser   => axi_if.write_address_channel.awuser,
      wr_port_in.awvalid  => axi_if.write_address_channel.awvalid,
      -- write data channel
      wr_port_in.wdata    => axi_if.write_data_channel.wdata,
      wr_port_in.wstrb    => axi_if.write_data_channel.wstrb,
      wr_port_in.wlast    => axi_if.write_data_channel.wlast,
      wr_port_in.wuser    => axi_if.write_data_channel.wuser,
      wr_port_in.wvalid   => axi_if.write_data_channel.wvalid,
      -- write response channel
      wr_port_in.bready   => axi_if.write_response_channel.bready,
      -- read address channel
      rd_port_in.arid     => axi_if.read_address_channel.arid,
      rd_port_in.araddr   => axi_if.read_address_channel.araddr,
      rd_port_in.arlen    => axi_if.read_address_channel.arlen,
      rd_port_in.arsize   => axi_if.read_address_channel.arsize,
      rd_port_in.arburst  => axi_if.read_address_channel.arburst,
      rd_port_in.arlock   => axi_if.read_address_channel.arlock,
      rd_port_in.arcache  => axi_if.read_address_channel.arcache,
      rd_port_in.arprot   => axi_if.read_address_channel.arprot,
      rd_port_in.arqos    => axi_if.read_address_channel.arqos,
      rd_port_in.arregion => axi_if.read_address_channel.arregion,
      rd_port_in.aruser   => axi_if.read_address_channel.aruser,
      rd_port_in.arvalid  => axi_if.read_address_channel.arvalid,
      -- read data channel
      rd_port_in.rready   => axi_if.read_data_channel.rready,
      -- Outputs
      -- write address channel
      wr_port_out.awready => axi_if.write_address_channel.awready,
      -- write data channel
      wr_port_out.wready  => axi_if.write_data_channel.wready,
      -- write response channel
      wr_port_out.bid     => axi_if.write_response_channel.bid,
      wr_port_out.bresp   => axi_if.write_response_channel.bresp,
      wr_port_out.buser   => axi_if.write_response_channel.buser,
      wr_port_out.bvalid  => axi_if.write_response_channel.bvalid,
      -- read address channel
      rd_port_out.arready => axi_if.read_address_channel.arready,
      -- read data channel
      rd_port_out.rid     => axi_if.read_data_channel.rid,
      rd_port_out.rdata   => axi_if.read_data_channel.rdata,
      rd_port_out.rresp   => axi_if.read_data_channel.rresp,
      rd_port_out.rlast   => axi_if.read_data_channel.rlast,
      rd_port_out.ruser   => axi_if.read_data_channel.ruser,
      rd_port_out.rvalid  => axi_if.read_data_channel.rvalid
    );

  p_main : process
    variable axi_bfm_config       : t_axi_bfm_config                   := C_AXI_BFM_CONFIG_DEFAULT;
    variable v_buser_value        : std_logic_vector(7 downto 0);
    variable v_bresp_value        : t_xresp;
    variable v_rdata_value        : t_slv_array(0 to 255)(31 downto 0);
    variable v_rresp_value        : t_xresp_array(0 to 255);
    variable v_ruser_value        : t_slv_array(0 to 255)(7 downto 0);
    variable v_single_rdata_value : std_logic_vector(31 downto 0);
    variable v_write_data         : t_slv_array(0 to 255)(31 downto 0) := (others => (others => '0'));
    variable v_write_data_narrow  : t_slv_array(0 to 1)(7 downto 0)    := (x"12", x"34");
    variable v_wstrb_narrow       : t_slv_array(0 to 1)(0 downto 0)    := ("1", "1");
    variable v_wuser_narrow       : t_slv_array(0 to 1)(0 downto 0)    := ("1", "1");
    variable v_buser_narrow       : std_logic_vector(0 downto 0);
    variable v_ruser_narrow       : t_slv_array(0 to 1)(0 downto 0)    := ("0", "0");
    variable v_rdata_narrow       : t_slv_array(0 to 1)(7 downto 0);
    variable v_write_data_wide    : t_slv_array(0 to 1)(39 downto 0)   := (x"0087654321", x"009ABCDEF0");
    variable v_wstrb_wide         : t_slv_array(0 to 1)(7 downto 0)    := (x"0F", x"0F");
    variable v_wuser_wide         : t_slv_array(0 to 1)(15 downto 0)   := (x"0001", x"0001");
    variable v_buser_wide         : std_logic_vector(15 downto 0);
    variable v_ruser_wide         : t_slv_array(0 to 1)(15 downto 0)   := (x"0000", x"0000");
    variable v_rdata_wide         : t_slv_array(0 to 1)(39 downto 0);
  begin
    -- To avoid that log files from different test cases (run in separate
    -- simulations) overwrite each other.
    set_log_file_name(GC_TESTCASE & "_Log.txt");
    set_alert_file_name(GC_TESTCASE & "_Alert.txt");

    axi_bfm_config.clock_period       := C_CLK_PERIOD;
    axi_bfm_config.num_aw_pipe_stages := 0;
    axi_bfm_config.num_w_pipe_stages  := 0;
    axi_bfm_config.num_b_pipe_stages  := 0;
    axi_bfm_config.num_ar_pipe_stages := 0;
    axi_bfm_config.num_r_pipe_stages  := 0;
    axi_if                            <= init_axi_if_signals(32, 32, 8, 8);

    -- Print the configuration to the log
    report_global_ctrl(VOID);
    report_msg_id_panel(VOID);

    -- Releasing reset
    wait for C_CLK_PERIOD * 2;
    aresetn <= '1';
    wait for C_CLK_PERIOD * 2;

    --------------------------------------------------------------------------------------------------------------------
    -- Testing write/read/check procedures
    --------------------------------------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Testing write/read/check procedures");
    axi_write(awaddr_value  => x"00000004",
              awlen_value   => x"01",
              awsize_value  => 4,
              awburst_value => INCR,
              awid_value    => x"12",
              wdata_value   => t_slv_array'(x"12345678", x"33333333"),
              buser_value   => v_buser_value,
              bresp_value   => v_bresp_value,
              msg           => "Testing axi write",
              clk           => clk,
              axi_if        => axi_if,
              scope         => C_SCOPE,
              config        => axi_bfm_config);

    axi_read(arid_value    => x"34",
             araddr_value  => x"00000004",
             arlen_value   => x"01",
             arsize_value  => 4,
             arburst_value => INCR,
             rdata_value   => v_rdata_value,
             rresp_value   => v_rresp_value,
             ruser_value   => v_ruser_value,
             msg           => "Testing axi read",
             clk           => clk,
             axi_if        => axi_if,
             scope         => C_SCOPE,
             config        => axi_bfm_config);
    check_value(v_rdata_value(0), x"12345678", "Checking read data", C_SCOPE);
    check_value(v_rdata_value(1), x"33333333", "Checking read data", C_SCOPE);

    axi_check(arid_value    => x"34",
              araddr_value  => x"00000004",
              arlen_value   => x"01",
              arsize_value  => 4,
              arburst_value => INCR,
              rdata_exp     => t_slv_array'(x"12345678", x"33333333"),
              msg           => "Testing axi check",
              clk           => clk,
              axi_if        => axi_if,
              scope         => C_SCOPE,
              config        => axi_bfm_config);

    --------------------------------------------------------------------------------------------------------------------
    -- Testing minimum burst length
    --------------------------------------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Testing minimum burst length");
    v_write_data(0) := x"55555555";
    axi_write(awaddr_value => x"00000010",
              awlen_value  => x"00",
              awsize_value => 4,
              wdata_value  => v_write_data(0 to 0),
              buser_value  => v_buser_value,
              bresp_value  => v_bresp_value,
              msg          => "Writing with minimum burst length",
              clk          => clk,
              axi_if       => axi_if,
              scope        => C_SCOPE,
              config       => axi_bfm_config);

    axi_check(araddr_value => x"00000010",
              arlen_value  => x"00",
              arsize_value => 4,
              rdata_exp    => v_write_data(0 to 0),
              msg          => "Checking with minimum burst length",
              clk          => clk,
              axi_if       => axi_if,
              scope        => C_SCOPE,
              config       => axi_bfm_config);

    axi_read(araddr_value => x"00000010",
             arlen_value  => x"00",
             arsize_value => 4,
             rdata_value  => v_rdata_value,
             rresp_value  => v_rresp_value,
             ruser_value  => v_ruser_value,
             msg          => "Reading with minimum burst length",
             clk          => clk,
             axi_if       => axi_if,
             scope        => C_SCOPE,
             config       => axi_bfm_config);

    check_value(v_rdata_value(0), v_write_data(0), "Checking read data", C_SCOPE);

    --------------------------------------------------------------------------------------------------------------------
    -- Testing maximum burst length
    --------------------------------------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Testing maximum burst length");
    for i in 0 to 255 loop
      v_write_data(i) := random(32);
    end loop;
    axi_write(awaddr_value => x"00000020",
              awlen_value  => x"FF",
              awsize_value => 4,
              wdata_value  => v_write_data,
              buser_value  => v_buser_value,
              bresp_value  => v_bresp_value,
              msg          => "Writing with maximum burst length",
              clk          => clk,
              axi_if       => axi_if,
              scope        => C_SCOPE,
              config       => axi_bfm_config);
    axi_check(araddr_value => x"00000020",
              arlen_value  => x"FF",
              arsize_value => 4,
              rdata_exp    => v_write_data,
              msg          => "Checking with maximum burst length",
              clk          => clk,
              axi_if       => axi_if,
              scope        => C_SCOPE,
              config       => axi_bfm_config);
    axi_read(araddr_value => x"00000020",
             arlen_value  => x"FF",
             arsize_value => 4,
             rdata_value  => v_rdata_value,
             rresp_value  => v_rresp_value,
             ruser_value  => v_ruser_value,
             msg          => "Reading with maximum burst length",
             clk          => clk,
             axi_if       => axi_if,
             scope        => C_SCOPE,
             config       => axi_bfm_config);
    for i in 0 to 255 loop
      check_value(v_rdata_value(i), v_write_data(i), "Checking read data", C_SCOPE);
    end loop;

    --------------------------------------------------------------------------------------------------------------------
    -- Testing that unconstrained command parameters are normalized correctly
    --------------------------------------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Testing that unconstrained command parameters are normalized correctly");
    -- Testing smaller parameter widths on all unconstrained inputs
    axi_write(awid_value   => "1",
              awaddr_value => x"500",
              awlen_value  => x"01",
              awsize_value => 4,
              awuser_value => "1",
              wdata_value  => v_write_data_narrow,
              wstrb_value  => v_wstrb_narrow,
              wuser_value  => v_wuser_narrow,
              buser_value  => v_buser_narrow,
              bresp_value  => v_bresp_value,
              msg          => "Testing smaller parameter widths on all unconstrained inputs",
              clk          => clk,
              axi_if       => axi_if,
              scope        => C_SCOPE,
              config       => axi_bfm_config);
    -- Checking that the data was written correctly
    axi_check(araddr_value => x"00000500",
              arlen_value  => x"01",
              arsize_value => 4,
              rdata_exp    => t_slv_array'(x"00000012", x"00000034"),
              msg          => "Checking that the data was written correctly",
              clk          => clk,
              axi_if       => axi_if,
              scope        => C_SCOPE,
              config       => axi_bfm_config);
    -- Testing smaller parameter widths on axi_check
    axi_check(arid_value   => "1",
              araddr_value => x"500",
              arlen_value  => x"01",
              arsize_value => 4,
              aruser_value => "1",
              rdata_exp    => v_write_data_narrow,
              ruser_exp    => v_ruser_narrow,
              msg          => "Testing smaller parameter widths on axi_check",
              clk          => clk,
              axi_if       => axi_if,
              scope        => C_SCOPE,
              config       => axi_bfm_config);
    -- Testing smaller parameter widths on axi_read
    axi_read(arid_value   => "1",
             araddr_value => x"500",
             arlen_value  => x"01",
             arsize_value => 4,
             aruser_value => "1",
             rdata_value  => v_rdata_narrow,
             rresp_value  => v_rresp_value,
             ruser_value  => v_ruser_narrow,
             msg          => "Reading with maximum burst length",
             clk          => clk,
             axi_if       => axi_if,
             scope        => C_SCOPE,
             config       => axi_bfm_config);
    for i in 0 to 1 loop
      check_value(v_rdata_narrow(i), v_write_data_narrow(i), "Checking read data", C_SCOPE);
      check_value(v_rresp_value(i) = OKAY, "Checking rresp value", C_SCOPE);
      check_value(v_ruser_narrow(i), "0", "Checking ruser value", C_SCOPE);
    end loop;
    -- Testing larger parameter widths on all unconstrained inputs
    axi_write(awid_value   => x"001",
              awaddr_value => x"000000510",
              awlen_value  => x"01",
              awsize_value => 4,
              awuser_value => x"001",
              wdata_value  => v_write_data_wide,
              wstrb_value  => v_wstrb_wide,
              wuser_value  => v_wuser_wide,
              buser_value  => v_buser_wide,
              bresp_value  => v_bresp_value,
              msg          => "Testing larger parameter widths on all unconstrained inputs",
              clk          => clk,
              axi_if       => axi_if,
              scope        => C_SCOPE,
              config       => axi_bfm_config);
    -- Checking that the data was written correctly
    axi_check(araddr_value => x"00000510",
              arlen_value  => x"01",
              arsize_value => 4,
              rdata_exp    => t_slv_array'(x"87654321", x"9ABCDEF0"),
              msg          => "Checking that the data was written correctly",
              clk          => clk,
              axi_if       => axi_if,
              scope        => C_SCOPE,
              config       => axi_bfm_config);
    -- Testing larger parameter widths on axi_check
    axi_check(arid_value   => x"001",
              araddr_value => x"0000000510",
              arlen_value  => x"01",
              arsize_value => 4,
              aruser_value => x"001",
              rdata_exp    => v_write_data_wide,
              ruser_exp    => v_ruser_wide,
              msg          => "Testing larger parameter widths on axi_check",
              clk          => clk,
              axi_if       => axi_if,
              scope        => C_SCOPE,
              config       => axi_bfm_config);
    -- Testing larger parameter widths on axi_read
    axi_read(arid_value   => x"001",
             araddr_value => x"0000000510",
             arlen_value  => x"01",
             arsize_value => 4,
             aruser_value => x"001",
             rdata_value  => v_rdata_wide,
             rresp_value  => v_rresp_value,
             ruser_value  => v_ruser_wide,
             msg          => "Reading with maximum burst length",
             clk          => clk,
             axi_if       => axi_if,
             scope        => C_SCOPE,
             config       => axi_bfm_config);
    for i in 0 to 1 loop
      check_value(v_rdata_wide(i), v_write_data_wide(i), "Checking read data", C_SCOPE);
      check_value(v_rresp_value(i) = OKAY, "Checking rresp value", C_SCOPE);
      check_value(v_ruser_wide(i), x"000", "Checking ruser value", C_SCOPE);
    end loop;

    report_alert_counters(FINAL);       -- Report final counters and print conclusion for simulation (Success/Fail)
    log(ID_LOG_HDR, "SIMULATION COMPLETED", C_SCOPE);

    -- Finish the simulation
    std.env.stop;
    wait;                               -- to stop completely
  end process;

end architecture;
