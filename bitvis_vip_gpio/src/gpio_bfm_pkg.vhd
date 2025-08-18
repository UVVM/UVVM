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

library std;
use std.textio.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

--===========================================================================================
package gpio_bfm_pkg is

  --=========================================================================================
  -- Types and constants for GPIO BFM
  --=========================================================================================
  constant C_BFM_SCOPE : string := "GPIO BFM";

  -- Configuration record to be assigned in the test harness.
  type t_gpio_bfm_config is record
    clock_period     : time;
    match_strictness : t_match_strictness; -- Matching strictness for std_logic values in check procedures.
    id_for_bfm       : t_msg_id;        -- The message ID used as a general message ID in the GPIO BFM
    id_for_bfm_wait  : t_msg_id;        -- The message ID used for logging waits in the GPIO BFM. -- DEPRECATE: will be removed
    timeout          : time;            -- Timeout value for the expect procedures
  end record;

  -- Define the default value for the BFM config
  constant C_GPIO_BFM_CONFIG_DEFAULT : t_gpio_bfm_config := (
    clock_period     => -1 ns,
    match_strictness => MATCH_STD,
    id_for_bfm       => ID_BFM,
    id_for_bfm_wait  => ID_BFM_WAIT,
    timeout          => -1 ns
  );

  --=========================================================================================
  -- BFM procedures
  --=========================================================================================

  ---------------------------------------------------------------------------------
  -- set data
  ---------------------------------------------------------------------------------
  procedure gpio_set(
    constant data_value   : in std_logic_vector; -- '-' means don't change
    constant msg          : in string;
    signal   data_port    : inout std_logic_vector;
    constant scope        : in string            := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel    := shared_msg_id_panel;
    constant config       : in t_gpio_bfm_config := C_GPIO_BFM_CONFIG_DEFAULT
  );

  ---------------------------------------------------------------------------------
  -- get data()
  ---------------------------------------------------------------------------------
  procedure gpio_get(
    variable data_value   : out std_logic_vector;
    constant msg          : in string;
    signal   data_port    : in std_logic_vector;
    constant scope        : in string            := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel    := shared_msg_id_panel;
    constant config       : in t_gpio_bfm_config := C_GPIO_BFM_CONFIG_DEFAULT
  );

  ---------------------------------------------------------------------------------
  -- check data()
  ---------------------------------------------------------------------------------
  -- Perform a read operation, then compare the read value to the expected value.
  procedure gpio_check(
    constant data_exp     : in std_logic_vector; -- '-' means don't care
    constant msg          : in string;
    signal   data_port    : in std_logic_vector;
    constant alert_level  : in t_alert_level     := error;
    constant scope        : in string            := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel    := shared_msg_id_panel;
    constant config       : in t_gpio_bfm_config := C_GPIO_BFM_CONFIG_DEFAULT
  );

  -- Perform a read operation, then compare the read value to the expected value.
  -- Verify that the read value has been stable for a certain time.
  procedure gpio_check_stable(
    constant data_exp     : in std_logic_vector;
    constant stable_req   : in time;
    constant msg          : in string;
    signal   data_port    : in std_logic_vector;
    constant alert_level  : in t_alert_level     := error;
    constant scope        : in string            := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel    := shared_msg_id_panel;
    constant config       : in t_gpio_bfm_config := C_GPIO_BFM_CONFIG_DEFAULT
  );

  ---------------------------------------------------------------------------------
  -- expect data()
  ---------------------------------------------------------------------------------
  -- Perform a read operation, then compare the read value to the expected value.
  procedure gpio_expect(
    constant data_exp     : in std_logic_vector;
    constant msg          : in string;
    signal   data_port    : in std_logic_vector;
    constant timeout      : in time              := -1 ns; -- -1 = no timeout
    constant alert_level  : in t_alert_level     := error;
    constant scope        : in string            := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel    := shared_msg_id_panel;
    constant config       : in t_gpio_bfm_config := C_GPIO_BFM_CONFIG_DEFAULT
  );

  -- Perform a read operation, then compare the read value to the expected value.
  -- Verify that the read value remains stable for a certain time after the data
  -- is same as expected or after the data last event.
  procedure gpio_expect_stable(
    constant data_exp        : in std_logic_vector;
    constant stable_req      : in time;
    constant stable_req_from : in t_from_point_in_time; -- Which point in time stable_req starts
    constant msg             : in string;
    signal   data_port       : in std_logic_vector;
    constant timeout         : in time              := -1 ns; -- -1 = no timeout
    constant alert_level     : in t_alert_level     := error;
    constant scope           : in string            := C_BFM_SCOPE;
    constant msg_id_panel    : in t_msg_id_panel    := shared_msg_id_panel;
    constant config          : in t_gpio_bfm_config := C_GPIO_BFM_CONFIG_DEFAULT
  );

