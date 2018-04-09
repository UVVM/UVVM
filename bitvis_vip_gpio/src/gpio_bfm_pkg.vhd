--========================================================================================================================
-- Copyright (c) 2017 by Bitvis AS.  All rights reserved.
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
  constant C_SCOPE : string := "GPIO BFM";

  -- Configuration record to be assigned in the test harness.
  type t_gpio_bfm_config is
  record
    clock_period     : time;
    match_strictness : t_match_strictness;
    id_for_bfm       : t_msg_id;  -- The message ID used as a general message ID in the GPIO BFM
    id_for_bfm_wait  : t_msg_id;  -- The message ID used for logging waits in the GPIO BFM.
    id_for_bfm_poll  : t_msg_id;  -- The message ID used for logging polling in the GPIO BFM
  end record;

  -- Define the default value for the BFM config
  constant C_GPIO_BFM_CONFIG_DEFAULT : t_gpio_bfm_config := (
    clock_period     => 10 ns,
    match_strictness => MATCH_STD,
    id_for_bfm       => ID_BFM,
    id_for_bfm_wait  => ID_BFM_WAIT,
    id_for_bfm_poll  => ID_BFM_POLL
    );


  --=========================================================================================
  -- BFM procedures
  --=========================================================================================

  ---------------------------------------------------------------------------------
  -- set data
  ---------------------------------------------------------------------------------
  procedure gpio_set (
    constant data_value   : in    std_logic_vector;  -- '-' means don't change
    constant msg          : in    string;
    signal data_port      : inout std_logic_vector;
    constant scope        : in    string         := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel := shared_msg_id_panel
    );

  ---------------------------------------------------------------------------------
  -- get data()
  ---------------------------------------------------------------------------------
  procedure gpio_get (
    variable data_value   : out std_logic_vector;
    constant msg          : in  string;
    signal data_port      : in  std_logic_vector;
    constant scope        : in  string         := C_SCOPE;
    constant msg_id_panel : in  t_msg_id_panel := shared_msg_id_panel
    );

  ---------------------------------------------------------------------------------
  -- check data()
  ---------------------------------------------------------------------------------
  -- Perform a read operation, then compare the read value to the expected value.
  procedure gpio_check (
    constant data_exp     : in std_logic_vector;  -- '-' means don't care
    constant msg          : in string;
    signal data_port      : in std_logic_vector;
    constant alert_level  : in t_alert_level     := error;
    constant scope        : in string            := C_SCOPE;
    constant msg_id_panel : in t_msg_id_panel    := shared_msg_id_panel;
    constant config       : in t_gpio_bfm_config := C_GPIO_BFM_CONFIG_DEFAULT
    );

  ---------------------------------------------------------------------------------
  -- expect data()
  ---------------------------------------------------------------------------------
  -- Perform a read operation, then compare the read value to the expected value.
  procedure gpio_expect (
    constant data_exp     : in std_logic_vector;
    constant msg          : in string;
    signal data_port      : in std_logic_vector;
    constant timeout      : in time              := 0 ns;  -- 0 = no timeout
    constant alert_level  : in t_alert_level     := error;
    constant scope        : in string            := C_SCOPE;
    constant msg_id_panel : in t_msg_id_panel    := shared_msg_id_panel;
    constant config       : in t_gpio_bfm_config := C_GPIO_BFM_CONFIG_DEFAULT
    );

end package gpio_bfm_pkg;


--=================================================================================
--=================================================================================

package body gpio_bfm_pkg is

  ---------------------------------------------------------------------------------
  -- set data
  ---------------------------------------------------------------------------------
  procedure gpio_set (
    constant data_value   : in    std_logic_vector;  -- '-' means don't change
    constant msg          : in    string;
    signal data_port      : inout std_logic_vector;
    constant scope        : in    string         := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel := shared_msg_id_panel
    ) is
    constant name : string := "gpio_set(" & to_string(data_value) & ")";
  begin
    for i in data_port'range loop
      if data_value(i) /= '-' then
        data_port(i) <= data_value(i);
      end if;
    end loop;
    log(ID_BFM, name & " completed. " & add_msg_delimiter(msg), scope, msg_id_panel);
  end procedure;


  ---------------------------------------------------------------------------------
  -- get data()
  ---------------------------------------------------------------------------------
  -- Perform a read operation and returns the gpio value
  procedure gpio_get (
    variable data_value   : out std_logic_vector;
    constant msg          : in  string;
    signal data_port      : in  std_logic_vector;
    constant scope        : in  string         := C_SCOPE;
    constant msg_id_panel : in  t_msg_id_panel := shared_msg_id_panel
    ) is
    constant name : string := "gpio_get()";
  begin
    log(ID_BFM, name & " => Read gpio value: " & to_string(data_port, HEX_BIN_IF_INVALID, AS_IS, INCL_RADIX) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
    data_value := data_port;
  end procedure;


  ---------------------------------------------------------------------------------
  -- check data()
  ---------------------------------------------------------------------------------
  -- Perform a read operation, then compare the read value to the expected value.
  procedure gpio_check (
    constant data_exp     : in std_logic_vector;  -- '-' means don't care
    constant msg          : in string;
    signal data_port      : in std_logic_vector;
    constant alert_level  : in t_alert_level     := error;
    constant scope        : in string            := C_SCOPE;
    constant msg_id_panel : in t_msg_id_panel    := shared_msg_id_panel;
    constant config       : in t_gpio_bfm_config := C_GPIO_BFM_CONFIG_DEFAULT
    ) is
    constant name       : string := "gpio_check(" & to_string(data_exp, HEX, AS_IS, INCL_RADIX) & ")";
    variable v_check_ok : boolean;
  begin
    v_check_ok := check_value(data_port, data_exp, config.match_strictness, alert_level, msg, scope, HEX_BIN_IF_INVALID, SKIP_LEADING_0, ID_NEVER, msg_id_panel, name);

    if v_check_ok then
      log(ID_BFM, name & "=> OK, read data = " & to_string(data_port, HEX_BIN_IF_INVALID, AS_IS, INCL_RADIX) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
    end if;
  end procedure;

  ---------------------------------------------------------------------------------
  -- expect()
  ---------------------------------------------------------------------------------
  -- Perform a receive operation, then compare the received value to the expected value.
  procedure gpio_expect (
    constant data_exp     : in std_logic_vector;
    constant msg          : in string;
    signal data_port      : in std_logic_vector;
    constant timeout      : in time              := 0 ns;  -- 0 = no timeout
    constant alert_level  : in t_alert_level     := error;
    constant scope        : in string            := C_SCOPE;
    constant msg_id_panel : in t_msg_id_panel    := shared_msg_id_panel;
    constant config       : in t_gpio_bfm_config := C_GPIO_BFM_CONFIG_DEFAULT
    ) is
    constant name : string := "gpio_expect(" & to_string(data_exp, HEX, AS_IS, INCL_RADIX) & ")";
  begin
    log(ID_BFM, name & "=> Expecting value " & to_string(data_exp, HEX_BIN_IF_INVALID, AS_IS, INCL_RADIX) & "." & add_msg_delimiter(msg), scope, msg_id_panel);
    await_value(data_port, data_exp, config.match_strictness, 0 ns, timeout, alert_level, msg, scope, HEX_BIN_IF_INVALID, SKIP_LEADING_0, ID_BFM, msg_id_panel);
  end procedure;

end package body gpio_bfm_pkg;

