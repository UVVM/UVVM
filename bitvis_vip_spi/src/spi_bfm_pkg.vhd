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

--=================================================================================================
package spi_bfm_pkg is

  --===============================================================================================
  -- Types and constants for SPI BFMs
  --===============================================================================================
  constant C_SCOPE : string := "SPI BFM";

  type t_spi_if is record
    ss_n : std_logic;                   -- master to slave
    sclk : std_logic;                   -- master to slave
    mosi : std_logic;                   -- master to slave
    miso : std_logic;                   -- slave to master
  end record;

  -- Configuration record to be assigned in the test harness.
  type t_spi_bfm_config is
  record
    CPOL            : std_logic;  -- sclk polarity, i.e. the base value of the clock.
                                  -- If CPOL is '0', the clock will be set to '0' when inactive, i.e., ordinary positive polarity.
    CPHA            : std_logic;  -- sclk phase, i.e. when data is sampled and transmitted w.r.t. sclk.
                                  -- If '0', sampling occurs on the first sclk edge and data is transmitted on the sclk active to idle state.
                                  -- If '1', data is sampled on the second sclk edge and transmitted on sclk idle to active state.
    spi_bit_time    : time;       -- Used in master for dictating sclk period
    ss_n_to_sclk    : time;       --Time from SS active until SCLK active
    sclk_to_ss_n    : time;       -- Last SCLK until SS off
    id_for_bfm      : t_msg_id;   -- The message ID used as a general message ID in the SPI BFM
    id_for_bfm_wait : t_msg_id;   -- The message ID used for logging waits in the SPI BFM
    id_for_bfm_poll : t_msg_id;   -- The message ID used for logging polling in the SPI BFM
  end record;

  constant C_SPI_BFM_CONFIG_DEFAULT : t_spi_bfm_config := (
    CPOL            => '0',
    CPHA            => '0',
    spi_bit_time    => -1 ns,  -- Make sure we notice if we forget to set bit time.
    ss_n_to_sclk    => 20 ns,
    sclk_to_ss_n    => 20 ns,
    id_for_bfm      => ID_BFM,
    id_for_bfm_wait => ID_BFM_WAIT,
    id_for_bfm_poll => ID_BFM_POLL
    );

  --===============================================================================================
  -- BFM procedures
  --===============================================================================================

  ------------------------------------------
  -- init_spi_if_signals
  ------------------------------------------
  -- - This function returns an SPI interface with initialized signals.
  -- - master_mode = true:
  --    - ss_n initialized to 'H'
  --    - if config.CPOL = '1', sclk initialized to 'H',
  --      otherwise sclk initialized to 'L'
  --    - miso and mosi initialized to 'Z'
  -- - master_mode = false:
  --    - all signals initialized to 'Z'
  function init_spi_if_signals (
    constant config      : in t_spi_bfm_config;
    constant master_mode : in boolean := true
    ) return t_spi_if;

  ------------------------------------------
  -- spi_master_transmit_and_receive
  ------------------------------------------
  -- This procedure transmits data 'tx_data' to the SPI slave DUT
  -- and receives 'rx_data' from the SPI slave DUT.
  procedure spi_master_transmit_and_receive (
    constant tx_data                      : in    std_logic_vector;
    variable rx_data                      : out   std_logic_vector;
    constant msg                          : in    string;
    signal sclk                           : inout std_logic;
    signal ss_n                           : inout std_logic;
    signal mosi                           : inout std_logic;
    signal miso                           : inout std_logic;
    constant action_when_transfer_is_done : in    t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
    constant scope                        : in    string                         := C_SCOPE;
    constant msg_id_panel                 : in    t_msg_id_panel                 := shared_msg_id_panel;
    constant config                       : in    t_spi_bfm_config               := C_SPI_BFM_CONFIG_DEFAULT;
    constant ext_proc_call                : in    string                         := ""  -- External proc_call; overwrite if called from other BFM procedure like spi_*_check
    );

  ------------------------------------------
  -- spi_master_transmit_and_receive
  ------------------------------------------
  -- This procedure transmits data 'tx_data' to the SPI slave DUT
  -- and receives 'rx_data' from the SPI slave DUT.
  -- The SPI interface in this procedure is given as a t_spi_if signal record
  procedure spi_master_transmit_and_receive (
    constant tx_data                      : in    std_logic_vector;
    variable rx_data                      : out   std_logic_vector;
    constant msg                          : in    string;
    signal spi_if                         : inout t_spi_if;
    constant action_when_transfer_is_done : in    t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
    constant scope                        : in    string                         := C_SCOPE;
    constant msg_id_panel                 : in    t_msg_id_panel                 := shared_msg_id_panel;
    constant config                       : in    t_spi_bfm_config               := C_SPI_BFM_CONFIG_DEFAULT;
    constant ext_proc_call                : in    string                         := ""  -- External proc_call; overwrite if called from other BFM procedure like spi_*_check
    );

  -- Multi-word
  procedure spi_master_transmit_and_receive (
    constant tx_data                      : in    t_slv_array;
    variable rx_data                      : out   t_slv_array;
    constant msg                          : in    string;
    signal spi_if                         : inout t_spi_if;
    constant action_when_transfer_is_done : in    t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
    constant action_between_words         : in    t_action_between_words         := HOLD_LINE_BETWEEN_WORDS;
    constant scope                        : in    string                         := C_SCOPE;
    constant msg_id_panel                 : in    t_msg_id_panel                 := shared_msg_id_panel;
    constant config                       : in    t_spi_bfm_config               := C_SPI_BFM_CONFIG_DEFAULT;
    constant ext_proc_call                : in    string                         := ""  -- External proc_call; overwrite if called from other BFM procedure like spi_*_check
    );


  ------------------------------------------
  -- spi_master_transmit_and_check
  ------------------------------------------
  -- This procedure ...
  -- The SPI interface in this procedure is given as a t_spi_if signal record
  procedure spi_master_transmit_and_check(
    constant tx_data                      : in    std_logic_vector;
    constant data_exp                     : in    std_logic_vector;
    constant msg                          : in    string;
    signal spi_if                         : inout t_spi_if;
    constant alert_level                  : in    t_alert_level                  := error;
    constant action_when_transfer_is_done : in    t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
    constant scope                        : in    string                         := C_SCOPE;
    constant msg_id_panel                 : in    t_msg_id_panel                 := shared_msg_id_panel;
    constant config                       : in    t_spi_bfm_config               := C_SPI_BFM_CONFIG_DEFAULT
    );

  -- Multi-word
  procedure spi_master_transmit_and_check(
    constant tx_data                      : in    t_slv_array;
    constant data_exp                     : in    t_slv_array;
    constant msg                          : in    string;
    signal spi_if                         : inout t_spi_if;
    constant alert_level                  : in    t_alert_level                  := error;
    constant action_when_transfer_is_done : in    t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
    constant action_between_words         : in    t_action_between_words         := HOLD_LINE_BETWEEN_WORDS;
    constant scope                        : in    string                         := C_SCOPE;
    constant msg_id_panel                 : in    t_msg_id_panel                 := shared_msg_id_panel;
    constant config                       : in    t_spi_bfm_config               := C_SPI_BFM_CONFIG_DEFAULT
    );

  ------------------------------------------
  -- spi_master_transmit
  ------------------------------------------
  -- This procedure transmits data 'tx_data' to the SPI DUT
  -- The SPI interface in this procedure is given as a t_spi_if signal record
  procedure spi_master_transmit(
    constant tx_data                      : in    std_logic_vector;
    constant msg                          : in    string;
    signal spi_if                         : inout t_spi_if;
    constant action_when_transfer_is_done : in    t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
    constant scope                        : in    string                         := C_SCOPE;
    constant msg_id_panel                 : in    t_msg_id_panel                 := shared_msg_id_panel;
    constant config                       : in    t_spi_bfm_config               := C_SPI_BFM_CONFIG_DEFAULT
    );

  -- Multi-word
  procedure spi_master_transmit(
    constant tx_data                      : in    t_slv_array;
    constant msg                          : in    string;
    signal spi_if                         : inout t_spi_if;
    constant action_when_transfer_is_done : in    t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
    constant action_between_words         : in    t_action_between_words         := HOLD_LINE_BETWEEN_WORDS;
    constant scope                        : in    string                         := C_SCOPE;
    constant msg_id_panel                 : in    t_msg_id_panel                 := shared_msg_id_panel;
    constant config                       : in    t_spi_bfm_config               := C_SPI_BFM_CONFIG_DEFAULT
    );

  ------------------------------------------
  -- spi_master_receive
  ------------------------------------------
  -- This procedure receives data 'rx_data' from the SPI DUT
  -- The SPI interface in this procedure is given as a t_spi_if signal record
  procedure spi_master_receive(
    variable rx_data                      : out   std_logic_vector;
    constant msg                          : in    string;
    signal spi_if                         : inout t_spi_if;
    constant action_when_transfer_is_done : in    t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
    constant scope                        : in    string                         := C_SCOPE;
    constant msg_id_panel                 : in    t_msg_id_panel                 := shared_msg_id_panel;
    constant config                       : in    t_spi_bfm_config               := C_SPI_BFM_CONFIG_DEFAULT
    );

  -- Multi-word
  procedure spi_master_receive(
    variable rx_data                      : out   t_slv_array;
    constant msg                          : in    string;
    signal spi_if                         : inout t_spi_if;
    constant action_when_transfer_is_done : in    t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
    constant action_between_words         : in    t_action_between_words         := HOLD_LINE_BETWEEN_WORDS;
    constant scope                        : in    string                         := C_SCOPE;
    constant msg_id_panel                 : in    t_msg_id_panel                 := shared_msg_id_panel;
    constant config                       : in    t_spi_bfm_config               := C_SPI_BFM_CONFIG_DEFAULT
    );


  ------------------------------------------
  -- spi_master_check
  ------------------------------------------
  -- This procedure receives an SPI transaction, and compares the read data
  -- to the expected data in 'data_exp'.
  -- If the read data is inconsistent with the expected data, an alert with
  -- severity 'alert_level' is triggered.
  -- The SPI interface in this procedure is given as a t_spi_if signal record
  procedure spi_master_check(
    constant data_exp                     : in    std_logic_vector;
    constant msg                          : in    string;
    signal spi_if                         : inout t_spi_if;
    constant alert_level                  : in    t_alert_level                  := error;
    constant action_when_transfer_is_done : in    t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
    constant scope                        : in    string                         := C_SCOPE;
    constant msg_id_panel                 : in    t_msg_id_panel                 := shared_msg_id_panel;
    constant config                       : in    t_spi_bfm_config               := C_SPI_BFM_CONFIG_DEFAULT
    );

  -- Multi-word
  procedure spi_master_check(
    constant data_exp                     : in    t_slv_array;
    constant msg                          : in    string;
    signal spi_if                         : inout t_spi_if;
    constant alert_level                  : in    t_alert_level                  := error;
    constant action_when_transfer_is_done : in    t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
    constant action_between_words         : in    t_action_between_words         := HOLD_LINE_BETWEEN_WORDS;
    constant scope                        : in    string                         := C_SCOPE;
    constant msg_id_panel                 : in    t_msg_id_panel                 := shared_msg_id_panel;
    constant config                       : in    t_spi_bfm_config               := C_SPI_BFM_CONFIG_DEFAULT
    );

  ------------------------------------------
  -- spi_slave_transmit_and_receive
  ------------------------------------------
  -- This procedure transmits data 'tx_data' to the SPI master DUT
  -- and receives 'rx_data' from the SPI master DUT.
  procedure spi_slave_transmit_and_receive (
    constant tx_data                : in    std_logic_vector;
    variable rx_data                : out   std_logic_vector;
    constant msg                    : in    string;
    signal sclk                     : inout std_logic;
    signal ss_n                     : inout std_logic;
    signal mosi                     : inout std_logic;
    signal miso                     : inout std_logic;
    constant when_to_start_transfer : in    t_when_to_start_transfer := START_TRANSFER_ON_NEXT_SS;
    constant scope                  : in    string                   := C_SCOPE;
    constant msg_id_panel           : in    t_msg_id_panel           := shared_msg_id_panel;
    constant config                 : in    t_spi_bfm_config         := C_SPI_BFM_CONFIG_DEFAULT;
    constant ext_proc_call          : in    string                   := ""  -- External proc_call; overwrite if called from other BFM procedure like spi_*_check
    );

  ------------------------------------------
  -- spi_slave_transmit_and_receive
  ------------------------------------------
  -- This procedure transmits data 'tx_data' to the SPI master DUT
  -- and receives 'rx_data' from the SPI master DUT.
  -- The SPI interface in this procedure is given as a t_spi_if signal record
  procedure spi_slave_transmit_and_receive (
    constant tx_data                : in    std_logic_vector;
    variable rx_data                : out   std_logic_vector;
    constant msg                    : in    string;
    signal spi_if                   : inout t_spi_if;
    constant when_to_start_transfer : in    t_when_to_start_transfer := START_TRANSFER_ON_NEXT_SS;
    constant scope                  : in    string                   := C_SCOPE;
    constant msg_id_panel           : in    t_msg_id_panel           := shared_msg_id_panel;
    constant config                 : in    t_spi_bfm_config         := C_SPI_BFM_CONFIG_DEFAULT;
    constant ext_proc_call          : in    string                   := ""  -- External proc_call; overwrite if called from other BFM procedure like spi_*_check
    );

  -- Multi-word
  procedure spi_slave_transmit_and_receive (
    constant tx_data                : in    t_slv_array;
    variable rx_data                : out   t_slv_array;
    constant msg                    : in    string;
    signal spi_if                   : inout t_spi_if;
    constant when_to_start_transfer : in    t_when_to_start_transfer := START_TRANSFER_ON_NEXT_SS;
    constant scope                  : in    string                   := C_SCOPE;
    constant msg_id_panel           : in    t_msg_id_panel           := shared_msg_id_panel;
    constant config                 : in    t_spi_bfm_config         := C_SPI_BFM_CONFIG_DEFAULT;
    constant ext_proc_call          : in    string                   := ""  -- External proc_call; overwrite if called from other BFM procedure like spi_*_check
    );

  ------------------------------------------
  -- spi_slave_transmit_and_check
  ------------------------------------------
  -- This procedure ...
  -- The SPI interface in this procedure is given as a t_spi_if signal record
  procedure spi_slave_transmit_and_check(
    constant tx_data                : in    std_logic_vector;
    constant data_exp               : in    std_logic_vector;
    constant msg                    : in    string;
    signal spi_if                   : inout t_spi_if;
    constant alert_level            : in    t_alert_level            := error;
    constant when_to_start_transfer : in    t_when_to_start_transfer := START_TRANSFER_ON_NEXT_SS;
    constant scope                  : in    string                   := C_SCOPE;
    constant msg_id_panel           : in    t_msg_id_panel           := shared_msg_id_panel;
    constant config                 : in    t_spi_bfm_config         := C_SPI_BFM_CONFIG_DEFAULT
    );

  -- Multi-word
  procedure spi_slave_transmit_and_check(
    constant tx_data                : in    t_slv_array;
    constant data_exp               : in    t_slv_array;
    constant msg                    : in    string;
    signal spi_if                   : inout t_spi_if;
    constant alert_level            : in    t_alert_level            := error;
    constant when_to_start_transfer : in    t_when_to_start_transfer := START_TRANSFER_ON_NEXT_SS;
    constant scope                  : in    string                   := C_SCOPE;
    constant msg_id_panel           : in    t_msg_id_panel           := shared_msg_id_panel;
    constant config                 : in    t_spi_bfm_config         := C_SPI_BFM_CONFIG_DEFAULT
    );

  ------------------------------------------
  -- spi_slave_transmit
  ------------------------------------------
  -- This procedure transmits data 'tx_data' to the SPI DUT
  -- The SPI interface in this procedure is given as a t_spi_if signal record
  procedure spi_slave_transmit (
    constant tx_data                : in    std_logic_vector;
    constant msg                    : in    string;
    signal spi_if                   : inout t_spi_if;
    constant when_to_start_transfer : in    t_when_to_start_transfer := START_TRANSFER_ON_NEXT_SS;
    constant scope                  : in    string                   := C_SCOPE;
    constant msg_id_panel           : in    t_msg_id_panel           := shared_msg_id_panel;
    constant config                 : in    t_spi_bfm_config         := C_SPI_BFM_CONFIG_DEFAULT
    );

  -- Multi-word
  procedure spi_slave_transmit (
    constant tx_data                : in    t_slv_array;
    constant msg                    : in    string;
    signal spi_if                   : inout t_spi_if;
    constant when_to_start_transfer : in    t_when_to_start_transfer := START_TRANSFER_ON_NEXT_SS;
    constant scope                  : in    string                   := C_SCOPE;
    constant msg_id_panel           : in    t_msg_id_panel           := shared_msg_id_panel;
    constant config                 : in    t_spi_bfm_config         := C_SPI_BFM_CONFIG_DEFAULT
    );

  ------------------------------------------
  -- spi_slave_receive
  ------------------------------------------
  -- This procedure receives data 'rx_data' from the SPI DUT
  -- The SPI interface in this procedure is given as a t_spi_if signal record
  procedure spi_slave_receive (
    variable rx_data                : out   std_logic_vector;
    constant msg                    : in    string;
    signal spi_if                   : inout t_spi_if;
    constant when_to_start_transfer : in    t_when_to_start_transfer := START_TRANSFER_ON_NEXT_SS;
    constant scope                  : in    string                   := C_SCOPE;
    constant msg_id_panel           : in    t_msg_id_panel           := shared_msg_id_panel;
    constant config                 : in    t_spi_bfm_config         := C_SPI_BFM_CONFIG_DEFAULT
    );

  -- Multi-word
  procedure spi_slave_receive (
    variable rx_data                : out   t_slv_array;
    constant msg                    : in    string;
    signal spi_if                   : inout t_spi_if;
    constant when_to_start_transfer : in    t_when_to_start_transfer := START_TRANSFER_ON_NEXT_SS;
    constant scope                  : in    string                   := C_SCOPE;
    constant msg_id_panel           : in    t_msg_id_panel           := shared_msg_id_panel;
    constant config                 : in    t_spi_bfm_config         := C_SPI_BFM_CONFIG_DEFAULT
    );

  ------------------------------------------
  -- spi_slave_check
  ------------------------------------------
  -- This procedure receives an SPI transaction, and compares the read data
  -- to the expected data in 'data_exp'.
  -- If the read data is inconsistent with the expected data, an alert with
  -- severity 'alert_level' is triggered.
  -- The SPI interface in this procedure is given as a t_spi_if signal record
  procedure spi_slave_check (
    constant data_exp               : in    std_logic_vector;
    constant msg                    : in    string;
    signal spi_if                   : inout t_spi_if;
    constant alert_level            : in    t_alert_level            := error;
    constant when_to_start_transfer : in    t_when_to_start_transfer := START_TRANSFER_ON_NEXT_SS;
    constant scope                  : in    string                   := C_SCOPE;
    constant msg_id_panel           : in    t_msg_id_panel           := shared_msg_id_panel;
    constant config                 : in    t_spi_bfm_config         := C_SPI_BFM_CONFIG_DEFAULT
    );

  -- Multi-word
  procedure spi_slave_check (
    constant data_exp               : in    t_slv_array;
    constant msg                    : in    string;
    signal spi_if                   : inout t_spi_if;
    constant alert_level            : in    t_alert_level            := error;
    constant when_to_start_transfer : in    t_when_to_start_transfer := START_TRANSFER_ON_NEXT_SS;
    constant scope                  : in    string                   := C_SCOPE;
    constant msg_id_panel           : in    t_msg_id_panel           := shared_msg_id_panel;
    constant config                 : in    t_spi_bfm_config         := C_SPI_BFM_CONFIG_DEFAULT
    );

