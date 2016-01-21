-- Copyright (c) 2016 by Bitvis AS.  All rights reserved.
-- You should have received a copy of the license file containing the MIT License (see LICENSE.TXT), if not, 
-- contact Bitvis AS <support@bitvis.no>.
-- UVVM AND ANY PART THEREOF ARE PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
-- IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
-- WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH UVVM.
--========================================================================================================================

------------------------------------------------------------------------------------------
-- Description   : See library quick reference (under 'doc') and README-file(s)
--
-- Important     : For systems not using 'ready' a dummy signal must be declared and set to '1'
--                 For systems not using 'terminate' a dummy signal must be declared and set to '1' if using sbi_poll_until()
------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

--=================================================================================================
package sbi_bfm_pkg is

  --===============================================================================================
  -- Types and constants for SBI BFMs 
  --===============================================================================================
  constant C_SCOPE : string := "SBI BFM";

  type t_sbi_if is record
    cs      : std_logic;          -- to dut
    addr    : unsigned;           -- to dut
    rd      : std_logic;          -- to dut
    wr      : std_logic;          -- to dut
    wdata   : std_logic_vector;   -- to dut
    ready   : std_logic;          -- from dut
    rdata   : std_logic_vector;   -- from dut
  end record;

  -- Configuration record to be assigned in the test harness.
  type t_sbi_bfm_config is
  record
    max_wait_cycles          : integer;
    max_wait_cycles_severity : t_alert_level;
    clock_period             : time;
    id_for_bfm               : t_msg_id;
    id_for_bfm_wait          : t_msg_id;
    id_for_bfm_poll          : t_msg_id;
    use_ready_signal         : boolean;
  end record;

  constant C_SBI_BFM_CONFIG_DEFAULT : t_sbi_bfm_config := (
    max_wait_cycles          => 10,
    max_wait_cycles_severity => failure,
    clock_period             => 10 ns,
    id_for_bfm               => ID_BFM,
    id_for_bfm_wait          => ID_BFM_WAIT,
    id_for_bfm_poll          => ID_BFM_POLL,
    use_ready_signal         => true
    );


  --===============================================================================================
  -- BFM procedures
  --===============================================================================================
  
  ------------------------------------------
  -- init_sbi_if_signals
  ------------------------------------------
  -- - This function returns an SBI interface with initialized signals.
  -- - All SBI input signals are initialized to 0
  -- - All SBI output signals are initialized to Z
  function init_sbi_if_signals(
    addr_width : natural;
    data_width : natural
    ) return t_sbi_if;


  ------------------------------------------
  -- sbi_write
  ------------------------------------------
  -- - This procedure writes data to the SBI DUT 
  -- - The SBI interface in this procedure is given as individual signals
  procedure sbi_write (
    constant addr_value    : in     unsigned;
    constant data_value    : in     std_logic_vector;
    constant msg           : in     string;
    signal   clk           : in     std_logic;
    signal   cs            : inout  std_logic;
    signal   addr          : inout  unsigned;
    signal   rd            : inout  std_logic;
    signal   wr            : inout  std_logic;
    signal   ready         : in     std_logic;
    signal   wdata         : inout  std_logic_vector;
    constant scope         : in     string            := C_SCOPE;
    constant msg_id_panel  : in     t_msg_id_panel    := shared_msg_id_panel;
    constant config        : in     t_sbi_bfm_config  := C_SBI_BFM_CONFIG_DEFAULT
    );

    
  ------------------------------------------
  -- sbi_write
  ------------------------------------------
  -- - This procedure writes data 'data_value' to the SBI DUT address 'addr_value'
  -- - The SBI interface in this procedure is given as a t_sbi_if signal record
  procedure sbi_write (
    constant addr_value   : in    unsigned;
    constant data_value   : in    std_logic_vector;
    constant msg          : in    string;
    signal   clk          : in    std_logic;
    signal   sbi_if       : inout t_sbi_if;
    constant scope        : in    string            := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel    := shared_msg_id_panel;
    constant config       : in    t_sbi_bfm_config  := C_SBI_BFM_CONFIG_DEFAULT
    );


  ------------------------------------------
  -- sbi_read
  ------------------------------------------
  -- - This procedure reads data from the SBI DUT address 'addr_value' and 
  --   returns the read data in the output 'data_value'
  -- - The SBI interface in this procedure is given as individual signals
  procedure sbi_read (
    constant addr_value    : in     unsigned;
    variable data_value    : out    std_logic_vector;
    constant msg           : in     string;
    signal   clk           : in     std_logic;
    signal   cs            : inout  std_logic;
    signal   addr          : inout  unsigned;
    signal   rd            : inout  std_logic;
    signal   wr            : inout  std_logic;
    signal   ready         : in     std_logic;
    signal   rdata         : in     std_logic_vector;
    constant scope         : in     string            := C_SCOPE;
    constant msg_id_panel  : in     t_msg_id_panel    := shared_msg_id_panel;
    constant config        : in     t_sbi_bfm_config  := C_SBI_BFM_CONFIG_DEFAULT;
    constant proc_name     : in     string            := "sbi_read"  -- overwrite if called from other procedure like sbi_check

  );

  ------------------------------------------
  -- sbi_read
  ------------------------------------------
  -- - This procedure reads data from the SBI DUT address 'addr_value' and returns 
  --   the read data in the output 'data_value'
  -- - The SBI interface in this procedure is given as a t_sbi_if signal record
  procedure sbi_read (
    constant addr_value   : in    unsigned;
    variable data_value   : out   std_logic_vector;
    constant msg          : in    string;
    signal   clk          : in    std_logic;
    signal   sbi_if       : inout t_sbi_if;
    constant scope        : in    string            := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel    := shared_msg_id_panel;
    constant config       : in    t_sbi_bfm_config  := C_SBI_BFM_CONFIG_DEFAULT;
    constant proc_name    : in    string            := "sbi_read"  -- overwrite if called from other procedure like sbi_check
    );

    
  ------------------------------------------
  -- sbi_check
  ------------------------------------------
  -- - This procedure reads data from the SBI DUT address 'addr_value' and 
  --   compares the read data to the expected data in 'data_exp'.
  -- - If the read data is inconsistent with the expected data, an alert with 
  --   severity 'alert_level' is triggered.
  -- - The SBI interface in this procedure is given as individual signals
  procedure sbi_check (
    constant addr_value   : in    unsigned;
    constant data_exp     : in    std_logic_vector;
    constant alert_level  : in    t_alert_level     := error;
    constant msg          : in    string;
    signal   clk          : in    std_logic;
    signal   cs           : inout std_logic;
    signal   addr         : inout unsigned;
    signal   rd           : inout std_logic;
    signal   wr           : inout std_logic;
    signal   ready        : in    std_logic;
    signal   rdata        : in    std_logic_vector;
    constant scope        : in    string            := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel    := shared_msg_id_panel;
    constant config       : in    t_sbi_bfm_config  := C_SBI_BFM_CONFIG_DEFAULT
    );

    
  ------------------------------------------
  -- sbi_check
  ------------------------------------------
  -- - This procedure reads data from the SBI DUT address 'addr_value' and 
  --   compares the read data to the expected data in 'data_exp'.
  -- - If the read data is inconsistent with the expected data, an alert with 
  --   severity 'alert_level' is triggered.
  -- - The SBI interface in this procedure is given as a t_sbi_if signal record
  procedure sbi_check (
    constant addr_value   : in    unsigned;
    constant data_exp     : in    std_logic_vector;
    constant alert_level  : in    t_alert_level     := error;
    constant msg          : in    string;
    signal   clk          : in    std_logic;
    signal   sbi_if       : inout t_sbi_if;
    constant scope        : in    string            := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel    := shared_msg_id_panel;
    constant config       : in    t_sbi_bfm_config  := C_SBI_BFM_CONFIG_DEFAULT
    );

    
  ------------------------------------------
  -- sbi_poll_until
  ------------------------------------------
  -- - This procedure reads data from the SBI DUT address 'addr_value' and 
  --   compares the read data to the expected data in 'data_exp'.
  -- - If the read data is inconsistent with the expected data, a new read 
  --   will be performed, and the new read data will be compared with the 
  --   'data_exp'. This process will continue until one of the following 
  --   conditions are met:
  --     a) The read data is equal to the expected data
  --     b) The number of reads equal 'max_polls'
  --     c) The time spent polling is equal to the 'timeout'
  -- - If 'timeout' is set to 0, it will be interpreted as no timeout
  -- - If 'max_polls' is set to 0, it will be interpreted as no limitation on number of polls
  -- - The SBI interface in this procedure is given as individual signals
  procedure sbi_poll_until (
    constant addr_value     : in    unsigned;
    constant data_exp       : in    std_logic_vector;
    constant max_polls      : in    integer           := 1;
    constant timeout        : in    time              := 0 ns;
    constant alert_level    : in    t_alert_level     := error;
    constant msg            : in    string;
    signal   clk            : in    std_logic;
    signal   cs             : inout std_logic;
    signal   addr           : inout unsigned;
    signal   rd             : inout std_logic;
    signal   wr             : inout std_logic;
    signal   ready          : in    std_logic;
    signal   rdata          : in    std_logic_vector;
    signal   terminate_loop : in    std_logic;
    constant scope          : in    string            := C_SCOPE;
    constant msg_id_panel   : in    t_msg_id_panel    := shared_msg_id_panel;
    constant config         : in    t_sbi_bfm_config  := C_SBI_BFM_CONFIG_DEFAULT
    );

    
  ------------------------------------------
  -- sbi_poll_until
  ------------------------------------------
  -- - This procedure reads data from the SBI DUT address 'addr_value' and 
  --   compares the read data to the expected data in 'data_exp'.
  -- - If the read data is inconsistent with the expected data, a new read 
  --   will be performed, and the new read data will be compared with the 
  --   'data_exp'. This process will continue until one of the following 
  --   conditions are met:
  --     a) The read data is equal to the expected data
  --     b) The number of reads equal 'max_polls'
  --     c) The time spent polling is equal to the 'timeout'
  -- - If 'timeout' is set to 0, it will be interpreted as no timeout
  -- - If 'max_polls' is set to 0, it will be interpreted as no limitation on number of polls
  -- - The SBI interface in this procedure is given as a t_sbi_if signal record
  procedure sbi_poll_until (
    constant addr_value     : in    unsigned;
    constant data_exp       : in    std_logic_vector;
    constant max_polls      : in    integer           := 1;
    constant timeout        : in    time              := 0 ns;
    constant alert_level    : in    t_alert_level     := error;
    constant msg            : in    string;
    signal   clk            : in    std_logic;
    signal   sbi_if         : inout t_sbi_if;
    signal   terminate_loop : in    std_logic;
    constant scope          : in    string            := C_SCOPE;
    constant msg_id_panel   : in    t_msg_id_panel    := shared_msg_id_panel;
    constant config         : in    t_sbi_bfm_config  := C_SBI_BFM_CONFIG_DEFAULT
    );

