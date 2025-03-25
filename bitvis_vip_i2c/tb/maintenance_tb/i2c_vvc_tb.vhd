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

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

-- Include Verification IPs
library bitvis_vip_i2c;
context bitvis_vip_i2c.vvc_context;
use bitvis_vip_i2c.vvc_sb_support_pkg.all;

library bitvis_vip_wishbone;
context bitvis_vip_wishbone.vvc_context;

library bitvis_vip_sbi;
context bitvis_vip_sbi.vvc_context;

-------------------------------------------------------------------------------

--hdlregression:tb
entity i2c_vvc_tb is
  generic(
    GC_TESTCASE : string := "UVVM"
  );
end entity i2c_vvc_tb;

-------------------------------------------------------------------------------

architecture behav of i2c_vvc_tb is
  constant C_SCOPE : string := "I2C_VVC_TB";

  constant C_CLK_PERIOD : time := 10 ns; -- 100 MHz

  constant C_I2C_DATA_WIDTH       : integer              := 8;
  constant C_WISHBONE_DATA_WIDTH  : integer              := 8;
  constant C_WISHBONE_ADDR_WIDTH  : integer              := 3;
  constant C_SBI_DATA_WIDTH       : integer              := 8;
  constant C_SBI_ADDR_WIDTH       : integer              := 7;
  constant C_I2C_SLAVE_DUT_ADDR_0 : unsigned(6 downto 0) := "1010101"; -- Used as address in Slave VVC
  constant C_I2C_SLAVE_DUT_ADDR_1 : unsigned(6 downto 0) := "0101010"; -- Used as both I2C address and SBI address for I2C slave DUT
  constant C_I2C_SLAVE_DUT_ADDR_2 : unsigned(6 downto 0) := "1111000"; -- Used as both I2C address and SBI address for I2C slave DUT
  constant C_I2C_SLAVE_DUT_ADDR_3 : unsigned(6 downto 0) := "0000000"; -- Used as both I2C address and SBI address for I2C slave DUT
  constant C_I2C_SLAVE_DUT_ADDR_4 : unsigned(6 downto 0) := "1111111"; -- Used as both I2C address and SBI address for I2C slave DUT

  constant C_DUMMY_SLAVE_DUT_ADDR : unsigned(6 downto 0) := "1100110";

  signal arst : std_logic := '0';

  constant C_I2C_BFM_CONFIG_DEFAULT : t_i2c_bfm_config := (
    enable_10_bits_addressing       => false,
    master_sda_to_scl               => 400 ns,
    master_scl_to_sda               => 505 ns,
    master_stop_condition_hold_time => 505 ns,
    max_wait_scl_change             => 10 ms,
    max_wait_scl_change_severity    => failure,
    max_wait_sda_change             => 10 ms,
    max_wait_sda_change_severity    => failure,
    i2c_bit_time                    => 1100 ns, -- approx. 1 MHz
    i2c_bit_time_severity           => failure,
    acknowledge_severity            => failure,
    slave_mode_address              => "000" & C_I2C_SLAVE_DUT_ADDR_0,
    slave_mode_address_severity     => failure,
    slave_rw_bit_severity           => failure,
    reserved_address_severity       => warning,
    match_strictness                => MATCH_EXACT,
    id_for_bfm                      => ID_BFM,
    id_for_bfm_wait                 => ID_BFM_WAIT,
    id_for_bfm_poll                 => ID_BFM_POLL
  );

  constant C_I2C_BFM_CONFIG_10_BIT_ADDRESSING : t_i2c_bfm_config := (
    enable_10_bits_addressing       => true,
    master_sda_to_scl               => 400 ns, -- used for checking
    master_scl_to_sda               => 505 ns, -- used for checking
    master_stop_condition_hold_time => 505 ns,
    max_wait_scl_change             => 10 ms,
    max_wait_scl_change_severity    => failure,
    max_wait_sda_change             => 10 ms,
    max_wait_sda_change_severity    => failure,
    i2c_bit_time                    => 1100 ns, -- approx. 1 MHz
    i2c_bit_time_severity           => failure,
    acknowledge_severity            => failure,
    slave_mode_address              => "101" & C_I2C_SLAVE_DUT_ADDR_0,
    slave_mode_address_severity     => failure,
    slave_rw_bit_severity           => failure,
    reserved_address_severity       => warning,
    match_strictness                => MATCH_EXACT,
    id_for_bfm                      => ID_BFM,
    id_for_bfm_wait                 => ID_BFM_WAIT,
    id_for_bfm_poll                 => ID_BFM_POLL
  );

  constant C_WISHBONE_MASTER_BFM_CONFIG_DEFAULT : t_wishbone_bfm_config := (
    max_wait_cycles          => 10,
    max_wait_cycles_severity => failure,
    clock_period             => C_CLK_PERIOD,
    clock_period_margin      => 0 ns,
    clock_margin_severity    => TB_ERROR,
    setup_time               => C_CLK_PERIOD / 4,
    hold_time                => C_CLK_PERIOD / 4,
    match_strictness         => MATCH_EXACT,
    id_for_bfm               => ID_BFM,
    id_for_bfm_wait          => ID_BFM_WAIT,
    id_for_bfm_poll          => ID_BFM_POLL
  );

  constant C_SBI_BFM_CONFIG : t_sbi_bfm_config := (
    max_wait_cycles            => 10000000,
    max_wait_cycles_severity   => failure,
    use_fixed_wait_cycles_read => false,
    fixed_wait_cycles_read     => 0,
    clock_period               => C_CLK_PERIOD,
    clock_period_margin        => 0 ns,
    clock_margin_severity      => TB_ERROR,
    setup_time                 => C_CLK_PERIOD / 4,
    hold_time                  => C_CLK_PERIOD / 4,
    bfm_sync                   => SYNC_ON_CLOCK_ONLY,
    match_strictness           => MATCH_EXACT,
    id_for_bfm                 => ID_BFM,
    id_for_bfm_wait            => ID_BFM_WAIT,
    id_for_bfm_poll            => ID_BFM_POLL,
    use_ready_signal           => true
  );

  procedure config_i2c_master_dut(
    signal WISHBONE_VVCT : inout bitvis_vip_wishbone.td_target_support_pkg.t_vvc_target_record
  ) is
  begin
    -- First configurate the DUT
    -- We have a system clk of 100 MHz and desire a I2C SCL of 10 MHz.
    -- See documentation of DUT.
    wishbone_write(WISHBONE_VVCT, 0, x"0", x"13", "Set SCL prescaler LSB");
    wishbone_write(WISHBONE_VVCT, 0, x"1", x"00", "Set SCL prescaler MSB");
    -- Enable the DUT
    wishbone_write(WISHBONE_VVCT, 0, x"2", x"80", "Enable DUT");
    await_completion(WISHBONE_VVCT, 0, 50 ms);
  end procedure config_i2c_master_dut;

  procedure poll_i2c_master_dut_status_register(
    signal   WISHBONE_VVCT : inout bitvis_vip_wishbone.td_target_support_pkg.t_vvc_target_record;
    constant expected      : in std_logic_vector(C_WISHBONE_DATA_WIDTH - 1 downto 0);
    constant max_wait_time : in time := 5 ms
  ) is
    variable v_cmd_idx              : natural;
    variable v_wishbone_read_result : std_logic_vector(bitvis_vip_wishbone.vvc_cmd_pkg.C_VVC_CMD_DATA_MAX_LENGTH - 1 downto 0);

    variable v_timeout    : boolean := false;
    variable v_start_time : time    := now;
    variable v_equal      : boolean := true;
  begin
    -- wait for interrupt or TIP flag to negate, then check for expected
    while not v_timeout loop
      v_equal   := true;
      wishbone_read(WISHBONE_VVCT, 0, x"4", "Read status reg");
      v_cmd_idx := get_last_received_cmd_idx(WISHBONE_VVCT, 0);
      await_completion(WISHBONE_VVCT, 0, 1 ms);
      fetch_result(WISHBONE_VVCT, 0, v_cmd_idx, v_wishbone_read_result, "Fetching result from I2C master DUT status register.", error);
      for i in expected'range loop
        if expected(i) /= '-' then
          if expected(i) /= v_wishbone_read_result(i) then
            v_equal := false;
          end if;
        end if;
      end loop;

      if v_equal then
        exit;                           -- Everything as expected
        log("I2C Master DUT status register equal to expected: " & to_string(expected));
      end if;

      wait for C_I2C_BFM_CONFIG_DEFAULT.i2c_bit_time;

      if now - v_start_time >= max_wait_time then
        v_timeout := true;
      end if;

    end loop;

    if v_timeout then
      error("Timeout while reading I2C master DUT status register!");
    end if;

  end procedure poll_i2c_master_dut_status_register;

  procedure transmit_single_byte_from_i2c_master_dut_to_vvc(
    signal   WISHBONE_VVCT : inout bitvis_vip_wishbone.td_target_support_pkg.t_vvc_target_record;
    signal   I2C_VVCT      : inout bitvis_vip_i2c.td_target_support_pkg.t_vvc_target_record;
    constant data          : in std_logic_vector(C_WISHBONE_DATA_WIDTH - 1 downto 0)
  ) is
  begin

    -- We set the address here to be 0b1010101 so we need to set 0xAA in the transmit register (address 0x3) since LSB must be '0' for a write to slave.
    wishbone_write(WISHBONE_VVCT, 0, x"3", x"AA", "Setting address to be x55 and setting RW bit to 0");
    wishbone_write(WISHBONE_VVCT, 0, x"4", x"90", "Setting STA and WR bit in command reg");
    i2c_slave_check(I2C_VVCT, 2, data, "Check data");
    await_completion(WISHBONE_VVCT, 0, 50 ms); -- Waiting for address and RW bit to be set in I2C master DUT
    poll_i2c_master_dut_status_register(WISHBONE_VVCT, "0-----0-"); -- Polling for the RXack bit to be set and the TIP bit to be low, i.e., the I2C slave BFM has returned ACK
    wishbone_write(WISHBONE_VVCT, 0, x"3", data, "Writing data " & to_string(data) & " to transmit register.");
    wishbone_write(WISHBONE_VVCT, 0, x"4", x"50", "Setting STO and WR bit in command reg");
    await_completion(WISHBONE_VVCT, 0, 50 ms);

    poll_i2c_master_dut_status_register(WISHBONE_VVCT, "0-----0-"); -- Polling for the RXack bit to be set and the TIP bit to be low
    await_completion(WISHBONE_VVCT, 0, 50 ms);
    await_completion(I2C_VVCT, 2, 50 ms);

  end procedure transmit_single_byte_from_i2c_master_dut_to_vvc;

  procedure transmit_multi_byte_from_i2c_master_dut_to_vvc(
    signal   WISHBONE_VVCT : inout bitvis_vip_wishbone.td_target_support_pkg.t_vvc_target_record;
    signal   I2C_VVCT      : inout bitvis_vip_i2c.td_target_support_pkg.t_vvc_target_record;
    constant data          : in t_byte_array
  ) is
  begin
    -- We set the address here to be 0b1010101 so we need to set 0xAA in the transmit register (address 0x3) since LSB must be '0' for a write to slave.
    wishbone_write(WISHBONE_VVCT, 0, x"3", x"AA", "Setting address to be x55 and setting RW bit to 0");
    wishbone_write(WISHBONE_VVCT, 0, x"4", x"90", "Setting STA and WR bit in command reg");
    i2c_slave_check(I2C_VVCT, 2, data, "Check data");
    await_completion(WISHBONE_VVCT, 0, 50 ms); -- Waiting for address and RW bit to be set in I2C master DUT
    poll_i2c_master_dut_status_register(WISHBONE_VVCT, "0-----0-"); -- Polling for the RXack bit to be set and the TIP bit to be low, i.e., the I2C slave BFM has returned ACK on address

    for i in 0 to data'length - 1 loop
      wishbone_write(WISHBONE_VVCT, 0, x"3", data(i), "Writing data " & to_string(data(i)) & " to transmit register.");
      if i < data'length - 1 then
        wishbone_write(WISHBONE_VVCT, 0, x"4", x"10", "Setting WR bit in command reg");
      else                              -- final byte, generate stop condition afterwards
        wishbone_write(WISHBONE_VVCT, 0, x"4", x"50", "Setting STO and WR bit in command reg");
      end if;
      await_completion(WISHBONE_VVCT, 0, 50 ms); -- Wait for data and RW bit to be set in I2C master DUTs
      poll_i2c_master_dut_status_register(WISHBONE_VVCT, "0-----0-"); -- Polling for the RXack bit to be set and the TIP bit to be low
    end loop;
    await_completion(WISHBONE_VVCT, 0, 50 ms);
    await_completion(I2C_VVCT, 2, 50 ms);
  end procedure transmit_multi_byte_from_i2c_master_dut_to_vvc;

  procedure transmit_multi_byte_from_i2c_master_dut_to_vvc_10_bit_addressing(
    signal   WISHBONE_VVCT : inout bitvis_vip_wishbone.td_target_support_pkg.t_vvc_target_record;
    signal   I2C_VVCT      : inout bitvis_vip_i2c.td_target_support_pkg.t_vvc_target_record;
    constant data          : in t_byte_array
  ) is
  begin
    -- generate start condition
    -- first transmit "11110<abit9><abit8>0" -- write
    -- Expect ack
    -- then transmit "<abit7-0>"
    -- expect ack
    -- write data, expect ack each data

    wishbone_write(WISHBONE_VVCT, 0, x"3", std_logic_vector'("11110") & std_logic_vector(C_I2C_BFM_CONFIG_10_BIT_ADDRESSING.slave_mode_address(9 downto 8)) & '0',
                   "Setting 10-bit address pattern, two MSB of address and write bit");
    wishbone_write(WISHBONE_VVCT, 0, x"4", x"90", "Setting STA and WR bit in command reg");
    i2c_slave_check(I2C_VVCT, 6, data, "Check data");
    await_completion(WISHBONE_VVCT, 0, 50 ms); -- Waiting for address and RW bit to be set in I2C master DUT
    -- Polling for the RXack bit to be set and the TIP bit to be low, i.e.,
    -- the I2C slave VVC has returned ACK after receiving address from master DUT
    poll_i2c_master_dut_status_register(WISHBONE_VVCT, "0-----0-");
    wishbone_write(WISHBONE_VVCT, 0, x"3", std_logic_vector(C_I2C_BFM_CONFIG_10_BIT_ADDRESSING.slave_mode_address(7 downto 0)), "Transmitting Least-significant byte of address");
    wishbone_write(WISHBONE_VVCT, 0, x"4", x"10", "Setting WR bit in command reg");
    await_completion(WISHBONE_VVCT, 0, 50 ms); -- Waiting for address and RW bit to be set in I2C master DUT
    poll_i2c_master_dut_status_register(WISHBONE_VVCT, "0-----0-");

    for i in 0 to data'length - 1 loop
      wishbone_write(WISHBONE_VVCT, 0, x"3", data(i), "Writing data " & to_string(data(i)) & " to transmit register.");
      if i < data'length - 1 then
        wishbone_write(WISHBONE_VVCT, 0, x"4", x"10", "Setting WR bit in command reg");
      else                              -- final byte, generate stop condition afterwards
        wishbone_write(WISHBONE_VVCT, 0, x"4", x"50", "Setting STO and WR bit in command reg");
      end if;
      await_completion(WISHBONE_VVCT, 0, 50 ms); -- Wait for data and RW bit to be set in I2C master DUTs
      poll_i2c_master_dut_status_register(WISHBONE_VVCT, "0-----0-"); -- Polling for the RXack bit to be set and the TIP bit to be low
    end loop;
    await_completion(WISHBONE_VVCT, 0, 50 ms);
    await_completion(I2C_VVCT, 6, 50 ms);
  end procedure transmit_multi_byte_from_i2c_master_dut_to_vvc_10_bit_addressing;

  procedure transmit_single_byte_from_vvc_to_i2c_master_dut(
    signal   WISHBONE_VVCT : inout bitvis_vip_wishbone.td_target_support_pkg.t_vvc_target_record;
    signal   I2C_VVCT      : inout bitvis_vip_i2c.td_target_support_pkg.t_vvc_target_record;
    constant data          : in std_logic_vector(C_WISHBONE_DATA_WIDTH - 1 downto 0)
  ) is
  begin
    -- Example:
    -- Write 1 byte of data to a slave.
    -- Slave address = 0x51 (b”1010001”)
    -- Data to write = 0xAC

    -- 1) generate start command
    -- 2) write slave address + read bit to master DUT
    -- 3) receive acknowledge from slave vvc
    -- 4) Receive data from slave vvc
    -- 5) Generate ack to slave vvc
    -- 6) generate stop command

    -- We set the address here to be 0b1010101 so we need to set 0xAA in the transmit register (address 0x3) since LSB must be '0' for a write to slave.
    wishbone_write(WISHBONE_VVCT, 0, x"3", x"AB", "Setting address to be x55 and setting RW bit to Read ('1')");
    wishbone_write(WISHBONE_VVCT, 0, x"4", x"90", "Setting STA and WR bit in command reg");
    i2c_slave_transmit(I2C_VVCT, 2, data, "Transmit data from I2C slave VVC");
    await_completion(WISHBONE_VVCT, 0, 50 ms); -- Waiting for address and RW bit to be set in I2C master DUT

    -- Polling for the RXack bit to be set and the TIP bit to be low, i.e.,
    -- the I2C slave VVC has returned ACK after receiving address from master DUT
    poll_i2c_master_dut_status_register(WISHBONE_VVCT, "0-----0-");

    wishbone_write(WISHBONE_VVCT, 0, x"4", x"68", "Setting STO, RD and NACK bit in command reg");
    await_completion(WISHBONE_VVCT, 0, 50 ms);
    poll_i2c_master_dut_status_register(WISHBONE_VVCT, "------0-"); -- Polling for the TIP bit to be low

    -- Check data
    wishbone_check(WISHBONE_VVCT, 0, x"3", data, "Checking data received from I2C VVC Slave");

    await_completion(WISHBONE_VVCT, 0, 50 ms);
    await_completion(I2C_VVCT, 2, 50 ms);

  end procedure transmit_single_byte_from_vvc_to_i2c_master_dut;

  procedure transmit_multi_byte_from_vvc_to_i2c_master_dut(
    signal   WISHBONE_VVCT : inout bitvis_vip_wishbone.td_target_support_pkg.t_vvc_target_record;
    signal   I2C_VVCT      : inout bitvis_vip_i2c.td_target_support_pkg.t_vvc_target_record;
    constant data          : in t_byte_array
  ) is
  begin

    -- Example:
    -- Write 1 byte of data to a slave.
    -- Slave address = 0x51 (b”1010001”)
    -- Data to write = 0xAC

    -- 1) generate start command
    -- 2) write slave address + read bit to master DUT
    -- 3) receive acknowledge from slave vvc
    -- 4) Receive data from slave vvc
    -- 5) Generate ack to slave vvc
    -- 6) generate stop command

    -- We set the address here to be 0b1010101 so we need to set 0xAA in the transmit register (address 0x3) since LSB must be '0' for a write to slave.
    wishbone_write(WISHBONE_VVCT, 0, x"3", x"AB", "Setting address to be x55 and setting RW bit to Read ('1')");
    wishbone_write(WISHBONE_VVCT, 0, x"4", x"90", "Setting STA and WR bit in command reg");
    i2c_slave_transmit(I2C_VVCT, 2, data, "Transmit data from I2C slave VVC");
    await_completion(WISHBONE_VVCT, 0, 50 ms); -- Waiting for address and RW bit to be set in I2C master DUT

    -- Polling for the RXack bit to be set and the TIP bit to be low, i.e.,
    -- the I2C slave VVC has returned ACK after receiving address from master DUT
    poll_i2c_master_dut_status_register(WISHBONE_VVCT, "0-----0-");

    for i in 0 to data'length - 1 loop
      if i < data'length - 1 then
        wishbone_write(WISHBONE_VVCT, 0, x"4", x"20", "Setting RD and ACK bit in command reg");
      else                              -- final byte, generate stop condition afterwards
        -- Nack to let slave know this was the last byte that the master will accept
        wishbone_write(WISHBONE_VVCT, 0, x"4", x"68", "Setting STO, RD and NACK bit in command reg");
      end if;

      await_completion(WISHBONE_VVCT, 0, 50 ms);
      poll_i2c_master_dut_status_register(WISHBONE_VVCT, "------0-"); -- Polling for the TIP bit to be low

      -- Check data
      wishbone_check(WISHBONE_VVCT, 0, x"3", data(i), "Checking data received from I2C VVC Slave");
    end loop;

    await_completion(WISHBONE_VVCT, 0, 50 ms);
    await_completion(I2C_VVCT, 2, 50 ms);
  end procedure transmit_multi_byte_from_vvc_to_i2c_master_dut;

  procedure transmit_multi_byte_from_vvc_to_i2c_master_dut_10_bit_addressing(
    signal   WISHBONE_VVCT : inout bitvis_vip_wishbone.td_target_support_pkg.t_vvc_target_record;
    signal   I2C_VVCT      : inout bitvis_vip_i2c.td_target_support_pkg.t_vvc_target_record;
    constant data          : in t_byte_array
  ) is
  begin
    -- generate start condition
    -- first transmit "11110<abit9><abit8>0" -- write
    -- Expect ack
    -- then transmit "<abit7-0>"
    -- expect ack
    -- Generate repeated start condition
    -- transmit "11110<abit9><abit8>1" -- read
    -- expect ack
    -- expect data, ack each data except final expected

    -- C_I2C_BFM_CONFIG_10_BIT_ADDRESSING.slave_mode_address
    wishbone_write(WISHBONE_VVCT, 0, x"3", std_logic_vector'("11110") & std_logic_vector(C_I2C_BFM_CONFIG_10_BIT_ADDRESSING.slave_mode_address(9 downto 8)) & '0',
                   "Setting 10-bit address pattern, two MSB of address and write bit");
    wishbone_write(WISHBONE_VVCT, 0, x"4", x"90", "Setting STA and WR bit in command reg");
    i2c_slave_transmit(I2C_VVCT, 6, data, "Transmit data from I2C slave VVC");
    await_completion(WISHBONE_VVCT, 0, 50 ms); -- Waiting for address and RW bit to be set in I2C master DUT
    -- Polling for the RXack bit to be set and the TIP bit to be low, i.e.,
    -- the I2C slave VVC has returned ACK after receiving address from master DUT
    poll_i2c_master_dut_status_register(WISHBONE_VVCT, "0-----0-");
    wishbone_write(WISHBONE_VVCT, 0, x"3", std_logic_vector(C_I2C_BFM_CONFIG_10_BIT_ADDRESSING.slave_mode_address(7 downto 0)), "Transmitting Least-significant byte of address");
    wishbone_write(WISHBONE_VVCT, 0, x"4", x"10", "Setting WR bit in command reg");
    await_completion(WISHBONE_VVCT, 0, 50 ms); -- Waiting for address and RW bit to be set in I2C master DUT
    poll_i2c_master_dut_status_register(WISHBONE_VVCT, "0-----0-");

    -- generate repeated start condition
    -- transmit first byte again, only this time with read instead of write bit
    wishbone_write(WISHBONE_VVCT, 0, x"3", std_logic_vector'("11110") & std_logic_vector(C_I2C_BFM_CONFIG_10_BIT_ADDRESSING.slave_mode_address(9 downto 8)) & '1', "Setting 10-bit address pattern, two MSB of address and write bit");
    wishbone_write(WISHBONE_VVCT, 0, x"4", x"90", "Setting STA and WR bit in command reg");
    await_completion(WISHBONE_VVCT, 0, 50 ms); -- Waiting for address and RW bit to be set in I2C master DUT

    -- Polling for the RXack bit to be set and the TIP bit to be low, i.e.,
    -- the I2C slave VVC has returned ACK after receiving address from master DUT
    poll_i2c_master_dut_status_register(WISHBONE_VVCT, "0-----0-");

    for i in 0 to data'length - 1 loop
      if i < data'length - 1 then
        wishbone_write(WISHBONE_VVCT, 0, x"4", x"20", "Setting RD and ACK bit in command reg");
      else                              -- final byte, generate stop condition afterwards
        -- Nack to let slave know this was the last byte that the master will accept
        wishbone_write(WISHBONE_VVCT, 0, x"4", x"68", "Setting STO, RD and NACK bit in command reg");
      end if;

      await_completion(WISHBONE_VVCT, 0, 50 ms);
      poll_i2c_master_dut_status_register(WISHBONE_VVCT, "------0-"); -- Polling for the TIP bit to be low

      -- Check data
      wishbone_check(WISHBONE_VVCT, 0, x"3", data(i), "Checking data received from I2C VVC Slave");
    end loop;

    await_completion(WISHBONE_VVCT, 0, 50 ms);
    await_completion(I2C_VVCT, 6, 50 ms);
  end procedure transmit_multi_byte_from_vvc_to_i2c_master_dut_10_bit_addressing;

  procedure master_dut_to_vvc_read_virtual_memory_location(
    signal   WISHBONE_VVCT : inout bitvis_vip_wishbone.td_target_support_pkg.t_vvc_target_record;
    signal   I2C_VVCT      : inout bitvis_vip_i2c.td_target_support_pkg.t_vvc_target_record;
    constant data          : in t_byte_array
  ) is
  begin
    i2c_slave_check(I2C_VVCT, 2, std_logic_vector'(x"55"), "Check virtual memory address");
    -- We set the address here to be 0b1010101 so we need to set 0xAA in the transmit register (reg address 0x3) since LSB must be '0' for a write to slave.
    wishbone_write(WISHBONE_VVCT, 0, x"3", x"AA", "Setting address to be x55 and setting RW bit to 0");
    wishbone_write(WISHBONE_VVCT, 0, x"4", x"90", "Setting STA and WR bit in command reg");
    await_completion(WISHBONE_VVCT, 0, 50 ms); -- Waiting for address and RW bit to be set in I2C master DUT
    poll_i2c_master_dut_status_register(WISHBONE_VVCT, "0-----0-"); -- Polling for the RXack bit to be set and the TIP bit to be low, i.e., the I2C slave BFM has returned ACK on address
    wishbone_write(WISHBONE_VVCT, 0, x"3", std_logic_vector'(x"55"), "Writing virtual memory address " & to_string(std_logic_vector'(x"55")) & " to transmit register.");
    wishbone_write(WISHBONE_VVCT, 0, x"4", x"10", "Setting Wr bit in command reg"); -- write virtual address on I2C.
    await_completion(WISHBONE_VVCT, 0, 50 ms);
    poll_i2c_master_dut_status_register(WISHBONE_VVCT, "0-----0-"); -- Polling for the RXack bit to be set and the TIP bit to be low
    await_completion(WISHBONE_VVCT, 0, 50 ms);

    -- Now the virtual memory address has been received.
    -- The master shall now generate a repeated start condition and expect to receive from the slave
    i2c_slave_transmit(I2C_VVCT, 2, data, "Transmit data from I2C slave VVC");
    wishbone_write(WISHBONE_VVCT, 0, x"3", x"AB", "Setting address to be x55 and setting RW bit to Read ('1')");
    wishbone_write(WISHBONE_VVCT, 0, x"4", x"90", "Setting STA and WR bit in command reg");
    await_completion(WISHBONE_VVCT, 0, 50 ms); -- Waiting for address and RD bit to be set in I2C master DUT

    -- Polling for the RXack bit to be set and the TIP bit to be low, i.e.,
    -- the I2C slave VVC has returned ACK after receiving address from master DUT
    poll_i2c_master_dut_status_register(WISHBONE_VVCT, "0-----0-");

    for i in 0 to data'length - 1 loop
      if i < data'length - 1 then
        wishbone_write(WISHBONE_VVCT, 0, x"4", x"20", "Setting RD and ACK bit in command reg");
      else                              -- final byte, generate stop condition afterwards
        -- Nack to let slave know this was the last byte that the master will accept
        wishbone_write(WISHBONE_VVCT, 0, x"4", x"68", "Setting STO, RD and NACK bit in command reg");
      end if;

      await_completion(WISHBONE_VVCT, 0, 50 ms);
      poll_i2c_master_dut_status_register(WISHBONE_VVCT, "------0-"); -- Polling for the TIP bit to be low

      -- Check data
      wishbone_check(WISHBONE_VVCT, 0, x"3", data(i), "Checking data received from I2C VVC Slave");
    end loop;

    await_completion(WISHBONE_VVCT, 0, 50 ms);
    await_completion(I2C_VVCT, 2, 50 ms);
  end procedure master_dut_to_vvc_read_virtual_memory_location;

  procedure transmit_single_byte_from_vvc_to_i2c_slave_dut(
    signal   SBI_VVCT : inout bitvis_vip_sbi.td_target_support_pkg.t_vvc_target_record;
    signal   I2C_VVCT : inout bitvis_vip_i2c.td_target_support_pkg.t_vvc_target_record;
    constant data     : in std_logic_vector(7 downto 0)
  ) is
  begin
    i2c_master_transmit(I2C_VVCT, 3, C_I2C_SLAVE_DUT_ADDR_1, data, "Transmit data to I2C slave");
    await_completion(I2C_VVCT, 3, 50 ms);
    sbi_check(SBI_VVCT, 0, C_I2C_SLAVE_DUT_ADDR_1, data, "Checking data that was just written via I2C");
    await_completion(SBI_VVCT, 0, 50 us);
  end procedure transmit_single_byte_from_vvc_to_i2c_slave_dut;

  procedure transmit_multi_byte_from_vvc_to_i2c_slave_dut(
    signal   SBI_VVCT   : inout bitvis_vip_sbi.td_target_support_pkg.t_vvc_target_record;
    signal   I2C_VVCT   : inout bitvis_vip_i2c.td_target_support_pkg.t_vvc_target_record;
    constant byte_array : in t_byte_array
  ) is
  begin
    i2c_master_transmit(I2C_VVCT, 3, C_I2C_SLAVE_DUT_ADDR_1, byte_array, "Transmit data to I2C slave");
    for i in byte_array'range loop
      sbi_poll_until(SBI_VVCT, 0, C_I2C_SLAVE_DUT_ADDR_1, byte_array(i), "Checking data that was just written via I2C", 10000, 10 ms);
    end loop;
    await_completion(I2C_VVCT, 3, 50 ms);
    await_completion(SBI_VVCT, 0, 50 us);
  end procedure transmit_multi_byte_from_vvc_to_i2c_slave_dut;

  procedure transmit_single_byte_from_i2c_slave_dut_to_vvc(
    signal   SBI_VVCT : inout bitvis_vip_sbi.td_target_support_pkg.t_vvc_target_record;
    signal   I2C_VVCT : inout bitvis_vip_i2c.td_target_support_pkg.t_vvc_target_record;
    constant data     : in std_logic_vector(7 downto 0)
  ) is
  begin
    sbi_write(SBI_VVCT, 0, C_I2C_SLAVE_DUT_ADDR_1, data, "Writing data that shall be transmitted via I2C.");
    await_completion(SBI_VVCT, 0, 50 us);
    i2c_master_check(I2C_VVCT, 3, C_I2C_SLAVE_DUT_ADDR_1, data, "Check data from I2C slave");
    await_completion(I2C_VVCT, 3, 50 ms);
  end procedure transmit_single_byte_from_i2c_slave_dut_to_vvc;

  procedure transmit_multi_byte_from_i2c_slave_dut_to_vvc(
    signal   SBI_VVCT   : inout bitvis_vip_sbi.td_target_support_pkg.t_vvc_target_record;
    signal   I2C_VVCT   : inout bitvis_vip_i2c.td_target_support_pkg.t_vvc_target_record;
    constant byte_array : in t_byte_array
  ) is
  begin
    for i in byte_array'range loop
      sbi_write(SBI_VVCT, 0, C_I2C_SLAVE_DUT_ADDR_1, byte_array(i), "Writing data that shall be transmitted via I2C.");
    end loop;

    i2c_master_check(I2C_VVCT, 3, C_I2C_SLAVE_DUT_ADDR_1, byte_array, "Receive data from I2C slave");
    await_completion(I2C_VVCT, 3, 50 ms);
    await_completion(SBI_VVCT, 0, 50 us);
  end procedure transmit_multi_byte_from_i2c_slave_dut_to_vvc;

  procedure transmit_random_data_from_vvc_master_to_multiple_slave_duts(
    signal SBI_VVCT : inout bitvis_vip_sbi.td_target_support_pkg.t_vvc_target_record;
    signal I2C_VVCT : inout bitvis_vip_i2c.td_target_support_pkg.t_vvc_target_record
  ) is
    variable v_data_1 : std_logic_vector(7 downto 0);
    variable v_data_2 : std_logic_vector(7 downto 0);
    variable v_data_3 : std_logic_vector(7 downto 0);
    variable v_data_4 : std_logic_vector(7 downto 0);
  begin
    for i in 1 to 10 loop
      v_data_1 := random(8);
      v_data_2 := random(8);
      v_data_3 := random(8);
      v_data_4 := random(8);
      i2c_master_transmit(I2C_VVCT, 3, C_I2C_SLAVE_DUT_ADDR_1, v_data_1, "Transmit data to I2C slave");
      i2c_master_transmit(I2C_VVCT, 3, C_I2C_SLAVE_DUT_ADDR_2, v_data_2, "Transmit data to I2C slave");
      i2c_master_transmit(I2C_VVCT, 3, C_I2C_SLAVE_DUT_ADDR_3, v_data_3, "Transmit data to I2C slave");
      i2c_master_transmit(I2C_VVCT, 3, C_I2C_SLAVE_DUT_ADDR_4, v_data_4, "Transmit data to I2C slave");
      await_completion(I2C_VVCT, 3, 50 ms);
      sbi_check(SBI_VVCT, 0, C_I2C_SLAVE_DUT_ADDR_1, v_data_1, "Checking data that was just written via I2C");
      sbi_check(SBI_VVCT, 0, C_I2C_SLAVE_DUT_ADDR_2, v_data_2, "Checking data that was just written via I2C");
      sbi_check(SBI_VVCT, 0, C_I2C_SLAVE_DUT_ADDR_3, v_data_3, "Checking data that was just written via I2C");
      sbi_check(SBI_VVCT, 0, C_I2C_SLAVE_DUT_ADDR_4, v_data_4, "Checking data that was just written via I2C");
      await_completion(SBI_VVCT, 0, 50 us);
    end loop;
  end procedure transmit_random_data_from_vvc_master_to_multiple_slave_duts;

  procedure transmit_random_data_from_multiple_slave_duts_to_vvc_master(
    signal SBI_VVCT : inout bitvis_vip_sbi.td_target_support_pkg.t_vvc_target_record;
    signal I2C_VVCT : inout bitvis_vip_i2c.td_target_support_pkg.t_vvc_target_record
  ) is
    variable v_data_1 : std_logic_vector(7 downto 0);
    variable v_data_2 : std_logic_vector(7 downto 0);
    variable v_data_3 : std_logic_vector(7 downto 0);
    variable v_data_4 : std_logic_vector(7 downto 0);
  begin
    for i in 1 to 10 loop
      v_data_1 := random(8);
      v_data_2 := random(8);
      v_data_3 := random(8);
      v_data_4 := random(8);
      i2c_master_check(I2C_VVCT, 3, C_I2C_SLAVE_DUT_ADDR_1, v_data_1, "Check data from I2C slave");
      i2c_master_check(I2C_VVCT, 3, C_I2C_SLAVE_DUT_ADDR_2, v_data_2, "Check data from I2C slave");
      i2c_master_check(I2C_VVCT, 3, C_I2C_SLAVE_DUT_ADDR_3, v_data_3, "Check data from I2C slave");
      i2c_master_check(I2C_VVCT, 3, C_I2C_SLAVE_DUT_ADDR_4, v_data_4, "Check data from I2C slave");
      sbi_write(SBI_VVCT, 0, C_I2C_SLAVE_DUT_ADDR_1, v_data_1, "Write data that shall be transmitted via I2C");
      sbi_write(SBI_VVCT, 0, C_I2C_SLAVE_DUT_ADDR_2, v_data_2, "Write data that shall be transmitted via I2C");
      sbi_write(SBI_VVCT, 0, C_I2C_SLAVE_DUT_ADDR_3, v_data_3, "Write data that shall be transmitted via I2C");
      sbi_write(SBI_VVCT, 0, C_I2C_SLAVE_DUT_ADDR_4, v_data_4, "Write data that shall be transmitted via I2C");
      await_completion(SBI_VVCT, 0, 50 us);
      await_completion(I2C_VVCT, 3, 50 ms);
    end loop;
  end procedure transmit_random_data_from_multiple_slave_duts_to_vvc_master;

  procedure transmit_random_data_from_vvc_master_to_multiple_slave_duts_without_stop_in_between(
    signal SBI_VVCT : inout bitvis_vip_sbi.td_target_support_pkg.t_vvc_target_record;
    signal I2C_VVCT : inout bitvis_vip_i2c.td_target_support_pkg.t_vvc_target_record
  ) is
    variable v_data_1 : std_logic_vector(7 downto 0);
    variable v_data_2 : std_logic_vector(7 downto 0);
    variable v_data_3 : std_logic_vector(7 downto 0);
    variable v_data_4 : std_logic_vector(7 downto 0);
  begin
    for i in 1 to 10 loop
      v_data_1 := random(8);
      v_data_2 := random(8);
      v_data_3 := random(8);
      v_data_4 := random(8);
      i2c_master_transmit(I2C_VVCT, 3, C_I2C_SLAVE_DUT_ADDR_1, v_data_1, "Transmit data to I2C slave", HOLD_LINE_AFTER_TRANSFER); -- No stop cond
      i2c_master_transmit(I2C_VVCT, 3, C_I2C_SLAVE_DUT_ADDR_2, v_data_2, "Transmit data to I2C slave", HOLD_LINE_AFTER_TRANSFER); -- No stop cond
      i2c_master_transmit(I2C_VVCT, 3, C_I2C_SLAVE_DUT_ADDR_3, v_data_3, "Transmit data to I2C slave", HOLD_LINE_AFTER_TRANSFER); -- No stop cond
      if i < 10 then
        i2c_master_transmit(I2C_VVCT, 3, C_I2C_SLAVE_DUT_ADDR_4, v_data_4, "Transmit data to I2C slave", HOLD_LINE_AFTER_TRANSFER); -- No stop cond
      else
        i2c_master_transmit(I2C_VVCT, 3, C_I2C_SLAVE_DUT_ADDR_4, v_data_4, "Transmit data to I2C slave", RELEASE_LINE_AFTER_TRANSFER); -- Stop cond
      end if;
      await_completion(I2C_VVCT, 3, 50 ms);
      sbi_check(SBI_VVCT, 0, C_I2C_SLAVE_DUT_ADDR_1, v_data_1, "Checking data that was just written via I2C");
      sbi_check(SBI_VVCT, 0, C_I2C_SLAVE_DUT_ADDR_2, v_data_2, "Checking data that was just written via I2C");
      sbi_check(SBI_VVCT, 0, C_I2C_SLAVE_DUT_ADDR_3, v_data_3, "Checking data that was just written via I2C");
      sbi_check(SBI_VVCT, 0, C_I2C_SLAVE_DUT_ADDR_4, v_data_4, "Checking data that was just written via I2C");
      await_completion(SBI_VVCT, 0, 50 us);
    end loop;
  end procedure transmit_random_data_from_vvc_master_to_multiple_slave_duts_without_stop_in_between;

  procedure vvc_to_slave_dut_read_virtual_memory_location(
    signal   SBI_VVCT   : inout bitvis_vip_sbi.td_target_support_pkg.t_vvc_target_record;
    signal   I2C_VVCT   : inout bitvis_vip_i2c.td_target_support_pkg.t_vvc_target_record;
    constant byte_array : in t_byte_array
  ) is
  begin
    -- Read virtual memory address x55 from slave 1
    i2c_master_transmit(I2C_VVCT, 3, C_I2C_SLAVE_DUT_ADDR_1, std_logic_vector'(x"55"), "Transmit virtual memory address to I2C slave", HOLD_LINE_AFTER_TRANSFER);
    await_completion(I2C_VVCT, 3, 50 ms);
    sbi_check(SBI_VVCT, 0, C_I2C_SLAVE_DUT_ADDR_1, std_logic_vector'(x"55"), "Checking virtual memory address received on I2C");
    for i in 0 to byte_array'length - 1 loop
      sbi_write(SBI_VVCT, 0, C_I2C_SLAVE_DUT_ADDR_1, byte_array(i), "Write virtual memory data that shall be transmitted via I2C");
    end loop;
    i2c_master_check(I2C_VVCT, 3, C_I2C_SLAVE_DUT_ADDR_1, byte_array, "Check virtual memory data from I2C slave.", HOLD_LINE_AFTER_TRANSFER);
    await_completion(I2C_VVCT, 3, 50 ms);

    -- Read virtual memory address xAA from slave 2
    i2c_master_transmit(I2C_VVCT, 3, C_I2C_SLAVE_DUT_ADDR_2, std_logic_vector'(x"AA"), "Transmit virtual memory address to I2C slave", HOLD_LINE_AFTER_TRANSFER);
    await_completion(I2C_VVCT, 3, 50 ms);
    sbi_check(SBI_VVCT, 0, C_I2C_SLAVE_DUT_ADDR_2, std_logic_vector'(x"AA"), "Checking virtual memory address received on I2C");
    for i in 0 to byte_array'length - 1 loop
      sbi_write(SBI_VVCT, 0, C_I2C_SLAVE_DUT_ADDR_2, byte_array(i), "Write virtual memory data that shall be transmitted via I2C");
    end loop;
    i2c_master_check(I2C_VVCT, 3, C_I2C_SLAVE_DUT_ADDR_2, byte_array, "Check virtual memory data from I2C slave.", RELEASE_LINE_AFTER_TRANSFER); -- Stop cond
    await_completion(I2C_VVCT, 3, 50 ms);

    -- Read virtual memory address x55 from slave 3
    i2c_master_transmit(I2C_VVCT, 3, C_I2C_SLAVE_DUT_ADDR_3, std_logic_vector'(x"55"), "Transmit virtual memory address to I2C slave", HOLD_LINE_AFTER_TRANSFER);
    await_completion(I2C_VVCT, 3, 50 ms);
    sbi_check(SBI_VVCT, 0, C_I2C_SLAVE_DUT_ADDR_3, std_logic_vector'(x"55"), "Checking virtual memory address received on I2C");
    for i in 0 to byte_array'length - 1 loop
      sbi_write(SBI_VVCT, 0, C_I2C_SLAVE_DUT_ADDR_3, byte_array(i), "Write virtual memory data that shall be transmitted via I2C");
    end loop;
    i2c_master_check(I2C_VVCT, 3, C_I2C_SLAVE_DUT_ADDR_3, byte_array, "Check virtual memory data from I2C slave.", HOLD_LINE_AFTER_TRANSFER);
    await_completion(I2C_VVCT, 3, 50 ms);

    -- Read virtual memory address xAA from slave 4
    i2c_master_transmit(I2C_VVCT, 3, C_I2C_SLAVE_DUT_ADDR_4, std_logic_vector'(x"AA"), "Transmit virtual memory address to I2C slave", HOLD_LINE_AFTER_TRANSFER);
    await_completion(I2C_VVCT, 3, 50 ms);
    sbi_check(SBI_VVCT, 0, C_I2C_SLAVE_DUT_ADDR_4, std_logic_vector'(x"AA"), "Checking virtual memory address received on I2C");
    for i in 0 to byte_array'length - 1 loop
      sbi_write(SBI_VVCT, 0, C_I2C_SLAVE_DUT_ADDR_4, byte_array(i), "Write virtual memory data that shall be transmitted via I2C");
    end loop;
    i2c_master_check(I2C_VVCT, 3, C_I2C_SLAVE_DUT_ADDR_4, byte_array, "Check virtual memory data from I2C slave.", RELEASE_LINE_AFTER_TRANSFER); -- Stop cond
    await_completion(I2C_VVCT, 3, 50 ms);

    await_completion(SBI_VVCT, 0, 50 us);
    await_completion(I2C_VVCT, 3, 50 ms);
  end procedure vvc_to_slave_dut_read_virtual_memory_location;

begin                                   -- architecture behav

  -----------------------------------------------------------------------------
  -- Instantiate test harness, containing DUT and Executors
  -----------------------------------------------------------------------------
  i_test_harness : entity work.i2c_th
    generic map(GC_CLK_PERIOD                 => C_CLK_PERIOD,
                GC_WISHBONE_DATA_WIDTH        => C_WISHBONE_DATA_WIDTH,
                GC_WISHBONE_ADDR_WIDTH        => C_WISHBONE_ADDR_WIDTH,
                GC_SBI_DATA_WIDTH             => C_SBI_DATA_WIDTH,
                GC_SBI_ADDR_WIDTH             => C_SBI_ADDR_WIDTH,
                GC_I2C_SLAVE_DUT_ADDR_1       => C_I2C_SLAVE_DUT_ADDR_1,
                GC_I2C_SLAVE_DUT_ADDR_2       => C_I2C_SLAVE_DUT_ADDR_2,
                GC_I2C_SLAVE_DUT_ADDR_3       => C_I2C_SLAVE_DUT_ADDR_3,
                GC_I2C_SLAVE_DUT_ADDR_4       => C_I2C_SLAVE_DUT_ADDR_4,
                GC_I2C_BFM_CONFIG_7_BIT_ADDR  => C_I2C_BFM_CONFIG_DEFAULT,
                GC_I2C_BFM_CONFIG_10_BIT_ADDR => C_I2C_BFM_CONFIG_10_BIT_ADDRESSING,
                GC_WISHBONE_MASTER_BFM_CONFIG => C_WISHBONE_MASTER_BFM_CONFIG_DEFAULT,
                GC_SBI_BFM_CONFIG             => C_SBI_BFM_CONFIG)
    port map(arst => arst);

  i_ti_uvvm_engine : entity uvvm_vvc_framework.ti_uvvm_engine;

  ------------------------------------------------
  -- PROCESS: p_main
  ------------------------------------------------
  p_main : process
    variable v_tx_byte           : std_logic_vector(C_I2C_DATA_WIDTH - 1 downto 0);
    variable v_rx_byte           : std_logic_vector(C_I2C_DATA_WIDTH - 1 downto 0);
    variable v_byte_array        : t_byte_array(0 to 4);
    variable v_cmd_idx           : natural;
    variable v_fetch_is_accepted : boolean;
    variable v_result_from_fetch : bitvis_vip_i2c.vvc_cmd_pkg.t_vvc_result; -- t_byte_array(0 to 63);
    variable v_master_byte_array : t_byte_array(0 to 1);
    variable v_slave_byte_array  : t_byte_array(0 to 1);
    variable v_alert_level       : t_alert_level;

    -- DUT ports towards VVC interface. Towards the master VVC: dut_sda, towards the slave VVC: dut_sda and dut_scl.
    constant C_NUM_VVC_SIGNALS : natural := 3;
    alias dut_sda is << signal i_test_harness.i2c_vvc_if_1_sda : std_logic >>;
    alias dut_scl is << signal i_test_harness.i2c_vvc_if_1_scl : std_logic >>;

    -- Toggles all the signals in the VVC interface and checks that the expected alerts are generated
    procedure toggle_vvc_if (
      constant alert_level : in t_alert_level
    ) is
      variable v_num_expected_alerts : natural;
      variable v_rand                : t_rand;
    begin
      -- Number of total expected alerts: (number of signals tested individually + number of signals tested together) x 1 toggle
      if alert_level /= NO_ALERT then
        increment_expected_alerts_and_stop_limit(alert_level, (C_NUM_VVC_SIGNALS + C_NUM_VVC_SIGNALS) * 2);
      end if;
      for i in 0 to C_NUM_VVC_SIGNALS - 1 loop
        -- Force new value
        v_num_expected_alerts := get_alert_counter(alert_level);
        case i is
          when 0 => dut_sda <= force not dut_sda;
                    dut_scl <= force not dut_scl;
          when 1 => dut_sda <= force not dut_sda;
          when 2 => dut_scl <= force not dut_scl;
        end case;
        wait for v_rand.rand(ONLY, (C_LOG_TIME_BASE, C_LOG_TIME_BASE * 5, C_LOG_TIME_BASE * 10)); -- Hold the value a random time
        v_num_expected_alerts := 0 when alert_level = NO_ALERT else
                                 v_num_expected_alerts + C_NUM_VVC_SIGNALS when i = 0 else
                                 v_num_expected_alerts + 2 when i = 1 else                 -- A change in SDA triggers for both master and slave VVC
                                 v_num_expected_alerts + 1;
        check_value(get_alert_counter(alert_level), v_num_expected_alerts, TB_NOTE, "Unwanted activity alert was expected", C_SCOPE, ID_NEVER);
        -- Set back original value
        v_num_expected_alerts := get_alert_counter(alert_level);
        case i is
          when 0 => dut_sda <= release;
                    dut_scl <= release;
          when 1 => dut_sda <= release;
          when 2 => dut_scl <= release;
        end case;
        wait for 0 ns; -- Wait two delta cycles so that the alert is triggered
        wait for 0 ns;
        wait for 0 ns; -- Wait an extra delta cycle so that the value is propagated from the non-record to the record signals
        v_num_expected_alerts := 0 when alert_level = NO_ALERT else
                                 v_num_expected_alerts + C_NUM_VVC_SIGNALS when i = 0 else
                                 v_num_expected_alerts + 2 when i = 1 else                 -- A change in SDA triggers for both master and slave VVC
                                 v_num_expected_alerts + 1;
        wait for 0 ns; -- Wait another cycle to allow signals to propagate before checking them - Needed for Riviera Pro
        check_value(get_alert_counter(alert_level), v_num_expected_alerts, TB_NOTE, "Unwanted activity alert was expected", C_SCOPE, ID_NEVER);
      end loop;
    end procedure;

  begin
    -- To avoid that log files from different test cases (run in separate
    -- simulations) overwrite each other.
    set_log_file_name(GC_TESTCASE & "_Log.txt");
    set_alert_file_name(GC_TESTCASE & "_Alert.txt");

    await_uvvm_initialization(VOID);

    -- Set all appropriate log settings
    disable_log_msg(ID_AWAIT_COMPLETION);
    disable_log_msg(ID_AWAIT_COMPLETION_LIST);
    disable_log_msg(ID_AWAIT_COMPLETION_WAIT);
    disable_log_msg(ID_AWAIT_COMPLETION_END);
    disable_log_msg(ID_UVVM_CMD_ACK);
    disable_log_msg(ID_POS_ACK);
    disable_log_msg(ID_UVVM_CMD_RESULT);

    disable_log_msg(VVC_BROADCAST, ID_CMD_EXECUTOR);
    disable_log_msg(VVC_BROADCAST, ID_CMD_EXECUTOR_WAIT);
    disable_log_msg(VVC_BROADCAST, ID_CMD_INTERPRETER);
    disable_log_msg(VVC_BROADCAST, ID_CMD_INTERPRETER_WAIT);
    disable_log_msg(VVC_BROADCAST, ID_IMMEDIATE_CMD);

    -- Print the configuration to the log
    report_global_ctrl(VOID);
    report_msg_id_panel(VOID);

    log("\rSetting inter-bfm delay");
    shared_i2c_vvc_config(0).inter_bfm_delay.delay_type    := TIME_START2START;
    shared_i2c_vvc_config(0).inter_bfm_delay.delay_in_time := C_I2C_BFM_CONFIG_DEFAULT.i2c_bit_time * 21;
    shared_i2c_vvc_config(1).inter_bfm_delay.delay_type    := TIME_START2START;
    shared_i2c_vvc_config(1).inter_bfm_delay.delay_in_time := C_I2C_BFM_CONFIG_DEFAULT.i2c_bit_time * 21;

    gen_pulse(arst, C_CLK_PERIOD + C_CLK_PERIOD / 4, BLOCKING, "Trigger DUT reset");
    wait for 1 ms;

    config_i2c_master_dut(WISHBONE_VVCT);
    for i in v_byte_array'range loop
      v_byte_array(i) := random(C_I2C_DATA_WIDTH);
    end loop;

    ------------------------------------------------------------------------------------------------------------------------------
    if GC_TESTCASE = "master_to_slave_VVC-to-VVC_7_bit_addressing" then
    ------------------------------------------------------------------------------------------------------------------------------
      shared_i2c_vvc_config(4).unwanted_activity_severity := NO_ALERT; -- Unwanted activity errors in other VVCs using common i2c_vvc_if_1 interface
      shared_i2c_vvc_config(5).unwanted_activity_severity := NO_ALERT; -- Unwanted activity errors in other VVCs using common i2c_vvc_if_1 interface

      -- There is only one interface, so transmission goes from Master to Slave or Slave to Master
      -- Master needs to act first to avoid problem with master pulling down SDA
      -- before slave starts sensing on it, i.e., slave misses the start condition.
      for iteration in 0 to 100 loop
        v_tx_byte := random(C_I2C_DATA_WIDTH);
        if iteration < 10 then
          i2c_slave_receive(I2C_VVCT, 1, 1, "master_to_slave_VVC-to-VVC_7_bit_addressing: Verify by using i2c_slave_receive");
          v_cmd_idx := get_last_received_cmd_idx(I2C_VVCT, 1);
          i2c_master_transmit(I2C_VVCT, 0, C_I2C_BFM_CONFIG_DEFAULT.slave_mode_address, v_tx_byte, "Master to Slave transmit");

          await_completion(I2C_VVCT, 1, 50 ms);
          await_completion(I2C_VVCT, 0, 50 ms);
          fetch_result(I2C_VVCT, 1, NA, v_cmd_idx, v_result_from_fetch, "Fetch result from i2c_slave_receive using the simple fetch_result overload");
          check_value(v_result_from_fetch(0), v_tx_byte, error, "Verifying data", C_TB_SCOPE_DEFAULT);
        else
          i2c_slave_check(I2C_VVCT, 1, v_tx_byte, "master_to_slave_VVC-to-VVC_7_bit_addressing: Verify by using i2c_slave_check");
          i2c_master_transmit(I2C_VVCT, 0, C_I2C_BFM_CONFIG_DEFAULT.slave_mode_address, v_tx_byte, "Master to Slave transmit");
        end if;
      end loop;
      await_completion(I2C_VVCT, 0, 50 ms);
      await_completion(I2C_VVCT, 1, 50 ms);

    ------------------------------------------------------------------------------------------------------------------------------
    elsif GC_TESTCASE = "slave_to_master_VVC-to-VVC_7_bit_addressing" then
    ------------------------------------------------------------------------------------------------------------------------------
      shared_i2c_vvc_config(4).unwanted_activity_severity := NO_ALERT; -- Unwanted activity errors in other VVCs using common i2c_vvc_if_1 interface
      shared_i2c_vvc_config(5).unwanted_activity_severity := NO_ALERT; -- Unwanted activity errors in other VVCs using common i2c_vvc_if_1 interface

      for iteration in 0 to 100 loop
        v_rx_byte := random(C_I2C_DATA_WIDTH);
        -- Master needs to act first to avoid problem with master pulling down SDA
        -- before slave starts sensing on it, i.e., slave misses the start condition.
        i2c_slave_transmit(I2C_VVCT, 1, v_rx_byte, "Slave to Master transmit");
        i2c_master_check(I2C_VVCT, 0, C_I2C_BFM_CONFIG_DEFAULT.slave_mode_address, v_rx_byte, "Slave to Master check");
      end loop;
      await_completion(I2C_VVCT, 1, 50 ms);
      await_completion(I2C_VVCT, 0, 50 ms);

    ------------------------------------------------------------------------------------------------------------------------------
    elsif GC_TESTCASE = "master_to_slave_VVC-to-VVC_10_bit_addressing" then
    ------------------------------------------------------------------------------------------------------------------------------
      shared_i2c_vvc_config(0).unwanted_activity_severity := NO_ALERT; -- Unwanted activity errors in other VVCs using common i2c_vvc_if_1 interface
      shared_i2c_vvc_config(1).unwanted_activity_severity := NO_ALERT; -- Unwanted activity errors in other VVCs using common i2c_vvc_if_1 interface

      -- There is only one interface, so transmission goes from Master to Slave or Slave to Master
      for iteration in 0 to 100 loop
        v_tx_byte := random(C_I2C_DATA_WIDTH);
        -- Master needs to act first to avoid problem with master pulling down SDA
        -- before slave starts sensing on it, i.e., slave misses the start condition.
        i2c_slave_check(I2C_VVCT, 4, v_tx_byte, "Master to Slave check");
        i2c_master_transmit(I2C_VVCT, 5, C_I2C_BFM_CONFIG_10_BIT_ADDRESSING.slave_mode_address, v_tx_byte, "Master to Slave transmit");
      end loop;
      await_completion(I2C_VVCT, 5, 50 ms);
      await_completion(I2C_VVCT, 4, 50 ms);

    ------------------------------------------------------------------------------------------------------------------------------
    elsif GC_TESTCASE = "slave_to_master_VVC-to-VVC_10_bit_addressing" then
    ------------------------------------------------------------------------------------------------------------------------------
      shared_i2c_vvc_config(0).unwanted_activity_severity := NO_ALERT; -- Unwanted activity errors in other VVCs using common i2c_vvc_if_1 interface
      shared_i2c_vvc_config(1).unwanted_activity_severity := NO_ALERT; -- Unwanted activity errors in other VVCs using common i2c_vvc_if_1 interface

      for iteration in 0 to 100 loop
        v_rx_byte := random(C_I2C_DATA_WIDTH);
        -- Master needs to act first to avoid problem with master pulling down SDA
        -- before slave starts sensing on it, i.e., slave misses the start condition.
        i2c_slave_transmit(I2C_VVCT, 4, v_rx_byte, "Slave to Master transmit");
        i2c_master_check(I2C_VVCT, 5, C_I2C_BFM_CONFIG_10_BIT_ADDRESSING.slave_mode_address, v_rx_byte, "Slave to Master check");
      end loop;
      await_completion(I2C_VVCT, 4, 50 ms);
      await_completion(I2C_VVCT, 5, 50 ms);

    ------------------------------------------------------------------------------------------------------------------------------
    elsif GC_TESTCASE = "single-byte_communication_with_master_dut" then
    ------------------------------------------------------------------------------------------------------------------------------
      shared_i2c_vvc_config(3).unwanted_activity_severity := NO_ALERT; -- Unwanted activity errors in other VVCs using common i2c_vvc_if_2 interface
      shared_i2c_vvc_config(6).unwanted_activity_severity := NO_ALERT; -- Unwanted activity errors in other VVCs using common i2c_vvc_if_2 interface

      -- -- **************** Simulation using an OpenCores I2C master **************************
      transmit_single_byte_from_i2c_master_dut_to_vvc(WISHBONE_VVCT, I2C_VVCT, x"55");

      wishbone_read(WISHBONE_VVCT, 0, x"0", "Dummy read which is not fetched, so remaining tests have old elements in the result queue.");
      transmit_single_byte_from_i2c_master_dut_to_vvc(WISHBONE_VVCT, I2C_VVCT, x"AA");

      transmit_single_byte_from_vvc_to_i2c_master_dut(WISHBONE_VVCT, I2C_VVCT, x"55");
      transmit_single_byte_from_vvc_to_i2c_master_dut(WISHBONE_VVCT, I2C_VVCT, x"AA");

      for i in 0 to 10 loop
        v_tx_byte := random(C_I2C_DATA_WIDTH);
        transmit_single_byte_from_i2c_master_dut_to_vvc(WISHBONE_VVCT, I2C_VVCT, v_tx_byte);
      end loop;

      for i in 0 to 10 loop
        v_tx_byte := random(C_I2C_DATA_WIDTH);
        transmit_single_byte_from_vvc_to_i2c_master_dut(WISHBONE_VVCT, I2C_VVCT, v_tx_byte);
      end loop;

    ------------------------------------------------------------------------------------------------------------------------------
    elsif GC_TESTCASE = "single-byte_communication_with_single_slave_dut" then
    ------------------------------------------------------------------------------------------------------------------------------
      shared_i2c_vvc_config(2).unwanted_activity_severity := NO_ALERT; -- Unwanted activity errors in other VVCs using common i2c_vvc_if_2 interface
      shared_i2c_vvc_config(6).unwanted_activity_severity := NO_ALERT; -- Unwanted activity errors in other VVCs using common i2c_vvc_if_2 interface

      -- **************** Simulation using a GitHub I2C slave ***************************
      transmit_single_byte_from_i2c_slave_dut_to_vvc(SBI_VVCT, I2C_VVCT, x"55");
      transmit_single_byte_from_i2c_slave_dut_to_vvc(SBI_VVCT, I2C_VVCT, x"AA");
      wait for C_CLK_PERIOD;            -- let slave rest for a clock cycle
      transmit_single_byte_from_vvc_to_i2c_slave_dut(SBI_VVCT, I2C_VVCT, x"55");
      transmit_single_byte_from_vvc_to_i2c_slave_dut(SBI_VVCT, I2C_VVCT, x"AA");

      for i in 0 to 10 loop
        v_tx_byte := random(C_I2C_DATA_WIDTH);
        transmit_single_byte_from_i2c_slave_dut_to_vvc(SBI_VVCT, I2C_VVCT, v_tx_byte);
      end loop;

      wait for C_CLK_PERIOD;            -- let slave rest for a clock cycle

      for i in 0 to 10 loop
        v_tx_byte := random(C_I2C_DATA_WIDTH);
        transmit_single_byte_from_vvc_to_i2c_slave_dut(SBI_VVCT, I2C_VVCT, v_tx_byte);
      end loop;

    ------------------------------------------------------------------------------------------------------------------------------
    elsif GC_TESTCASE = "single-byte_communication_with_multiple_slave_duts" then
    ------------------------------------------------------------------------------------------------------------------------------
      shared_i2c_vvc_config(2).unwanted_activity_severity := NO_ALERT; -- Unwanted activity errors in other VVCs using common i2c_vvc_if_2 interface
      shared_i2c_vvc_config(6).unwanted_activity_severity := NO_ALERT; -- Unwanted activity errors in other VVCs using common i2c_vvc_if_2 interface

      -- -- *************** Simulation with multiple slaves *******************************
      -- Increment expected warnings by 60 since we are using reserved addresses for the
      -- DUTs
      increment_expected_alerts(warning, 60);

      transmit_random_data_from_vvc_master_to_multiple_slave_duts(SBI_VVCT, I2C_VVCT);
      transmit_random_data_from_multiple_slave_duts_to_vvc_master(SBI_VVCT, I2C_VVCT);

    ------------------------------------------------------------------------------------------------------------------------------
    elsif GC_TESTCASE = "multi-byte_transmit_to_i2c_master_dut" then
    ------------------------------------------------------------------------------------------------------------------------------
      shared_i2c_vvc_config(3).unwanted_activity_severity := NO_ALERT; -- Unwanted activity errors in other VVCs using common i2c_vvc_if_2 interface
      shared_i2c_vvc_config(6).unwanted_activity_severity := NO_ALERT; -- Unwanted activity errors in other VVCs using common i2c_vvc_if_2 interface

      transmit_multi_byte_from_vvc_to_i2c_master_dut(WISHBONE_VVCT, I2C_VVCT, v_byte_array);

    ------------------------------------------------------------------------------------------------------------------------------
    elsif GC_TESTCASE = "multi-byte_receive_from_i2c_master_dut" then
    ------------------------------------------------------------------------------------------------------------------------------
      shared_i2c_vvc_config(3).unwanted_activity_severity := NO_ALERT; -- Unwanted activity errors in other VVCs using common i2c_vvc_if_2 interface
      shared_i2c_vvc_config(6).unwanted_activity_severity := NO_ALERT; -- Unwanted activity errors in other VVCs using common i2c_vvc_if_2 interface

      transmit_multi_byte_from_i2c_master_dut_to_vvc(WISHBONE_VVCT, I2C_VVCT, v_byte_array);

    ------------------------------------------------------------------------------------------------------------------------------
    elsif GC_TESTCASE = "multi-byte_transmit_to_i2c_slave_dut" then
    ------------------------------------------------------------------------------------------------------------------------------
      shared_i2c_vvc_config(2).unwanted_activity_severity := NO_ALERT; -- Unwanted activity errors in other VVCs using common i2c_vvc_if_2 interface
      shared_i2c_vvc_config(6).unwanted_activity_severity := NO_ALERT; -- Unwanted activity errors in other VVCs using common i2c_vvc_if_2 interface

      transmit_multi_byte_from_vvc_to_i2c_slave_dut(SBI_VVCT, I2C_VVCT, v_byte_array);

    ------------------------------------------------------------------------------------------------------------------------------
    elsif GC_TESTCASE = "multi-byte_receive_from_i2c_slave_dut" then
    ------------------------------------------------------------------------------------------------------------------------------
      shared_i2c_vvc_config(2).unwanted_activity_severity := NO_ALERT; -- Unwanted activity errors in other VVCs using common i2c_vvc_if_2 interface
      shared_i2c_vvc_config(6).unwanted_activity_severity := NO_ALERT; -- Unwanted activity errors in other VVCs using common i2c_vvc_if_2 interface

      transmit_multi_byte_from_i2c_slave_dut_to_vvc(SBI_VVCT, I2C_VVCT, v_byte_array);

    ------------------------------------------------------------------------------------------------------------------------------
    elsif GC_TESTCASE = "multi-byte_receive_from_i2c_slave_VVC-to-VVC" then
    ------------------------------------------------------------------------------------------------------------------------------
      shared_i2c_vvc_config(4).unwanted_activity_severity := NO_ALERT; -- Unwanted activity errors in other VVCs using common i2c_vvc_if_1 interface
      shared_i2c_vvc_config(5).unwanted_activity_severity := NO_ALERT; -- Unwanted activity errors in other VVCs using common i2c_vvc_if_1 interface

      -- Need higher inter-bfm delay for multi-byte
      shared_i2c_vvc_config(0).inter_bfm_delay.delay_type    := TIME_START2START;
      shared_i2c_vvc_config(0).inter_bfm_delay.delay_in_time := C_I2C_BFM_CONFIG_DEFAULT.i2c_bit_time * 11 * (v_byte_array'length + 1);
      shared_i2c_vvc_config(1).inter_bfm_delay.delay_type    := TIME_START2START;
      shared_i2c_vvc_config(1).inter_bfm_delay.delay_in_time := C_I2C_BFM_CONFIG_DEFAULT.i2c_bit_time * 11 * (v_byte_array'length + 1);

      i2c_slave_transmit(I2C_VVCT, 1, v_byte_array, "Slave to Master transmit");
      i2c_master_check(I2C_VVCT, 0, C_I2C_BFM_CONFIG_DEFAULT.slave_mode_address, v_byte_array, "Slave to Master check");
      await_completion(I2C_VVCT, 1, 50 ms);
      await_completion(I2C_VVCT, 0, 50 ms);

    ------------------------------------------------------------------------------------------------------------------------------
    elsif GC_TESTCASE = "multi-byte_transaction_with_i2c_master_dut_with_repeated_start_conditions" then
    ------------------------------------------------------------------------------------------------------------------------------
      shared_i2c_vvc_config(3).unwanted_activity_severity := NO_ALERT; -- Unwanted activity errors in other VVCs using common i2c_vvc_if_2 interface
      shared_i2c_vvc_config(6).unwanted_activity_severity := NO_ALERT; -- Unwanted activity errors in other VVCs using common i2c_vvc_if_2 interface

      -- master dut writes to a slave with a data byte. We pretend that the data byte is an address for a register inside our virtual slave.
      -- no stop condition is generated.
      -- The master then requests data from the slave at that same address.
      -- the slave returns an array of data bytes from the register.
      -- the master generates a stop condition
      master_dut_to_vvc_read_virtual_memory_location(WISHBONE_VVCT, I2C_VVCT, v_byte_array);

    ------------------------------------------------------------------------------------------------------------------------------
    elsif GC_TESTCASE = "single-byte_communication_with_multiple_slave_duts_without_stop_condition_in_between" then
    ------------------------------------------------------------------------------------------------------------------------------
      shared_i2c_vvc_config(2).unwanted_activity_severity := NO_ALERT; -- Unwanted activity errors in other VVCs using common i2c_vvc_if_2 interface
      shared_i2c_vvc_config(6).unwanted_activity_severity := NO_ALERT; -- Unwanted activity errors in other VVCs using common i2c_vvc_if_2 interface

      -- Increment expected warnings by 30 since we are using reserved addresses for the
      -- DUTs
      increment_expected_alerts(warning, 36);
      transmit_random_data_from_vvc_master_to_multiple_slave_duts_without_stop_in_between(SBI_VVCT, I2C_VVCT);
      vvc_to_slave_dut_read_virtual_memory_location(SBI_VVCT, I2C_VVCT, v_byte_array);

    ------------------------------------------------------------------------------------------------------------------------------
    elsif GC_TESTCASE = "multi-byte_transmit_to_i2c_master_dut_10_bit_addressing" then
    ------------------------------------------------------------------------------------------------------------------------------
      shared_i2c_vvc_config(2).unwanted_activity_severity := NO_ALERT; -- Unwanted activity errors in other VVCs using common i2c_vvc_if_2 interface
      shared_i2c_vvc_config(3).unwanted_activity_severity := NO_ALERT; -- Unwanted activity errors in other VVCs using common i2c_vvc_if_2 interface

      transmit_multi_byte_from_vvc_to_i2c_master_dut_10_bit_addressing(WISHBONE_VVCT, I2C_VVCT, v_byte_array);

    ------------------------------------------------------------------------------------------------------------------------------
    elsif GC_TESTCASE = "multi-byte_receive_from_i2c_master_dut_10_bit_addressing" then
    ------------------------------------------------------------------------------------------------------------------------------
      shared_i2c_vvc_config(2).unwanted_activity_severity := NO_ALERT; -- Unwanted activity errors in other VVCs using common i2c_vvc_if_2 interface
      shared_i2c_vvc_config(3).unwanted_activity_severity := NO_ALERT; -- Unwanted activity errors in other VVCs using common i2c_vvc_if_2 interface

      transmit_multi_byte_from_i2c_master_dut_to_vvc_10_bit_addressing(WISHBONE_VVCT, I2C_VVCT, v_byte_array);

    ------------------------------------------------------------------------------------------------------------------------------
    elsif GC_TESTCASE = "receive_and_fetch_result" then
    ------------------------------------------------------------------------------------------------------------------------------
      shared_i2c_vvc_config(4).unwanted_activity_severity := NO_ALERT; -- Unwanted activity errors in other VVCs using common i2c_vvc_if_1 interface
      shared_i2c_vvc_config(5).unwanted_activity_severity := NO_ALERT; -- Unwanted activity errors in other VVCs using common i2c_vvc_if_1 interface

      -- Need higher inter-bfm delay for multi-byte
      shared_i2c_vvc_config(0).inter_bfm_delay.delay_type    := TIME_START2START;
      shared_i2c_vvc_config(0).inter_bfm_delay.delay_in_time := C_I2C_BFM_CONFIG_DEFAULT.i2c_bit_time * 11 * (v_byte_array'length + 1);
      shared_i2c_vvc_config(1).inter_bfm_delay.delay_type    := TIME_START2START;
      shared_i2c_vvc_config(1).inter_bfm_delay.delay_in_time := C_I2C_BFM_CONFIG_DEFAULT.i2c_bit_time * 11 * (v_byte_array'length + 1);

      i2c_slave_transmit(I2C_VVCT, 1, v_byte_array, "Slave to Master transmit");
      i2c_master_receive(I2C_VVCT, 0, C_I2C_BFM_CONFIG_DEFAULT.slave_mode_address, v_byte_array'length, "Slave to Master check");
      v_cmd_idx := get_last_received_cmd_idx(I2C_VVCT, 0);

      await_completion(I2C_VVCT, 1, 50 ms);
      await_completion(I2C_VVCT, 0, 50 ms);

      fetch_result(I2C_VVCT, 0, NA, v_cmd_idx, v_result_from_fetch, "Fetch result from i2c_master_receive using the simple fetch_result overload");
      check_value(v_result_from_fetch(v_byte_array'range) = v_byte_array, error, "Verifying data", C_TB_SCOPE_DEFAULT);

      increment_expected_alerts(tb_warning, 1);
      fetch_result(I2C_VVCT, 0, NA, 14, v_result_from_fetch, v_fetch_is_accepted); -- will trigger tb_warning since cmd_idx has not been executed yet
      check_value(not v_fetch_is_accepted, error, "Verifying fetch is not accepted", C_TB_SCOPE_DEFAULT);

    ------------------------------------------------------------------------------------------------------------------------------
    elsif GC_TESTCASE = "multi-byte-send-and-receive-with-restart" then
    ------------------------------------------------------------------------------------------------------------------------------
      shared_i2c_vvc_config(4).unwanted_activity_severity := NO_ALERT; -- Unwanted activity errors in other VVCs using common i2c_vvc_if_1 interface
      shared_i2c_vvc_config(5).unwanted_activity_severity := NO_ALERT; -- Unwanted activity errors in other VVCs using common i2c_vvc_if_1 interface

      log(ID_LOG_HDR, "Checking multi-byte read/write between master and slave with restart condition", C_TB_SCOPE_DEFAULT);
      -- Need higher inter-bfm delay for multi-byte
      shared_i2c_vvc_config(0).inter_bfm_delay.delay_type := NO_DELAY;
      shared_i2c_vvc_config(1).inter_bfm_delay.delay_type := NO_DELAY;

      -- Set up random data
      v_master_byte_array(0) := random(8);
      v_master_byte_array(1) := random(8);
      v_slave_byte_array(0)  := random(8);
      v_slave_byte_array(1)  := random(8);

      -- Set the the master will first send two bytes which will be checked by the slave
      -- The slave will then respond by sending two bytes back to the master. These bytes will be checked by the master VVC.
      i2c_slave_check(I2C_VVCT, 1, v_master_byte_array, "Master to Slave check, two bytes");
      i2c_master_transmit(I2C_VVCT, 0, C_I2C_BFM_CONFIG_DEFAULT.slave_mode_address, v_master_byte_array, "Master to Slave transmit, two bytes", RELEASE_LINE_AFTER_TRANSFER); --false);
      i2c_slave_transmit(I2C_VVCT, 1, v_slave_byte_array, "Slave to Master transmit, two bytes");
      i2c_master_check(I2C_VVCT, 0, C_I2C_BFM_CONFIG_DEFAULT.slave_mode_address, v_slave_byte_array, "Slave to Master check, two bytes", HOLD_LINE_AFTER_TRANSFER);

      -- Await completion
      await_completion(I2C_VVCT, 0, 50 ms);
      await_completion(I2C_VVCT, 1, 50 ms);

    ------------------------------------------------------------------------------------------------------------------------------
    elsif GC_TESTCASE = "master-slave-vvc-quick-command" then
    ------------------------------------------------------------------------------------------------------------------------------
      shared_i2c_vvc_config(4).unwanted_activity_severity := NO_ALERT; -- Unwanted activity errors in other VVCs using common i2c_vvc_if_1 interface
      shared_i2c_vvc_config(5).unwanted_activity_severity := NO_ALERT; -- Unwanted activity errors in other VVCs using common i2c_vvc_if_1 interface

      log(ID_LOG_HDR, "Checking Quick Command between VVCs", C_TB_SCOPE_DEFAULT);
      -- Need higher inter-bfm delay for multi-byte
      shared_i2c_vvc_config(0).inter_bfm_delay.delay_type := NO_DELAY;
      shared_i2c_vvc_config(1).inter_bfm_delay.delay_type := NO_DELAY;

      i2c_slave_check(I2C_VVCT, 1, '0', "Master to Slave check, two bytes");
      i2c_master_quick_command(I2C_VVCT, 0, C_I2C_BFM_CONFIG_DEFAULT.slave_mode_address, "Sending quick command to slave, R/#W=0", '0');
      await_completion(I2C_VVCT, 0, 50 ms);
      await_completion(I2C_VVCT, 1, 50 ms);

      i2c_slave_check(I2C_VVCT, 1, '1', "Master to Slave check, two bytes");
      i2c_master_quick_command(I2C_VVCT, 0, C_I2C_BFM_CONFIG_DEFAULT.slave_mode_address, "Sending quick command to slave, R/#W=0", '1');
      await_completion(I2C_VVCT, 0, 50 ms);
      await_completion(I2C_VVCT, 1, 50 ms);

    ------------------------------------------------------------------------------------------------------------------------------
    elsif GC_TESTCASE = "master_quick_cmd_I2C_7bit_dut_test" then
    ------------------------------------------------------------------------------------------------------------------------------
      shared_i2c_vvc_config(2).unwanted_activity_severity := NO_ALERT; -- Unwanted activity errors in other VVCs using common i2c_vvc_if_2 interface
      shared_i2c_vvc_config(6).unwanted_activity_severity := NO_ALERT; -- Unwanted activity errors in other VVCs using common i2c_vvc_if_2 interface

      log(ID_LOG_HDR, "Checking Quick Command as pinging of slave", C_TB_SCOPE_DEFAULT);

      shared_i2c_vvc_config(0).inter_bfm_delay.delay_type := NO_DELAY;
      shared_i2c_vvc_config(1).inter_bfm_delay.delay_type := NO_DELAY;
      i2c_master_quick_command(I2C_VVCT, 3, C_I2C_SLAVE_DUT_ADDR_1, "Pinging existing I2C slave");
      await_completion(I2C_VVCT, 3, 50 ms);
      wait for 10 * C_CLK_PERIOD;       -- let slave rest for some clock cycles
      i2c_master_quick_command(I2C_VVCT, 3, C_DUMMY_SLAVE_DUT_ADDR, "Pinging nonexistant I2C slave", '0', false);
      await_completion(I2C_VVCT, 3, 50 ms);
      wait for 10 * C_CLK_PERIOD;       -- let slave rest for some clock cycles
      i2c_master_quick_command(I2C_VVCT, 3, C_I2C_SLAVE_DUT_ADDR_1, "Pinging existing I2C slave");
      await_completion(I2C_VVCT, 3, 50 ms);

      log(ID_LOG_HDR, "Checking Quick Command with restart condition", C_TB_SCOPE_DEFAULT);
      wait for 10 * C_CLK_PERIOD;       -- let slave rest for some clock cycles
      i2c_master_quick_command(I2C_VVCT, 3, C_I2C_SLAVE_DUT_ADDR_1, "Pinging existing I2C slave", '0', true, HOLD_LINE_AFTER_TRANSFER);
      i2c_master_quick_command(I2C_VVCT, 3, C_I2C_SLAVE_DUT_ADDR_1, "Pinging existing I2C slave", '0', true, HOLD_LINE_AFTER_TRANSFER);
      i2c_master_quick_command(I2C_VVCT, 3, C_I2C_SLAVE_DUT_ADDR_1, "Pinging existing I2C slave", '0', true, RELEASE_LINE_AFTER_TRANSFER); --false);
      await_completion(I2C_VVCT, 3, 50 ms);

      log(ID_LOG_HDR, "Checking Quick Command with read bit", C_TB_SCOPE_DEFAULT);
      wait for 10 * C_CLK_PERIOD;       -- let slave rest for some clock cycles
      i2c_master_quick_command(I2C_VVCT, 3, C_I2C_SLAVE_DUT_ADDR_1, "Pinging existing I2C slave", '1');
      await_completion(I2C_VVCT, 3, 50 ms);

    ------------------------------------------------------------------------------------------------------------------------------
    elsif GC_TESTCASE = "scoreboard_test" then
    ------------------------------------------------------------------------------------------------------------------------------
      shared_i2c_vvc_config(4).unwanted_activity_severity := NO_ALERT; -- Unwanted activity errors in other VVCs using common i2c_vvc_if_1 interface
      shared_i2c_vvc_config(5).unwanted_activity_severity := NO_ALERT; -- Unwanted activity errors in other VVCs using common i2c_vvc_if_1 interface

      log(ID_LOG_HDR, "Checking internal scoreboard", C_TB_SCOPE_DEFAULT);
      -- Need higher inter-bfm delay for multi-byte
      shared_i2c_vvc_config(0).inter_bfm_delay.delay_type    := TIME_START2START;
      shared_i2c_vvc_config(0).inter_bfm_delay.delay_in_time := C_I2C_BFM_CONFIG_DEFAULT.i2c_bit_time * 11 * (v_byte_array'length + 1);
      shared_i2c_vvc_config(1).inter_bfm_delay.delay_type    := TIME_START2START;
      shared_i2c_vvc_config(1).inter_bfm_delay.delay_in_time := C_I2C_BFM_CONFIG_DEFAULT.i2c_bit_time * 11 * (v_byte_array'length + 1);

      i2c_slave_transmit(I2C_VVCT, 1, v_byte_array, "Slave to Master transmit");
      for i in 0 to v_byte_array'length - 1 loop
        I2C_VVC_SB.add_expected(0, pad_i2c_sb(v_byte_array(i)));
      end loop;
      i2c_master_receive(I2C_VVCT, 0, C_I2C_BFM_CONFIG_DEFAULT.slave_mode_address, v_byte_array'length, TO_SB, "Slave to Master check using SB");
      await_completion(I2C_VVCT, 0, 50 ms);

      i2c_slave_receive(I2C_VVCT, 1, v_byte_array'length, TO_SB, "Master to Slave check using SB");
      i2c_master_transmit(I2C_VVCT, 0, C_I2C_BFM_CONFIG_DEFAULT.slave_mode_address, v_byte_array, "Master to Slave transmit");
      for i in 0 to v_byte_array'length - 1 loop
        I2C_VVC_SB.add_expected(1, pad_i2c_sb(v_byte_array(i)));
      end loop;
      await_completion(I2C_VVCT, 1, 50 ms);

      wait for 1000 ns;
      I2C_VVC_SB.report_counters(ALL_INSTANCES);

    ------------------------------------------------------------------------------------------------------------------------------
    elsif GC_TESTCASE = "test_unwanted_activity" then
    ------------------------------------------------------------------------------------------------------------------------------
      shared_i2c_vvc_config(4).unwanted_activity_severity := NO_ALERT; -- Unwanted activity errors in other VVCs using common i2c_vvc_if_1 interface
      shared_i2c_vvc_config(5).unwanted_activity_severity := NO_ALERT; -- Unwanted activity errors in other VVCs using common i2c_vvc_if_1 interface

      log(ID_LOG_HDR, "Testing Unwanted Activity Detection in VVC", C_SCOPE);
      for i in 0 to 2 loop
        -- Test different alert severity configurations
        if i = 0 then
          v_alert_level := C_I2C_VVC_CONFIG_DEFAULT.unwanted_activity_severity;
        elsif i = 1 then
          v_alert_level := FAILURE;
        else
          v_alert_level := NO_ALERT;
        end if;
        log(ID_SEQUENCER, "Setting unwanted_activity_severity to " & to_upper(to_string(v_alert_level)), C_SCOPE);
        shared_i2c_vvc_config(0).unwanted_activity_severity := v_alert_level;
        shared_i2c_vvc_config(1).unwanted_activity_severity := v_alert_level;

        log(ID_SEQUENCER, "Testing normal data transmission", C_SCOPE);
        v_tx_byte := random(C_I2C_DATA_WIDTH);
        i2c_slave_check(I2C_VVCT, 1, v_tx_byte, "Slave check data");
        i2c_master_transmit(I2C_VVCT, 0, C_I2C_BFM_CONFIG_DEFAULT.slave_mode_address, v_tx_byte, "Master transmit data");
        await_completion(I2C_VVCT, 1, 50 ms);

        v_rx_byte := random(C_I2C_DATA_WIDTH);
        i2c_slave_transmit(I2C_VVCT, 1, v_rx_byte, "Slave transmit data");
        i2c_master_check(I2C_VVCT, 0, C_I2C_BFM_CONFIG_DEFAULT.slave_mode_address, v_rx_byte, "Master check data");
        await_completion(I2C_VVCT, 0, 50 ms);

        -- Test with and without a time gap between await_completion and unexpected data transmission
        if i = 0 then
          log(ID_SEQUENCER, "Wait 100 ns", C_SCOPE);
          wait for 100 ns;
        end if;

        log(ID_SEQUENCER, "Testing unexpected data transmission", C_SCOPE);
        toggle_vvc_if(v_alert_level);
      end loop;

    end if;

    -- ****************** Simulation with multiple slave DUTs and a SLAVE VVC. *************

    -- *************** Simulation with multiple masters ******************************

    -- *************** Simulation with multiple slaves and multiple masters **********

    -- **************** Combination of 10-bit address and 7-bit address on same bus ******

    -----------------------------------------------------------------------------
    -- Ending the simulation
    -----------------------------------------------------------------------------
    wait for 1000 ns;                   -- to allow some time for completion
    report_alert_counters(FINAL);       -- Report final counters and print conclusion for simulation (Success/Fail)
    log(ID_LOG_HDR, "SIMULATION COMPLETED", C_SCOPE);

    -- Finish the simulation
    std.env.stop;
    wait;                               -- to stop completely
  end process p_main;
end architecture behav;
