--================================================================================================================================
-- Copyright 2020 Bitvis
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
-- Description   : Package for accessing each AXI channel separately. Used by the VVC
------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library work;
use work.axi_bfm_pkg.all;
use work.axi_read_data_queue_pkg.all;
use work.vvc_cmd_pkg.all;

--=================================================================================================
package axi_channel_handler_pkg is

  --===============================================================================================
  -- Types and constants
  --===============================================================================================
  constant C_SCOPE : string := "AXI_CHANNEL_HANDLER";

  --===============================================================================================
  -- Procedures
  --===============================================================================================

  ------------------------------------------
  -- write_address_channel_write
  ------------------------------------------
  -- This procedure writes adress on the write address channel
  -- - When the write is completed, a log message is issued with ID_CHANNEL_BFM
  procedure write_address_channel_write (
    constant awid_value         : in    std_logic_vector;
    constant awaddr_value       : in    unsigned;
    constant awlen_value        : in    unsigned(7 downto 0);
    constant awsize_value       : in    integer range 1 to 128;
    constant awburst_value      : in    t_axburst;
    constant awlock_value       : in    t_axlock;
    constant awcache_value      : in    std_logic_vector(3 downto 0);
    constant awprot_value       : in    t_axprot;
    constant awqos_value        : in    std_logic_vector(3 downto 0);
    constant awregion_value     : in    std_logic_vector(3 downto 0);
    constant awuser_value       : in    std_logic_vector;
    constant msg                : in    string;
    signal   clk                : in    std_logic;
    signal   write_addr_channel : inout t_axi_write_address_channel;
    constant scope              : in    string                := C_SCOPE;
    constant msg_id_panel       : in    t_msg_id_panel        := shared_msg_id_panel;
    constant config             : in    t_axi_bfm_config  := C_AXI_BFM_CONFIG_DEFAULT
  );

  ------------------------------------------
  -- write_data_channel_write
  ------------------------------------------
  -- This procedure writes data on the write data channel
  -- - When the write is completed, a log message is issued with ID_CHANNEL_BFM
  procedure write_data_channel_write (
    constant wdata_value        : in    t_slv_array;
    constant wstrb_value        : in    t_slv_array;
    constant wuser_value        : in    t_slv_array;
    constant awlen_value        : in    unsigned(7 downto 0);
    constant msg                : in    string;
    signal   clk                : in    std_logic;
    signal   write_data_channel : inout t_axi_write_data_channel;
    constant scope              : in    string                := C_SCOPE;
    constant msg_id_panel       : in    t_msg_id_panel        := shared_msg_id_panel;
    constant config             : in    t_axi_bfm_config  := C_AXI_BFM_CONFIG_DEFAULT
  );

  ------------------------------------------
  -- write_response_channel_receive
  ------------------------------------------
  -- This procedure receives the write response on the write response channel
  -- and returns the response data
  -- - When completed, a log message with ID id_for_bfm is issued.
  procedure write_response_channel_receive (
    variable bid_value          : out   std_logic_vector;
    variable bresp_value        : out   t_xresp;
    variable buser_value        : out   std_logic_vector;
    constant msg                : in    string;
    signal   clk                : in    std_logic;
    signal   write_resp_channel : inout t_axi_write_response_channel;
    constant alert_level        : in    t_alert_level         := error;
    constant scope              : in    string                := C_SCOPE;
    constant msg_id_panel       : in    t_msg_id_panel        := shared_msg_id_panel;
    constant config             : in    t_axi_bfm_config      := C_AXI_BFM_CONFIG_DEFAULT;
    constant ext_proc_call      : in    string                := ""  -- External proc_call. Overwrite if called from another BFM procedure
  );

  ------------------------------------------
  -- read_address_channel_write
  ------------------------------------------
  -- This procedure writes adress on the read address channel
  -- - When the write is completed, a log message is issued with ID_CHANNEL_BFM
  procedure read_address_channel_write (
    constant arid_value         : in    std_logic_vector;
    constant araddr_value       : in    unsigned;
    constant arlen_value        : in    unsigned(7 downto 0);
    constant arsize_value       : in    integer range 1 to 128;
    constant arburst_value      : in    t_axburst;
    constant arlock_value       : in    t_axlock;
    constant arcache_value      : in    std_logic_vector(3 downto 0);
    constant arprot_value       : in    t_axprot;
    constant arqos_value        : in    std_logic_vector(3 downto 0);
    constant arregion_value     : in    std_logic_vector(3 downto 0);
    constant aruser_value       : in    std_logic_vector;
    constant msg                : in    string;
    signal   clk                : in    std_logic;
    signal   read_addr_channel  : inout t_axi_read_address_channel;
    constant scope              : in    string                := C_SCOPE;
    constant msg_id_panel       : in    t_msg_id_panel        := shared_msg_id_panel;
    constant config             : in    t_axi_bfm_config      := C_AXI_BFM_CONFIG_DEFAULT
  );

  ------------------------------------------
  -- read_data_channel_receive
  ------------------------------------------
  -- This procedure receives read data on the read data channel,
  -- and returns the read data
  -- - When completed, a log message with ID id_for_bfm is issued.
  procedure read_data_channel_receive (
    variable read_result              : out   t_vvc_result;
    variable read_data_queue          : inout t_axi_read_data_queue;
    constant msg                      : in    string;
    signal   clk                      : in    std_logic;
    signal   read_data_channel        : inout t_axi_read_data_channel;
    constant scope                    : in    string                := C_SCOPE;
    constant msg_id_panel             : in    t_msg_id_panel        := shared_msg_id_panel;
    constant config                   : in    t_axi_bfm_config  := C_AXI_BFM_CONFIG_DEFAULT;
    constant ext_proc_call            : in    string                := ""  -- External proc_call. Overwrite if called from another BFM procedure
  );

