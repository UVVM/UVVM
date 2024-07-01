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

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library STD;
use std.env.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library bitvis_vip_sbi;
use bitvis_vip_sbi.sbi_bfm_pkg.all;

use work.irqc_pif_pkg.all;

--hdlregression:tb
-- Test case entity
entity irqc_demo_tb is
end entity irqc_demo_tb;

-- Test case architecture
architecture func of irqc_demo_tb is

  -- DSP interface and general control signals
  signal clk    : std_logic                                                        := '0';
  signal arst   : std_logic                                                        := '0';
  -- CPU interface
  signal sbi_if : t_sbi_if(addr(2 downto 0), wdata(7 downto 0), rdata(7 downto 0)) := init_sbi_if_signals(3, 8);

  -- Interrupt related signals
  signal irq_source  : std_logic_vector(C_NUM_SOURCES - 1 downto 0) := (others => '0');
  signal irq2cpu     : std_logic                                    := '0';
  signal irq2cpu_ack : std_logic                                    := '0';

  signal clock_ena : boolean := false;

  constant C_CLK_PERIOD : time := 10 ns;

  subtype t_irq_source is std_logic_vector(C_NUM_SOURCES - 1 downto 0);

  -- Trim (cut) a given vector to fit the number of irq sources (i.e. pot. reduce width)
  function trim(
    constant source   : std_logic_vector;
    constant num_bits : positive := C_NUM_SOURCES)
  return t_irq_source is
    variable v_result : std_logic_vector(source'length - 1 downto 0) := source;
  begin
    return v_result(num_bits - 1 downto 0);
  end;

  -- Fit a given vector to the number of irq sources by masking with zeros above irq width
  function fit(
    constant source   : std_logic_vector;
    constant num_bits : positive := C_NUM_SOURCES)
  return std_logic_vector is
    variable v_result : std_logic_vector(source'length - 1 downto 0) := (others => '0');
    variable v_source : std_logic_vector(source'length - 1 downto 0) := source;
  begin
    v_result(num_bits - 1 downto 0) := v_source(num_bits - 1 downto 0);
    return v_result;
  end;

begin

  -----------------------------------------------------------------------------
  -- Instantiate DUT
  -----------------------------------------------------------------------------
  i_irqc : entity work.irqc
    port map(
      -- DSP interface and general control signals
      clk         => clk,
      arst        => arst,
      -- CPU interface
      cs          => sbi_if.cs,
      addr        => sbi_if.addr,
      wr          => sbi_if.wena,
      rd          => sbi_if.rena,
      din         => sbi_if.wdata,
      dout        => sbi_if.rdata,
      -- Interrupt related signals
      irq_source  => irq_source,
      irq2cpu     => irq2cpu,
      irq2cpu_ack => irq2cpu_ack
    );

  sbi_if.ready <= '1';                  -- always ready in the same clock cycle.

  -----------------------------------------------------------------------------
  -- Clock Generator
  -----------------------------------------------------------------------------
  clock_generator(clk, clock_ena, C_CLK_PERIOD, "IRQC TB clock");

  ------------------------------------------------
  -- PROCESS: p_main
  ------------------------------------------------
  p_main : process
    constant C_SCOPE : string := C_TB_SCOPE_DEFAULT;

    -- Overloads for PIF BFMs for SBI (Simple Bus Interface)
    procedure write(
      constant addr_value : in natural;
      constant data_value : in std_logic_vector;
      constant msg        : in string) is
    begin
      sbi_write(to_unsigned(addr_value, sbi_if.addr'length), data_value, msg,
                clk, sbi_if, C_SCOPE);
    end;

    procedure check(
      constant addr_value  : in natural;
      constant data_exp    : in std_logic_vector;
      constant alert_level : in t_alert_level;
      constant msg         : in string) is
    begin
      sbi_check(to_unsigned(addr_value, sbi_if.addr'length), data_exp, msg,
                clk, sbi_if, alert_level, C_SCOPE);
    end;

    procedure set_inputs_passive(
      dummy : t_void) is
    begin
      sbi_if.cs    <= '0';
      sbi_if.addr  <= (others => '0');
      sbi_if.wena  <= '0';
      sbi_if.rena  <= '0';
      sbi_if.wdata <= (others => '0');
      irq_source   <= (others => '0');
      irq2cpu_ack  <= '0';
      log(ID_SEQUENCER_SUB, "All inputs set passive", C_SCOPE);
    end;

    variable v_time_stamp   : time := 0 ns;
    variable v_irq_mask     : std_logic_vector(7 downto 0);
    variable v_irq_mask_inv : std_logic_vector(7 downto 0);

  begin
    -- Print the configuration to the log
    report_global_ctrl(VOID);
    report_msg_id_panel(VOID);

    enable_log_msg(ALL_MESSAGES);
    --disable_log_msg(ALL_MESSAGES);
    --enable_log_msg(ID_LOG_HDR);

    log(ID_LOG_HDR, "Start Simulation of TB for IRQC", C_SCOPE);
    ------------------------------------------------------------

    set_inputs_passive(VOID);

    clock_ena <= true;                  -- to start clock generator

    gen_pulse(arst, 10 * C_CLK_PERIOD, "Pulsed reset-signal - active for 10T");
    v_time_stamp := now;                -- time from which irq2cpu should be stable off until triggered

    check_value(C_NUM_SOURCES > 0, FAILURE, "Must be at least 1 interrupt source", C_SCOPE);
    check_value(C_NUM_SOURCES <= 8, TB_WARNING, "This TB is only checking IRQC with up to 8 interrupt sources", C_SCOPE);

    log(ID_LOG_HDR, "Check defaults on output ports", C_SCOPE);
    ------------------------------------------------------------
    check_value(irq2cpu, '0', ERROR, "Interrupt to CPU must be default inactive", C_SCOPE);
    check_value(sbi_if.rdata, x"00", ERROR, "Register data bus output must be default passive");

    log(ID_LOG_HDR, "Check register defaults and access (write + read)", C_SCOPE);
    ------------------------------------------------------------
    log("\nChecking Register defaults");
    check(C_ADDR_IRR, x"00", ERROR, "IRR default");
    check(C_ADDR_IER, x"00", ERROR, "IER default");
    check(C_ADDR_IPR, x"00", ERROR, "IPR default");
    check(C_ADDR_IRQ2CPU_ALLOWED, x"00", ERROR, "IRQ2CPU_ALLOWED default");

    log("\nChecking Register Write/Read");
    write(C_ADDR_IER, fit(x"55"), "IER");
    check(C_ADDR_IER, fit(x"55"), ERROR, "IER pure readback");
    write(C_ADDR_IER, fit(x"AA"), "IER");
    check(C_ADDR_IER, fit(x"AA"), ERROR, "IER pure readback");
    write(C_ADDR_IER, fit(x"00"), "IER");
    check(C_ADDR_IER, fit(x"00"), ERROR, "IER pure readback");

    log(ID_LOG_HDR, "Check register trigger/clear mechanism", C_SCOPE);
    ------------------------------------------------------------
    write(C_ADDR_ITR, fit(x"AA"), "ITR : Set interrupts");
    check(C_ADDR_IRR, fit(x"AA"), ERROR, "IRR");
    write(C_ADDR_ITR, fit(x"55"), "ITR : Set more interrupts");
    check(C_ADDR_IRR, fit(x"FF"), ERROR, "IRR");
    write(C_ADDR_ICR, fit(x"71"), "ICR : Clear interrupts");
    check(C_ADDR_IRR, fit(x"8E"), ERROR, "IRR");
    write(C_ADDR_ICR, fit(x"85"), "ICR : Clear interrupts");
    check(C_ADDR_IRR, fit(x"0A"), ERROR, "IRR");
    write(C_ADDR_ITR, fit(x"55"), "ITR : Set more interrupts");
    check(C_ADDR_IRR, fit(x"5F"), ERROR, "IRR");
    write(C_ADDR_ICR, fit(x"5F"), "ICR : Clear interrupts");
    check(C_ADDR_IRR, fit(x"00"), ERROR, "IRR");

    log(ID_LOG_HDR, "Check interrupt sources, IER, IPR and irq2cpu", C_SCOPE);
    ------------------------------------------------------------
    log("\nChecking interrupts and IRR");
    write(C_ADDR_ICR, fit(x"FF"), "ICR : Clear all interrupts");
    gen_pulse(irq_source, trim(x"AA"), clk, 1, "Pulse irq_source 1T");
    check(C_ADDR_IRR, fit(x"AA"), ERROR, "IRR after irq pulses");
    gen_pulse(irq_source, trim(x"01"), clk, 1, "Add more interrupts");
    check(C_ADDR_IRR, fit(x"AB"), ERROR, "IRR after irq pulses");
    gen_pulse(irq_source, trim(x"A1"), clk, 1, "Repeat same interrupts");
    check(C_ADDR_IRR, fit(x"AB"), ERROR, "IRR after irq pulses");
    gen_pulse(irq_source, trim(x"54"), clk, 1, "Add remaining interrupts");
    check(C_ADDR_IRR, fit(x"FF"), ERROR, "IRR after irq pulses");
    write(C_ADDR_ICR, fit(x"AA"), "ICR : Clear half the interrupts");
    gen_pulse(irq_source, trim(x"A0"), clk, 1, "Add more interrupts");
    check(C_ADDR_IRR, fit(x"F5"), ERROR, "IRR after irq pulses");
    write(C_ADDR_ICR, fit(x"FF"), "ICR : Clear all interrupts");
    check(C_ADDR_IRR, fit(x"00"), ERROR, "IRR after clearing all");

    log("\nChecking IER, IPR and irq2cpu");
    write(C_ADDR_ICR, fit(x"FF"), "ICR : Clear all interrupts");
    write(C_ADDR_IER, fit(x"55"), "IER : Enable some interrupts");
    write(C_ADDR_ITR, fit(x"AA"), "ITR : Trigger non-enable interrupts");
    check(C_ADDR_IPR, fit(x"00"), ERROR, "IPR should not be active");
    check(C_ADDR_IRQ2CPU_ALLOWED, x"00", ERROR, "IRQ2CPU_ALLOWED should not be active");
    write(C_ADDR_IRQ2CPU_ENA, x"01", "IRQ2CPU_ENA : Enable main interrupt to CPU");
    check(C_ADDR_IRQ2CPU_ALLOWED, x"01", ERROR, "IRQ2CPU_ALLOWED should now be active");
    check_value(irq2cpu, '0', ERROR, "Interrupt to CPU must still be inactive", C_SCOPE);
    check_stable(irq2cpu, (now - v_time_stamp), ERROR, "No spikes allowed on irq2cpu", C_SCOPE);
    gen_pulse(irq_source, trim(x"01"), clk, 1, "Add a single enabled interrupt");
    await_value(irq2cpu, '1', 0 ns, C_CLK_PERIOD, ERROR, "Interrupt expected immediately", C_SCOPE);
    v_time_stamp := now;                -- from time of stable active irq2cpu
    check(C_ADDR_IRR, fit(x"AB"), ERROR, "IRR should now be active");
    check(C_ADDR_IPR, fit(x"01"), ERROR, "IPR should now be active");

    log("\nMore details checked in the autonomy section below");
    check_value(irq2cpu, '1', ERROR, "Interrupt to CPU must still be active", C_SCOPE);
    check_stable(irq2cpu, (now - v_time_stamp), ERROR, "No spikes allowed on irq2cpu", C_SCOPE);

    log(ID_LOG_HDR, "Check autonomy for all interrupts", C_SCOPE);
    ------------------------------------------------------------
    write(C_ADDR_ICR, fit(x"FF"), "ICR : Clear all interrupts");
    write(C_ADDR_IER, fit(x"FF"), "IER : Disable all interrupts");
    write(C_ADDR_IRQ2CPU_ENA, x"01", "IRQ2CPU_ENA : Allow interrupt to CPU");
    for i in 0 to C_NUM_SOURCES - 1 loop

      log(" ");
      log("- Checking irq_source(" & to_string(i) & ") and all corresponding functionality");
      log("- - Check interrupt activation not affected by non related interrupts or registers");
      v_time_stamp      := now;         -- from time of stable inactive irq2cpu
      v_irq_mask        := (others => '0');
      v_irq_mask(i)     := '1';
      v_irq_mask_inv    := (others => '1');
      v_irq_mask_inv(i) := '0';
      write(C_ADDR_IER, v_irq_mask, "IER : Enable selected interrupt");
      gen_pulse(irq_source, trim(v_irq_mask_inv), clk, 1, "Pulse all non-enabled interrupts");
      write(C_ADDR_ITR, v_irq_mask_inv, "ITR : Trigger all non-enabled interrupts");
      check(C_ADDR_IRR, fit(v_irq_mask_inv), ERROR, "IRR not yet triggered");
      check(C_ADDR_IPR, x"00", ERROR, "IPR not yet triggered");
      check_value(irq2cpu, '0', ERROR, "Interrupt to CPU must still be inactive", C_SCOPE);
      check_stable(irq2cpu, (now - v_time_stamp), ERROR, "No spikes allowed on irq2cpu", C_SCOPE);
      gen_pulse(irq_source, trim(v_irq_mask), clk, 1, "Pulse the enabled interrupt");
      await_value(irq2cpu, '1', 0 ns, C_CLK_PERIOD, ERROR, "Interrupt expected immediately", C_SCOPE);
      check(C_ADDR_IRR, fit(x"FF"), ERROR, "All IRR triggered");
      check(C_ADDR_IPR, v_irq_mask, ERROR, "IPR triggered for selected");

      log("\n- - Check interrupt deactivation not affected by non related interrupts or registers");
      v_time_stamp := now;              -- from time of stable active irq2cpu
      write(C_ADDR_ICR, v_irq_mask_inv, "ICR : Clear all non-enabled interrupts");
      write(C_ADDR_IER, fit(x"FF"), "IER : Enable all interrupts");
      write(C_ADDR_IER, v_irq_mask, "IER : Disable non-selected interrupts");
      gen_pulse(irq_source, trim(x"FF"), clk, 1, "Pulse all interrupts");
      write(C_ADDR_ITR, x"FF", "ITR : Trigger all interrupts");
      check_stable(irq2cpu, (now - v_time_stamp), ERROR, "No spikes allowed on irq2cpu (='1')", C_SCOPE);
      write(C_ADDR_IER, v_irq_mask_inv, "IER : Enable all interrupts but disable selected");
      check_value(irq2cpu, '1', ERROR, "Interrupt to CPU still active", C_SCOPE);
      check(C_ADDR_IRR, fit(x"FF"), ERROR, "IRR still active for all");
      write(C_ADDR_ICR, v_irq_mask_inv, "ICR : Clear all non-enabled interrupts");
      await_value(irq2cpu, '0', 0 ns, C_CLK_PERIOD, ERROR, "Interrupt deactivation expected immediately", C_SCOPE);
      write(C_ADDR_IER, v_irq_mask, "IER : Re-enable selected interrupt");
      await_value(irq2cpu, '1', 0 ns, C_CLK_PERIOD, ERROR, "Interrupt reactivation expected immediately", C_SCOPE);
      check(C_ADDR_IPR, v_irq_mask, ERROR, "IPR still active for selected");
      write(C_ADDR_ICR, v_irq_mask, "ICR : Clear selected interrupt");
      check_value(irq2cpu, '0', ERROR, "Interrupt to CPU must go inactive", C_SCOPE);
      check(C_ADDR_IRR, x"00", ERROR, "IRR all inactive");
      check(C_ADDR_IPR, x"00", ERROR, "IPR all inactive");
      write(C_ADDR_IER, x"00", "IER : Disable all interrupts");
    end loop;

    report_alert_counters(INTERMEDIATE); -- Report intermediate counters

    log(ID_LOG_HDR, "Check irq acknowledge and re-enable", C_SCOPE);
    ------------------------------------------------------------
    log("- Activate interrupt");
    write(C_ADDR_ITR, v_irq_mask, "ICR : Set single upper interrupt");
    write(C_ADDR_IER, v_irq_mask, "IER : Enable single upper interrupts");
    write(C_ADDR_IRQ2CPU_ENA, x"01", "IRQ2CPU_ENA : Allow interrupt to CPU");
    await_value(irq2cpu, '1', 0 ns, C_CLK_PERIOD, ERROR, "Interrupt activation expected", C_SCOPE);
    v_time_stamp := now;                -- from time of stable active irq2cpu

    log("\n- Try potential malfunction");
    write(C_ADDR_IRQ2CPU_ENA, x"01", "IRQ2CPU_ENA : Allow interrupt to CPU again - should not affect anything");
    write(C_ADDR_IRQ2CPU_ENA, x"00", "IRQ2CPU_ENA : Set to 0 - should not affect anything");
    write(C_ADDR_IRQ2CPU_DISABLE, x"00", "IRQ2CPU_DISABLE : Set to 0 - should not affect anything");
    check_stable(irq2cpu, (now - v_time_stamp), ERROR, "No spikes allowed on irq2cpu (='1')", C_SCOPE);

    log("\n- Acknowledge and deactivate interrupt");
    gen_pulse(irq2cpu_ack, clk, 1, "Pulse irq2cpu_ack");
    await_value(irq2cpu, '0', 0 ns, C_CLK_PERIOD, ERROR, "Interrupt deactivation expected", C_SCOPE);
    v_time_stamp := now;                -- from time of stable inactive irq2cpu

    log("\n- Test for potential malfunction");
    write(C_ADDR_IRQ2CPU_DISABLE, x"01", "IRQ2CPU_DISABLE : Disable interrupt to CPU again - should not affect anything");
    write(C_ADDR_IRQ2CPU_DISABLE, x"00", "IRQ2CPU_DISABLE : Set to 0 - should not affect anything");
    write(C_ADDR_IRQ2CPU_ENA, x"00", "IRQ2CPU_ENA : Set to 0 - should not affect anything");
    write(C_ADDR_ITR, x"FF", "ICR : Trigger all interrupts");
    write(C_ADDR_IER, x"FF", "IER : Enable all interrupts");
    gen_pulse(irq_source, trim(x"FF"), clk, 1, "Pulse all interrupts");
    gen_pulse(irq2cpu_ack, clk, 1, "Pulse irq2cpu_ack");
    check_stable(irq2cpu, (now - v_time_stamp), ERROR, "No spikes allowed on irq2cpu (='0')", C_SCOPE);

    log("\n- Re-/de-activation");
    write(C_ADDR_IRQ2CPU_ENA, x"01", "IRQ2CPU_ENA : Reactivate interrupt to CPU");
    await_value(irq2cpu, '1', 0 ns, C_CLK_PERIOD, ERROR, "Interrupt reactivation expected", C_SCOPE);
    write(C_ADDR_IRQ2CPU_DISABLE, x"01", "IRQ2CPU_DISABLE : Deactivate interrupt to CPU");
    await_value(irq2cpu, '0', 0 ns, C_CLK_PERIOD, ERROR, "Interrupt deactivation expected", C_SCOPE);
    write(C_ADDR_IRQ2CPU_ENA, x"01", "IRQ2CPU_ENA : Reactivate interrupt to CPU");
    await_value(irq2cpu, '1', 0 ns, C_CLK_PERIOD, ERROR, "Interrupt reactivation expected", C_SCOPE);

    log(ID_LOG_HDR, "Check Reset", C_SCOPE);
    ------------------------------------------------------------
    log("- Activate all interrupts");
    write(C_ADDR_ITR, x"FF", "ICR : Set all interrupts");
    write(C_ADDR_IER, x"FF", "IER : Enable all interrupts");
    write(C_ADDR_IRQ2CPU_ENA, x"01", "IRQ2CPU_ENA : Allow interrupt to CPU");
    await_value(irq2cpu, '1', 0 ns, C_CLK_PERIOD, ERROR, "Interrupt activation expected", C_SCOPE);
    gen_pulse(arst, clk, 1, "Pulse reset");
    await_value(irq2cpu, '0', 0 ns, C_CLK_PERIOD, ERROR, "Interrupt deactivation", C_SCOPE);
    check(C_ADDR_IER, x"00", ERROR, "IER all inactive");
    check(C_ADDR_IRR, x"00", ERROR, "IRR all inactive");
    check(C_ADDR_IPR, x"00", ERROR, "IPR all inactive");

    --==================================================================================================
    -- Ending the simulation
    --------------------------------------------------------------------------------------
    wait for 1000 ns;                   -- to allow some time for completion
    report_alert_counters(FINAL);       -- Report final counters and print conclusion for simulation (Success/Fail)
    log(ID_LOG_HDR, "SIMULATION COMPLETED", C_SCOPE);

    -- Finish the simulation
    std.env.stop;
    wait;                               -- to stop completely

  end process p_main;

end func;
