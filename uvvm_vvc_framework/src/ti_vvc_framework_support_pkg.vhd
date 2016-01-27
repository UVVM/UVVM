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
------------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

package ti_vvc_framework_support_pkg is

  ------------------------------------------------------------------------
  -- Common support types for UVVM
  ------------------------------------------------------------------------
  type t_immediate_or_queued is (NO_command_type, IMMEDIATE, QUEUED);

  type t_flag_record is record
    set        : std_logic;
    reset      : std_logic;
    is_active  : std_logic;
  end record;
  
  type t_uvvm_state is (IDLE, PHASE_A, PHASE_B, INIT_COMPLETED);

  
  ------------------------------------------------------------------------
  -- Common signals for acknowledging a pending command
  ------------------------------------------------------------------------
  signal global_vvc_ack : std_logic;    -- ACK on global triggers
  signal VVC_BROADCAST  : std_logic;    -- Signal for broadcasting to all VVCs

  
  ------------------------------------------------------------------------
  -- Shared variables for UVVM framework
  ------------------------------------------------------------------------
  shared variable shared_vvc_response : t_vvc_response;
  shared variable shared_cmd_idx      : integer := 0;
  shared variable shared_uvvm_state   : t_uvvm_state := IDLE;

  
  -------------------------------------------
  -- acknowledge_cmd
  -------------------------------------------
  -- Drives global_vvc_ack signal (to '1') for 1 delta cycle, then sets it back to 'Z'.
  procedure acknowledge_cmd (
    signal   global_vvc_ack      : out std_logic
  );


  -------------------------------------------
  -- flag_handler
  -------------------------------------------
  -- Flag handler is a general flag/semaphore handling mechanism between two separate processes/threads
  -- The idea is to allow one process to set a flag and another to reset it. The flag may then be used by both - or others
  -- May be used for a message from process 1 to process 2 with acknowledge; - like do-something & done, or valid & ack
  procedure flag_handler(
    signal flag : inout t_flag_record
  );

  
  -------------------------------------------
  -- set_flag
  -------------------------------------------
  -- Sets reset and is_active to 'Z' and pulses set_flag
  procedure set_flag(
    signal flag : inout t_flag_record
  );

  
  -------------------------------------------
  -- reset_flag
  -------------------------------------------
  -- Sets set and is_active to 'Z' and pulses reset_flag
  procedure reset_flag(
    signal flag : inout t_flag_record
  );

  
  -------------------------------------------
  -- initialize_uvvm
  -------------------------------------------
  -- Initializes the UVVM VVC Framework
  procedure initialize_uvvm;

  
  -------------------------------------------
  -- await_uvvm_initialization
  -------------------------------------------
  -- Waits until uvvm has been initialized
  procedure await_uvvm_initialization(
    constant dummy : in t_void
  );
  
  
  -------------------------------------------
  -- format_command_idx
  -------------------------------------------
  -- Converts the command index to string, enclused by
  -- C_CMD_IDX_PREFIX and C_CMD_IDX_SUFFIX
 impure function format_command_idx(
    command_idx : integer
  ) return string;

end package ti_vvc_framework_support_pkg;




package body ti_vvc_framework_support_pkg is

  ------------------------------------------------------------------------
  --
  ------------------------------------------------------------------------
  procedure acknowledge_cmd (
    signal   global_vvc_ack      : out std_logic
  ) is
  begin
    -- Drive ack signal for 1 delta cycle.
    global_vvc_ack <= '1';
    wait for 0 ns;
    global_vvc_ack <= 'Z';
    wait for 0 ns;
  end procedure;


  -- Flag handler is a general flag/semaphore handling mechanism between two separate processes/threads
  -- The idea is to allow one process to set a flag and another to reset it. The flag may then be used by both - or others
  -- May be used for a message from process 1 to process 2 with acknowledge; - like do-something & done, or valid & ack
  procedure flag_handler(
    signal flag : inout t_flag_record
  ) is
  begin
    flag.reset <= 'Z';
    flag.set   <= 'Z';

    flag.is_active <= '0';
    wait until flag.set = '1';
    flag.is_active <= '1';
    wait until flag.reset = '1';
    flag.is_active <= '0';
  end procedure;

  procedure set_flag(
    signal flag : inout t_flag_record
  ) is
  begin
    flag.reset <= 'Z';
    flag.is_active <= 'Z';
    gen_pulse(flag.set, 0 ns, "set flag");
  end procedure;

  procedure reset_flag(
    signal flag : inout t_flag_record
  ) is
  begin
    flag.set <= 'Z';
    flag.is_active <= 'Z';
    gen_pulse(flag.reset, 0 ns, "reset flag");
  end procedure;

  procedure initialize_uvvm is
  begin
    -- shared_uvvm_state is initialized to IDLE. Hence it will stay in IDLE if this procedure is not included in the TB
    shared_uvvm_state := PHASE_A;
    wait for 0 ns;  -- A single delta cycle
    if (shared_uvvm_state = PHASE_B) then
      tb_failure("Concurrent procedure 'Initialize_uvvm' has been instantiated more than once in this testbench system", C_SCOPE);
    end if;
    shared_uvvm_state := PHASE_B;
    wait for 0 ns;  -- A single delta cycle
    shared_uvvm_state := INIT_COMPLETED;
    wait;
  end procedure;
  
  -- This procedure checks the shared_uvvm_state on each delta cycle
  procedure await_uvvm_initialization(
    constant dummy : in t_void) is
  begin
    while (shared_uvvm_state /= INIT_COMPLETED) loop
      wait for 0 ns;
    end loop;
  end procedure;

  impure function format_command_idx(
    command_idx : integer
  ) return string is
  begin
    return C_CMD_IDX_PREFIX & to_string(command_idx) & C_CMD_IDX_SUFFIX;
  end;

end package body ti_vvc_framework_support_pkg;