end package axi_channel_handler_pkg;

package body axi_channel_handler_pkg is

  ----------------------------------------------------
  -- BFM procedures
  ----------------------------------------------------

  procedure write_address_channel_write (
    constant awid_value         : in    std_logic_vector;
    constant awaddr_value       : in    unsigned;
    constant awlen_value        : in    unsigned(7 downto 0);
    constant awsize_value       : in    integer range 1 to 128;
    constant awburst_value      : in    t_axburst;
    constant awlock_value       : in    t_axlock;
    constant awcache_value      : in    std_logic_vector(3 downto 0);
    constant awprot_value       : in    t_axprot;
    constant awqos_value        : in    std_logic_vector(3 downto 0);
    constant awregion_value     : in    std_logic_vector(3 downto 0);
    constant awuser_value       : in    std_logic_vector;
    constant msg                : in    string;
    signal   clk                : in    std_logic;
    signal   write_addr_channel : inout t_axi_write_address_channel;
    constant scope              : in    string                := C_SCOPE;
    constant msg_id_panel       : in    t_msg_id_panel        := shared_msg_id_panel;
    constant config             : in    t_axi_bfm_config  := C_AXI_BFM_CONFIG_DEFAULT
  ) is
    constant proc_call : string := "write_address_channel_write(" & to_string(awaddr_value, HEX, AS_IS, INCL_RADIX) & ")";
    variable v_await_awready     : boolean := true;
    -- Normalizing unconstrained inputs
    variable v_normalized_awid : std_logic_vector(write_addr_channel.awid'length-1 downto 0);
    variable v_normalized_awaddr : std_logic_vector(write_addr_channel.awaddr'length-1 downto 0) :=
      normalize_and_check(std_logic_vector(awaddr_value), write_addr_channel.awaddr, ALLOW_WIDER, "awaddr_value", "write_addr_channel.awaddr", msg);
    variable v_normalized_awuser : std_logic_vector(write_addr_channel.awuser'length-1 downto 0);
    -- Helper variables
    variable v_time_of_rising_edge    : time := -1 ns;  -- time stamp for clk period checking
    variable v_time_of_falling_edge   : time := -1 ns;  -- time stamp for clk period checking
  begin
    if write_addr_channel.awid'length > 0 then
      v_normalized_awid := normalize_and_check(awid_value, write_addr_channel.awid, ALLOW_WIDER, "awid_value", "write_addr_channel.awid", msg);
    end if;
    if write_addr_channel.awuser'length > 0 then
      v_normalized_awuser := normalize_and_check(awuser_value, write_addr_channel.awuser, ALLOW_WIDER, "awuser_value", "write_addr_channel.awuser", msg);
    end if;
    for cycle in 0 to config.max_wait_cycles loop
      -- Wait according to config.bfm_sync setup
      wait_on_bfm_sync_start(clk, config.bfm_sync, config.setup_time, config.clock_period, v_time_of_falling_edge, v_time_of_rising_edge);
      -- Assigning the write data channel outputs
      if cycle = config.num_aw_pipe_stages then
        write_addr_channel.awid     <= v_normalized_awid;
        write_addr_channel.awaddr   <= v_normalized_awaddr;
        write_addr_channel.awlen    <= std_logic_vector(awlen_value);
        write_addr_channel.awsize   <= bytes_to_axsize(awsize_value);
        write_addr_channel.awburst  <= axburst_to_slv(awburst_value);
        write_addr_channel.awlock   <= axlock_to_sl(awlock_value);
        write_addr_channel.awcache  <= awcache_value;
        write_addr_channel.awprot   <= axprot_to_slv(awprot_value);
        write_addr_channel.awqos    <= awqos_value;
        write_addr_channel.awregion <= awregion_value;
        write_addr_channel.awuser   <= v_normalized_awuser;
        write_addr_channel.awvalid  <= '1';
      end if;
      wait until rising_edge(clk);
      -- Checking clock behavior
      if v_time_of_rising_edge =  -1 ns then
        v_time_of_rising_edge := now;
      end if;
      check_clock_period_margin(clk, config.bfm_sync, v_time_of_falling_edge, v_time_of_rising_edge, 
                                config.clock_period, config.clock_period_margin, config.clock_margin_severity);
      -- Checking if the write address channel access is done
      if write_addr_channel.awready = '1' and cycle >= config.num_aw_pipe_stages then
        -- Wait according to config.bfm_sync setup
        wait_on_bfm_exit(clk, config.bfm_sync, config.hold_time, v_time_of_falling_edge, v_time_of_rising_edge);
        write_addr_channel.awid     <= (write_addr_channel.awid'range => '0');
        write_addr_channel.awaddr   <= (write_addr_channel.awaddr'range => '0');
        write_addr_channel.awlen    <= (others=>'0');
        write_addr_channel.awsize   <= (others=>'0');
        write_addr_channel.awburst  <= (others=>'0');
        write_addr_channel.awlock   <= '0';
        write_addr_channel.awcache  <= (others=>'0');
        write_addr_channel.awprot   <= (others=>'0');
        write_addr_channel.awqos    <= (others=>'0');
        write_addr_channel.awregion <= (others=>'0');
        write_addr_channel.awuser   <= (write_addr_channel.awuser'range => '0');
        write_addr_channel.awvalid  <= '0';
        v_await_awready := false;
        exit;
      end if;
    end loop;
    check_value(not v_await_awready, config.max_wait_cycles_severity, ": Timeout waiting for AWREADY", scope, ID_NEVER, msg_id_panel, proc_call);
    log(ID_CHANNEL_BFM, proc_call & " completed. " & add_msg_delimiter(msg), scope, msg_id_panel);
  end procedure write_address_channel_write;

  procedure write_data_channel_write (
    constant wdata_value        : in    t_slv_array;
    constant wstrb_value        : in    t_slv_array;
    constant wuser_value        : in    t_slv_array;
    constant awlen_value        : in    unsigned(7 downto 0);
    constant msg                : in    string;
    signal   clk                : in    std_logic;
    signal   write_data_channel : inout t_axi_write_data_channel;
    constant scope              : in    string                := C_SCOPE;
    constant msg_id_panel       : in    t_msg_id_panel        := shared_msg_id_panel;
    constant config             : in    t_axi_bfm_config  := C_AXI_BFM_CONFIG_DEFAULT
  ) is
    constant proc_call : string := "write_data_channel_write(" & to_string(wdata_value, HEX, AS_IS, INCL_RADIX) &
                                   ", " & to_string(wstrb_value, HEX, AS_IS, INCL_RADIX) & ")";
    variable v_await_wready      : boolean := true;
    variable v_normalized_wdata  : std_logic_vector(write_data_channel.wdata'length-1 downto 0) :=
      normalize_and_check(wdata_value(0), write_data_channel.wdata, ALLOW_NARROWER, "WDATA", "write_data_channel.wdata", msg);
    variable v_normalized_wstrb  : std_logic_vector(write_data_channel.wstrb'length-1 downto 0) :=
      normalize_and_check(wstrb_value(0), write_data_channel.wstrb, ALLOW_EXACT_ONLY, "WSTRB", "write_data_channel.wstrb", msg);
    variable v_normalized_wuser  : std_logic_vector(write_data_channel.wuser'length-1 downto 0);
    -- Helper variables
    variable v_time_of_rising_edge    : time := -1 ns;  -- time stamp for clk period checking
    variable v_time_of_falling_edge   : time := -1 ns;  -- time stamp for clk period checking
  begin
    if write_data_channel.wuser'length > 0 then
      v_normalized_wuser := normalize_and_check(wuser_value(0), write_data_channel.wuser, ALLOW_NARROWER, "WSTRB", "write_data_channel.wstrb", msg);
    end if;
    for write_transfer_num in 0 to to_integer(unsigned(awlen_value)) loop
      for cycle in 0 to config.max_wait_cycles loop
        -- Wait according to config.bfm_sync setup
        wait_on_bfm_sync_start(clk, config.bfm_sync, config.setup_time, config.clock_period, v_time_of_falling_edge, v_time_of_rising_edge);
        -- Assigning the write data channel outputs
        if cycle = config.num_w_pipe_stages then
          v_normalized_wdata := normalize_and_check(wdata_value(write_transfer_num), write_data_channel.wdata, ALLOW_NARROWER, "wdata_value", "axi_if.write_data_channel.wdata", msg);
          v_normalized_wstrb := normalize_and_check(wstrb_value(write_transfer_num), write_data_channel.wstrb, ALLOW_EXACT_ONLY, "wstrb_value", "write_data_channel.wstrb", msg);
          if write_data_channel.wuser'length > 0 then
            v_normalized_wuser := normalize_and_check(wuser_value(write_transfer_num), write_data_channel.wuser, ALLOW_NARROWER, "wuser_value", "write_data_channel.wuser", msg);
          end if;
          write_data_channel.wdata  <= v_normalized_wdata;
          write_data_channel.wstrb  <= v_normalized_wstrb;
          write_data_channel.wuser  <= v_normalized_wuser;
          write_data_channel.wvalid <= '1';
          if write_transfer_num = unsigned(awlen_value) then
            write_data_channel.wlast <= '1';
          end if;
        end if;
        wait until rising_edge(clk);
        -- Checking clock behavior
        if v_time_of_rising_edge =  -1 ns then
          v_time_of_rising_edge := now;
        end if;
        check_clock_period_margin(clk, config.bfm_sync, v_time_of_falling_edge, v_time_of_rising_edge, 
                                  config.clock_period, config.clock_period_margin, config.clock_margin_severity);
        -- Checking if the write data channel access is done
        if write_data_channel.wready = '1' and cycle >= config.num_w_pipe_stages then
          -- Wait according to config.bfm_sync setup
          wait_on_bfm_exit(clk, config.bfm_sync, config.hold_time, v_time_of_falling_edge, v_time_of_rising_edge);
          write_data_channel.wdata  <= (write_data_channel.wdata'range => '0');
          write_data_channel.wstrb  <= (write_data_channel.wstrb'range => '0');
          write_data_channel.wuser  <= (write_data_channel.wuser'range => '0');
          write_data_channel.wlast  <= '0';
          write_data_channel.wvalid <= '0';
          v_await_wready := false;
          exit;
        end if;
      end loop;
      check_value(not v_await_wready, config.max_wait_cycles_severity, ": Timeout waiting for WREADY", scope, ID_NEVER, msg_id_panel, proc_call);
    end loop;
    log(ID_CHANNEL_BFM, proc_call & " completed. " & add_msg_delimiter(msg), scope, msg_id_panel);
  end procedure write_data_channel_write;

  procedure write_response_channel_receive (
    variable bid_value          : out   std_logic_vector;
    variable bresp_value        : out   t_xresp;
    variable buser_value        : out   std_logic_vector;
    constant msg                : in    string;
    signal   clk                : in    std_logic;
    signal   write_resp_channel : inout t_axi_write_response_channel;
    constant alert_level        : in    t_alert_level         := error;
    constant scope              : in    string                := C_SCOPE;
    constant msg_id_panel       : in    t_msg_id_panel        := shared_msg_id_panel;
    constant config             : in    t_axi_bfm_config  := C_AXI_BFM_CONFIG_DEFAULT;
    constant ext_proc_call      : in    string                := ""  -- External proc_call. Overwrite if called from another BFM procedure
  ) is
    constant local_proc_name        : string := "write_response_channel_receive";
    constant local_proc_call        : string := local_proc_name & "()";
    variable v_proc_call            : line;
    variable v_await_bvalid         : boolean := true;
    variable v_time_of_rising_edge  : time := -1 ns;  -- time stamp for clk period checking
    variable v_time_of_falling_edge : time := -1 ns;  -- time stamp for clk period checking
    variable v_alert_radix          : t_radix;
  begin
    -- Setting procedure name for logging
    if ext_proc_call = "" then
      -- Called directly from sequencer/VVC, log 'axi_read...'
      write(v_proc_call, local_proc_call);
    else
      -- Called from another BFM procedure, log 'ext_proc_call while executing axi_read...'
      write(v_proc_call, ext_proc_call & " while executing " & local_proc_name);
    end if;

    for cycle in 0 to config.max_wait_cycles loop
      -- Wait according to config.bfm_sync setup
      wait_on_bfm_sync_start(clk, config.bfm_sync, config.setup_time, config.clock_period, v_time_of_falling_edge, v_time_of_rising_edge);
      -- Assigning the write response channel ready signal
      if cycle = config.num_b_pipe_stages then
        write_resp_channel.bready <= '1';
      end if;
      wait until rising_edge(clk);
      if v_time_of_rising_edge = -1 ns then
        v_time_of_rising_edge := now;
      end if;
      check_clock_period_margin(clk, config.bfm_sync, v_time_of_falling_edge, v_time_of_rising_edge, 
                                config.clock_period, config.clock_period_margin, config.clock_margin_severity);
      -- Checking if the write response channel access is done
      if write_resp_channel.bvalid = '1' and cycle >= config.num_b_pipe_stages then
        -- Receiving response
        if write_resp_channel.bid'length > 0 then
          bid_value   := normalize_and_check(write_resp_channel.bid, bid_value, ALLOW_EXACT_ONLY, "write_resp_channel.bid", "bid_value", msg);
        end if;
        if write_resp_channel.buser'length > 0 then
          buser_value := normalize_and_check(write_resp_channel.buser, buser_value, ALLOW_EXACT_ONLY, "write_resp_channel.buser", "buser_value", msg);
        end if;
        bresp_value := slv_to_xresp(write_resp_channel.bresp);
        -- Wait according to config.bfm_sync setup
        wait_on_bfm_exit(clk, config.bfm_sync, config.hold_time, v_time_of_falling_edge, v_time_of_rising_edge);
        write_resp_channel.bready <= '0';
        v_await_bvalid := false;
      end if;
      if not v_await_bvalid then
        exit;
      end if;
    end loop;
    check_value(not v_await_bvalid, config.max_wait_cycles_severity, ": Timeout waiting for BVALID", scope, ID_NEVER, msg_id_panel, v_proc_call.all);

    if ext_proc_call = "" then
      log(config.id_for_bfm, v_proc_call.all & " " & add_msg_delimiter(msg), scope, msg_id_panel);
    else
      -- Log will be handled by calling procedure (e.g. read_data_channel_check)
    end if;
    DEALLOCATE(v_proc_call);
  end procedure write_response_channel_receive;

  procedure read_address_channel_write (
    constant arid_value         : in    std_logic_vector;
    constant araddr_value       : in    unsigned;
    constant arlen_value        : in    unsigned(7 downto 0);
    constant arsize_value       : in    integer range 1 to 128;
    constant arburst_value      : in    t_axburst;
    constant arlock_value       : in    t_axlock;
    constant arcache_value      : in    std_logic_vector(3 downto 0);
    constant arprot_value       : in    t_axprot;
    constant arqos_value        : in    std_logic_vector(3 downto 0);
    constant arregion_value     : in    std_logic_vector(3 downto 0);
    constant aruser_value       : in    std_logic_vector;
    constant msg                : in    string;
    signal   clk                : in    std_logic;
    signal   read_addr_channel  : inout t_axi_read_address_channel;
    constant scope              : in    string                := C_SCOPE;
    constant msg_id_panel       : in    t_msg_id_panel        := shared_msg_id_panel;
    constant config             : in    t_axi_bfm_config  := C_AXI_BFM_CONFIG_DEFAULT
  ) is
    constant proc_call : string := "read_address_channel_write(" & to_string(araddr_value, HEX, AS_IS, INCL_RADIX) & ")";
    variable v_await_arready     : boolean := true;
    -- Normalizing unconstrained inputs
    variable v_normalized_arid : std_logic_vector(read_addr_channel.arid'length-1 downto 0);
    variable v_normalized_araddr : std_logic_vector(read_addr_channel.araddr'length-1 downto 0) :=
      normalize_and_check(std_logic_vector(araddr_value), read_addr_channel.araddr, ALLOW_WIDER, "araddr_value", "read_addr_channel.araddr", msg);
    variable v_normalized_aruser : std_logic_vector(read_addr_channel.aruser'length-1 downto 0);
    -- Helper variables
    variable v_time_of_rising_edge    : time := -1 ns;  -- time stamp for clk period checking
    variable v_time_of_falling_edge   : time := -1 ns;  -- time stamp for clk period checking
  begin
    if read_addr_channel.arid'length > 0 then
      v_normalized_arid := normalize_and_check(arid_value, read_addr_channel.arid, ALLOW_WIDER, "arid_value", "read_addr_channel.arid", msg);
    end if;
    if read_addr_channel.aruser'length > 0 then
      v_normalized_aruser := normalize_and_check(aruser_value, read_addr_channel.aruser, ALLOW_WIDER, "aruser_value", "read_addr_channel.awuser", msg);
    end if;
    for cycle in 0 to config.max_wait_cycles loop
      -- Wait according to config.bfm_sync setup
      wait_on_bfm_sync_start(clk, config.bfm_sync, config.setup_time, config.clock_period, v_time_of_falling_edge, v_time_of_rising_edge);
      -- Assigning the write data channel outputs
      if cycle = config.num_ar_pipe_stages then
        read_addr_channel.arid     <= v_normalized_arid;
        read_addr_channel.araddr   <= v_normalized_araddr;
        read_addr_channel.arlen    <= std_logic_vector(arlen_value);
        read_addr_channel.arsize   <= bytes_to_axsize(arsize_value);
        read_addr_channel.arburst  <= axburst_to_slv(arburst_value);
        read_addr_channel.arlock   <= axlock_to_sl(arlock_value);
        read_addr_channel.arcache  <= arcache_value;
        read_addr_channel.arprot   <= axprot_to_slv(arprot_value);
        read_addr_channel.arqos    <= arqos_value;
        read_addr_channel.arregion <= arregion_value;
        read_addr_channel.aruser   <= v_normalized_aruser;
        read_addr_channel.arvalid <= '1';
      end if;
      wait until rising_edge(clk);
      -- Checking clock behavior
      if v_time_of_rising_edge =  -1 ns then
        v_time_of_rising_edge := now;
      end if;
      check_clock_period_margin(clk, config.bfm_sync, v_time_of_falling_edge, v_time_of_rising_edge, 
                                config.clock_period, config.clock_period_margin, config.clock_margin_severity);
      -- Checking if the write address channel access is done
      if read_addr_channel.arready = '1' and cycle >= config.num_ar_pipe_stages then
        -- Wait according to config.bfm_sync setup
        wait_on_bfm_exit(clk, config.bfm_sync, config.hold_time, v_time_of_falling_edge, v_time_of_rising_edge);
        read_addr_channel.arid     <= (read_addr_channel.arid'range => '0');
        read_addr_channel.araddr   <= (read_addr_channel.araddr'range => '0');
        read_addr_channel.arlen    <= (others=>'0');
        read_addr_channel.arsize   <= (others=>'0');
        read_addr_channel.arburst  <= (others=>'0');
        read_addr_channel.arlock   <= '0';
        read_addr_channel.arcache  <= (others=>'0');
        read_addr_channel.arprot   <= (others=>'0');
        read_addr_channel.arqos    <= (others=>'0');
        read_addr_channel.arregion <= (others=>'0');
        read_addr_channel.aruser   <= (read_addr_channel.aruser'range => '0');
        read_addr_channel.arvalid  <= '0';
        v_await_arready := false;
        exit;
      end if;
    end loop;
    check_value(not v_await_arready, config.max_wait_cycles_severity, ": Timeout waiting for ARREADY", scope, ID_NEVER, msg_id_panel, proc_call);
    log(ID_CHANNEL_BFM, proc_call & " completed. " & add_msg_delimiter(msg), scope, msg_id_panel);
  end procedure read_address_channel_write;

  procedure read_data_channel_receive (
    variable read_result              : out   t_vvc_result;
    variable read_data_queue          : inout t_axi_read_data_queue;
    constant msg                      : in    string;
    signal   clk                      : in    std_logic;
    signal   read_data_channel        : inout t_axi_read_data_channel;
    constant scope                    : in    string                := C_SCOPE;
    constant msg_id_panel             : in    t_msg_id_panel        := shared_msg_id_panel;
    constant config                   : in    t_axi_bfm_config      := C_AXI_BFM_CONFIG_DEFAULT;
    constant ext_proc_call            : in    string                := ""  -- External proc_call. Overwrite if called from another BFM procedure
  ) is
    constant local_proc_name        : string := "read_data_channel_receive"; -- Local proc_name; used if called from sequncer or VVC
    constant local_proc_call        : string := local_proc_name & "()"; -- Local proc_call; used if called from sequncer or VVC
    variable v_proc_call            : line;
    variable v_await_rvalid         : boolean := true;
    variable v_time_of_rising_edge  : time := -1 ns;  -- time stamp for clk period checking
    variable v_time_of_falling_edge : time := -1 ns;  -- time stamp for clk period checking
    variable v_rlast_detected       : boolean := false;
    variable v_returning_rid        : std_logic_vector(read_data_channel.rid'length-1 downto 0);
    variable v_read_data            : t_vvc_result;
  begin

    if ext_proc_call = "" then
      -- Called directly from sequencer/VVC, log 'axi_read...'
      write(v_proc_call, local_proc_call);
    else
      -- Called from another BFM procedure, log 'ext_proc_call while executing axi_read...'
      write(v_proc_call, ext_proc_call & " while executing " & local_proc_name);
    end if;

    loop
      for cycle in 0 to config.max_wait_cycles loop
        -- Wait according to config.bfm_sync setup
        wait_on_bfm_sync_start(clk, config.bfm_sync, config.setup_time, config.clock_period, v_time_of_falling_edge, v_time_of_rising_edge);
        -- Assigning the read data channel ready signal
        if cycle = config.num_r_pipe_stages then
          read_data_channel.rready  <= '1';
        end if;
        wait until rising_edge(clk);
        -- Checking clock behavior
        if v_time_of_rising_edge =  -1 ns then
          v_time_of_rising_edge := now;
        end if;
        check_clock_period_margin(clk, config.bfm_sync, v_time_of_falling_edge, v_time_of_rising_edge, 
                                  config.clock_period, config.clock_period_margin, config.clock_margin_severity);
        -- Checking if the read data channel access is done
        if read_data_channel.rvalid = '1' and cycle >= config.num_r_pipe_stages then
          v_await_rvalid := false;
          -- Storing response
          read_data_queue.add_to_queue(read_data_channel.rid, read_data_channel.rdata, slv_to_xresp(read_data_channel.rresp), read_data_channel.ruser);
          -- Checking if the transfer is done
          if read_data_channel.rlast = '1' then
            v_rlast_detected := true;
            v_returning_rid := read_data_channel.rid;
          end if;
          -- Wait according to config.bfm_sync setup
          wait_on_bfm_exit(clk, config.bfm_sync, config.hold_time, v_time_of_falling_edge, v_time_of_rising_edge);
          read_data_channel.rready  <= '0';
        end if;
        if not v_await_rvalid then
          exit;
        end if;
      end loop;
      check_value(not v_await_rvalid, config.max_wait_cycles_severity, ": Timeout waiting for RVALID", scope, ID_NEVER, msg_id_panel, v_proc_call.all);
      if v_rlast_detected then
        read_result := read_data_queue.fetch_from_queue(v_returning_rid);
        exit;
      end if;
      v_await_rvalid := true;
    end loop;

    if ext_proc_call = "" then
      log(config.id_for_bfm, v_proc_call.all & " " & add_msg_delimiter(msg), scope, msg_id_panel);
    else
      -- Log will be handled by calling procedure (e.g. read_data_channel_check)
    end if;
    DEALLOCATE(v_proc_call);
  end procedure read_data_channel_receive;

end package body axi_channel_handler_pkg;
