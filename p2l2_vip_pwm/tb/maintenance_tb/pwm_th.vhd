--================================================================================================================================
-- Copyright 2026 UVVM
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
-- Description   : Test harness of pwm_vvc_tb:
--                 - i1_pwm_vvc (GENERATOR, idx 1) and i2_pwm_vvc (OBSERVER, idx 2) on the loopback line pwm_loop
--                 - i3_pwm_vvc (OBSERVER, idx 3) on pwm_inject, driven by the testbench for error injection
--                 - i4_pwm_vvc (GENERATOR, idx 4) on pwm_loop_b, a second channel for per-instance jitter
--                 - an edge logger that records every event on pwm_loop in shared_th_edge_log, as independent
--                   reference for the generation tests, and one for pwm_loop_b in shared_th_edge_log_b
------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

library p2l2_vip_pwm;
context p2l2_vip_pwm.vvc_context;

use work.pwm_tb_pkg.all;
use work.pwm_th_pkg.all;

entity pwm_th is
  generic(
    GC_PWM_BFM_CONFIG : t_pwm_bfm_config := C_PWM_BFM_CONFIG_DEFAULT
  );
  port(
    pwm_inject : in std_ulogic := 'Z'
  );
end entity pwm_th;

architecture struct of pwm_th is

  -- Resolved type where a line has several drivers: generator and observer (which drives 'Z') on pwm_loop,
  -- the injection and observer i3 on pwm_inject_line
  signal pwm_loop        : std_logic;
  signal pwm_inject_line : std_logic;
  signal pwm_loop_b      : std_ulogic; -- generator i4 only

begin

  -----------------------------------------------------------------------------
  -- Instantiate the concurrent procedure that initializes UVVM
  -----------------------------------------------------------------------------
  i_ti_uvvm_engine : entity uvvm_vvc_framework.ti_uvvm_engine;

  -----------------------------------------------------------------------------
  -- PWM VVCs
  -----------------------------------------------------------------------------
  i1_pwm_vvc : entity p2l2_vip_pwm.pwm_vvc
    generic map(
      GC_INSTANCE_IDX   => 1,
      GC_ROLE           => GENERATOR,
      GC_PWM_BFM_CONFIG => GC_PWM_BFM_CONFIG
    )
    port map(
      pwm_vvc_if => pwm_loop
    );

  i2_pwm_vvc : entity p2l2_vip_pwm.pwm_vvc
    generic map(
      GC_INSTANCE_IDX   => 2,
      GC_ROLE           => OBSERVER,
      GC_PWM_BFM_CONFIG => GC_PWM_BFM_CONFIG
    )
    port map(
      pwm_vvc_if => pwm_loop
    );

  pwm_inject_line <= pwm_inject;

  i3_pwm_vvc : entity p2l2_vip_pwm.pwm_vvc
    generic map(
      GC_INSTANCE_IDX   => 3,
      GC_ROLE           => OBSERVER,
      GC_PWM_BFM_CONFIG => GC_PWM_BFM_CONFIG
    )
    port map(
      pwm_vvc_if => pwm_inject_line
    );

  i4_pwm_vvc : entity p2l2_vip_pwm.pwm_vvc
    generic map(
      GC_INSTANCE_IDX   => 4,
      GC_ROLE           => GENERATOR,
      GC_PWM_BFM_CONFIG => GC_PWM_BFM_CONFIG
    )
    port map(
      pwm_vvc_if => pwm_loop_b
    );

  -----------------------------------------------------------------------------
  -- Edge loggers: every event on the loopback line and on the second channel, from time 0
  -----------------------------------------------------------------------------
  p_edge_logger : process is
  begin
    wait on pwm_loop;
    shared_th_edge_log.add(now, pwm_loop);
  end process p_edge_logger;

  p_edge_logger_b : process is
  begin
    wait on pwm_loop_b;
    shared_th_edge_log_b.add(now, pwm_loop_b);
  end process p_edge_logger_b;

end architecture struct;
