--========================================================================================================================
-- Copyright (c) 2018 by Bitvis AS.  All rights reserved.
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

library uvvm_util;
context uvvm_util.uvvm_util_context;

--========================================================================================================================
--========================================================================================================================
package gmii_bfm_pkg is

  --========================================================================================================================
  -- Types and constants for GMII BFM
  --========================================================================================================================
  constant C_SCOPE : string := "GMII BFM";

  -- GMII Interface signals
  type t_gmii_to_dut_if is record
    rxclk : std_logic;
    rxdv  : std_logic;
    rxd   : std_logic_vector(7 downto 0);
  end record t_gmii_to_dut_if;

  type t_gmii_from_dut_if is record
    gtxclk : std_logic;
    txen   : std_logic;
    txd    : std_logic_vector(7 downto 0);
  end record t_gmii_from_dut_if;

  type t_gmii_if is record
    gmii_to_dut_if   : t_gmii_to_dut_if;
    gmii_from_dut_if : t_gmii_from_dut_if;
  end record t_gmii_if;

  constant C_GMII_TO_DUT_PASSIVE : t_gmii_to_dut_if := (
    rxclk => 'Z',
    rxdv  => '0',
    rxd   => (others => '0')
  );

  -- Configuration record to be assigned in the test harness.
  type t_gmii_bfm_config is record
    clock_period                : time;           -- Period of the clock signal
    clock_period_margin         : time;           -- Input clock period margin to specified clock_period.
                                                  -- Checking low period of input clock if BFM is called while CLK is high.
                                                  -- Checking clock_period of input clock if BFM is called while CLK is low.
    clock_margin_severity       : t_alert_level;  -- The above margin will have this severity
    setup_time                  : time;           -- Generated signals setup time, set to clock_period/4
    hold_time                   : time;           -- Generated signals hold time, set to clock_period/4
    timeout                     : time;           -- The maximum time allowed to wait for DUT.
    timeout_severity            : t_alert_level;  -- Severity of alert when timeout.
    id_for_bfm                  : t_msg_id;       -- The message ID used as a general message ID in the SBI BFM
    id_for_bfm_wait             : t_msg_id;       -- The message ID used for logging waits in the SBI BFM
  end record;

  constant C_GMII_BFM_CONFIG_DEFAULT : t_gmii_bfm_config := (
    clock_period                => 8 ns,
    clock_period_margin         => 0 ns,
    clock_margin_severity       => TB_ERROR,
    setup_time                  => 2 ns,
    hold_time                   => 2 ns,
    timeout                     => 1 us,
    timeout_severity            => TB_ERROR,
    id_for_bfm                  => ID_BFM,
    id_for_bfm_wait             => ID_BFM_WAIT
    );



  --========================================================================================================================
  -- BFM procedures
  --========================================================================================================================


  function init_gmii_to_dut_if
  return t_gmii_to_dut_if;

  function init_gmii_from_dut_if
  return t_gmii_from_dut_if;

  impure function init_gmii_if
  return t_gmii_if;

  ------------------------------------------
  -- gmii_write
  ------------------------------------------
  -- This procedure writes data to the DUT
  -- from the PHY layer point of view

  procedure gmii_write(
    constant data           :    in t_byte_array;
    constant msg            :    in string;
    signal   gmii_to_dut_if : inout t_gmii_to_dut_if;
    constant scope          :    in string            := C_SCOPE;
    constant msg_id_panel   :    in t_msg_id_panel    := shared_msg_id_panel;
    constant config         :    in t_gmii_bfm_config := C_GMII_BFM_CONFIG_DEFAULT
  );


  ------------------------------------------
  -- gmii_read
  ------------------------------------------
  -- This procedure reads data from the DUT
  -- from the PHY layer point of view

  procedure gmii_read(
    variable data             : out t_byte_array;
    constant msg              :  in string;
    signal   gmii_from_dut_if :  in t_gmii_from_dut_if;
    constant scope            :  in string            := C_SCOPE;
    constant msg_id_panel     :  in t_msg_id_panel    := shared_msg_id_panel;
    constant config           :  in t_gmii_bfm_config := C_GMII_BFM_CONFIG_DEFAULT
  );


end package gmii_bfm_pkg;


--========================================================================================================================
--========================================================================================================================

