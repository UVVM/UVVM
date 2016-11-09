--========================================================================================================================
-- Copyright (c) 2016 by Bitvis AS.  All rights reserved.
-- You should have received a copy of the license file containing the MIT License (see LICENSE.TXT), if not, 
-- contact Bitvis AS <support@bitvis.no>.
--
-- UVVM AND ANY PART THEREOF ARE PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
-- WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
-- OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH UVVM OR THE USE OR OTHER DEALINGS IN UVVM.
--========================================================================================================================

------------------------------------------------------------------------------------------
-- Description   : See library quick reference (under 'doc') and README-file(s)
--
------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

--=================================================================================================
package i2c_bfm_pkg is

  --===============================================================================================
  -- Types and constants for I2C BFMs 
  --===============================================================================================
  constant C_SCOPE : string := "I2C BFM";

  type t_i2c_if is record
    scl : std_logic;                    -- clock
    sda : std_logic;                    -- data
  end record;

  -- Configuration record to be assigned in the test harness.
  type t_i2c_bfm_config is
  record
    enable_10_bits_addressing       : boolean;  -- true: 10-bit addressing enabled, false: 7-bit addressing enabled
    master_sda_to_scl               : time;  -- Used in master mode, start condition. From sda active to scl active.
    master_scl_to_sda               : time;  -- Used in master mode, stop condition. From scl inactive to sda inactive.
    master_stop_condition_hold_time : time;
    max_wait_scl_change             : time;  -- Used as timeout when checking the SCL active period.
    max_wait_scl_change_severity    : t_alert_level;
    max_wait_sda_change             : time;
    max_wait_sda_change_severity    : t_alert_level;
    i2c_bit_time                    : time;
    i2c_bit_time_severity           : t_alert_level;
    acknowledge_severity            : t_alert_level;  -- Severity if message not acknowledged
    slave_mode_address              : unsigned(9 downto 0);
    slave_mode_address_severity     : t_alert_level;
    slave_rw_bit_severity           : t_alert_level;
    reserved_address_severity       : t_alert_level;
    id_for_bfm                      : t_msg_id;
    id_for_bfm_wait                 : t_msg_id;
    id_for_bfm_poll                 : t_msg_id;
  end record;

  constant C_I2C_BFM_CONFIG_DEFAULT : t_i2c_bfm_config := (
    enable_10_bits_addressing       => false,
    master_sda_to_scl               => 20 ns,
    master_scl_to_sda               => 20 ns,
    master_stop_condition_hold_time => 20 ns,
    max_wait_scl_change             => 10 ms,
    max_wait_scl_change_severity    => failure,
    max_wait_sda_change             => 10 ms,
    max_wait_sda_change_severity    => failure,
    i2c_bit_time                    => 100 ns,
    i2c_bit_time_severity           => failure,
    acknowledge_severity            => failure,
    slave_mode_address              => "0000000000",
    slave_mode_address_severity     => failure,
    slave_rw_bit_severity           => failure,
    reserved_address_severity       => warning,
    id_for_bfm                      => ID_BFM,
    id_for_bfm_wait                 => ID_BFM_WAIT,
    id_for_bfm_poll                 => ID_BFM_POLL
    );

  --===============================================================================================
  -- BFM procedures
  --===============================================================================================

  ------------------------------------------
  -- init_i2c_if_signals
  ------------------------------------------
  -- - This function returns an I2C interface with initialized signals.
  -- - All I2C signals are initialized to Z
  function init_i2c_if_signals (
    constant VOID : in t_void
    ) return t_i2c_if;

  ------------------------------------------
  -- i2c_master_transmit
  ------------------------------------------
  -- This procedure transmits data 'data' to an I2C slave DUT 
  -- at address 'addr_value'.
  procedure i2c_master_transmit (
    constant addr_value   : in    unsigned;
    constant data         : in    t_byte_array;
    constant msg          : in    string;
    signal scl            : inout std_logic;
    signal sda            : inout std_logic;
    constant continue     : in    boolean          := false;
    constant scope        : in    string           := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in    t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT
    );

  ------------------------------------------
  -- i2c_master_transmit
  ------------------------------------------
  -- This procedure transmits data 'data' to an I2C slave DUT 
  -- at address 'addr_value'.
  -- The I2C interface in this procedure is given as a t_i2c_if signal record
  procedure i2c_master_transmit (
    constant addr_value   : in    unsigned;
    constant data         : in    t_byte_array;
    constant msg          : in    string;
    signal i2c_if         : inout t_i2c_if;
    constant continue     : in    boolean          := false;
    constant scope        : in    string           := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in    t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT
    );

  ------------------------------------------
  -- i2c_master_transmit
  ------------------------------------------
  -- This procedure transmits data 'data' to an I2C slave DUT 
  -- at address 'addr_value'.
  -- The I2C interface in this procedure is given as a t_i2c_if signal record
  procedure i2c_master_transmit (
    constant addr_value   : in    unsigned;
    constant data         : in    std_logic_vector;
    constant msg          : in    string;
    signal i2c_if         : inout t_i2c_if;
    constant continue     : in    boolean          := false;
    constant scope        : in    string           := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in    t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT
    );

  ------------------------------------------
  -- i2c_slave_transmit
  ------------------------------------------
  -- This procedure transmits data 'data' to an I2C master DUT.
  procedure i2c_slave_transmit (
    constant data         : in    t_byte_array;
    constant msg          : in    string;
    signal scl            : inout std_logic;
    signal sda            : inout std_logic;
    constant scope        : in    string           := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in    t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT
    );

  ------------------------------------------
  -- i2c_slave_transmit
  ------------------------------------------
  -- This procedure transmits data 'data' to an I2C master DUT.
  -- The I2C interface in this procedure is given as a t_i2c_if signal record
  procedure i2c_slave_transmit (
    constant data         : in    t_byte_array;
    constant msg          : in    string;
    signal i2c_if         : inout t_i2c_if;
    constant scope        : in    string           := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in    t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT
    );

  ------------------------------------------
  -- i2c_slave_transmit
  ------------------------------------------
  -- This procedure transmits data 'data' to an I2C master DUT.
  -- The I2C interface in this procedure is given as a t_i2c_if signal record
  procedure i2c_slave_transmit (
    constant data         : in    std_logic_vector;
    constant msg          : in    string;
    signal i2c_if         : inout t_i2c_if;
    constant scope        : in    string           := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in    t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT
    );

  ------------------------------------------
  -- i2c_master_receive
  ------------------------------------------
  -- This procedure receives data 'data' from an I2C slave DUT
  -- at address 'addr_value'.
  procedure i2c_master_receive (
    constant addr_value   : in    unsigned;
    variable data         : out   t_byte_array;
    constant msg          : in    string;
    signal scl            : inout std_logic;
    signal sda            : inout std_logic;
    constant continue     : in    boolean          := false;
    constant scope        : in    string           := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in    t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT;
    constant proc_name    : in    string           := "i2c_master_receive"  -- overwrite if called from other procedure like i2c_slave_check
    );

  ------------------------------------------
  -- i2c_master_receive
  ------------------------------------------
  -- This procedure receives data 'data' from an I2C slave DUT
  -- at address 'addr_value'.
  -- The I2C interface in this procedure is given as a t_i2c_if signal record
  procedure i2c_master_receive (
    constant addr_value   : in    unsigned;
    variable data         : out   t_byte_array;
    constant msg          : in    string;
    signal i2c_if         : inout t_i2c_if;
    constant continue     : in    boolean          := false;
    constant scope        : in    string           := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in    t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT;
    constant proc_name    : in    string           := "i2c_master_receive"  -- overwrite if called from other procedure like i2c_slave_check
    );

  ------------------------------------------
  -- i2c_master_receive
  ------------------------------------------
  -- This procedure receives data 'data' from an I2C slave DUT
  -- at address 'addr_value'.
  -- The I2C interface in this procedure is given as a t_i2c_if signal record
  procedure i2c_master_receive (
    constant addr_value   : in    unsigned;
    variable data         : out   std_logic_vector;
    constant msg          : in    string;
    signal i2c_if         : inout t_i2c_if;
    constant continue     : in    boolean          := false;
    constant scope        : in    string           := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in    t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT;
    constant proc_name    : in    string           := "i2c_master_receive"  -- overwrite if called from other procedure like i2c_slave_check
    );

  ------------------------------------------
  -- i2c_slave_receive
  ------------------------------------------
  -- This procedure receives data 'data' from an I2C master DUT.
  -- at address 'addr_value'.
  procedure i2c_slave_receive (
    variable data         : out   t_byte_array;
    constant msg          : in    string;
    signal scl            : inout std_logic;
    signal sda            : inout std_logic;
    constant scope        : in    string           := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in    t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT;
    constant proc_name    : in    string           := "i2c_slave_receive"  -- overwrite if called from other procedure like i2c_slave_check
    );

  ------------------------------------------
  -- i2c_slave_receive
  ------------------------------------------
  -- This procedure receives data 'data' from an I2C master DUT.
  -- The I2C interface in this procedure is given as a t_i2c_if signal record
  procedure i2c_slave_receive (
    variable data         : out   t_byte_array;
    constant msg          : in    string;
    signal i2c_if         : inout t_i2c_if;
    constant scope        : in    string           := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in    t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT;
    constant proc_name    : in    string           := "i2c_slave_receive"  -- overwrite if called from other procedure like i2c_slave_check
    );

  ------------------------------------------
  -- i2c_slave_receive
  ------------------------------------------
  -- This procedure receives data 'data' from an I2C master DUT.
  -- The I2C interface in this procedure is given as a t_i2c_if signal record
  procedure i2c_slave_receive (
    variable data         : out   std_logic_vector;
    constant msg          : in    string;
    signal i2c_if         : inout t_i2c_if;
    constant scope        : in    string           := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in    t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT;
    constant proc_name    : in    string           := "i2c_slave_receive"  -- overwrite if called from other procedure like i2c_slave_check
    );

  ------------------------------------------
  -- i2c_master_check
  ------------------------------------------
  -- This procedure receives an I2C transaction from an I2C slave DUT at address
  -- 'addr_value', and compares the read data to the expected data in 'data_exp'.
  -- If the read data is inconsistent with the expected data, an alert with 
  -- severity 'alert_level' is triggered.
  -- The I2C interface in this procedure is given as individual signals
  procedure i2c_master_check (
    constant addr_value   : in    unsigned;
    constant data_exp     : in    t_byte_array;
    constant alert_level  : in    t_alert_level    := error;
    constant msg          : in    string;
    signal scl            : inout std_logic;
    signal sda            : inout std_logic;
    constant continue     : in    boolean          := false;
    constant scope        : in    string           := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in    t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT
    );

  ------------------------------------------
  -- i2c_master_check
  ------------------------------------------
  -- This procedure receives an I2C transaction from an I2C slave DUT at address
  -- 'addr_value', and compares the read data to the expected data in 'data_exp'.
  -- If the read data is inconsistent with the expected data, an alert with 
  -- severity 'alert_level' is triggered.
  -- The I2C interface in this procedure is given as a t_i2c_if signal record
  procedure i2c_master_check (
    constant addr_value   : in    unsigned;
    constant data_exp     : in    t_byte_array;
    constant alert_level  : in    t_alert_level    := error;
    constant msg          : in    string;
    signal i2c_if         : inout t_i2c_if;
    constant continue     : in    boolean          := false;
    constant scope        : in    string           := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in    t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT
    );

  ------------------------------------------
  -- i2c_master_check
  ------------------------------------------
  -- This procedure receives an I2C transaction from an I2C slave DUT at address
  -- 'addr_value', and compares the read data to the expected data in 'data_exp'.
  -- If the read data is inconsistent with the expected data, an alert with 
  -- severity 'alert_level' is triggered.
  -- The I2C interface in this procedure is given as a t_i2c_if signal record
  procedure i2c_master_check (
    constant addr_value   : in    unsigned;
    constant data_exp     : in    std_logic_vector;
    constant alert_level  : in    t_alert_level    := error;
    constant msg          : in    string;
    signal i2c_if         : inout t_i2c_if;
    constant continue     : in    boolean          := false;
    constant scope        : in    string           := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in    t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT
    );

  ------------------------------------------
  -- i2c_slave_check
  ------------------------------------------
  -- This procedure receives an I2C transaction from an I2C master DUT, 
  -- and compares the read data to the expected data in 'data_exp'.
  -- If the read data is inconsistent with the expected data, an alert with 
  -- severity 'alert_level' is triggered.
  -- The I2C interface in this procedure is given as individual signals
  procedure i2c_slave_check (
    constant data_exp     : in    t_byte_array;
    constant alert_level  : in    t_alert_level    := error;
    constant msg          : in    string;
    signal scl            : inout std_logic;
    signal sda            : inout std_logic;
    constant scope        : in    string           := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in    t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT
    );

  ------------------------------------------
  -- i2c_slave_check
  ------------------------------------------
  -- This procedure receives an I2C transaction from an I2C master DUT, 
  -- and compares the read data to the expected data in 'data_exp'.
  -- If the read data is inconsistent with the expected data, an alert with 
  -- severity 'alert_level' is triggered.
  -- The I2C interface in this procedure is given as a t_i2c_if signal record
  procedure i2c_slave_check (
    constant data_exp     : in    t_byte_array;
    constant alert_level  : in    t_alert_level    := error;
    constant msg          : in    string;
    signal i2c_if         : inout t_i2c_if;
    constant scope        : in    string           := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in    t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT
    );

  ------------------------------------------
  -- i2c_slave_check
  ------------------------------------------
  -- This procedure receives an I2C transaction from an I2C master DUT, 
  -- and compares the read data to the expected data in 'data_exp'.
  -- If the read data is inconsistent with the expected data, an alert with 
  -- severity 'alert_level' is triggered.
  -- The I2C interface in this procedure is given as a t_i2c_if signal record
  procedure i2c_slave_check (
    constant data_exp     : in    std_logic_vector;
    constant alert_level  : in    t_alert_level    := error;
    constant msg          : in    string;
    signal i2c_if         : inout t_i2c_if;
    constant scope        : in    string           := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in    t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT
    );

  -- support procedure not yet in uvvm_util
  procedure check_value_X01 (
    signal target         : std_logic;
    constant exp          : std_logic;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant name         : string         := "check_value()"
    );

  -- support procedure not yet in uvvm_util
  procedure await_value_X01 (
    signal target         : std_logic;
    constant exp          : std_logic;
    constant min_time     : time;
    constant max_time     : time;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel
    );