end package sbi_bfm_pkg;


--=================================================================================================
--=================================================================================================

package body sbi_bfm_pkg is

  ---------------------------------------------------------------------------------
  -- initialize sbi to dut signals
  ---------------------------------------------------------------------------------

  function init_sbi_if_signals(
    addr_width : natural;
    data_width : natural
    ) return t_sbi_if is
    variable result : t_sbi_if( addr(addr_width - 1 downto 0), 
                                wdata(data_width - 1 downto 0), 
                                rdata(data_width - 1 downto 0));
  begin
    result.cs     := '0';
    result.rd     := '0';
    result.wr     := '0';
    result.addr   := (others => '0');
    result.wdata  := (others => '0');
    result.ready  := 'Z';
    result.rdata  := (others => 'Z');
    return result;
  end function;

  ---------------------------------------------------------------------------------
  -- write
  ---------------------------------------------------------------------------------
  procedure sbi_write (
    constant addr_value   : in    unsigned;
    constant data_value   : in    std_logic_vector;
    constant msg          : in    string;
    signal   clk          : in    std_logic;
    signal   cs           : inout std_logic;
    signal   addr         : inout unsigned;
    signal   rd           : inout std_logic;
    signal   wr           : inout std_logic;
    signal   ready        : in    std_logic;
    signal   wdata        : inout std_logic_vector;
    constant scope        : in    string            := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel    := shared_msg_id_panel;
    constant config       : in    t_sbi_bfm_config  := C_SBI_BFM_CONFIG_DEFAULT
  ) is
    constant proc_name  : string :=  "sbi_write";
    constant proc_call  : string :=  "sbi_write(A:" & to_string(addr_value, HEX, AS_IS, INCL_RADIX) &
                                     ", " & to_string(data_value, HEX, AS_IS, INCL_RADIX) & ")";
    -- Normalise to the DUT addr/data widths
    variable v_normalised_addr    : unsigned(addr'length-1 downto 0) :=
        normalize_and_check(addr_value, addr, ALLOW_WIDER_NARROWER, "addr_value", "sbi_core_in.addr", msg);
    variable v_normalised_data    : std_logic_vector(wdata'length-1 downto 0) :=
        normalize_and_check(data_value, wdata, ALLOW_NARROWER, "data_value", "sbi_core_in.wdata", msg);
    variable v_clk_cycles_waited  : natural := 0;
  begin
    wait_until_given_time_after_rising_edge(clk, config.clock_period/4);
    cs    <= '1';
    wr    <= '1';
    rd    <= '0';
    addr  <= v_normalised_addr;
    wdata <= v_normalised_data;

    wait for config.clock_period;
    while (config.use_ready_signal and ready = '0') loop
      if v_clk_cycles_waited = 0 then
        log(config.id_for_bfm_wait, proc_call & " waiting for response (sbi ready=0)" & msg, scope, msg_id_panel);
      end if;
      wait for config.clock_period;
      v_clk_cycles_waited := v_clk_cycles_waited + 1;
      check_value(v_clk_cycles_waited <= config.max_wait_cycles, config.max_wait_cycles_severity,
                  ": Timeout while waiting for sbi ready", scope, ID_NEVER, msg_id_panel, proc_call);
    end loop;

    cs  <= '0';
    wr  <= '0';
    log(config.id_for_bfm, proc_call & " completed. " & msg, scope, msg_id_panel);
  end procedure;

  procedure sbi_write (
    constant addr_value   : in    unsigned;
    constant data_value   : in    std_logic_vector;
    constant msg          : in    string;
    signal   clk          : in    std_logic;
    signal   sbi_if       : inout t_sbi_if;
    constant scope        : in    string            := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel    := shared_msg_id_panel;
    constant config       : in    t_sbi_bfm_config  := C_SBI_BFM_CONFIG_DEFAULT
    ) is
  begin
    sbi_write(addr_value, data_value, msg, clk, sbi_if.cs, sbi_if.addr,
              sbi_if.rd, sbi_if.wr, sbi_if.ready, sbi_if.wdata,
              scope, msg_id_panel, config);
  end procedure;


  ---------------------------------------------------------------------------------
  -- sbi_read
  ---------------------------------------------------------------------------------
  procedure sbi_read (
    constant addr_value    : in     unsigned;
    variable data_value    : out    std_logic_vector;
    constant msg           : in     string;
    signal   clk           : in     std_logic;
    signal   cs            : inout  std_logic;
    signal   addr          : inout  unsigned;
    signal   rd            : inout  std_logic;
    signal   wr            : inout  std_logic;
    signal   ready         : in     std_logic;
    signal   rdata         : in     std_logic_vector;
    constant scope         : in     string            := C_SCOPE;
    constant msg_id_panel  : in     t_msg_id_panel    := shared_msg_id_panel;
    constant config        : in     t_sbi_bfm_config  := C_SBI_BFM_CONFIG_DEFAULT;
    constant proc_name     : in     string            := "sbi_read"  -- overwrite if called from other procedure like sbi_check
  ) is
    constant proc_call            : string := "sbi_read(A:" & to_string(addr_value, HEX, AS_IS, INCL_RADIX) & ")";
    -- Normalize to the DUT addr/data widths
    variable v_normalised_addr    : unsigned(addr'length-1 downto 0) :=
        normalize_and_check(addr_value, addr, ALLOW_WIDER_NARROWER, "addr_value", "sbi_core_in.addr", msg);
    variable v_data_value         : std_logic_vector(data_value'range);
    variable v_clk_cycles_waited  : natural := 0;
  begin
    wait_until_given_time_after_rising_edge(clk, config.clock_period/4);
    cs   <= '1';
    wr   <= '0';
    rd   <= '1';
    addr <= v_normalised_addr;
    wait for config.clock_period;
    while (config.use_ready_signal and ready = '0') loop
      if v_clk_cycles_waited = 0 then
        log(config.id_for_bfm_wait, proc_call & " waiting for response (sbi ready=0)" & msg, scope, msg_id_panel);
      end if;
      wait for config.clock_period;
      v_clk_cycles_waited := v_clk_cycles_waited + 1;
      check_value(v_clk_cycles_waited <= config.max_wait_cycles, config.max_wait_cycles_severity,
                  ": Timeout while waiting for sbi ready", scope, ID_NEVER, msg_id_panel, proc_call);
    end loop;

    cs  <= '0';
    rd  <= '0';
    v_data_value  := rdata;
    data_value    := v_data_value;
    if proc_name = "sbi_read" then
      log(config.id_for_bfm, proc_call & "=> " & to_string(v_data_value, HEX, SKIP_LEADING_0, INCL_RADIX) & ". " & msg, scope, msg_id_panel);
    else
      -- Log will be handled by calling procedure (e.g. sbi_check)
    end if;
  end procedure;

  procedure sbi_read (
    constant addr_value   : in    unsigned;
    variable data_value   : out   std_logic_vector;
    constant msg          : in    string;
    signal   clk          : in    std_logic;
    signal   sbi_if       : inout t_sbi_if;
    constant scope        : in    string            := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel    := shared_msg_id_panel;
    constant config       : in    t_sbi_bfm_config  := C_SBI_BFM_CONFIG_DEFAULT;
    constant proc_name    : in    string            := "sbi_read"  -- overwrite if called from other procedure like sbi_check
    ) is
  begin
    sbi_read(addr_value, data_value, msg, clk, sbi_if.cs, sbi_if.addr,
             sbi_if.rd, sbi_if.wr, sbi_if.ready, sbi_if.rdata,
             scope, msg_id_panel, config, proc_name);
  end procedure;


  ---------------------------------------------------------------------------------
  -- sbi_check
  ---------------------------------------------------------------------------------
  -- Perform a read operation, then compare the read value to the POLL_UNTILed value.
  procedure sbi_check (
    constant addr_value   : in    unsigned;
    constant data_exp     : in    std_logic_vector;
    constant alert_level  : in    t_alert_level     := error;
    constant msg          : in    string;
    signal   clk          : in    std_logic;
    signal   cs           : inout std_logic;
    signal   addr         : inout unsigned;
    signal   rd           : inout std_logic;
    signal   wr           : inout std_logic;
    signal   ready        : in    std_logic;
    signal   rdata        : in    std_logic_vector;
    constant scope        : in    string            := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel    := shared_msg_id_panel;
    constant config       : in    t_sbi_bfm_config  := C_SBI_BFM_CONFIG_DEFAULT
  ) is
    constant proc_name    : string :=  "sbi_check";
    constant proc_call    : string :=  "sbi_check(A:" & to_string(addr_value, HEX, AS_IS, INCL_RADIX) &
                                       ", "  & to_string(data_exp, HEX, AS_IS, INCL_RADIX) & ")";
    -- Normalize to the DUT addr/data widths
    variable v_normalised_addr    : unsigned(addr'length-1 downto 0) :=
      normalize_and_check(addr_value, addr, ALLOW_WIDER_NARROWER, "addr_value", "sbi_core_in.addr", msg);
    -- Helper variables
    variable v_data_value         : std_logic_vector(rdata'length - 1 downto 0);
    variable v_check_ok           : boolean;
    variable v_clk_cycles_waited  : natural := 0;
  begin
    sbi_read(addr_value, v_data_value, msg, clk, cs, addr, rd, wr, ready, rdata, scope, msg_id_panel, config, proc_name);

    -- Compare values, but ignore any leading zero's if widths are different.
    -- Use ID_NEVER so that check_value method does not log when check is OK,
    -- log it here instead.
    v_check_ok := check_value(v_data_value, data_exp, alert_level, msg, scope, HEX_BIN_IF_INVALID, SKIP_LEADING_0, ID_NEVER, msg_id_panel, proc_call);
    if v_check_ok then
      log(config.id_for_bfm, proc_call & "=> OK, read data = " & to_string(v_data_value, HEX, SKIP_LEADING_0, INCL_RADIX) & ". " & msg, scope, msg_id_panel);
    end if;
  end procedure;

  procedure sbi_check (
    constant addr_value   : in    unsigned;
    constant data_exp     : in    std_logic_vector;
    constant alert_level  : in    t_alert_level     := error;
    constant msg          : in    string;
    signal   clk          : in    std_logic;
    signal   sbi_if       : inout t_sbi_if;
    constant scope        : in    string            := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel    := shared_msg_id_panel;
    constant config       : in    t_sbi_bfm_config  := C_SBI_BFM_CONFIG_DEFAULT
    ) is
  begin
    sbi_check(addr_value, data_exp, alert_level, msg, clk, sbi_if.cs, sbi_if.addr,
              sbi_if.rd, sbi_if.wr, sbi_if.ready, sbi_if.rdata,
              scope, msg_id_panel, config);
  end procedure;


  ---------------------------------------------------------------------------------
  -- sbi_poll_until
  ---------------------------------------------------------------------------------
  -- Perform a read operation, then compare the read value to the POLL_UNTILed value.
  -- The checking is repeated until timeout or N occurrences (reads) without POLL_UNTILed data.
  procedure sbi_poll_until (
    constant addr_value     : in    unsigned;
    constant data_exp       : in    std_logic_vector;
    constant max_polls      : in    integer           := 1;
    constant timeout        : in    time              := 0 ns;
    constant alert_level    : in    t_alert_level     := error;
    constant msg            : in    string;
    signal   clk            : in    std_logic;
    signal   cs             : inout std_logic;
    signal   addr           : inout unsigned;
    signal   rd             : inout std_logic;
    signal   wr             : inout std_logic;
    signal   ready          : in    std_logic;
    signal   rdata          : in    std_logic_vector;
    signal   terminate_loop : in    std_logic;
    constant scope          : in    string            := C_SCOPE;
    constant msg_id_panel   : in    t_msg_id_panel    := shared_msg_id_panel;
    constant config         : in    t_sbi_bfm_config  := C_SBI_BFM_CONFIG_DEFAULT
  ) is
    constant proc_name      : string   := "sbi_poll_until";
    constant proc_call      : string   := proc_name & "(A:" & to_string(addr_value, HEX, AS_IS, INCL_RADIX) &
                                         ", "  & to_string(data_exp, HEX, AS_IS, INCL_RADIX) & ", " & to_string(max_polls) & ", " & to_string(timeout, ns) & ")";
    constant start_time     : time     := now;
    -- Normalise to the DUT addr/data widths
    variable v_normalised_addr        : unsigned(addr'length-1 downto 0) :=
      normalize_and_check(addr_value, addr, ALLOW_WIDER_NARROWER, "addr_value", "sbi_core_in.addr", msg);
    -- Helper variables
    variable v_data_value             : std_logic_vector(rdata'length - 1 downto 0);
    variable v_check_ok               : boolean;
    variable v_timeout_ok             : boolean;
    variable v_num_of_occurrences_ok  : boolean;
    variable v_num_of_occurrences     : integer           := 0;
    variable v_clk_cycles_waited      : natural           := 0;
    variable v_config                 : t_sbi_bfm_config  := config;

  begin
    -- Check for timeout = 0 and max_polls = 0. This combination can result in an infinite loop if the POLL_UNTILed data does not appear.
    if max_polls = 0 and timeout = 0 ns then
      alert(TB_WARNING, proc_name & " called with timeout=0 and max_polls=0. This can result in an infinite loop.");
    end if;

    -- Initial status of the checks
    v_check_ok              := false;
    v_timeout_ok            := true;
    v_num_of_occurrences_ok := true;
    v_config.id_for_bfm     := ID_BFM_POLL;

    while not v_check_ok and v_timeout_ok and v_num_of_occurrences_ok and (terminate_loop = '0')  loop
      -- Read data on SBI register
      sbi_read(v_normalised_addr, v_data_value, "As a part of " & proc_call & ". " & msg, clk, cs, addr, rd, wr, ready, rdata, scope, msg_id_panel, v_config,
      return_string1_if_true_otherwise_string2("sbi_read", proc_name, is_log_msg_enabled(ID_BFM_POLL, msg_id_panel)));   -- ID_BFM_POLL will allow the logging inside sbi_read to be executed

      -- Evaluate data
      if v_data_value = data_exp then
        v_check_ok := true;
      else
        v_check_ok := false;
      end if;

      -- Evaluate number of occurrences, if limited by user
      v_num_of_occurrences := v_num_of_occurrences + 1;
      if max_polls > 0 then
        v_num_of_occurrences_ok := v_num_of_occurrences < max_polls;
      end if;

      -- Evaluate timeout, if specified by user
      if timeout = 0 ns then
        v_timeout_ok := true;
      else
        v_timeout_ok := (now - start_time) < timeout;
      end if;

    end loop;


    if v_check_ok then
      log(config.id_for_bfm, proc_call & "=> OK, read data = " & to_string(v_data_value, HEX, SKIP_LEADING_0, INCL_RADIX) & " after " & to_string(v_num_of_occurrences) & " occurrences and " & to_string((now - start_time),ns) & ". " & msg, scope, msg_id_panel);
    elsif not v_timeout_ok then
      alert(alert_level, proc_call & "=> Failed due to timeout. Did not get POLL_UNTILed value " & to_string(data_exp, HEX, AS_IS, INCL_RADIX) & " before time " & to_string(timeout,ns) & ". " & msg, scope);
    elsif terminate_loop = '1' then
      log(ID_TERMINATE_CMD, proc_call & " Terminated from outside this BFM. " & msg, scope, msg_id_panel);
    else
      alert(alert_level, proc_call & "=> Failed. POLL_UNTILed value " & to_string(data_exp, HEX, AS_IS, INCL_RADIX) & " did not appear within " & to_string(max_polls) & " occurrences. " & msg, scope);
    end if;
  end procedure;


  procedure sbi_poll_until (
    constant addr_value     : in    unsigned;
    constant data_exp       : in    std_logic_vector;
    constant max_polls      : in    integer           := 1;
    constant timeout        : in    time              := 0 ns;
    constant alert_level    : in    t_alert_level     := error;
    constant msg            : in    string;
    signal   clk            : in    std_logic;
    signal   sbi_if         : inout t_sbi_if;
    signal   terminate_loop : in    std_logic;
    constant scope          : in    string            := C_SCOPE;
    constant msg_id_panel   : in    t_msg_id_panel    := shared_msg_id_panel;
    constant config         : in    t_sbi_bfm_config  := C_SBI_BFM_CONFIG_DEFAULT
    ) is
  begin
    sbi_poll_until(addr_value, data_exp, max_polls, timeout, alert_level, msg, clk, sbi_if.cs, sbi_if.addr,
              sbi_if.rd, sbi_if.wr, sbi_if.ready, sbi_if.rdata,
              terminate_loop, scope, msg_id_panel, config);
  end procedure;
end package body sbi_bfm_pkg;