package body gmii_bfm_pkg is


  function init_gmii_to_dut_if
  return t_gmii_to_dut_if is
    variable v_gmii_to_dut_if : t_gmii_to_dut_if;
  begin
    v_gmii_to_dut_if.rxclk := 'Z';
    v_gmii_to_dut_if.rxdv  := '0';
    v_gmii_to_dut_if.rxd   := (others => '0');
    return v_gmii_to_dut_if;
  end function init_gmii_to_dut_if;

  function init_gmii_from_dut_if
  return t_gmii_from_dut_if is
    variable v_gmii_from_dut_if : t_gmii_from_dut_if;
  begin
    v_gmii_from_dut_if.gtxclk := 'Z';
    v_gmii_from_dut_if.txen   := 'Z';
    v_gmii_from_dut_if.txd    := (others => 'Z');
    return v_gmii_from_dut_if;
  end function init_gmii_from_dut_if;

  impure function init_gmii_if
  return t_gmii_if is
    variable v_gmii_if : t_gmii_if;
  begin
    v_gmii_if.gmii_to_dut_if   := init_gmii_to_dut_if;
    v_gmii_if.gmii_from_dut_if := init_gmii_from_dut_if;
    return v_gmii_if;
  end function init_gmii_if;

  procedure santity_check(
    constant config       : in t_gmii_bfm_config;
    constant scope        : in string;
    constant msg_id_panel : in t_msg_id_panel;
    constant proc_call    : in string
  ) is
  begin
    -- setup_time and hold_time checking
    check_value(config.setup_time < config.clock_period/2, TB_FAILURE, "Sanity check: Check that setup_time do not exceed clock_period/2.", scope, ID_NEVER, msg_id_panel, proc_call);
    check_value(config.hold_time < config.clock_period/2, TB_FAILURE, "Sanity check: Check that hold_time do not exceed clock_period/2.", scope, ID_NEVER, msg_id_panel, proc_call);
    check_value(config.setup_time > 0 ns, TB_FAILURE, "Sanity check: Check that setup_time is more than 0 ns.", scope, ID_NEVER, msg_id_panel, proc_call);
    check_value(config.hold_time > 0 ns, TB_FAILURE, "Sanity check: Check that hold_time is more than 0 ns.", scope, ID_NEVER, msg_id_panel, proc_call);
  end procedure santity_check;


  ------------------------------------------
  -- gmii_write
  ------------------------------------------
  procedure gmii_write(
    constant data           :    in t_byte_array;
    constant msg            :    in string;
    signal   gmii_to_dut_if : inout t_gmii_to_dut_if;
    constant scope          :    in string            := C_SCOPE;
    constant msg_id_panel   :    in t_msg_id_panel    := shared_msg_id_panel;
    constant config         :    in t_gmii_bfm_config := C_GMII_BFM_CONFIG_DEFAULT
  ) is
    constant proc_name : string := "gmii_write";
    constant proc_call : string := proc_name;
  begin
    -- Sanity check
    santity_check(config, scope, msg_id_panel, proc_call);

    gmii_to_dut_if <= C_GMII_TO_DUT_PASSIVE;

    for i in data'range loop
      wait_until_given_time_before_rising_edge(gmii_to_dut_if.rxclk, config.setup_time, config.clock_period);
      gmii_to_dut_if.rxd  <= data(i);
      gmii_to_dut_if.rxdv <= '1';
      wait_until_given_time_after_rising_edge(gmii_to_dut_if.rxclk, config.hold_time);
    end loop;

    gmii_to_dut_if.rxdv <= '0';

    log(config.id_for_bfm, proc_call & " completed. " & add_msg_delimiter(msg), scope, msg_id_panel);

  end procedure gmii_write;


  ------------------------------------------
  -- gmii_read
  ------------------------------------------
  procedure gmii_read(
    variable data             : out t_byte_array;
    constant msg              :  in string;
    signal   gmii_from_dut_if :  in t_gmii_from_dut_if;
    constant scope            :  in string            := C_SCOPE;
    constant msg_id_panel     :  in t_msg_id_panel    := shared_msg_id_panel;
    constant config           :  in t_gmii_bfm_config := C_GMII_BFM_CONFIG_DEFAULT
  ) is
    constant proc_name    : string := "gmii_read";
    constant proc_call    : string := proc_name;
    variable v_time_stamp : time   := now;
  begin
    -- Sanity check
    santity_check(config, scope, msg_id_panel, proc_call);

    for i in 0 to data'length-1 loop
      wait until rising_edge(gmii_from_dut_if.gtxclk) for config.timeout;
      -- Wait on data enable signal
      while gmii_from_dut_if.txen /= '1' loop
        if now-v_time_stamp < config.timeout then
          wait until rising_edge(gmii_from_dut_if.gtxclk) for v_time_stamp + config.timeout - now;
        end if;
        if now-v_time_stamp >= config.timeout then
          alert(config.timeout_severity, proc_call & ": timeout while waiting for DUT.");
        end if;
      end loop;
      v_time_stamp := now;
      data(i) := gmii_from_dut_if.txd;
    end loop;

    log(config.id_for_bfm, proc_call & " completed. " & add_msg_delimiter(msg), scope, msg_id_panel);

  end procedure gmii_read;

end package body gmii_bfm_pkg;