end package i2c_bfm_pkg;


--=================================================================================================
--=================================================================================================

package body i2c_bfm_pkg is

  ---------------------------------------------------------------------------------
  -- check slave address
  -- 
  -- Compares slave address with known reserved addresses and triggers an alert
  -- if equal. Input is a slave address, either 7-bit or 10-bit. Make sure that
  -- the correct length address is input to this procedure, i.e., that a 10-bit
  -- value is not sent in when the BFM is in 7-bit address mode.
  ---------------------------------------------------------------------------------

  procedure i2c_check_slave_addr(
    constant addr_value  : in unsigned;
    constant alert_level :    t_alert_level;
    constant scope       : in string := C_TB_SCOPE_DEFAULT
    ) is
    constant C_SCOPE : string := scope & ": i2c_check_slave_addr()";
    constant head    : string := "This address is reserved for ";
    constant tail    : string := ". Only use this address if you are certain " &
                              "that the address is never going to be used " &
                              "for its intended purpose. See I2C-bus specification Rev. 6 " &
                              "for more information.";
    -- WORKAROUND: for GHDL
    --   Version:	 0.34dev (last tested pre-release version: 6235a6a)
    --   Issue:		 'addr_value' is not considdered locally static, so it can't
    --             be used as an expression in a case statement.
    --   Ticket:   https://github.com/tgingold/ghdl/issues/190
    --   Solution: Define an alias for the lower bits
    alias addr_value_a : unsigned(6 downto 0) is addr_value(6 downto 0);
  begin
    if addr_value'length = 7 then
      if addr_value_a(6 downto 2) = "00000" then
        case addr_value_a(1 downto 0) is
          when "00" =>
            -- general call (rw = 0)
            -- START byte (rw = 1)
            alert(alert_level, head & "general call and START byte" & tail, C_SCOPE);
          when "01" =>
            -- cbus addr
            alert(alert_level, head & "CBUS address" & tail, C_SCOPE);
          when "10" =>
            -- reserved for different bus format
            alert(alert_level, head & "different bus format" & tail, C_SCOPE);
          when "11" =>
            -- reserved for future purposes
            alert(alert_level, head & "future purposes" & tail, C_SCOPE);
          when others =>
            null;
        end case;
      elsif addr_value_a(6 downto 2) = "00001" then
        -- Hs-mode master code
        alert(alert_level, head & "High-speed mode (Hs-mode) master code" & tail, C_SCOPE);
      elsif addr_value_a(6 downto 2) = "11111" then
        -- device ID
        alert(alert_level, head & "device ID" & tail, C_SCOPE);
      elsif addr_value_a(6 downto 2) = "11110" then
        -- 10-bit-addressing
        alert(alert_level, head & "10-bit-addressing" & tail, C_SCOPE);
      else
      -- do nothing
      end if;
    elsif addr_value'length = 10 then
    -- do nothing
    else
      alert(error, "Invalid address length!", C_SCOPE);
    end if;
  end procedure;

  ---------------------------------------------------------------------------------
  -- initialize i2c to dut signals
  ---------------------------------------------------------------------------------

  function init_i2c_if_signals (
    constant VOID : in t_void
    ) return t_i2c_if is
    variable result : t_i2c_if;
  begin
    result.sda := 'Z';
    result.scl := 'Z';
    return result;
  end function;


  ---------------------------------------------------------------------------------
  -- check_time_window method here since it is local in uvvm_util.methods_pkg
  -- just for the time being while having the local procedure await_value_X01()
  ---------------------------------------------------------------------------------
  -- check_time_window is used to check if a given condition occurred between
  -- min_time and max_time
  -- Usage: wait for requested condition until max_time is reached, then call check_time_window().
  -- The input 'success' is needed to distinguish between the following cases:
  --      - the signal reached success condition at max_time,
  --      - max_time was reached with no success condition
  procedure check_time_window(
    constant success      : boolean;    -- F.ex target'event, or target=exp
    constant elapsed_time : time;
    constant min_time     : time;
    constant max_time     : time;
    constant alert_level  : t_alert_level;
    constant name         : string;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel
    ) is
  begin
    -- Sanity check
    check_value(max_time >= min_time, TB_ERROR, name & " => min_time must be less than max_time." & LF & msg, scope, ID_NEVER, msg_id_panel, name);

    if elapsed_time < min_time then
      alert(alert_level, name & " => Failed. Condition occurred too early, after " &
            to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & msg, scope);
    elsif success then
      log(msg_id, name & " => OK. Condition occurred after " &
          to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & msg, scope, msg_id_panel);
    else                                -- max_time reached with no success
      alert(alert_level, name & " => Failed. Timed out after " &
            to_string(max_time, C_LOG_TIME_BASE) & ". " & msg, scope);
    end if;
  end;

  -- support procedure not yet in uvvm_util
  procedure check_value_X01 (
    signal target         : std_logic;
    constant exp          : std_logic;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant name         : string         := "check_value()"
    ) is
    constant value_type   : string := "std_logic";
    constant v_target_str : string := to_string(target);
    constant v_exp_str    : string := to_string(exp);

    variable v_success : boolean := false;
  begin
    if ((exp = '1' or exp = 'H') and
        (target = '1' or target = 'H')) then
      v_success := true;
    elsif ((exp = '0' or exp = 'L') and
           (target = '0' or target = 'L')) then
      v_success := true;
    end if;

    if v_success then
      log(msg_id, name & " => OK, for " & value_type & " '" & v_target_str & "'. " & msg, scope, msg_id_panel);
    else
      alert(alert_level, name & " => Failed. " & value_type & "  Was '" & v_target_str & "'. Expected '" & v_exp_str & "'" & LF & msg, scope);
    end if;
  end procedure check_value_X01;

  -- support procedure not yet in uvvm_util
  procedure await_value_X01 (
    signal target         : std_logic;
    constant exp          : std_logic;
    constant min_time     : time;
    constant max_time     : time;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel
    ) is
    constant value_type : string := "std_logic";
    constant start_time : time   := now;
    constant v_exp_str  : string := to_string(exp);
    constant name       : string := "await_value(" & value_type & " " & v_exp_str & ", " &
                              to_string(min_time, ns) & ", " & to_string(max_time, ns) & ")";
    variable success : boolean;
  begin
    if ((exp = '1' or exp = 'H') and
        (target /= '1') and (target /= 'H')) then
      wait until (target = '1' or target = 'H')
        for max_time;
    elsif ((exp = '0' or exp = 'L') and
           (target /= '0') and (target /= 'L')) then
      wait until (target = '0' or target = 'L')
        for max_time;
    end if;
    success := false;
    if ((exp = '1' or exp = 'H') and
        (target = '1' or target = 'H')) then
      success := true;
    elsif ((exp = '0' or exp = 'L') and
           (target = '0' or target = 'L')) then
      success := true;
    end if;
    check_time_window(success, now-start_time, min_time, max_time, alert_level, name, msg, scope, msg_id, msg_id_panel);
  end;

  procedure i2c_master_transmit_single_byte (
    constant byte         : in    std_logic_vector(7 downto 0);
    constant msg          : in    string;
    signal scl            : inout std_logic;
    signal sda            : inout std_logic;
    constant scope        : in    string           := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in    t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT
    ) is
  begin
    -- Time shall be at the falling edge time of SCL.

    for i in 7 downto 0 loop
      wait for config.i2c_bit_time/4;
      if byte(i) = '1' then
        sda <= 'Z';
      else
        sda <= '0';
      end if;
      wait for config.i2c_bit_time/4;
      scl <= 'Z';                       -- release
      wait for config.i2c_bit_time/2;
      -- check for clock stretching
      await_value_X01(scl, '1', 0 ns, config.i2c_bit_time, config.i2c_bit_time_severity, msg, scope, ID_NEVER, msg_id_panel);
      scl <= '0';
    end loop;
  end procedure;

  procedure i2c_master_receive_single_byte (
    variable byte         : out   std_logic_vector(7 downto 0);
    constant msg          : in    string;
    signal scl            : inout std_logic;
    signal sda            : inout std_logic;
    constant scope        : in    string           := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in    t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT
    ) is
  begin
    -- Time shall be at the falling edge time of SCL.

    for i in 7 downto 0 loop
      wait for config.i2c_bit_time/2;
      scl     <= 'Z';                   -- release
      -- check for clock stretching
      await_value_X01(scl, '1', 0 ns, config.max_wait_scl_change, config.max_wait_scl_change_severity, msg, scope, ID_NEVER, msg_id_panel);
      byte(i) := to_X01(sda);
      wait for config.i2c_bit_time/2;
      scl     <= '0';
    end loop;
  end procedure;

  procedure i2c_master_set_ack (
    constant ack          : in    std_logic;
    constant msg          : in    string;
    signal scl            : inout std_logic;
    signal sda            : inout std_logic;
    constant scope        : in    string           := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in    t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT
    ) is
  begin
    -- Time shall be at the falling edge time of SCL.

    wait for config.i2c_bit_time/4;
    if ack = '1' then
      sda <= 'Z';
    else
      sda <= '0';
    end if;
    wait for config.i2c_bit_time/4;
    scl <= 'Z';                         -- release
    wait for config.i2c_bit_time/2;
    -- check for clock stretching
    await_value_X01(scl, '1', 0 ns, config.i2c_bit_time, config.i2c_bit_time_severity, msg, scope, ID_NEVER, msg_id_panel);
    scl <= '0';
    wait for config.i2c_bit_time/4;
    sda <= 'Z';                         -- release
  end procedure;

  procedure i2c_master_check_ack (
    constant ack_exp      : in    std_logic;
    constant msg          : in    string;
    signal scl            : inout std_logic;
    signal sda            : inout std_logic;
    constant scope        : in    string           := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in    t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT
    ) is
  begin
    -- Time shall be at the falling edge time of SCL.

    -- Check ACK
    -- The master shall drive scl during the acknowledge cycle
    -- A valid ack is detected when sda is '0'.
    wait for config.i2c_bit_time/4;
    sda <= 'Z';                         -- release
    wait for config.i2c_bit_time/4;
    scl <= 'Z';
    wait for config.i2c_bit_time/4;
    check_value_X01(sda, ack_exp, config.acknowledge_severity, msg, scope, ID_NEVER, msg_id_panel);
    wait for config.i2c_bit_time/4;
    -- check for clock stretching
    await_value_X01(scl, '1', 0 ns, config.i2c_bit_time, config.i2c_bit_time_severity, msg, scope, ID_NEVER, msg_id_panel);
    scl <= '0';
  end procedure;

  procedure i2c_slave_transmit_single_byte (
    constant byte         : in    std_logic_vector(7 downto 0);
    constant msg          : in    string;
    signal scl            : inout std_logic;
    signal sda            : inout std_logic;
    constant scope        : in    string           := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in    t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT
    ) is
  begin
    -- Time shall be at the falling edge time of SCL.

    for i in 7 downto 0 loop
      wait for config.i2c_bit_time/4;
      if byte(i) = '1' then
        sda <= 'Z';
      else
        sda <= '0';
      end if;
      await_value_X01(scl, '1', 0 ns, config.max_wait_scl_change + config.max_wait_scl_change/100, config.max_wait_scl_change_severity, msg, scope, ID_NEVER, msg_id_panel);
      await_value(scl, '0', 0 ns, config.max_wait_scl_change + config.max_wait_scl_change/100, config.max_wait_scl_change_severity, msg, scope, ID_NEVER, msg_id_panel);
    end loop;
  end procedure;

  procedure i2c_slave_receive_single_byte (
    variable byte         : out   std_logic_vector(7 downto 0);
    constant msg          : in    string;
    signal scl            : inout std_logic;
    signal sda            : inout std_logic;
    constant scope        : in    string           := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in    t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT
    ) is
  begin
    -- Time shall be at the falling edge time of SCL.

    for i in 7 downto 0 loop
      await_value_X01(scl, '1', 0 ns, config.max_wait_scl_change + config.max_wait_scl_change/100, config.max_wait_scl_change_severity, msg, scope, ID_NEVER, msg_id_panel);
      wait for config.i2c_bit_time/4;  -- to sample in the middle of the high period
      byte(i) := to_X01(sda);
      await_value(scl, '0', 0 ns, config.max_wait_scl_change + config.max_wait_scl_change/100, config.max_wait_scl_change_severity, msg, scope, ID_NEVER, msg_id_panel);
    end loop;
  end procedure;

  procedure i2c_slave_set_ack (
    constant ack          : in    std_logic;
    constant msg          : in    string;
    signal scl            : inout std_logic;
    signal sda            : inout std_logic;
    constant scope        : in    string           := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in    t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT
    ) is
  begin
    -- Time shall be at the falling edge time of SCL.

    wait for config.i2c_bit_time/4;
    if ack = '1' then
      sda <= 'Z';
    else
      sda <= '0';
    end if;
    await_value_X01(scl, '1', 0 ns, config.max_wait_scl_change + config.max_wait_scl_change/100, config.max_wait_scl_change_severity, msg, scope, ID_NEVER, msg_id_panel);
    await_value(scl, '0', 0 ns, config.max_wait_scl_change + config.max_wait_scl_change/100, config.max_wait_scl_change_severity, msg, scope, ID_NEVER, msg_id_panel);
    wait for config.i2c_bit_time/4;
    sda <= 'Z';
  end procedure;

  procedure i2c_slave_check_ack (
    constant ack_exp      : in    std_logic;
    constant msg          : in    string;
    signal scl            : inout std_logic;
    signal sda            : inout std_logic;
    constant scope        : in    string           := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in    t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT
    ) is
  begin
    -- Time shall be at the falling edge time of SCL.

    -- Check ACK
    -- The master shall drive scl during the acknowledge cycle
    -- A valid ack is detected when sda is '0'.
    wait for config.i2c_bit_time/4;
    sda <= 'Z';                         -- release
    await_value_X01(scl, '1', 0 ns, config.max_wait_scl_change + config.max_wait_scl_change/100, config.max_wait_scl_change_severity, msg, scope, ID_NEVER, msg_id_panel);
    check_value_X01(sda, ack_exp, config.acknowledge_severity, msg, scope, ID_NEVER, msg_id_panel);
    await_value(scl, '0', 0 ns, config.max_wait_scl_change + config.max_wait_scl_change/100, config.max_wait_scl_change_severity, msg, scope, ID_NEVER, msg_id_panel);
  end procedure;


  ---------------------------------------------------------------------------------
  -- i2c_master_transmit
  -- alert if size of data doesn't match with how long sda is kept low
  ---------------------------------------------------------------------------------
  procedure i2c_master_transmit (
    constant addr_value   : in    unsigned;
    constant data         : in    t_byte_array;
    constant msg          : in    string;
    signal scl            : inout std_logic;
    signal sda            : inout std_logic;
    constant continue     : in    boolean          := false;
    constant scope        : in    string           := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in    t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT
    ) is
    constant proc_name : string := "i2c_master_transmit";
    constant proc_call : string := proc_name & "(A:" & to_string(addr_value, HEX, AS_IS, INCL_RADIX) &
                                   ", " & to_string(data, HEX, AS_IS, INCL_RADIX) & ")";

    constant C_10_BIT_ADDRESS_PATTERN : std_logic_vector(4 downto 0) := "11110";

    -- Normalize to the 7 bit addr and 8 bit data widths
    variable v_normalized_addr : unsigned(9 downto 0) :=
      normalize_and_check(addr_value, config.slave_mode_address, ALLOW_NARROWER, "addr", "config.slave_mode_address", msg);

    constant C_FIRST_10_BIT_ADDRESS_BITS : std_logic_vector(6 downto 0) := C_10_BIT_ADDRESS_PATTERN & std_logic_vector(v_normalized_addr(9 downto 8));

    procedure i2c_master_transmit_single_byte (
      constant byte : in std_logic_vector(7 downto 0)
      ) is
    begin
      i2c_master_transmit_single_byte(byte, msg, scl, sda, scope, msg_id_panel, config);
    end procedure;

    procedure i2c_master_check_ack (
      constant ack_exp : in std_logic
      ) is
    begin
      i2c_master_check_ack(ack_exp, msg, scl, sda, scope, msg_id_panel, config);
    end procedure;

  begin

    if not config.enable_10_bits_addressing then
      check_value(v_normalized_addr(9 downto 7), unsigned'("000"), config.slave_mode_address_severity,
                  "Verifying that top slave address bits (9-7) are not set in 7-bit addressing mode.",
                  scope, HEX_BIN_IF_INVALID, KEEP_LEADING_0, ID_NEVER, msg_id_panel);
      i2c_check_slave_addr(v_normalized_addr(6 downto 0), config.reserved_address_severity, scope);
    else
      i2c_check_slave_addr(v_normalized_addr, config.reserved_address_severity, scope);
    end if;

    check_value(data'ascending, failure, "Verifying that data is of ascending type.", scope, ID_NEVER, msg_id_panel);

    await_value_X01(sda, '1', 0 ns, config.max_wait_sda_change, config.max_wait_sda_change_severity, msg, scope, ID_NEVER, msg_id_panel);
    await_value_X01(scl, '1', 0 ns, config.max_wait_scl_change, config.max_wait_scl_change_severity, msg, scope, ID_NEVER, msg_id_panel);

    if to_X01(sda) = '1' and to_X01(scl) = '1' then
      -- do the start condition
      sda <= '0';
      wait for config.master_sda_to_scl;
      scl <= '0';

      if sda = '0' then
        -- Transmit address
        if not config.enable_10_bits_addressing then
          i2c_master_transmit_single_byte(std_logic_vector(v_normalized_addr(6 downto 0)) & '0');  -- 7 bit address + write bit

        else                            -- 10-bits addressing enabled
          -- transmit 11110<addr bit 9><addr bit 8><Write>
          i2c_master_transmit_single_byte(C_FIRST_10_BIT_ADDRESS_BITS & '0');  -- Pattern indicating 10-bit addresing + first 2 bits of 10-bit address + write bit
        end if;

        -- Check ACK
        -- The master shall drive scl during the acknowledge cycle
        -- A valid ack is detected when sda is '0'.
        i2c_master_check_ack('0');

        -- If 10-bits addressing is enabled, transmit second address byte.
        if config.enable_10_bits_addressing then
          i2c_master_transmit_single_byte(std_logic_vector(v_normalized_addr(7 downto 0)));  -- LSB of 10-bit address

          -- Check ACK
          -- The master shall drive scl during the acknowledge cycle
          -- A valid ack is detected when sda is '0'.
          i2c_master_check_ack('0');
        end if;

        -- serially shift out data to sda
        for i in 0 to data'length - 1 loop
          i2c_master_transmit_single_byte(data(i));

          -- Check ACK
          -- The master shall drive scl during the acknowledge cycle
          -- A valid ack is detected when sda is '0'.
          i2c_master_check_ack('0');
        end loop;

        wait for config.i2c_bit_time/4;

        if not continue then
          -- do the stop condition
          sda <= '0';
          wait for config.i2c_bit_time/4;
          scl <= 'Z';
          -- check for clock stretching
          await_value_X01(scl, '1', 0 ns, config.i2c_bit_time, config.i2c_bit_time_severity, msg, scope, ID_NEVER, msg_id_panel);
          wait for config.master_scl_to_sda;
          sda <= 'Z';
        else
          -- Do not perform the stop condition. Instead release SDA when SCL is low.
          -- This will prepare for a repeated start condition.
          sda <= 'Z';
          wait for config.i2c_bit_time/4;
          scl <= 'Z';
          -- check for clock stretching
          await_value_X01(scl, '1', 0 ns, config.i2c_bit_time, config.i2c_bit_time_severity, msg, scope, ID_NEVER, msg_id_panel);
        end if;

        wait for config.master_stop_condition_hold_time;
      end if;
    else
      alert(error, proc_call & " sda and scl not inactive (high) when wishing to start");
    end if;

    log(config.id_for_bfm, proc_call & "=> " & to_string(data, HEX, SKIP_LEADING_0, INCL_RADIX) & ". " & msg, scope, msg_id_panel);

  end procedure;

  procedure i2c_master_transmit(
    constant addr_value   : in    unsigned;
    constant data         : in    t_byte_array;
    constant msg          : in    string;
    signal i2c_if         : inout t_i2c_if;
    constant continue     : in    boolean          := false;
    constant scope        : in    string           := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in    t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT
    ) is
  begin
    i2c_master_transmit(addr_value, data, msg,
                        i2c_if.scl, i2c_if.sda, continue,
                        scope, msg_id_panel, config);
  end procedure;

  ---------------------------------------------------------------------------------
  -- i2c_master_transmit
  -- alert if size of data doesn't match with how long sda is kept low
  ---------------------------------------------------------------------------------
  procedure i2c_master_transmit (
    constant addr_value   : in    unsigned;
    constant data         : in    std_logic_vector;
    constant msg          : in    string;
    signal i2c_if         : inout t_i2c_if;
    constant continue     : in    boolean          := false;
    constant scope        : in    string           := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in    t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT
    ) is
    variable v_bfm_tx_data : std_logic_vector(7 downto 0) := (others => '0');

    -- Normalize to the 8 bit data width
    variable v_normalized_data : std_logic_vector(7 downto 0) :=
      normalize_and_check(data, v_bfm_tx_data, ALLOW_NARROWER, "data", "v_bfm_tx_data", msg);

    variable v_byte_array : t_byte_array(0 to 0) := (0 => v_normalized_data);
  begin
    i2c_master_transmit(addr_value, v_byte_array, msg,
                        i2c_if.scl, i2c_if.sda, continue,
                        scope, msg_id_panel, config);
  end procedure;


  ---------------------------------------------------------------------------------
  -- i2c_slave_transmit
  -- alert if size of data doesn't match with how long sda is kept low
  ---------------------------------------------------------------------------------
  procedure i2c_slave_transmit (
    constant data         : in    t_byte_array;
    constant msg          : in    string;
    signal scl            : inout std_logic;
    signal sda            : inout std_logic;
    constant scope        : in    string           := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in    t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT
    ) is
    constant proc_name : string := "i2c_slave_transmit";
    constant proc_call : string := proc_name & "(" & to_string(data, HEX, AS_IS, INCL_RADIX) & ")";

    variable v_bfm_rx_data   : std_logic_vector(7 downto 0) := (others => '0');
    variable v_received_addr : unsigned(9 downto 0)         := (others => '0');

    constant C_10_BIT_ADDRESS_PATTERN    : std_logic_vector(4 downto 0) := "11110";
    constant C_FIRST_10_BIT_ADDRESS_BITS : std_logic_vector(6 downto 0) := C_10_BIT_ADDRESS_PATTERN & std_logic_vector(config.slave_mode_address(9 downto 8));

    procedure i2c_slave_transmit_single_byte (
      constant byte : in std_logic_vector(7 downto 0)
      ) is
    begin
      i2c_slave_transmit_single_byte(byte, msg, scl, sda, scope, msg_id_panel, config);
    end procedure;

    procedure i2c_slave_receive_single_byte (
      variable byte : out std_logic_vector(7 downto 0)
      ) is
    begin
      i2c_slave_receive_single_byte(byte, msg, scl, sda, scope, msg_id_panel, config);
    end procedure;

    procedure i2c_slave_set_ack (
      constant ack : in std_logic
      ) is
    begin
      i2c_slave_set_ack(ack, msg, scl, sda, scope, msg_id_panel, config);
    end procedure;

    procedure i2c_slave_check_ack (
      constant ack_exp : in std_logic
      ) is
    begin
      i2c_slave_check_ack(ack_exp, msg, scl, sda, scope, msg_id_panel, config);
    end procedure;

  begin
    if not config.enable_10_bits_addressing then
      check_value(config.slave_mode_address(9 downto 7), unsigned'("000"), config.slave_mode_address_severity,
                  "Verifying that top slave address bits (9-7) are not set in 7-bit addressing mode.",
                  scope, HEX_BIN_IF_INVALID, KEEP_LEADING_0, ID_NEVER, msg_id_panel);
      i2c_check_slave_addr(config.slave_mode_address(6 downto 0), config.reserved_address_severity, scope);
    else
      i2c_check_slave_addr(config.slave_mode_address, config.reserved_address_severity, scope);
    end if;

    check_value(data'ascending, failure, "Verifying that data is of ascending type.", scope, ID_NEVER, msg_id_panel);

    await_value_X01(sda, '1', 0 ns, config.max_wait_sda_change, config.max_wait_sda_change_severity, msg, scope, ID_NEVER, msg_id_panel);
    await_value_X01(scl, '1', 0 ns, config.max_wait_scl_change, config.max_wait_scl_change_severity, msg, scope, ID_NEVER, msg_id_panel);

    if to_X01(sda) = '1' and to_X01(scl) = '1' then
      -- await the start condition
      await_value(sda, '0', 0 ns, config.max_wait_sda_change + config.max_wait_sda_change/100, config.max_wait_sda_change_severity, msg, scope, ID_NEVER, msg_id_panel);
      await_value(scl, '0', 0 ns, config.max_wait_scl_change + config.max_wait_scl_change/100, config.max_wait_scl_change_severity, msg, scope, ID_NEVER, msg_id_panel);

      if sda = '0' then
        if not config.enable_10_bits_addressing then
          -- receive the address bits
          i2c_slave_receive_single_byte(v_bfm_rx_data);
          v_received_addr(6 downto 0) := unsigned(v_bfm_rx_data(7 downto 1));
          -- Check R/W bit
          check_value(v_bfm_rx_data(0), '1', config.slave_rw_bit_severity, msg, scope, ID_NEVER, msg_id_panel);

          -- Set ACK/NACK based on address
          -- The master shall drive scl during the acknowledge cycle
          -- A valid ack is detected when sda is '0'.
          if v_received_addr = config.slave_mode_address then
            -- ACK
            i2c_slave_set_ack('0');
          else
            -- NACK
            alert(config.slave_mode_address_severity, proc_call & " wrong slave address!" &
                  " Expected: " & to_string(config.slave_mode_address, BIN, KEEP_LEADING_0) &
                  ", Got: " & to_string(v_received_addr, BIN, KEEP_LEADING_0));
            return;
          end if;
        else                            -- 10 bit addressing
          -- receive the first byte, consisting of "11110<bit 9><bit 8><write>"
          i2c_slave_receive_single_byte(v_bfm_rx_data);
          v_received_addr(9 downto 8) := unsigned(v_bfm_rx_data(2 downto 1));
          -- Check R/W bit
          check_value(v_bfm_rx_data(0), '0', config.slave_rw_bit_severity, msg & ": checking R/W bit after first address byte (10-bit addressing)", scope, ID_NEVER, msg_id_panel);

          -- Set ACK/NACK based on first received byte
          -- The master shall drive scl during the acknowledge cycle
          -- A valid ack is detected when sda is '0'.
          if v_bfm_rx_data(7 downto 1) = C_FIRST_10_BIT_ADDRESS_BITS then
            -- ACK
            i2c_slave_set_ack('0');
          else
            -- NACK
            alert(config.slave_mode_address_severity, proc_call & " first byte was other than expected!");
            return;
          end if;

          -- Receive LSB of 10-bit address
          i2c_slave_receive_single_byte(v_bfm_rx_data);
          v_received_addr(7 downto 0) := unsigned(v_bfm_rx_data);

          -- Set ACK/NACK based on address
          -- The master shall drive scl during the acknowledge cycle
          -- A valid ack is detected when sda is '0'.
          if v_received_addr = config.slave_mode_address then
            -- ACK
            i2c_slave_set_ack('0');
          else
            -- NACK
            alert(config.slave_mode_address_severity, proc_call & " wrong slave address!" &
                  " Expected: " & to_string(config.slave_mode_address, BIN, KEEP_LEADING_0) &
                  ", Got: " & to_string(v_received_addr, BIN, KEEP_LEADING_0));
            return;
          end if;

          -- Expect repeated start condition
          sda <= 'Z';                   -- other side should drive now
          await_value_X01(scl, '1', 0 ns, config.max_wait_scl_change + config.max_wait_scl_change/100, config.max_wait_scl_change_severity, msg, scope, ID_NEVER, msg_id_panel);
          await_value_X01(sda, '1', 0 ns, config.master_scl_to_sda + config.master_scl_to_sda/100, config.max_wait_sda_change_severity, msg, scope, ID_NEVER, msg_id_panel);

          if to_X01(sda) = '1' and to_X01(scl) = '1' then
            -- await the start condition
            await_value(sda, '0', 0 ns, config.max_wait_sda_change + config.max_wait_sda_change/100, config.max_wait_sda_change_severity, msg, scope, ID_NEVER, msg_id_panel);
            await_value(scl, '0', 0 ns, config.max_wait_scl_change + config.max_wait_scl_change/100, config.max_wait_scl_change_severity, msg, scope, ID_NEVER, msg_id_panel);

            if sda = '0' then
              -- receive the first 2 address bits again+ read bit, consisting of "11110<bit 9><bit 8><read>"
              i2c_slave_receive_single_byte(v_bfm_rx_data);
              -- Check R/W bit
              check_value(v_bfm_rx_data(0), '1', config.slave_rw_bit_severity, msg & ": checking R/W bit after first address byte (10-bit addressing)", scope, ID_NEVER, msg_id_panel);

              -- Set ACK/NACK based on first received byte
              -- The master shall drive scl during the acknowledge cycle
              -- A valid ack is detected when sda is '0'.
              if v_bfm_rx_data(7 downto 1) = C_FIRST_10_BIT_ADDRESS_BITS then
                -- ACK
                i2c_slave_set_ack('0');
              else
                -- NACK
                alert(config.slave_mode_address_severity, proc_call & " first byte was other than expected!");
                return;
              end if;
            else
              alert(error, proc_call & " sda and scl not inactive (high) when wishing to start after repeated start condition for 10 bit address");
            end if;
          end if;
        end if;

        for i in 0 to data'length - 1 loop
          i2c_slave_transmit_single_byte(data(i));

          -- Check ACK
          -- The master shall drive scl during the acknowledge cycle
          -- A valid ack is detected when sda is '0'.
          -- A NACK ('1'/'H') means that the transaction is over.
          if i < data'length - 1 then
            i2c_slave_check_ack('0');
          else                          -- final data byte expected
            i2c_slave_check_ack('1');
          end if;

          await_value(scl, '0', 0 ns, config.max_wait_scl_change + config.max_wait_scl_change/100, config.max_wait_scl_change_severity, msg, scope, ID_NEVER, msg_id_panel);
        end loop;

        -- Wait for either the stop condition or preparation for
        -- repeated start condition.
        sda <= 'Z';                     -- other side should drive now
        await_value_X01(scl, '1', 0 ns, config.max_wait_scl_change + config.max_wait_scl_change/100, config.max_wait_scl_change_severity, msg, scope, ID_NEVER, msg_id_panel);
        await_value_X01(sda, '1', 0 ns, config.master_scl_to_sda + config.master_scl_to_sda/100, config.max_wait_sda_change_severity, msg, scope, ID_NEVER, msg_id_panel);

      end if;
    else
      alert(error, proc_call & " sda and scl not inactive (high) when wishing to start");
    end if;

    log(config.id_for_bfm, proc_call & "=> " & to_string(data, HEX, SKIP_LEADING_0, INCL_RADIX) & ". " & msg, scope, msg_id_panel);

  end procedure;

  procedure i2c_slave_transmit(
    constant data         : in    t_byte_array;
    constant msg          : in    string;
    signal i2c_if         : inout t_i2c_if;
    constant scope        : in    string           := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in    t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT
    ) is
  begin
    i2c_slave_transmit(data, msg,
                       i2c_if.scl, i2c_if.sda,
                       scope, msg_id_panel, config);
  end procedure;

  procedure i2c_slave_transmit(
    constant data         : in    std_logic_vector;
    constant msg          : in    string;
    signal i2c_if         : inout t_i2c_if;
    constant scope        : in    string           := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in    t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT
    ) is
    variable v_bfm_tx_data : std_logic_vector(7 downto 0) := (others => '0');

    -- Normalize to the 8 bit data width
    variable v_normalized_data : std_logic_vector(7 downto 0) :=
      normalize_and_check(data, v_bfm_tx_data, ALLOW_NARROWER, "data", "v_bfm_tx_data", msg);

    variable v_byte_array : t_byte_array(0 to 0) := (0 => v_normalized_data);
  begin
    i2c_slave_transmit(v_byte_array, msg,
                       i2c_if.scl, i2c_if.sda,
                       scope, msg_id_panel, config);
  end procedure;

  ---------------------------------------------------------------------------------
  -- i2c_master_receive
  ---------------------------------------------------------------------------------
  procedure i2c_master_receive (
    constant addr_value   : in    unsigned;
    variable data         : out   t_byte_array;
    constant msg          : in    string;
    signal scl            : inout std_logic;
    signal sda            : inout std_logic;
    constant continue     : in    boolean          := false;
    constant scope        : in    string           := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in    t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT;
    constant proc_name    : in    string           := "i2c_master_receive"  -- overwrite if called from other procedure like i2c_master_check
    ) is
    constant proc_call : string := proc_name & "(A:" & to_string(addr_value, HEX, AS_IS, INCL_RADIX) & ")";

    constant C_10_BIT_ADDRESS_PATTERN : std_logic_vector(4 downto 0) := "11110";

    -- Normalize to the 7 bit addr and 8 bit data widths
    variable v_normalized_addr : unsigned(9 downto 0) :=
      normalize_and_check(addr_value, config.slave_mode_address, ALLOW_NARROWER, "addr", "config.slave_mode_address", msg);

    constant C_FIRST_10_BIT_ADDRESS_BITS : std_logic_vector(6 downto 0) := C_10_BIT_ADDRESS_PATTERN & std_logic_vector(v_normalized_addr(9 downto 8));

    procedure i2c_master_transmit_single_byte (
      constant byte : in std_logic_vector(7 downto 0)
      ) is
    begin
      i2c_master_transmit_single_byte(byte, msg, scl, sda, scope, msg_id_panel, config);
    end procedure;

    procedure i2c_master_receive_single_byte (
      variable byte : out std_logic_vector(7 downto 0)
      ) is
    begin
      i2c_master_receive_single_byte(byte, msg, scl, sda, scope, msg_id_panel, config);
    end procedure;

    procedure i2c_master_set_ack (
      constant ack : in std_logic
      ) is
    begin
      i2c_master_set_ack(ack, msg, scl, sda, scope, msg_id_panel, config);
    end procedure;

    procedure i2c_master_check_ack (
      constant ack_exp : in std_logic
      ) is
    begin
      i2c_master_check_ack(ack_exp, msg, scl, sda, scope, msg_id_panel, config);
    end procedure;
  begin

    if not config.enable_10_bits_addressing then
      check_value(v_normalized_addr(9 downto 7), unsigned'("000"), config.slave_mode_address_severity,
                  "Verifying that top slave address bits (9-7) are not set in 7-bit addressing mode.",
                  scope, HEX_BIN_IF_INVALID, KEEP_LEADING_0, ID_NEVER, msg_id_panel);
      i2c_check_slave_addr(v_normalized_addr(6 downto 0), config.reserved_address_severity, scope);
    else
      i2c_check_slave_addr(v_normalized_addr(9 downto 0), config.reserved_address_severity, scope);
    end if;

    check_value(data'ascending, failure, "Verifying that data is of ascending type.", scope, ID_NEVER, msg_id_panel);

    -- start condition
    await_value_X01(sda, '1', 0 ns, config.max_wait_sda_change, config.max_wait_sda_change_severity, msg, scope, ID_NEVER, msg_id_panel);
    await_value_X01(scl, '1', 0 ns, config.max_wait_scl_change, config.max_wait_scl_change_severity, msg, scope, ID_NEVER, msg_id_panel);

    if to_X01(sda) = '1' and to_X01(scl) = '1' then
      -- do the start condition
      sda <= '0';
      wait for config.master_sda_to_scl;
      scl <= '0';

      if sda = '0' then
        -- Transmit address
        if not config.enable_10_bits_addressing then
          i2c_master_transmit_single_byte(std_logic_vector(v_normalized_addr(6 downto 0)) & '1');
        else                            -- 10-bits addressing enabled
          -- Transmit Slave Address first 7 bits 11110<addr bit 9><addr bit 8><Write>
          i2c_master_transmit_single_byte(C_FIRST_10_BIT_ADDRESS_BITS & '0');
        end if;

        -- Check ACK
        -- The master shall drive scl during the acknowledge cycle
        -- A valid ack is detected when sda is '0'.
        i2c_master_check_ack('0');

        -- If 10-bits addressing is enabled, transmit second address byte.
        if config.enable_10_bits_addressing then
          i2c_master_transmit_single_byte(std_logic_vector(v_normalized_addr(7 downto 0)));

          -- Check ACK
          -- The master shall drive scl during the acknowledge cycle
          -- A valid ack is detected when sda is '0'.
          i2c_master_check_ack('0');

          -- Now generate a repeated start condition, send the first byte again (only with read/write-bit set to read), check ack. Then receive data bytes.

          -- Generate repeated start condition
          wait for config.i2c_bit_time/4;
          sda <= 'Z';
          wait for config.i2c_bit_time/4;
          scl <= 'Z';
          -- check for clock stretching
          await_value_X01(scl, '1', 0 ns, config.i2c_bit_time, config.i2c_bit_time_severity, msg, scope, ID_NEVER, msg_id_panel);

          wait for config.master_stop_condition_hold_time;
          -- do the start condition
          sda <= '0';
          wait for config.master_sda_to_scl;
          scl <= '0';
          if sda = '0' then
            -- Transmit Slave Address first 7 bits 11110<addr bit 9><addr bit 8><Read>
            i2c_master_transmit_single_byte(C_FIRST_10_BIT_ADDRESS_BITS & '1');

            -- Check ACK
            -- The master shall drive scl during the acknowledge cycle
            -- A valid ack is detected when sda is '0'.
            i2c_master_check_ack('0');
          else
            alert(error, proc_name & " sda not '0' when expected after repeated start condition for 10-bit addressing!");
          end if;
        end if;

        -- receive the data bytes
        for i in 0 to data'length-1 loop
          i2c_master_receive_single_byte(data(i));

          -- Set ACK/NACK
          -- The master shall drive scl during the acknowledge cycle
          -- A valid ack is detected when sda is '0'.
          -- Each byte shall be ACKed except last byte.
          -- Transaction ends when master sets NACK.
          -- scl has been driven to '0' above
          if i < data'length - 1 then
            i2c_master_set_ack('0');    -- ACK
          else
            i2c_master_set_ack('1');    -- NACK
          end if;
        end loop;

        if not continue then
          -- do the stop condition
          sda <= '0';
          wait for config.i2c_bit_time/4;
          scl <= 'Z';
          -- check for clock stretching
          await_value_X01(scl, '1', 0 ns, config.i2c_bit_time, config.i2c_bit_time_severity, msg, scope, ID_NEVER, msg_id_panel);
          wait for config.master_scl_to_sda;
          sda <= 'Z';
        else
          -- Do not perform the stop condition. Instead release SDA when SCL is low.
          -- This will prepare for a repeated start condition.
          sda <= 'Z';
          wait for config.i2c_bit_time/4;
          scl <= 'Z';
          -- check for clock stretching
          await_value_X01(scl, '1', 0 ns, config.i2c_bit_time, config.i2c_bit_time_severity, msg, scope, ID_NEVER, msg_id_panel);
        end if;

        wait for config.master_stop_condition_hold_time;
      end if;
    else
      alert(error, proc_call & " sda and scl not inactive (high) when wishing to start");
    end if;

    if proc_name = "i2c_master_receive" then
      log(config.id_for_bfm, proc_call & "=> " & to_string(data, HEX, SKIP_LEADING_0, INCL_RADIX) & ". " & msg, scope, msg_id_panel);
    else
    -- Log will be handled by calling procedure (e.g. i2c_master_check)
    end if;

  end procedure;

  procedure i2c_master_receive(
    constant addr_value   : in    unsigned;
    variable data         : out   t_byte_array;
    constant msg          : in    string;
    signal i2c_if         : inout t_i2c_if;
    constant continue     : in    boolean          := false;
    constant scope        : in    string           := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in    t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT;
    constant proc_name    : in    string           := "i2c_master_receive"  -- overwrite if called from other procedure like i2c_master_check
    ) is
  begin
    i2c_master_receive(addr_value, data, msg,
                       i2c_if.scl, i2c_if.sda, continue,
                       scope, msg_id_panel, config, proc_name);
  end procedure;

  procedure i2c_master_receive(
    constant addr_value   : in    unsigned;
    variable data         : out   std_logic_vector;
    constant msg          : in    string;
    signal i2c_if         : inout t_i2c_if;
    constant continue     : in    boolean          := false;
    constant scope        : in    string           := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in    t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT;
    constant proc_name    : in    string           := "i2c_master_receive"  -- overwrite if called from other procedure like i2c_master_check
    ) is
    variable v_byte_array : t_byte_array(0 to 0);
  begin
    i2c_master_receive(addr_value, v_byte_array, msg,
                       i2c_if.scl, i2c_if.sda, continue,
                       scope, msg_id_panel, config, proc_name);

    data := v_byte_array(0);
  end procedure;

  ---------------------------------------------------------------------------------
  -- i2c_slave_receive
  ---------------------------------------------------------------------------------
  procedure i2c_slave_receive (
    variable data         : out   t_byte_array;
    constant msg          : in    string;
    signal scl            : inout std_logic;
    signal sda            : inout std_logic;
    constant scope        : in    string           := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in    t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT;
    constant proc_name    : in    string           := "i2c_slave_receive"  -- overwrite if called from other procedure like i2c_slave_check
    ) is
    constant proc_call : string := proc_name;

    variable v_received_addr : unsigned(9 downto 0) := (others => '0');
    variable v_bfm_rx_data   : std_logic_vector(7 downto 0);

    constant C_10_BIT_ADDRESS_PATTERN    : std_logic_vector(4 downto 0) := "11110";
    constant C_FIRST_10_BIT_ADDRESS_BITS : std_logic_vector(6 downto 0) := C_10_BIT_ADDRESS_PATTERN & std_logic_vector(config.slave_mode_address(9 downto 8));

    procedure i2c_slave_receive_single_byte (
      variable byte : out std_logic_vector(7 downto 0)
      ) is
    begin
      i2c_slave_receive_single_byte(byte, msg, scl, sda, scope, msg_id_panel, config);
    end procedure;

    procedure i2c_slave_set_ack (
      constant ack : in std_logic
      ) is
    begin
      i2c_slave_set_ack(ack, msg, scl, sda, scope, msg_id_panel, config);
    end procedure;
  begin

    if not config.enable_10_bits_addressing then
      check_value(config.slave_mode_address(9 downto 7), unsigned'("000"), config.slave_mode_address_severity,
                  "Verifying that top slave address bits (9-7) are not set in 7-bit addressing mode.",
                  scope, HEX_BIN_IF_INVALID, KEEP_LEADING_0, ID_NEVER, msg_id_panel);
      i2c_check_slave_addr(config.slave_mode_address(6 downto 0), config.reserved_address_severity, scope);
    else
      i2c_check_slave_addr(config.slave_mode_address, config.reserved_address_severity, scope);
    end if;

    check_value(data'ascending, failure, "Verifying that data is of ascending type.", scope, ID_NEVER, msg_id_panel);

    await_value_X01(sda, '1', 0 ns, config.max_wait_sda_change, config.max_wait_sda_change_severity, msg, scope, ID_NEVER, msg_id_panel);
    await_value_X01(scl, '1', 0 ns, config.max_wait_scl_change, config.max_wait_scl_change_severity, msg, scope, ID_NEVER, msg_id_panel);

    if to_X01(sda) = '1' and to_X01(scl) = '1' then
      -- await the start condition
      await_value(sda, '0', 0 ns, config.max_wait_sda_change + config.max_wait_sda_change/100, config.max_wait_sda_change_severity, msg, scope, ID_NEVER, msg_id_panel);
      await_value(scl, '0', 0 ns, config.max_wait_scl_change + config.max_wait_scl_change/100, config.max_wait_scl_change_severity, msg, scope, ID_NEVER, msg_id_panel);

      if sda = '0' then
        if not config.enable_10_bits_addressing then
          -- receive the address bits
          i2c_slave_receive_single_byte(v_bfm_rx_data);

          check_value(v_bfm_rx_data(0), '0', config.slave_rw_bit_severity, msg, scope, ID_NEVER, msg_id_panel);  -- R/W bit

          -- Set ACK/NACK based on address
          -- The master shall drive scl during the acknowledge cycle
          -- A valid ack is detected when sda is '0'.
          if unsigned(v_bfm_rx_data(7 downto 1)) = config.slave_mode_address(6 downto 0) then
            -- ACK
            i2c_slave_set_ack('0');
          else
            -- NACK
            alert(config.slave_mode_address_severity, proc_call & " wrong slave address!" &
                  " Expected: " & to_string(config.slave_mode_address, BIN, KEEP_LEADING_0) &
                  ", Got: " & to_string(unsigned(v_bfm_rx_data(7 downto 1)), BIN, KEEP_LEADING_0));
            return;
          end if;
        else
          -- receive the first byte, consisting of "11110<bit 9><bit 8><write>"
          i2c_slave_receive_single_byte(v_bfm_rx_data);
          v_received_addr(9 downto 8) := unsigned(v_bfm_rx_data(2 downto 1));
          -- Check R/W bit
          check_value(v_bfm_rx_data(0), '0', config.slave_rw_bit_severity, msg & ": checking R/W bit after first address byte (10-bit addressing)", scope, ID_NEVER, msg_id_panel);

          -- Set ACK/NACK based on first received byte
          -- The master shall drive scl during the acknowledge cycle
          -- A valid ack is detected when sda is '0'.
          if v_bfm_rx_data(7 downto 1) = C_FIRST_10_BIT_ADDRESS_BITS then
            -- ACK
            i2c_slave_set_ack('0');
          else
            -- NACK
            alert(config.slave_mode_address_severity, proc_call & " first byte was other than expected!");
            return;
          end if;

          i2c_slave_receive_single_byte(v_bfm_rx_data);
          v_received_addr(7 downto 0) := unsigned(v_bfm_rx_data);

          -- Set ACK/NACK based on address
          -- The master shall drive scl during the acknowledge cycle
          -- A valid ack is detected when sda is '0'.
          if v_received_addr = config.slave_mode_address then
            -- ACK
            i2c_slave_set_ack('0');
          else
            -- NACK
            alert(config.slave_mode_address_severity, proc_call & " wrong slave address!" &
                  " Expected: " & to_string(config.slave_mode_address, BIN, KEEP_LEADING_0) &
                  ", Got: " & to_string(v_received_addr, BIN, KEEP_LEADING_0));
            return;
          end if;

        end if;

        -- receive the data bytes
        for i in 0 to data'length-1 loop
          i2c_slave_receive_single_byte(data(i));

          -- Set ACK
          -- The master shall drive scl during the acknowledge cycle
          -- A valid ack is detected when sda is '0'.
          i2c_slave_set_ack('0');
        end loop;

        -- Wait for either the stop condition or preparation for
        -- repeated start condition.
        await_value_X01(scl, '1', 0 ns, config.max_wait_scl_change + config.max_wait_scl_change/100, config.max_wait_scl_change_severity, msg, scope, ID_NEVER, msg_id_panel);
        await_value_X01(sda, '1', 0 ns, config.master_scl_to_sda + config.master_scl_to_sda/100, config.max_wait_sda_change_severity, msg, scope, ID_NEVER, msg_id_panel);
      end if;
    else
      alert(error, proc_call & " sda and scl not inactive (high) when wishing to start");
    end if;

    if proc_name = "i2c_slave_receive" then
      log(config.id_for_bfm, proc_call & "=> " & to_string(data, HEX, SKIP_LEADING_0, INCL_RADIX) & ". " & msg, scope, msg_id_panel);
    else
    -- Log will be handled by calling procedure (e.g. i2c_slave_check)
    end if;

  end procedure;

  procedure i2c_slave_receive(
    variable data         : out   t_byte_array;
    constant msg          : in    string;
    signal i2c_if         : inout t_i2c_if;
    constant scope        : in    string           := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in    t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT;
    constant proc_name    : in    string           := "i2c_slave_receive"  -- overwrite if called from other procedure like i2c_slave_check
    ) is
  begin
    i2c_slave_receive(data, msg,
                      i2c_if.scl, i2c_if.sda,
                      scope, msg_id_panel, config, proc_name);
  end procedure;

  procedure i2c_slave_receive(
    variable data         : out   std_logic_vector;
    constant msg          : in    string;
    signal i2c_if         : inout t_i2c_if;
    constant scope        : in    string           := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in    t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT;
    constant proc_name    : in    string           := "i2c_slave_receive"  -- overwrite if called from other procedure like i2c_slave_check
    ) is
    variable v_byte_array : t_byte_array(0 to 0);
  begin
    i2c_slave_receive(v_byte_array, msg,
                      i2c_if.scl, i2c_if.sda,
                      scope, msg_id_panel, config, proc_name);
    data := v_byte_array(0);
  end procedure;

  ---------------------------------------------------------------------------------
  -- i2c_master_check
  ---------------------------------------------------------------------------------
  -- Perform a read operation, then compare the read value to the data_exp.
  procedure i2c_master_check (
    constant addr_value   : in    unsigned;
    constant data_exp     : in    t_byte_array;
    constant alert_level  : in    t_alert_level    := error;
    constant msg          : in    string;
    signal scl            : inout std_logic;
    signal sda            : inout std_logic;
    constant continue     : in    boolean          := false;
    constant scope        : in    string           := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in    t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT
    ) is
    constant proc_name : string := "i2c_master_check";
    constant proc_call : string := proc_name & "(A:" & to_string(addr_value, HEX, AS_IS, INCL_RADIX) &
                                   ", " & to_string(data_exp, HEX, AS_IS, INCL_RADIX) & ")";
    -- Helper variables
    variable v_data_array : t_byte_array(data_exp'range);
    variable v_check_ok   : boolean := true;
    variable v_byte_ok    : boolean;
  begin
    i2c_master_receive(addr_value, v_data_array, msg, scl, sda, continue, scope, msg_id_panel, config, proc_name);

    -- Compare values, but ignore any leading zero's if widths are different.
    -- Use ID_NEVER so that check_value method does not log when check is OK,
    -- log it here instead.
    for i in data_exp'range loop
      v_byte_ok := check_value(v_data_array(i), data_exp(i), alert_level, msg, scope, HEX_BIN_IF_INVALID, SKIP_LEADING_0, ID_NEVER, msg_id_panel, proc_call);

      if not v_byte_ok then
        v_check_ok := false;
      end if;
    end loop;

    if v_check_ok then
      log(config.id_for_bfm, proc_call & "=> OK, read data = " & to_string(v_data_array, HEX, SKIP_LEADING_0, INCL_RADIX) & ". " & msg, scope, msg_id_panel);
    end if;
  end procedure;

  procedure i2c_master_check (
    constant addr_value   : in    unsigned;
    constant data_exp     : in    t_byte_array;
    constant alert_level  : in    t_alert_level    := error;
    constant msg          : in    string;
    signal i2c_if         : inout t_i2c_if;
    constant continue     : in    boolean          := false;
    constant scope        : in    string           := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in    t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT
    ) is
  begin
    i2c_master_check(addr_value, data_exp, alert_level, msg,
                     i2c_if.scl, i2c_if.sda, continue,
                     scope, msg_id_panel, config);
  end procedure;

  procedure i2c_master_check (
    constant addr_value   : in    unsigned;
    constant data_exp     : in    std_logic_vector;
    constant alert_level  : in    t_alert_level    := error;
    constant msg          : in    string;
    signal i2c_if         : inout t_i2c_if;
    constant continue     : in    boolean          := false;
    constant scope        : in    string           := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in    t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT
    ) is

    variable v_bfm_rx_data : std_logic_vector(7 downto 0) := (others => '0');

    -- Normalize to the 8 bit data width
    variable v_normalized_data_exp : std_logic_vector(7 downto 0) :=
      normalize_and_check(data_exp, v_bfm_rx_data, ALLOW_NARROWER, "data", "v_bfm_rx_data", msg);

    variable v_byte_array : t_byte_array(0 to 0) := (0 => v_normalized_data_exp);
  begin
    i2c_master_check(addr_value, v_byte_array, alert_level, msg,
                     i2c_if.scl, i2c_if.sda, continue,
                     scope, msg_id_panel, config);
  end procedure;

  ---------------------------------------------------------------------------------
  -- i2c_slave_check
  ---------------------------------------------------------------------------------
  -- Perform a read operation, then compare the read value to the data_exp.
  procedure i2c_slave_check (
    constant data_exp     : in    t_byte_array;
    constant alert_level  : in    t_alert_level    := error;
    constant msg          : in    string;
    signal scl            : inout std_logic;
    signal sda            : inout std_logic;
    constant scope        : in    string           := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in    t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT
    ) is
    constant proc_name : string := "i2c_slave_check";
    constant proc_call : string := proc_name & "(" & to_string(data_exp, HEX, AS_IS, INCL_RADIX) & ")";

    -- Helper variables
    variable v_data_array : t_byte_array(data_exp'range);
    variable v_check_ok   : boolean := true;
    variable v_byte_ok    : boolean;
  begin
    i2c_slave_receive(v_data_array, msg, scl, sda, scope, msg_id_panel, config, proc_name);

    -- Compare values, but ignore any leading zero's if widths are different.
    -- Use ID_NEVER so that check_value method does not log when check is OK,
    -- log it here instead.
    for i in data_exp'range loop
      v_byte_ok := check_value(v_data_array(i), data_exp(i), alert_level, msg, scope, HEX_BIN_IF_INVALID, SKIP_LEADING_0, ID_NEVER, msg_id_panel, proc_call);

      if not v_byte_ok then
        v_check_ok := false;
      end if;
    end loop;

    if v_check_ok then
      log(config.id_for_bfm, proc_call & "=> OK, read data = " & to_string(v_data_array, HEX, SKIP_LEADING_0, INCL_RADIX) & ". " & msg, scope, msg_id_panel);
    end if;
  end procedure;

  procedure i2c_slave_check (
    constant data_exp     : in    t_byte_array;
    constant alert_level  : in    t_alert_level    := error;
    constant msg          : in    string;
    signal i2c_if         : inout t_i2c_if;
    constant scope        : in    string           := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in    t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT
    ) is
  begin
    i2c_slave_check(data_exp, alert_level, msg,
                    i2c_if.scl, i2c_if.sda,
                    scope, msg_id_panel, config);
  end procedure;

  procedure i2c_slave_check (
    constant data_exp     : in    std_logic_vector;
    constant alert_level  : in    t_alert_level    := error;
    constant msg          : in    string;
    signal i2c_if         : inout t_i2c_if;
    constant scope        : in    string           := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in    t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT
    ) is

    variable v_bfm_rx_data : std_logic_vector(7 downto 0) := (others => '0');

    -- Normalize to the 8 bit data width
    variable v_normalized_data_exp : std_logic_vector(7 downto 0) :=
      normalize_and_check(data_exp, v_bfm_rx_data, ALLOW_NARROWER, "data", "v_bfm_rx_data", msg);

    variable v_byte_array : t_byte_array(0 to 0) := (0 => v_normalized_data_exp);
  begin
    i2c_slave_check(v_byte_array, alert_level, msg,
                    i2c_if.scl, i2c_if.sda,
                    scope, msg_id_panel, config);
  end procedure;
end package body i2c_bfm_pkg;