end package gpio_bfm_pkg;

--=================================================================================
--=================================================================================

package body gpio_bfm_pkg is

  ---------------------------------------------------------------------------------
  -- set data
  ---------------------------------------------------------------------------------
  procedure gpio_set(
    constant data_value   : in std_logic_vector; -- '-' means don't change
    constant msg          : in string;
    signal   data_port    : inout std_logic_vector;
    constant scope        : in string            := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel    := shared_msg_id_panel;
    constant config       : in t_gpio_bfm_config := C_GPIO_BFM_CONFIG_DEFAULT
  ) is
    constant name         : string                            := "gpio_set(" & to_string(data_value) & ")";
    constant c_data_value : std_logic_vector(data_port'range) := data_value;
  begin

    for i in 0 to data_port'length - 1 loop --data_port'range loop
      if c_data_value(i) /= '-' then
        data_port(i) <= c_data_value(i);
      end if;
    end loop;
    log(config.id_for_bfm, name & " completed. " & add_msg_delimiter(msg), scope, msg_id_panel);
  end procedure;

  ---------------------------------------------------------------------------------
  -- get data()
  ---------------------------------------------------------------------------------
  -- Perform a read operation and returns the gpio value
  procedure gpio_get(
    variable data_value   : out std_logic_vector;
    constant msg          : in string;
    signal   data_port    : in std_logic_vector;
    constant scope        : in string            := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel    := shared_msg_id_panel;
    constant config       : in t_gpio_bfm_config := C_GPIO_BFM_CONFIG_DEFAULT
  ) is
    constant name : string := "gpio_get()";
  begin
    log(config.id_for_bfm, name & " => Read gpio value: " & to_string(data_port, HEX_BIN_IF_INVALID, AS_IS, INCL_RADIX) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
    data_value := data_port;
  end procedure;

  ---------------------------------------------------------------------------------
  -- check data()
  ---------------------------------------------------------------------------------
  -- Perform a read operation, then compare the read value to the expected value.
  procedure gpio_check(
    constant data_exp     : in std_logic_vector; -- '-' means don't care
    constant msg          : in string;
    signal   data_port    : in std_logic_vector;
    constant alert_level  : in t_alert_level     := error;
    constant scope        : in string            := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel    := shared_msg_id_panel;
    constant config       : in t_gpio_bfm_config := C_GPIO_BFM_CONFIG_DEFAULT
  ) is
    constant name          : string                            := "gpio_check(" & to_string(data_exp, HEX, AS_IS, INCL_RADIX) & ")";
    constant c_data_exp    : std_logic_vector(data_port'range) := data_exp;
    variable v_check_ok    : boolean                           := true;
    variable v_alert_radix : t_radix;
  begin
    for i in c_data_exp'range loop
      -- Allow don't care in expected value and use match strictness from config for comparison
      if c_data_exp(i) = '-' or check_value(data_port(i), c_data_exp(i), config.match_strictness, NO_ALERT, msg, scope, ID_NEVER) then
        v_check_ok := true;
      else
        v_check_ok := false;
        exit;
      end if;
    end loop;

    if not v_check_ok then
      -- Use binary representation when mismatch is due to weak signals
      v_alert_radix := BIN when config.match_strictness = MATCH_EXACT and check_value(data_port, c_data_exp, MATCH_STD, NO_ALERT, msg, scope, HEX_BIN_IF_INVALID, KEEP_LEADING_0, ID_NEVER) else HEX;
      alert(alert_level, name & "=> Failed. Was " & to_string(data_port, v_alert_radix, AS_IS, INCL_RADIX) & ". Expected " & to_string(c_data_exp, v_alert_radix, AS_IS, INCL_RADIX) & "." & LF & add_msg_delimiter(msg), scope);
    else
      log(config.id_for_bfm, name & "=> OK, read data = " & to_string(data_port, HEX_BIN_IF_INVALID, AS_IS, INCL_RADIX) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
    end if;
  end procedure;

  procedure gpio_check_stable(
    constant data_exp     : in std_logic_vector;
    constant stable_req   : in time;
    constant msg          : in string;
    signal   data_port    : in std_logic_vector;
    constant alert_level  : in t_alert_level     := error;
    constant scope        : in string            := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel    := shared_msg_id_panel;
    constant config       : in t_gpio_bfm_config := C_GPIO_BFM_CONFIG_DEFAULT
  ) is
    constant name          : string                            := "gpio_check_stable(" & to_string(data_exp, HEX, AS_IS, INCL_RADIX) & ", " & to_string(stable_req) & ")";
    constant c_data_exp    : std_logic_vector(data_port'range) := data_exp;
    variable v_data_ok     : boolean                           := true;
    variable v_stable_ok   : boolean                           := true;
    variable v_alert_radix : t_radix;
  begin
    for i in c_data_exp'range loop
      -- Use match strictness from config for comparison
      if check_value(data_port(i), c_data_exp(i), config.match_strictness, NO_ALERT, msg, scope, ID_NEVER) then
        v_data_ok := true;
      else
        v_data_ok := false;
        exit;
      end if;
    end loop;

    check_stable(data_port, stable_req, alert_level, v_stable_ok, msg, scope, ID_NEVER, msg_id_panel, name);

    if not v_data_ok then
      -- Use binary representation when mismatch is due to weak signals
      v_alert_radix := BIN when config.match_strictness = MATCH_EXACT and check_value(data_port, c_data_exp, MATCH_STD, NO_ALERT, msg, scope, HEX_BIN_IF_INVALID, KEEP_LEADING_0, ID_NEVER) else HEX;
      alert(alert_level, name & "=> Failed. Was " & to_string(data_port, v_alert_radix, AS_IS, INCL_RADIX) & ". Expected " & to_string(c_data_exp, v_alert_radix, AS_IS, INCL_RADIX) & "." & LF & add_msg_delimiter(msg), scope);
    elsif v_stable_ok then
      log(config.id_for_bfm, name & "=> OK, read data = " & to_string(data_port, HEX_BIN_IF_INVALID, AS_IS, INCL_RADIX) & ", stable for " & to_string(stable_req) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
    end if;
  end procedure;

  ---------------------------------------------------------------------------------
  -- expect()
  ---------------------------------------------------------------------------------
  -- Perform a receive operation, then compare the received value to the expected value.
  procedure gpio_expect(
    constant data_exp     : in std_logic_vector;
    constant msg          : in string;
    signal   data_port    : in std_logic_vector;
    constant timeout      : in time              := -1 ns; -- -1 = no timeout
    constant alert_level  : in t_alert_level     := error;
    constant scope        : in string            := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel    := shared_msg_id_panel;
    constant config       : in t_gpio_bfm_config := C_GPIO_BFM_CONFIG_DEFAULT
  ) is
    constant name               : string                            := "gpio_expect(" & to_string(data_exp, HEX, AS_IS, INCL_RADIX) & ")";
    constant c_data_exp         : std_logic_vector(data_port'range) := data_exp;
    variable v_internal_timeout : time;
    variable v_timestamp        : time                              := now;
    variable v_time_lapse       : time;
    variable v_data_ok          : boolean                           := true;
  begin
    if timeout = -1 ns then             -- function was called without parameter
      v_internal_timeout := config.timeout;
    else
      v_internal_timeout := timeout;
    end if;
    check_value(v_internal_timeout >= 0 ns, TB_FAILURE, "Configured negative timeout (not allowed). " & add_msg_delimiter(msg), scope, ID_NEVER, msg_id_panel);

    await_value(data_port, c_data_exp, config.match_strictness, 0 ns, v_internal_timeout, alert_level, v_data_ok, msg, scope, HEX_BIN_IF_INVALID, SKIP_LEADING_0, ID_NEVER, msg_id_panel, name);
    v_time_lapse := now - v_timestamp;

    if v_data_ok then
      log(config.id_for_bfm, name & "=> OK, expected data = " & to_string(data_port, HEX_BIN_IF_INVALID, AS_IS, INCL_RADIX) & " after " & to_string(v_time_lapse) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
    end if;
  end procedure;

  procedure gpio_expect_stable(
    constant data_exp        : in std_logic_vector;
    constant stable_req      : in time;
    constant stable_req_from : in t_from_point_in_time; -- Which point in time stable_req starts
    constant msg             : in string;
    signal   data_port       : in std_logic_vector;
    constant timeout         : in time              := -1 ns; -- -1 = no timeout
    constant alert_level     : in t_alert_level     := error;
    constant scope           : in string            := C_BFM_SCOPE;
    constant msg_id_panel    : in t_msg_id_panel    := shared_msg_id_panel;
    constant config          : in t_gpio_bfm_config := C_GPIO_BFM_CONFIG_DEFAULT
  ) is
    constant name               : string                            := "gpio_expect_stable(" & to_string(data_exp, HEX, AS_IS, INCL_RADIX) & ", " & to_string(stable_req) & ")";
    constant c_data_exp         : std_logic_vector(data_port'range) := data_exp;
    variable v_internal_timeout : time;
    variable v_timestamp        : time                              := now;
    variable v_time_lapse       : time;
    variable v_data_ok          : boolean                           := true;
    variable v_stable_ok        : boolean                           := true;
  begin
    if timeout = -1 ns then             -- function was called without parameter
      v_internal_timeout := config.timeout;
    else
      v_internal_timeout := timeout;
    end if;
    check_value(v_internal_timeout >= 0 ns, TB_FAILURE, "Configured negative timeout (not allowed). " & add_msg_delimiter(msg), scope, ID_NEVER, msg_id_panel);

    await_value(data_port, c_data_exp, config.match_strictness, 0 ns, v_internal_timeout, alert_level, v_data_ok, msg, scope, HEX_BIN_IF_INVALID, SKIP_LEADING_0, ID_NEVER, msg_id_panel, name);
    v_time_lapse := now - v_timestamp;

    -- The data port already had the expected value
    if v_timestamp = now then
      await_stable(data_port, stable_req, stable_req_from, stable_req, stable_req_from, alert_level, v_stable_ok, msg, scope, ID_NEVER, msg_id_panel, name);
    -- The data port received the expected value after some time
    else
      await_stable(data_port, stable_req, FROM_NOW, stable_req, FROM_NOW, alert_level, v_stable_ok, msg, scope, ID_NEVER, msg_id_panel, name);
    end if;

    if v_data_ok and v_stable_ok then
      log(config.id_for_bfm, name & "=> OK, expected data = " & to_string(data_port, HEX_BIN_IF_INVALID, AS_IS, INCL_RADIX) & " after " & to_string(v_time_lapse) & ", stable for " & to_string(stable_req) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
    end if;
  end procedure;

end package body gpio_bfm_pkg;