end package spi_bfm_pkg;


--=================================================================================================
--=================================================================================================

package body spi_bfm_pkg is

  ---------------------------------------------------------------------------------
  -- initialize spi to dut signals
  ---------------------------------------------------------------------------------

  function init_spi_if_signals (
    constant config      : in t_spi_bfm_config;
    constant master_mode : in boolean := true
    ) return t_spi_if is
    variable result : t_spi_if;
  begin
    if master_mode then
      result.ss_n := 'H';

      if (config.CPOL) then
        result.sclk := 'H';
      else
        result.sclk := 'L';
      end if;
    else
      result.ss_n := 'Z';
      result.sclk := 'Z';
    end if;

    result.mosi := 'Z';
    result.miso := 'Z';
    return result;
  end function;


  ---------------------------------------------------------------------------------
  -- spi_master_transmit_and_receive
  --
  -- alert if size of tx_data or rx_data doesn't
  -- match with how long ss_n is kept low
  ---------------------------------------------------------------------------------
  procedure spi_master_transmit_and_receive (
    constant tx_data                      : in    std_logic_vector;
    variable rx_data                      : out   std_logic_vector;
    constant msg                          : in    string;
    signal sclk                           : inout std_logic;
    signal ss_n                           : inout std_logic;
    signal mosi                           : inout std_logic;
    signal miso                           : inout std_logic;
    constant action_when_transfer_is_done : in    t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
    constant scope                        : in    string                         := C_SCOPE;
    constant msg_id_panel                 : in    t_msg_id_panel                 := shared_msg_id_panel;
    constant config                       : in    t_spi_bfm_config               := C_SPI_BFM_CONFIG_DEFAULT;
    constant ext_proc_call                : in    string                         := ""  -- External proc_call; overwrite if called from other BFM procedure like spi_*_check
    ) is
    constant local_proc_name                   : string                                      := "spi_master_transmit_and_receive";
    constant local_proc_call                   : string                                      := local_proc_name;
    constant C_ACCESS_SIZE                     : integer                                     := tx_data'length;
    -- Helper variables
    variable v_access_done                     : boolean                                     := false;
    variable v_tx_count                        : integer                                     := 0;
    variable v_tx_data                         : std_logic_vector(tx_data'length-1 downto 0) := tx_data;
    variable v_rx_data                         : std_logic_vector(rx_data'length-1 downto 0) := (others => 'X');
    variable v_rx_count                        : integer                                     := 1;
    variable v_proc_call                       : line;
    variable v_multi_word_transfer_in_progress : boolean                                     := false;

  begin
    -- check whether config.spi_bit_time was set
    check_value(config.spi_bit_time /= -1 ns, TB_ERROR, "SPI Bit time was not set in config. " & add_msg_delimiter(msg), C_SCOPE, ID_NEVER, msg_id_panel);

    if ext_proc_call = "" then
      -- Called directly from sequencer/VVC. Include 'spi_master_transmit_and_receive' when logging
      write(v_proc_call, local_proc_call);
    else
      -- Called from other BFM procedure like spi_*_check. Include 'spi_*_check(..) while executing spi_master_transmit_and_receive' when logging
      write(v_proc_call, ext_proc_call & " while executing " & local_proc_name);
    end if;

    -- Detect if we have an ongoing multi-word transfer
    if ss_n = '0' then
      v_multi_word_transfer_in_progress := true;
    end if;

    sclk <= config.CPOL;
    ss_n <= '0';
    wait for 0 ns;                      -- wait a delta cycle

    if ss_n = '0' then
      -- set MOSI together with SS_N when CPHA=0
      if not config.CPHA then
        mosi       <= v_tx_data(C_ACCESS_SIZE- v_tx_count - 1);
        v_tx_count := v_tx_count + 1;
      end if;

      -- Decide delay before initial SCLK edge
      if not v_multi_word_transfer_in_progress then
        wait for config.ss_n_to_sclk;
      else
        wait for config.spi_bit_time/2;
      end if;
      sclk <= not config.CPOL;

      -- serially shift out v_tx_data to mosi
      -- serially shift in v_rx_data from miso
      while ss_n = '0' and not v_access_done loop

        if not config.CPHA then
          log(ID_BFM, " rx_data(" & to_string(C_ACCESS_SIZE-v_rx_count) & ") " & to_string(miso));
          log(ID_BFM, " v_rx_count=" & to_string(v_rx_count) & " , ");

          v_rx_data(C_ACCESS_SIZE-v_rx_count) := miso;
          wait for config.spi_bit_time/2;
          sclk                                <= config.CPOL;
          mosi                                <= v_tx_data(C_ACCESS_SIZE-v_tx_count-1);

          log(ID_BFM, " tx_data(" & to_string(C_ACCESS_SIZE-v_tx_count-1) & ") " & to_string(mosi));
          log(ID_BFM, " v_tx_count=" & to_string(v_tx_count) & " , ");
        else                            -- config.CPHA
          log(ID_BFM, " tx_data(" & to_string(C_ACCESS_SIZE-v_tx_count-1) & ") " & to_string(mosi));
          log(ID_BFM, " v_tx_count=" & to_string(v_tx_count) & " , ");

          mosi                                <= v_tx_data(C_ACCESS_SIZE-v_tx_count-1);
          wait for config.spi_bit_time/2;
          sclk                                <= config.CPOL;
          v_rx_data(C_ACCESS_SIZE-v_rx_count) := miso;

          log(ID_BFM, " rx_data(" & to_string(C_ACCESS_SIZE-v_rx_count) & ") " & to_string(miso));
          log(ID_BFM, " v_rx_count=" & to_string(v_rx_count) & " , ");
        end if;

        if v_tx_count < C_ACCESS_SIZE-1 then  -- Not done
          v_rx_count := v_rx_count + 1;
          v_tx_count := v_tx_count + 1;
          wait for config.spi_bit_time/2;
          sclk       <= not config.CPOL;
        else                                  -- Final bit
          if not config.CPHA then
            v_rx_count                          := v_rx_count + 1;
            -- Sample Last bit on the second to last edge of SCLK (CPOL=0: last rising. CPOL=1: last falling)
            wait for config.spi_bit_time/2;
            log(ID_BFM, " rx_data(" & to_string(C_ACCESS_SIZE-v_rx_count) & ") " & to_string(miso));
            log(ID_BFM, " v_rx_count=" & to_string(v_rx_count) & " , ");
            v_rx_data(C_ACCESS_SIZE-v_rx_count) := miso;
            sclk                                <= not config.CPOL;
          end if;

          log(ID_BFM, " rx_data(" & to_string(C_ACCESS_SIZE-v_rx_count) & ") " & to_string(miso));
          log(config.id_for_bfm, v_proc_call.all & "=> " & to_string(v_tx_data, HEX, SKIP_LEADING_0, INCL_RADIX) & " completed. " & add_msg_delimiter(msg), scope, msg_id_panel);
          v_access_done := true;
        end if;
      end loop;

      -- Clock the last bit
      if not config.CPHA then
        wait for config.spi_bit_time/2;
        sclk <= config.CPOL;
      end if;

      -- Determine if single- or multi-word transfer
      if action_when_transfer_is_done = RELEASE_LINE_AFTER_TRANSFER then
        wait for config.sclk_to_ss_n;
        mosi <= 'Z';
        ss_n <= '1';
      else  -- action_when_transfer_is_done = HOLD_LINE_AFTER_TRANSFER
        ss_n <= '0';
      end if;
      wait for 0 ns;                    -- delta cycle

      if (v_tx_count /= C_ACCESS_SIZE-1) or (v_rx_count /= C_ACCESS_SIZE) then
        alert(note, " v_tx_count /= C_ACCESS_SIZE-1 or v_rx_count /= C_ACCESS_SIZE then");
        alert(note, to_string(v_tx_count) & " /= " & to_string(C_ACCESS_SIZE-1) & " or" &to_string(v_rx_count) & " /= " & to_string(C_ACCESS_SIZE));
        alert(note, local_proc_name & " ss_n not kept low for v_tx_data size duration");
      else
        rx_data := v_rx_data;
      end if;
    else
      alert(error, local_proc_name & " ss_n not low when expected.");
    end if;

    if ext_proc_call = "" then  -- proc_name = "spi_master_transmit_and_receive"
      log(config.id_for_bfm, v_proc_call.all & "=> Transmitted: " & to_string(v_tx_data, HEX, SKIP_LEADING_0, INCL_RADIX) & ". Received: " & to_string(v_rx_data, HEX, SKIP_LEADING_0, INCL_RADIX) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
    end if;
  end procedure;

  -- Single-word
  procedure spi_master_transmit_and_receive (
    constant tx_data                      : in    std_logic_vector;
    variable rx_data                      : out   std_logic_vector;
    constant msg                          : in    string;
    signal spi_if                         : inout t_spi_if;
    constant action_when_transfer_is_done : in    t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
    constant scope                        : in    string                         := C_SCOPE;
    constant msg_id_panel                 : in    t_msg_id_panel                 := shared_msg_id_panel;
    constant config                       : in    t_spi_bfm_config               := C_SPI_BFM_CONFIG_DEFAULT;
    constant ext_proc_call                : in    string                         := ""  -- External proc_call; overwrite if called from other BFM procedure like spi_*_check
    ) is
  begin
    spi_master_transmit_and_receive(tx_data, rx_data, msg,
                                    spi_if.sclk, spi_if.ss_n, spi_if.mosi, spi_if.miso,
                                    action_when_transfer_is_done, scope, msg_id_panel, config, ext_proc_call);
  end procedure;

  -- Multi-word
  procedure spi_master_transmit_and_receive (
    constant tx_data                      : in    t_slv_array;
    variable rx_data                      : out   t_slv_array;
    constant msg                          : in    string;
    signal spi_if                         : inout t_spi_if;
    constant action_when_transfer_is_done : in    t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
    constant action_between_words         : in    t_action_between_words         := HOLD_LINE_BETWEEN_WORDS;
    constant scope                        : in    string                         := C_SCOPE;
    constant msg_id_panel                 : in    t_msg_id_panel                 := shared_msg_id_panel;
    constant config                       : in    t_spi_bfm_config               := C_SPI_BFM_CONFIG_DEFAULT;
    constant ext_proc_call                : in    string                         := ""  -- External proc_call; overwrite if called from other BFM procedure like spi_*_check
    ) is
    variable v_action_when_transfer_is_done : t_action_when_transfer_is_done;  -- between words and after transfer
  begin
    -- Check length of tx_data and rx_data
    if tx_data'length /= rx_data'length then
      alert(error, ext_proc_call & " tx_data and rx_data have different sizes.");
    end if;

    for idx in 0 to (tx_data'length-1) loop
      case action_between_words is
        when RELEASE_LINE_BETWEEN_WORDS =>
          if idx < tx_data'length-1 then
            v_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
          else
            v_action_when_transfer_is_done := action_when_transfer_is_done;
          end if;
        when others =>                  -- HOLD_LINE_BETWEEN_WORDS
          if idx < tx_data'length-1 then
            v_action_when_transfer_is_done := HOLD_LINE_AFTER_TRANSFER;
          else
            v_action_when_transfer_is_done := action_when_transfer_is_done;
          end if;
      end case;
      -- call single-word procedure
      spi_master_transmit_and_receive(tx_data(idx), rx_data(idx), msg, spi_if, v_action_when_transfer_is_done, scope, msg_id_panel, config, ext_proc_call);
    end loop;
  end procedure;

  ---------------------------------------------------------------------------------
  -- spi_master_transmit_and_check
  ---------------------------------------------------------------------------------
  procedure spi_master_transmit_and_check(
    constant tx_data                      : in    std_logic_vector;
    constant data_exp                     : in    std_logic_vector;
    constant msg                          : in    string;
    signal spi_if                         : inout t_spi_if;
    constant alert_level                  : in    t_alert_level                  := error;
    constant action_when_transfer_is_done : in    t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
    constant scope                        : in    string                         := C_SCOPE;
    constant msg_id_panel                 : in    t_msg_id_panel                 := shared_msg_id_panel;
    constant config                       : in    t_spi_bfm_config               := C_SPI_BFM_CONFIG_DEFAULT
    ) is
    constant local_proc_name : string := "spi_master_transmit_and_check";
    constant local_proc_call : string := local_proc_name;
    -- Helper variables
    variable v_rx_data       : std_logic_vector(data_exp'length-1 downto 0);
    variable v_check_ok      : boolean;
  begin
    spi_master_transmit_and_receive(tx_data, v_rx_data, msg, spi_if, action_when_transfer_is_done, scope, msg_id_panel, config, local_proc_call);

    -- Compare values, but ignore any leading zero's if widths are different.
    -- Use ID_NEVER so that check_value method does not log when check is OK,
    -- log it here instead.
    v_check_ok := check_value(v_rx_data, data_exp, alert_level, msg, scope, HEX_BIN_IF_INVALID, SKIP_LEADING_0, ID_NEVER, msg_id_panel, local_proc_call);
    if v_check_ok then
      log(config.id_for_bfm, local_proc_call & "=> OK, read data = " & to_string(v_rx_data, HEX, SKIP_LEADING_0, INCL_RADIX) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
    end if;
  end procedure;

  -- Multi-word
  procedure spi_master_transmit_and_check(
    constant tx_data                      : in    t_slv_array;
    constant data_exp                     : in    t_slv_array;
    constant msg                          : in    string;
    signal spi_if                         : inout t_spi_if;
    constant alert_level                  : in    t_alert_level                  := error;
    constant action_when_transfer_is_done : in    t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
    constant action_between_words         : in    t_action_between_words         := HOLD_LINE_BETWEEN_WORDS;
    constant scope                        : in    string                         := C_SCOPE;
    constant msg_id_panel                 : in    t_msg_id_panel                 := shared_msg_id_panel;
    constant config                       : in    t_spi_bfm_config               := C_SPI_BFM_CONFIG_DEFAULT
    ) is
    constant local_proc_name                : string := "spi_master_transmit_and_check";
    constant local_proc_call                : string := local_proc_name;
    variable v_action_when_transfer_is_done : t_action_when_transfer_is_done;  -- between words and after transfer
  begin
    -- Check length of tx_data and data_exp
    if tx_data'length /= data_exp'length then
      alert(error, local_proc_call & " tx_data and data_exp have different sizes.");
    end if;

    for idx in 0 to (tx_data'length-1) loop
      case action_between_words is
        when RELEASE_LINE_BETWEEN_WORDS =>
          if idx < tx_data'length-1 then
            v_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
          else
            v_action_when_transfer_is_done := action_when_transfer_is_done;
          end if;
        when others =>                  -- HOLD_LINE_BETWEEN_WORDS
          if idx < tx_data'length-1 then
            v_action_when_transfer_is_done := HOLD_LINE_AFTER_TRANSFER;
          else
            v_action_when_transfer_is_done := action_when_transfer_is_done;
          end if;
      end case;
      -- call single-word procedure
      spi_master_transmit_and_check(tx_data(idx), data_exp(idx), msg, spi_if, alert_level, v_action_when_transfer_is_done, scope, msg_id_panel, config);
    end loop;
  end procedure;

  ---------------------------------------------------------------------------------
  -- spi_master_transmit
  ---------------------------------------------------------------------------------
  procedure spi_master_transmit(
    constant tx_data                      : in    std_logic_vector;
    constant msg                          : in    string;
    signal spi_if                         : inout t_spi_if;
    constant action_when_transfer_is_done : in    t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
    constant scope                        : in    string                         := C_SCOPE;
    constant msg_id_panel                 : in    t_msg_id_panel                 := shared_msg_id_panel;
    constant config                       : in    t_spi_bfm_config               := C_SPI_BFM_CONFIG_DEFAULT
    ) is
    constant local_proc_name : string := "spi_master_transmit";
    constant local_proc_call : string := local_proc_name;
    -- Helper variables
    variable v_rx_data       : std_logic_vector(tx_data'length - 1 downto 0);
  begin
    spi_master_transmit_and_receive(tx_data, v_rx_data, msg, spi_if, action_when_transfer_is_done, scope, msg_id_panel, config, local_proc_call);
  end procedure;

  -- Multi-word
  procedure spi_master_transmit(
    constant tx_data                      : in    t_slv_array;
    constant msg                          : in    string;
    signal spi_if                         : inout t_spi_if;
    constant action_when_transfer_is_done : in    t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
    constant action_between_words         : in    t_action_between_words         := HOLD_LINE_BETWEEN_WORDS;
    constant scope                        : in    string                         := C_SCOPE;
    constant msg_id_panel                 : in    t_msg_id_panel                 := shared_msg_id_panel;
    constant config                       : in    t_spi_bfm_config               := C_SPI_BFM_CONFIG_DEFAULT
    ) is
    variable v_action_when_transfer_is_done : t_action_when_transfer_is_done;  -- between words and after transfer
  begin
    for idx in 0 to (tx_data'length-1) loop
      case action_between_words is
        when RELEASE_LINE_BETWEEN_WORDS =>
          if idx < tx_data'length-1 then
            v_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
          else
            v_action_when_transfer_is_done := action_when_transfer_is_done;
          end if;
        when others =>                  -- HOLD_LINE_BETWEEN_WORDS
          if idx < tx_data'length-1 then
            v_action_when_transfer_is_done := HOLD_LINE_AFTER_TRANSFER;
          else
            v_action_when_transfer_is_done := action_when_transfer_is_done;
          end if;
      end case;
      -- call single-word procedure
      spi_master_transmit(tx_data(idx), msg, spi_if, v_action_when_transfer_is_done, scope, msg_id_panel, config);
    end loop;
  end procedure;

  ---------------------------------------------------------------------------------
  -- spi_master_receive
  ---------------------------------------------------------------------------------
  procedure spi_master_receive(
    variable rx_data                      : out   std_logic_vector;
    constant msg                          : in    string;
    signal spi_if                         : inout t_spi_if;
    constant action_when_transfer_is_done : in    t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
    constant scope                        : in    string                         := C_SCOPE;
    constant msg_id_panel                 : in    t_msg_id_panel                 := shared_msg_id_panel;
    constant config                       : in    t_spi_bfm_config               := C_SPI_BFM_CONFIG_DEFAULT
    ) is
    constant local_proc_name : string                                        := "spi_master_receive";
    constant local_proc_call : string                                        := local_proc_name;
    -- Helper variables
    variable v_tx_data       : std_logic_vector(rx_data'length - 1 downto 0) := (others => '0');
  begin
    spi_master_transmit_and_receive(v_tx_data, rx_data, msg, spi_if, action_when_transfer_is_done, scope, msg_id_panel, config, local_proc_call);
  end procedure;

  -- Multi-word
  procedure spi_master_receive(
    variable rx_data                      : out   t_slv_array;
    constant msg                          : in    string;
    signal spi_if                         : inout t_spi_if;
    constant action_when_transfer_is_done : in    t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
    constant action_between_words         : in    t_action_between_words         := HOLD_LINE_BETWEEN_WORDS;
    constant scope                        : in    string                         := C_SCOPE;
    constant msg_id_panel                 : in    t_msg_id_panel                 := shared_msg_id_panel;
    constant config                       : in    t_spi_bfm_config               := C_SPI_BFM_CONFIG_DEFAULT
    ) is
    variable v_action_when_transfer_is_done : t_action_when_transfer_is_done;  -- between words and after transfer
  begin
    for idx in 0 to (rx_data'length-1) loop
      case action_between_words is
        when RELEASE_LINE_BETWEEN_WORDS =>
          if idx < rx_data'length-1 then
            v_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
          else
            v_action_when_transfer_is_done := action_when_transfer_is_done;
          end if;
        when others =>                  -- HOLD_LINE_BETWEEN_WORDS
          if idx < rx_data'length-1 then
            v_action_when_transfer_is_done := HOLD_LINE_AFTER_TRANSFER;
          else
            v_action_when_transfer_is_done := action_when_transfer_is_done;
          end if;
      end case;
      -- call single-word procedure
      spi_master_receive(rx_data(idx), msg, spi_if, v_action_when_transfer_is_done, scope, msg_id_panel, config);
    end loop;
  end procedure;

  ---------------------------------------------------------------------------------
  -- spi_master_check
  ---------------------------------------------------------------------------------
  procedure spi_master_check(
    constant data_exp                     : in    std_logic_vector;
    constant msg                          : in    string;
    signal spi_if                         : inout t_spi_if;
    constant alert_level                  : in    t_alert_level                  := error;
    constant action_when_transfer_is_done : in    t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
    constant scope                        : in    string                         := C_SCOPE;
    constant msg_id_panel                 : in    t_msg_id_panel                 := shared_msg_id_panel;
    constant config                       : in    t_spi_bfm_config               := C_SPI_BFM_CONFIG_DEFAULT
    ) is
    constant local_proc_name : string                                         := "spi_master_check";
    constant local_proc_call : string                                         := local_proc_name;
    -- Helper variables
    variable v_tx_data       : std_logic_vector(data_exp'length - 1 downto 0) := (others => '0');
    variable v_rx_data       : std_logic_vector(data_exp'length-1 downto 0);
    variable v_check_ok      : boolean;
  begin
    spi_master_transmit_and_receive(v_tx_data, v_rx_data, msg, spi_if, action_when_transfer_is_done, scope, msg_id_panel, config);

    -- Compare values, but ignore any leading zero's if widths are different.
    -- Use ID_NEVER so that check_value method does not log when check is OK,
    -- log it here instead.
    v_check_ok := check_value(v_rx_data, data_exp, alert_level, msg, scope, HEX_BIN_IF_INVALID, SKIP_LEADING_0, ID_NEVER, msg_id_panel, local_proc_call);
    if v_check_ok then
      log(config.id_for_bfm, local_proc_call & "=> OK, read data = " & to_string(v_rx_data, HEX, SKIP_LEADING_0, INCL_RADIX) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
    end if;
  end procedure;

  -- Multi-word
  procedure spi_master_check(
    constant data_exp                     : in    t_slv_array;
    constant msg                          : in    string;
    signal spi_if                         : inout t_spi_if;
    constant alert_level                  : in    t_alert_level                  := error;
    constant action_when_transfer_is_done : in    t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
    constant action_between_words         : in    t_action_between_words         := HOLD_LINE_BETWEEN_WORDS;
    constant scope                        : in    string                         := C_SCOPE;
    constant msg_id_panel                 : in    t_msg_id_panel                 := shared_msg_id_panel;
    constant config                       : in    t_spi_bfm_config               := C_SPI_BFM_CONFIG_DEFAULT
    ) is
    variable v_action_when_transfer_is_done : t_action_when_transfer_is_done;  -- between words and after transfer
  begin
    for idx in 0 to (data_exp'length-1) loop
      case action_between_words is
        when RELEASE_LINE_BETWEEN_WORDS =>
          if idx < data_exp'length-1 then
            v_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
          else
            v_action_when_transfer_is_done := action_when_transfer_is_done;
          end if;
        when others =>                  -- HOLD_LINE_BETWEEN_WORDS
          if idx < data_exp'length-1 then
            v_action_when_transfer_is_done := HOLD_LINE_AFTER_TRANSFER;
          else
            v_action_when_transfer_is_done := action_when_transfer_is_done;
          end if;
      end case;
      -- call single-word procedure
      spi_master_check(data_exp(idx), msg, spi_if, alert_level, v_action_when_transfer_is_done, scope, msg_id_panel, config);
    end loop;
  end procedure;


  ---------------------------------------------------------------------------------
  -- spi_slave_transmit_and_receive
  --
  ---------------------------------------------------------------------------------
  procedure spi_slave_transmit_and_receive (
    constant tx_data                : in    std_logic_vector;
    variable rx_data                : out   std_logic_vector;
    constant msg                    : in    string;
    signal sclk                     : inout std_logic;
    signal ss_n                     : inout std_logic;
    signal mosi                     : inout std_logic;
    signal miso                     : inout std_logic;
    constant when_to_start_transfer : in    t_when_to_start_transfer := START_TRANSFER_ON_NEXT_SS;
    constant scope                  : in    string                   := C_SCOPE;
    constant msg_id_panel           : in    t_msg_id_panel           := shared_msg_id_panel;
    constant config                 : in    t_spi_bfm_config         := C_SPI_BFM_CONFIG_DEFAULT;
    constant ext_proc_call          : in    string                   := ""  -- External proc_call; overwrite if called from other BFM procedure like spi_*_check
    ) is
    -- Local_proc_name/call used if called from sequencer or VVC
    constant local_proc_name : string                                      := "spi_slave_transmit_and_receive";
    constant local_proc_call : string                                      := local_proc_name;
    constant C_ACCESS_SIZE   : integer                                     := rx_data'length;
    -- Helper variables
    variable v_rx_data       : std_logic_vector(rx_data'range)             := (others => 'X');
    variable bfm_tx_data     : std_logic_vector(tx_data'length-1 downto 0) := tx_data;
    variable v_access_done   : boolean                                     := false;
    variable v_tx_count      : integer                                     := 0;
    variable v_rx_count      : integer                                     := 1;
    variable v_proc_call     : line;
  begin
    -- check whether config.spi_bit_time was set
    check_value(config.spi_bit_time /= -1 ns, TB_ERROR, "SPI Bit time was not set in config. " & add_msg_delimiter(msg), C_SCOPE, ID_NEVER, msg_id_panel);

    if ext_proc_call = "" then
      -- Called directly from sequencer/VVC. Include 'spi_slave_receive...' when logging
      write(v_proc_call, local_proc_call);
    else
      -- Called from other BFM procedure like spi_*_check. Include 'spi_*_check(..) while executing spi_*_receive.. when logging'
      write(v_proc_call, ext_proc_call & " while executing " & local_proc_name);
    end if;

    -- Await for master to drive SS_N and SCLK
    if (ss_n /= '0') then               -- master not acvtive
      wait until (ss_n = '0');
    elsif (ss_n = '0') then             -- master active
      case when_to_start_transfer is
        when START_TRANSFER_ON_NEXT_SS =>
          if (ss_n = '0') and (ss_n'last_active > 0 ns) then
            wait until (ss_n = '0') and (ss_n'last_active <= 0 ns);
          end if;
        when others =>                  -- START_TRANSFER_IMMEDIATE
          null;
      end case;
    end if;

    if ss_n = '0' then
      -- set MISO together with SS_N when CPHA=0
      if not config.CPHA then
        miso       <= bfm_tx_data(C_ACCESS_SIZE - v_tx_count - 1);
        v_tx_count := v_tx_count + 1;
      end if;

      -- Await first clock edge
      wait until sclk = not(config.CPOL);

      -- Receive bits
      while (ss_n = '0') and not(v_access_done) loop

        if not config.CPHA then
          v_rx_data(C_ACCESS_SIZE - v_rx_count) := mosi;
          wait until sclk'event and sclk = config.CPOL;
          miso                                  <= bfm_tx_data(C_ACCESS_SIZE - v_tx_count - 1);
        else                            -- config.CPHA
          miso                                  <= bfm_tx_data(C_ACCESS_SIZE - v_tx_count - 1);
          wait until sclk'event and sclk = config.CPOL;
          v_rx_data(C_ACCESS_SIZE - v_rx_count) := mosi;
        end if;

        if (v_tx_count < (C_ACCESS_SIZE-1)) and (v_rx_count < C_ACCESS_SIZE) then
          wait until sclk'event and sclk = not(config.CPOL);
          v_tx_count := v_tx_count + 1;
          v_rx_count := v_rx_count + 1;
        else
          if not config.CPHA then
            wait until sclk'event and sclk = not(config.CPOL);
          end if;
          v_access_done := true;
        end if;
      end loop;
    end if;

    -- Sample last bit
    if not config.CPHA then
      v_rx_count                            := v_rx_count + 1;
      v_rx_data(C_ACCESS_SIZE - v_rx_count) := mosi;
      wait until sclk'event and sclk = config.CPOL;
    end if;

    if (v_tx_count < C_ACCESS_SIZE-1) then
      alert(error, v_proc_call.all & " ss_n not kept active for tx_data size duration " & add_msg_delimiter(msg), scope);
    elsif (v_rx_count < C_ACCESS_SIZE) then
      alert(error, v_proc_call.all & " ss_n not kept active for rx_data size duration " & add_msg_delimiter(msg), scope);
    else
      rx_data := v_rx_data;
    end if;

    -- Await for master to finish
    wait until (mosi = 'Z')
      for config.ss_n_to_sclk;
    miso <= 'Z';

    if ext_proc_call = "" then
      log(config.id_for_bfm, local_proc_call & "=> " & to_string(v_rx_data, HEX, SKIP_LEADING_0, INCL_RADIX) & " rx completed. " & add_msg_delimiter(msg), scope, msg_id_panel);
      log(config.id_for_bfm, local_proc_call & "=> " & to_string(bfm_tx_data, HEX, SKIP_LEADING_0, INCL_RADIX) & " tx completed. " & add_msg_delimiter(msg), scope, msg_id_panel);
    else
    -- Log will be handled by calling procedure (e.g. spi_*_check)
    end if;
 end procedure;

  procedure spi_slave_transmit_and_receive (
    constant tx_data                : in    std_logic_vector;
    variable rx_data                : out   std_logic_vector;
    constant msg                    : in    string;
    signal spi_if                   : inout t_spi_if;
    constant when_to_start_transfer : in    t_when_to_start_transfer := START_TRANSFER_ON_NEXT_SS;
    constant scope                  : in    string                   := C_SCOPE;
    constant msg_id_panel           : in    t_msg_id_panel           := shared_msg_id_panel;
    constant config                 : in    t_spi_bfm_config         := C_SPI_BFM_CONFIG_DEFAULT;
    constant ext_proc_call          : in    string                   := ""  -- External proc_call; overwrite if called from other BFM procedure like spi_*_check
    ) is
  begin
    spi_slave_transmit_and_receive(tx_data, rx_data, msg,
                                   spi_if.sclk, spi_if.ss_n, spi_if.mosi, spi_if.miso,
                                   when_to_start_transfer, scope, msg_id_panel, config, ext_proc_call);
  end procedure;

  -- Multi-word
  procedure spi_slave_transmit_and_receive (
    constant tx_data                : in    t_slv_array;
    variable rx_data                : out   t_slv_array;
    constant msg                    : in    string;
    signal spi_if                   : inout t_spi_if;
    constant when_to_start_transfer : in    t_when_to_start_transfer := START_TRANSFER_ON_NEXT_SS;
    constant scope                  : in    string                   := C_SCOPE;
    constant msg_id_panel           : in    t_msg_id_panel           := shared_msg_id_panel;
    constant config                 : in    t_spi_bfm_config         := C_SPI_BFM_CONFIG_DEFAULT;
    constant ext_proc_call          : in    string                   := ""  -- External proc_call; overwrite if called from other BFM procedure like spi_*_check
    ) is
  begin
    -- Check length of tx_data and rx_data
    if tx_data'length /= rx_data'length then
      alert(error, ext_proc_call & "tx_data and rx_data have different sizes.");
    end if;
    for idx in 0 to (tx_data'length-1) loop
      spi_slave_transmit_and_receive(tx_data(idx), rx_data(idx), msg, spi_if, when_to_start_transfer, scope, msg_id_panel, config, ext_proc_call);
    end loop;
  end procedure;

  ------------------------------------------
  -- spi_slave_transmit_and_check
  ------------------------------------------
  procedure spi_slave_transmit_and_check(
    constant tx_data                : in    std_logic_vector;
    constant data_exp               : in    std_logic_vector;
    constant msg                    : in    string;
    signal spi_if                   : inout t_spi_if;
    constant alert_level            : in    t_alert_level            := error;
    constant when_to_start_transfer : in    t_when_to_start_transfer := START_TRANSFER_ON_NEXT_SS;
    constant scope                  : in    string                   := C_SCOPE;
    constant msg_id_panel           : in    t_msg_id_panel           := shared_msg_id_panel;
    constant config                 : in    t_spi_bfm_config         := C_SPI_BFM_CONFIG_DEFAULT
    ) is
    constant local_proc_name : string := "spi_slave_transmit_and_check";
    constant local_proc_call : string := local_proc_name & "(" & to_string(data_exp, HEX, AS_IS, INCL_RADIX) & ")";
    -- Helper variables
    variable v_rx_data       : std_logic_vector(data_exp'length-1 downto 0);
    variable v_check_ok      : boolean;
  begin
    spi_slave_transmit_and_receive(tx_data, v_rx_data, msg, spi_if, when_to_start_transfer, scope, msg_id_panel, config, local_proc_call);

    -- Compare values, but ignore any leading zero's if widths are different.
    -- Use ID_NEVER so that check_value method does not log when check is OK,
    -- log it here instead.
    v_check_ok := check_value(v_rx_data, data_exp, alert_level, msg, scope, HEX_BIN_IF_INVALID, SKIP_LEADING_0, ID_NEVER, msg_id_panel, local_proc_call);
    if v_check_ok then
      log(config.id_for_bfm, local_proc_call & "=> OK, read data = " & to_string(v_rx_data, HEX, SKIP_LEADING_0, INCL_RADIX) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
    end if;
  end;

  -- Multi-word
  procedure spi_slave_transmit_and_check(
    constant tx_data                : in    t_slv_array;
    constant data_exp               : in    t_slv_array;
    constant msg                    : in    string;
    signal spi_if                   : inout t_spi_if;
    constant alert_level            : in    t_alert_level            := error;
    constant when_to_start_transfer : in    t_when_to_start_transfer := START_TRANSFER_ON_NEXT_SS;
    constant scope                  : in    string                   := C_SCOPE;
    constant msg_id_panel           : in    t_msg_id_panel           := shared_msg_id_panel;
    constant config                 : in    t_spi_bfm_config         := C_SPI_BFM_CONFIG_DEFAULT
    ) is
    constant loc_proc_call : string := "spi_slave_transmit_and_check";  -- External proc_call; overwrite if called from other BFM procedure like spi_*_check
  begin
    -- Check length of tx_data and rx_data
    if tx_data'length /= data_exp'length then
      alert(error, loc_proc_call & " tx_data and data_exp have different sizes.");
    end if;
    for idx in 0 to (tx_data'length-1) loop
      -- call single-word procedure - will handle error checking
      spi_slave_transmit_and_check(tx_data(idx), data_exp(idx), msg, spi_if, alert_level, when_to_start_transfer, scope, msg_id_panel, config);
    end loop;
  end;

  ---------------------------------------------------------------------------------
  -- spi_slave_transmit
  ---------------------------------------------------------------------------------
  procedure spi_slave_transmit(
    constant tx_data                : in    std_logic_vector;
    constant msg                    : in    string;
    signal spi_if                   : inout t_spi_if;
    constant when_to_start_transfer : in    t_when_to_start_transfer := START_TRANSFER_ON_NEXT_SS;
    constant scope                  : in    string                   := C_SCOPE;
    constant msg_id_panel           : in    t_msg_id_panel           := shared_msg_id_panel;
    constant config                 : in    t_spi_bfm_config         := C_SPI_BFM_CONFIG_DEFAULT
    ) is
    constant local_proc_name : string := "spi_slave_transmit";
    constant local_proc_call : string := local_proc_name & "(" & to_string(tx_data, HEX, AS_IS, INCL_RADIX) & ")";
    -- Helper variables
    variable v_rx_data       : std_logic_vector(tx_data'length-1 downto 0);  -- := (others => '0');
  begin
    spi_slave_transmit_and_receive(tx_data, v_rx_data, msg, spi_if, when_to_start_transfer, scope, msg_id_panel, config, local_proc_call);
  end procedure;

  -- Multi-word
  procedure spi_slave_transmit(
    constant tx_data                : in    t_slv_array;
    constant msg                    : in    string;
    signal spi_if                   : inout t_spi_if;
    constant when_to_start_transfer : in    t_when_to_start_transfer := START_TRANSFER_ON_NEXT_SS;
    constant scope                  : in    string                   := C_SCOPE;
    constant msg_id_panel           : in    t_msg_id_panel           := shared_msg_id_panel;
    constant config                 : in    t_spi_bfm_config         := C_SPI_BFM_CONFIG_DEFAULT
    ) is
    constant local_proc_name : string                                                               := "spi_slave_transmit";
    constant local_proc_call : string                                                               := local_proc_name & "(" & to_string(tx_data, HEX, AS_IS, INCL_RADIX) & ")";
    -- Helper variables
    variable v_tx_data       : t_slv_array(tx_data'length-1 downto 0)(tx_data(0)'length-1 downto 0) := (others => (others => '0'));
  begin
    -- call multi-word procedure
    spi_slave_transmit_and_receive(tx_data, v_tx_data, msg, spi_if, when_to_start_transfer, scope, msg_id_panel, config, local_proc_call);
  end procedure;

  ---------------------------------------------------------------------------------
  -- spi_slave_receive
  ---------------------------------------------------------------------------------
  procedure spi_slave_receive (
    variable rx_data                : out   std_logic_vector;
    constant msg                    : in    string;
    signal spi_if                   : inout t_spi_if;
    constant when_to_start_transfer : in    t_when_to_start_transfer := START_TRANSFER_ON_NEXT_SS;
    constant scope                  : in    string                   := C_SCOPE;
    constant msg_id_panel           : in    t_msg_id_panel           := shared_msg_id_panel;
    constant config                 : in    t_spi_bfm_config         := C_SPI_BFM_CONFIG_DEFAULT
    ) is
    constant local_proc_name : string                                      := "spi_slave_receive";
    constant local_proc_call : string                                      := local_proc_name & "(" & to_string(rx_data, HEX, AS_IS, INCL_RADIX) & ")";
    -- Helper variables
    variable v_tx_data       : std_logic_vector(rx_data'length-1 downto 0) := (others => '0');
  begin
    spi_slave_transmit_and_receive(v_tx_data, rx_data, msg, spi_if, when_to_start_transfer, scope, msg_id_panel, config, local_proc_call);
  end;

  -- Multi-word
  procedure spi_slave_receive (
    variable rx_data                : out   t_slv_array;
    constant msg                    : in    string;
    signal spi_if                   : inout t_spi_if;
    constant when_to_start_transfer : in    t_when_to_start_transfer := START_TRANSFER_ON_NEXT_SS;
    constant scope                  : in    string                   := C_SCOPE;
    constant msg_id_panel           : in    t_msg_id_panel           := shared_msg_id_panel;
    constant config                 : in    t_spi_bfm_config         := C_SPI_BFM_CONFIG_DEFAULT
    ) is
    constant local_proc_name : string                                                               := "spi_slave_receive";
    constant local_proc_call : string                                                               := local_proc_name & "(" & to_string(rx_data, HEX, AS_IS, INCL_RADIX) & ")";
    -- Helper variables
    variable v_rx_data       : t_slv_array(rx_data'length-1 downto 0)(rx_data(0)'length-1 downto 0) := (others => (others => '0'));
  begin
    -- call multi-word procedure
    spi_slave_transmit_and_receive(v_rx_data, rx_data, msg, spi_if, when_to_start_transfer, scope, msg_id_panel, config, local_proc_call);
  end;

  ---------------------------------------------------------------------------------
  -- spi_slave_check
  ---------------------------------------------------------------------------------
  procedure spi_slave_check (
    constant data_exp               : in    std_logic_vector;
    constant msg                    : in    string;
    signal spi_if                   : inout t_spi_if;
    constant alert_level            : in    t_alert_level            := error;
    constant when_to_start_transfer : in    t_when_to_start_transfer := START_TRANSFER_ON_NEXT_SS;
    constant scope                  : in    string                   := C_SCOPE;
    constant msg_id_panel           : in    t_msg_id_panel           := shared_msg_id_panel;
    constant config                 : in    t_spi_bfm_config         := C_SPI_BFM_CONFIG_DEFAULT
    ) is
    constant local_proc_name : string                                       := "spi_slave_check";
    constant local_proc_call : string                                       := local_proc_name & "(" & to_string(data_exp, HEX, AS_IS, INCL_RADIX) & ")";
    -- Helper variables
    variable v_rx_data       : std_logic_vector(data_exp'length-1 downto 0) := (others => 'X');
    variable v_tx_data       : std_logic_vector(data_exp'length-1 downto 0) := (others => '0');
    variable v_check_ok      : boolean;
  begin
    spi_slave_transmit_and_receive(v_tx_data, v_rx_data, msg, spi_if, when_to_start_transfer, scope, msg_id_panel, config, local_proc_call);

    -- Compare values, but ignore any leading zero's if widths are different.
    -- Use ID_NEVER so that check_value method does not log when check is OK,
    -- log it here instead.
    v_check_ok := check_value(v_rx_data, data_exp, alert_level, msg, scope, HEX_BIN_IF_INVALID, SKIP_LEADING_0, ID_NEVER, msg_id_panel, local_proc_call);
    if v_check_ok then
      log(config.id_for_bfm, local_proc_call & "=> OK, read data = " & to_string(v_rx_data, HEX, SKIP_LEADING_0, INCL_RADIX) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
    end if;
  end procedure;

  -- Multi-word
  procedure spi_slave_check (
    constant data_exp               : in    t_slv_array;
    constant msg                    : in    string;
    signal spi_if                   : inout t_spi_if;
    constant alert_level            : in    t_alert_level            := error;
    constant when_to_start_transfer : in    t_when_to_start_transfer := START_TRANSFER_ON_NEXT_SS;
    constant scope                  : in    string                   := C_SCOPE;
    constant msg_id_panel           : in    t_msg_id_panel           := shared_msg_id_panel;
    constant config                 : in    t_spi_bfm_config         := C_SPI_BFM_CONFIG_DEFAULT
    ) is
  begin
    for idx in 0 to (data_exp'length-1) loop
      -- call singl-word procedure - will handle error check
      spi_slave_check(data_exp(idx), msg, spi_if, alert_level, when_to_start_transfer, scope, msg_id_panel, config);
    end loop;
  end procedure;

end package body spi_bfm_pkg;
