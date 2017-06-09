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
    ss_n   : std_logic;                   -- master to slave
    sclk : std_logic;                   -- master to slave
    mosi : std_logic;                   -- master to slave
    miso : std_logic;                   -- slave to master
  end record;

  -- Configuration record to be assigned in the test harness.
  type t_spi_bfm_config is
  record
    CPOL                  : std_logic;  -- sclk polarity, i.e. the base value of the clock.
                                        -- If CPOL is '0', the clock will be set to '0' when inactive, i.e., ordinary positive polarity.
    CPHA                  : std_logic;  -- sclk phase, i.e. when data is sampled and transmitted w.r.t. sclk.
                                        -- If '0', sampling occurs on the first sclk edge and data is transmitted on the sclk active to idle state.
                                        -- If '1', data is sampled on the second sclk edge and transmitted on sclk idle to active state.
    --multi_word_transfer   : boolean; -- SPI transfer is multi-word or single-word
    spi_bit_time          : time;  -- used in master for dictating sclk period
    spi_bit_time_severity : t_alert_level;  -- Alert severity used if slave detects that the received sclk period is incorrect
    ss_to_sclk            : time;       -- time from SS active until SCLK active
    ss_to_sclk_severity   : t_alert_level;  -- Alert severity used if time from SS active to sclk active is exceeded
    sclk_to_ss            : time;       -- Last SCLK until SS off
    sclk_to_ss_severity   : t_alert_level;  -- Alert severity used if ss_n is not released within sclk_to_ss time after last sclk
    max_wait_ss           : time;  -- Maximum time a slave will wait for SS
    max_wait_ss_severity  : t_alert_level;  -- Alert severity used if slave does not detect SS within max_wait_ss time.
    --min_wait_ss           : time; -- Minimum time a slave will wait for SS
    --min_wait_ss_severity  : t_alert_level; -- Alert severity used if slave does not detect SS within min_wait_ss time.
    id_for_bfm            : t_msg_id;  -- The message ID used as a general message ID in the SPI BFM
    id_for_bfm_wait       : t_msg_id;  -- The message ID used for logging waits in the SPI BFM
    id_for_bfm_poll       : t_msg_id;  -- The message ID used for logging polling in the SPI BFM
  end record;

  constant C_SPI_BFM_CONFIG_DEFAULT : t_spi_bfm_config := (
    CPOL                  => '0',
    CPHA                  => '0',
    --multi_word_transfer   => false,
    spi_bit_time          => -1 ns,
    spi_bit_time_severity => failure,
    ss_to_sclk            => 20 ns,
    ss_to_sclk_severity   => failure,
    sclk_to_ss            => 20 ns,
    sclk_to_ss_severity   => failure,
    max_wait_ss           => 1000 ns,
    max_wait_ss_severity  => failure,
    --min_wait_ss           => 0 ns,
    --min_wait_ss_severity  => failure,
    id_for_bfm            => ID_BFM,
    id_for_bfm_wait       => ID_BFM_WAIT,
    id_for_bfm_poll       => ID_BFM_POLL
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
    constant tx_data       : in    std_logic_vector;
    variable rx_data       : out   std_logic_vector;
    constant msg           : in    string;
    signal sclk            : inout std_logic;
    signal ss_n              : inout std_logic;
    signal mosi            : inout std_logic;
    signal miso            : inout std_logic;
    constant scope         : in    string                         := C_SCOPE;
    constant msg_id_panel  : in    t_msg_id_panel                 := shared_msg_id_panel;
    constant config        : in    t_spi_bfm_config               := C_SPI_BFM_CONFIG_DEFAULT;
    constant ext_proc_call : in    string                         := ""  -- External proc_call; overwrite if called from other BFM procedure like spi_*_check
    );

  ------------------------------------------
  -- spi_master_transmit_and_receive
  ------------------------------------------
  -- This procedure transmits data 'tx_data' to the SPI slave DUT 
  -- and receives 'rx_data' from the SPI slave DUT.
  -- The SPI interface in this procedure is given as a t_spi_if signal record
  procedure spi_master_transmit_and_receive (
    constant tx_data       : in    std_logic_vector;
    variable rx_data       : out   std_logic_vector;
    constant msg           : in    string;
    signal spi_if          : inout t_spi_if;
    constant scope         : in    string                         := C_SCOPE;
    constant msg_id_panel  : in    t_msg_id_panel                 := shared_msg_id_panel;
    constant config        : in    t_spi_bfm_config               := C_SPI_BFM_CONFIG_DEFAULT;
    constant ext_proc_call : in    string                         := ""  -- External proc_call; overwrite if called from other BFM procedure like spi_*_check
    );

  ------------------------------------------
  -- spi_master_transmit_and_check
  ------------------------------------------
  -- This procedure ...
  -- The SPI interface in this procedure is given as a t_spi_if signal record
  procedure spi_master_transmit_and_check(
    constant tx_data      : in    std_logic_vector;
    constant data_exp     : in    std_logic_vector;
    constant alert_level  : in    t_alert_level                  := error;
    constant msg          : in    string;
    signal spi_if         : inout t_spi_if;
    constant scope        : in    string                         := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel                 := shared_msg_id_panel;
    constant config       : in    t_spi_bfm_config               := C_SPI_BFM_CONFIG_DEFAULT
    );  

  ------------------------------------------
  -- spi_master_transmit
  ------------------------------------------
  -- This procedure transmits data 'tx_data' to the SPI DUT
  -- The SPI interface in this procedure is given as a t_spi_if signal record
  procedure spi_master_transmit(
    constant tx_data      : in    std_logic_vector;
    constant msg          : in    string;
    signal spi_if         : inout t_spi_if;
    constant scope        : in    string                         := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel                 := shared_msg_id_panel;
    constant config       : in    t_spi_bfm_config               := C_SPI_BFM_CONFIG_DEFAULT
    );

  ------------------------------------------
  -- spi_master_receive
  ------------------------------------------
  -- This procedure receives data 'rx_data' from the SPI DUT
  -- The SPI interface in this procedure is given as a t_spi_if signal record
  procedure spi_master_receive(
    variable rx_data      : out   std_logic_vector;
    constant msg          : in    string;
    signal spi_if         : inout t_spi_if;
    constant scope        : in    string                         := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel                 := shared_msg_id_panel;
    constant config       : in    t_spi_bfm_config               := C_SPI_BFM_CONFIG_DEFAULT
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
    constant data_exp     : in    std_logic_vector;
    constant alert_level  : in    t_alert_level                  := error;
    constant msg          : in    string;
    signal spi_if         : inout t_spi_if;
    constant scope        : in    string                         := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel                 := shared_msg_id_panel;
    constant config       : in    t_spi_bfm_config               := C_SPI_BFM_CONFIG_DEFAULT
    );



  ------------------------------------------
  -- spi_slave_transmit_and_receive
  ------------------------------------------
  -- This procedure transmits data 'tx_data' to the SPI master DUT 
  -- and receives 'rx_data' from the SPI master DUT.
  procedure spi_slave_transmit_and_receive (
    constant tx_data       : in    std_logic_vector;
    variable rx_data       : out   std_logic_vector;
    constant msg           : in    string;
    signal sclk            : inout std_logic;
    signal ss_n              : inout std_logic;
    signal mosi            : inout std_logic;
    signal miso            : inout std_logic;
    constant scope         : in    string           := C_SCOPE;
    constant msg_id_panel  : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config        : in    t_spi_bfm_config := C_SPI_BFM_CONFIG_DEFAULT;
    constant ext_proc_call : in    string           := ""  -- External proc_call; overwrite if called from other BFM procedure like spi_*_check
    );

  ------------------------------------------
  -- spi_slave_transmit_and_receive
  ------------------------------------------
  -- This procedure transmits data 'tx_data' to the SPI master DUT 
  -- and receives 'rx_data' from the SPI master DUT.
  -- The SPI interface in this procedure is given as a t_spi_if signal record
  procedure spi_slave_transmit_and_receive (
    constant tx_data       : in    std_logic_vector;
    variable rx_data       : out   std_logic_vector;
    constant msg           : in    string;
    signal spi_if          : inout t_spi_if;
    constant scope         : in    string           := C_SCOPE;
    constant msg_id_panel  : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config        : in    t_spi_bfm_config := C_SPI_BFM_CONFIG_DEFAULT;
    constant ext_proc_call : in    string           := ""  -- External proc_call; overwrite if called from other BFM procedure like spi_*_check
    );

  ------------------------------------------
  -- spi_slave_transmit_and_check
  ------------------------------------------
  -- This procedure ...
  -- The SPI interface in this procedure is given as a t_spi_if signal record
  procedure spi_slave_transmit_and_check(
    constant tx_data      : in    std_logic_vector;
    constant data_exp     : in    std_logic_vector;
    constant alert_level  : in    t_alert_level    := error;
    constant msg          : in    string;
    signal spi_if         : inout t_spi_if;
    constant scope        : in    string           := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in    t_spi_bfm_config := C_SPI_BFM_CONFIG_DEFAULT
    );

  ------------------------------------------
  -- spi_slave_transmit
  ------------------------------------------
  -- This procedure transmits data 'tx_data' to the SPI DUT
  -- The SPI interface in this procedure is given as a t_spi_if signal record
  procedure spi_slave_transmit (
    constant tx_data      : in    std_logic_vector;
    constant msg          : in    string;
    signal spi_if         : inout t_spi_if;
    constant scope        : in    string           := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in    t_spi_bfm_config := C_SPI_BFM_CONFIG_DEFAULT
    );

  ------------------------------------------
  -- spi_slave_receive
  ------------------------------------------
  -- This procedure receives data 'rx_data' from the SPI DUT
  -- The SPI interface in this procedure is given as a t_spi_if signal record
  procedure spi_slave_receive (
    variable rx_data      : out   std_logic_vector;
    constant msg          : in    string;
    signal spi_if         : inout t_spi_if;
    constant scope        : in    string           := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in    t_spi_bfm_config := C_SPI_BFM_CONFIG_DEFAULT
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
    constant data_exp     : in    std_logic_vector;
    constant msg          : in    string;
    signal spi_if         : inout t_spi_if;
    constant alert_level  : in    t_alert_level    := error;
    constant scope        : in    string           := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in    t_spi_bfm_config := C_SPI_BFM_CONFIG_DEFAULT
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
      result.ss_n   := 'Z';
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
    constant tx_data       : in    std_logic_vector;
    variable rx_data       : out   std_logic_vector;
    constant msg           : in    string;
    signal sclk            : inout std_logic;
    signal ss_n            : inout std_logic;
    signal mosi            : inout std_logic;
    signal miso            : inout std_logic;
    constant scope         : in    string                         := C_SCOPE;
    constant msg_id_panel  : in    t_msg_id_panel                 := shared_msg_id_panel;
    constant config        : in    t_spi_bfm_config               := C_SPI_BFM_CONFIG_DEFAULT;
    constant ext_proc_call : in    string                         := ""  -- External proc_call; overwrite if called from other BFM procedure like spi_*_check
    ) is
    constant local_proc_name   : string                                      := "spi_master_transmit_and_receive";
    constant local_proc_call   : string                                      := local_proc_name;
    constant C_ACCESS_SIZE     : integer                                     := tx_data'length;
    -- Helper variables        
    variable v_access_done     : boolean                                     := false;
    variable v_tx_count        : integer                                     := 0;
    variable v_tx_data         : std_logic_vector(tx_data'length-1 downto 0) := tx_data;
    variable v_rx_data         : std_logic_vector(rx_data'length-1 downto 0) := (others => 'X');
    variable v_rx_count        : integer                                     := 1;
    variable v_proc_call       : line;
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

    sclk <= config.CPOL;
    ss_n   <= '0';
    wait for 0 ns;                      -- wait a delta cycle

    if ss_n = '0' then
      -- set MOSI together with SS_N when CPHA=0
      if not config.CPHA then
        mosi       <= v_tx_data(C_ACCESS_SIZE- v_tx_count - 1);
        v_tx_count := v_tx_count + 1;
      end if;

      -- set first sclk
      wait for config.ss_to_sclk;
      sclk <= not sclk;

      -- serially shift out v_tx_data to mosi
      -- serially shift in v_rx_data from miso
      while ss_n = '0' and not v_access_done loop
        if not config.CPHA then
          log(ID_BFM, " rx_data(" & to_string(C_ACCESS_SIZE-v_rx_count) & ") ");
          log(ID_BFM, " v_rx_count=" & to_string(v_rx_count) & " , ");
          v_rx_data(C_ACCESS_SIZE-v_rx_count) := miso;

          wait for config.spi_bit_time/2;
          sclk <= not sclk;

          log(ID_BFM, " tx_data(" & to_string(C_ACCESS_SIZE-v_tx_count-1) & ") ");
          log(ID_BFM, " v_tx_count=" & to_string(v_tx_count) & " , ");
          mosi <= v_tx_data(C_ACCESS_SIZE-v_tx_count-1);
        -- next bit
        else                            -- config.CPHA
          -- next bit
          mosi <= v_tx_data(C_ACCESS_SIZE-v_tx_count-1);

          wait for config.spi_bit_time/2;
          sclk <= not sclk;

          v_rx_data(C_ACCESS_SIZE-v_rx_count) := miso;
        end if;

        v_rx_count := v_rx_count + 1;
        if v_tx_count < C_ACCESS_SIZE-1 then
          wait for config.spi_bit_time/2;
          sclk       <= not sclk;
          v_tx_count := v_tx_count + 1;
        else                            -- Final bit
          if not config.CPHA then
            -- Sample Last bit on the second to last edge of SCLK (CPOL=0: last rising. CPOL=1: last falling)
            wait for config.spi_bit_time/2;
            v_rx_data(C_ACCESS_SIZE-v_rx_count) := miso;
            sclk                                <= not sclk;
            log(ID_BFM, " rx_data(" & to_string(C_ACCESS_SIZE-v_rx_count) & ") ");
          else
            v_rx_count                          := v_rx_count - 1;
            v_rx_data(C_ACCESS_SIZE-v_rx_count) := miso;
            log(ID_BFM, " rx_data(" & to_string(C_ACCESS_SIZE-v_rx_count) & ") ");
          end if;

          v_access_done := true;
          log(config.id_for_bfm, v_proc_call.all & "=> " & to_string(v_tx_data, HEX, SKIP_LEADING_0, INCL_RADIX) & " completed. " & add_msg_delimiter(msg), scope, msg_id_panel);
        end if;
      end loop;

      -- clock the last bit
      if not config.CPHA then
        wait for config.spi_bit_time/2;
        sclk <= config.CPOL;
      end if;

      wait for config.sclk_to_ss;
      mosi <= 'Z';

      ss_n<= '1';

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
  
  procedure spi_master_transmit_and_receive (
    constant tx_data       : in    std_logic_vector;
    variable rx_data       : out   std_logic_vector;
    constant msg           : in    string;
    signal spi_if          : inout t_spi_if;
    constant scope         : in    string                         := C_SCOPE;
    constant msg_id_panel  : in    t_msg_id_panel                 := shared_msg_id_panel;
    constant config        : in    t_spi_bfm_config               := C_SPI_BFM_CONFIG_DEFAULT;
    constant ext_proc_call : in    string                         := ""  -- External proc_call; overwrite if called from other BFM procedure like spi_*_check
    ) is
  begin
    spi_master_transmit_and_receive(tx_data, rx_data, msg,
                                    spi_if.sclk, spi_if.ss_n, spi_if.mosi, spi_if.miso,
                                    scope, msg_id_panel, config, ext_proc_call);
  end procedure;

  ---------------------------------------------------------------------------------
  -- spi_master_transmit_and_check
  ---------------------------------------------------------------------------------      
  procedure spi_master_transmit_and_check(
    constant tx_data      : in    std_logic_vector;
    constant data_exp     : in    std_logic_vector;
    constant alert_level  : in    t_alert_level                  := error;
    constant msg          : in    string;
    signal spi_if         : inout t_spi_if;
    constant scope        : in    string                         := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel                 := shared_msg_id_panel;
    constant config       : in    t_spi_bfm_config               := C_SPI_BFM_CONFIG_DEFAULT
    ) is
    constant local_proc_name : string := "spi_master_transmit_and_check";
    constant local_proc_call : string := local_proc_name;
    -- Helper variables    
    variable v_rx_data       : std_logic_vector(data_exp'length-1 downto 0);
    variable v_check_ok      : boolean;
  begin
    spi_master_transmit_and_receive(tx_data, v_rx_data, msg, spi_if, scope, msg_id_panel, config, local_proc_call);

    -- Compare values, but ignore any leading zero's if widths are different.
    -- Use ID_NEVER so that check_value method does not log when check is OK,
    -- log it here instead.
    v_check_ok := check_value(v_rx_data, data_exp, alert_level, msg, scope, HEX_BIN_IF_INVALID, SKIP_LEADING_0, ID_NEVER, msg_id_panel, local_proc_call);
    if v_check_ok then
      log(config.id_for_bfm, local_proc_call & "=> OK, read data = " & to_string(v_rx_data, HEX, SKIP_LEADING_0, INCL_RADIX) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
    end if;
  end procedure;

  ---------------------------------------------------------------------------------
  -- spi_master_transmit
  ---------------------------------------------------------------------------------    
  procedure spi_master_transmit(
    constant tx_data      : in    std_logic_vector;
    constant msg          : in    string;
    signal spi_if         : inout t_spi_if;
    constant scope        : in    string                         := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel                 := shared_msg_id_panel;
    constant config       : in    t_spi_bfm_config               := C_SPI_BFM_CONFIG_DEFAULT
    ) is
    constant local_proc_name : string := "spi_master_transmit";
    constant local_proc_call : string := local_proc_name;
    -- Helper variables    
    variable v_rx_data       : std_logic_vector(tx_data'length - 1 downto 0);
  begin
    spi_master_transmit_and_receive(tx_data, v_rx_data, msg, spi_if, scope, msg_id_panel, config, local_proc_call);
  end procedure;

  ---------------------------------------------------------------------------------
  -- spi_master_receive
  ---------------------------------------------------------------------------------    
  procedure spi_master_receive(
    variable rx_data      : out   std_logic_vector;
    constant msg          : in    string;
    signal spi_if         : inout t_spi_if;
    constant scope        : in    string                         := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel                 := shared_msg_id_panel;
    constant config       : in    t_spi_bfm_config               := C_SPI_BFM_CONFIG_DEFAULT
    ) is
    constant local_proc_name : string                                        := "spi_master_receive";
    constant local_proc_call : string                                        := local_proc_name;
    -- Helper variables    
    variable v_tx_data       : std_logic_vector(rx_data'length - 1 downto 0) := (others => '0');
  begin
    spi_master_transmit_and_receive(v_tx_data, rx_data, msg, spi_if, scope, msg_id_panel, config, local_proc_call);
  end procedure;

  ---------------------------------------------------------------------------------
  -- spi_master_check
  ---------------------------------------------------------------------------------  
  procedure spi_master_check(
    constant data_exp     : in    std_logic_vector;
    constant alert_level  : in    t_alert_level                  := error;
    constant msg          : in    string;
    signal spi_if         : inout t_spi_if;
    constant scope        : in    string                         := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel                 := shared_msg_id_panel;
    constant config       : in    t_spi_bfm_config               := C_SPI_BFM_CONFIG_DEFAULT
    ) is
    constant local_proc_name : string                                         := "spi_master_check";
    constant local_proc_call : string                                         := local_proc_name;
    -- Helper variables    
    variable v_tx_data       : std_logic_vector(data_exp'length - 1 downto 0) := (others => '0');
    variable v_rx_data       : std_logic_vector(data_exp'length-1 downto 0);
    variable v_check_ok      : boolean;
  begin
    spi_master_transmit_and_receive(v_tx_data, v_rx_data, msg, spi_if, scope, msg_id_panel, config);

    -- Compare values, but ignore any leading zero's if widths are different.
    -- Use ID_NEVER so that check_value method does not log when check is OK,
    -- log it here instead.
    v_check_ok := check_value(v_rx_data, data_exp, alert_level, msg, scope, HEX_BIN_IF_INVALID, SKIP_LEADING_0, ID_NEVER, msg_id_panel, local_proc_call);
    if v_check_ok then
      log(config.id_for_bfm, local_proc_call & "=> OK, read data = " & to_string(v_rx_data, HEX, SKIP_LEADING_0, INCL_RADIX) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
    end if;
  end procedure;



  ---------------------------------------------------------------------------------
  -- spi_slave_transmit_and_receive
  --
  ---------------------------------------------------------------------------------
  procedure spi_slave_transmit_and_receive (
    constant tx_data       : in    std_logic_vector;
    variable rx_data       : out   std_logic_vector;
    constant msg           : in    string;
    signal sclk            : inout std_logic;
    signal ss_n            : inout std_logic;
    signal mosi            : inout std_logic;
    signal miso            : inout std_logic;
    constant scope         : in    string           := C_SCOPE;
    constant msg_id_panel  : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config        : in    t_spi_bfm_config := C_SPI_BFM_CONFIG_DEFAULT;
    constant ext_proc_call : in    string           := ""  -- External proc_call; overwrite if called from other BFM procedure like spi_*_check
    ) is
    -- Local_proc_name/call used if called from sequencer or VVC 
    constant local_proc_name   : string                                      := "spi_slave_transmit_and_receive";
    constant local_proc_call   : string                                      := local_proc_name;
    constant C_ACCESS_SIZE     : integer                                     := rx_data'length;
    -- Helper variables    
    variable v_rx_data         : std_logic_vector(rx_data'range)             := (others => 'X');
    variable bfm_tx_data       : std_logic_vector(tx_data'length-1 downto 0) := tx_data;
    variable v_access_done     : boolean                                     := false;
    variable v_tx_count        : integer                                     := 0;
    variable v_rx_count        : integer                                     := 1;
    variable v_proc_call       : line;
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

    -- the spi_write procedure will drive the clock and ss_n signal; can't have
    -- two procedures driving the same signals
    await_value(ss_n, '0', 0 ns, config.max_wait_ss + 1 ps, config.max_wait_ss_severity, add_msg_delimiter(msg) & ": awaiting ss_n", scope, ID_NEVER, msg_id_panel);

    if ss_n = '0' then

      -- set MISO together with SS_N when CPHA=0
      if not config.CPHA then
        miso       <= bfm_tx_data(C_ACCESS_SIZE - v_tx_count - 1);
        v_tx_count := v_tx_count + 1;
      end if;

      -- Await first clock edge
      await_value(sclk, not config.CPOL, 0 ns, config.ss_to_sclk + 1 ps, config.ss_to_sclk_severity, add_msg_delimiter(msg) & ": awaiting initial edge of sclk", scope, ID_NEVER, msg_id_panel);

      -- receive the bits
      while ss_n = '0' and not v_access_done loop

        if not config.CPHA then
          v_rx_data(C_ACCESS_SIZE - v_rx_count) := mosi;
          await_value(sclk, config.CPOL, 0 ns, config.spi_bit_time/2 + 1 ps, config.spi_bit_time_severity, add_msg_delimiter(msg) & ": awaiting first edge of sclk", scope, ID_NEVER, msg_id_panel);
          miso                                  <= bfm_tx_data(C_ACCESS_SIZE - v_tx_count - 1);
        else                            -- config.CPHA
          miso                                  <= bfm_tx_data(C_ACCESS_SIZE - v_tx_count - 1);
          await_value(sclk, config.CPOL, 0 ns, config.spi_bit_time/2 + 1 ps, config.spi_bit_time_severity, add_msg_delimiter(msg) & ": awaiting second edge of sclk", scope, ID_NEVER, msg_id_panel);
          v_rx_data(C_ACCESS_SIZE - v_rx_count) := mosi;
        end if;

        if (v_tx_count < (C_ACCESS_SIZE-1)) and (v_rx_count < C_ACCESS_SIZE) then
          await_value(sclk, not config.CPOL, 0 ns, config.spi_bit_time/2 + 1 ps, config.spi_bit_time_severity, add_msg_delimiter(msg) & ": awaiting final edge of sclk", scope, ID_NEVER, msg_id_panel);
          v_tx_count := v_tx_count + 1;
          v_rx_count := v_rx_count + 1;
        else
          if not config.CPHA then
            await_value(sclk, not config.CPOL, 0 ns, config.spi_bit_time/2 + 1 ps, config.spi_bit_time_severity, add_msg_delimiter(msg) & ": awaiting first edge of sclk", scope, ID_NEVER, msg_id_panel);
          end if;
          v_access_done := true;
        end if;
      end loop;
    end if;

    -- sample last bit
    if not config.CPHA then
      v_rx_count                            := v_rx_count + 1;
      v_rx_data(C_ACCESS_SIZE - v_rx_count) := mosi;
      await_value(sclk, config.CPOL, 0 ns, config.spi_bit_time/2 + 1 ps, config.spi_bit_time_severity, add_msg_delimiter(msg) & ": awaiting final edge of sclk", scope, ID_NEVER, msg_id_panel);
    end if;

    if (v_tx_count < C_ACCESS_SIZE-1) then
      alert(error, v_proc_call.all & " ss_n not kept active for tx_data size duration " & add_msg_delimiter(msg), scope);
    elsif (v_rx_count < C_ACCESS_SIZE) then
      alert(error, v_proc_call.all & " ss_n not kept active for rx_data size duration " & add_msg_delimiter(msg), scope);
    else
      rx_data := v_rx_data;
    end if;

    -- check ss_n deactivation
    await_value(ss_n, '1', 0 ns, config.sclk_to_ss + 1 ps, config.sclk_to_ss_severity, add_msg_delimiter(msg) & ": awaiting ss_n deactivation", scope, ID_NEVER, msg_id_panel);
    
    miso <= 'Z';

    if ext_proc_call = "" then
      log(config.id_for_bfm, local_proc_call & "=> " & to_string(v_rx_data, HEX, SKIP_LEADING_0, INCL_RADIX) & " rx completed. " & add_msg_delimiter(msg), scope, msg_id_panel);
      log(config.id_for_bfm, local_proc_call & "=> " & to_string(bfm_tx_data, HEX, SKIP_LEADING_0, INCL_RADIX) & " tx completed. " & add_msg_delimiter(msg), scope, msg_id_panel);
    else
    -- Log will be handled by calling procedure (e.g. spi_*_check)
    end if;
  end procedure;

  procedure spi_slave_transmit_and_receive (
    constant tx_data       : in    std_logic_vector;
    variable rx_data       : out   std_logic_vector;
    constant msg           : in    string;
    signal spi_if          : inout t_spi_if;
    constant scope         : in    string           := C_SCOPE;
    constant msg_id_panel  : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config        : in    t_spi_bfm_config := C_SPI_BFM_CONFIG_DEFAULT;
    constant ext_proc_call : in    string           := ""  -- External proc_call; overwrite if called from other BFM procedure like spi_*_check
    ) is
  begin
    spi_slave_transmit_and_receive(tx_data, rx_data, msg,
                                   spi_if.sclk, spi_if.ss_n, spi_if.mosi, spi_if.miso,
                                   scope, msg_id_panel, config, ext_proc_call);
  end procedure;

  ------------------------------------------
  -- spi_slave_transmit_and_check
  ------------------------------------------
  procedure spi_slave_transmit_and_check(
    constant tx_data      : in    std_logic_vector;
    constant data_exp     : in    std_logic_vector;
    constant alert_level  : in    t_alert_level    := error;
    constant msg          : in    string;
    signal spi_if         : inout t_spi_if;
    constant scope        : in    string           := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in    t_spi_bfm_config := C_SPI_BFM_CONFIG_DEFAULT
    ) is
    constant local_proc_name : string := "spi_slave_transmit_and_check";
    constant local_proc_call : string := local_proc_name & "(" & to_string(data_exp, HEX, AS_IS, INCL_RADIX) & ")";
    -- Helper variables
    variable v_rx_data       : std_logic_vector(data_exp'length-1 downto 0);
    variable v_check_ok      : boolean;
  begin
    spi_slave_transmit_and_receive(tx_data, v_rx_data, msg, spi_if, scope, msg_id_panel, config, local_proc_call);

    -- Compare values, but ignore any leading zero's if widths are different.
    -- Use ID_NEVER so that check_value method does not log when check is OK,
    -- log it here instead.
    v_check_ok := check_value(v_rx_data, data_exp, alert_level, msg, scope, HEX_BIN_IF_INVALID, SKIP_LEADING_0, ID_NEVER, msg_id_panel, local_proc_call);
    if v_check_ok then
      log(config.id_for_bfm, local_proc_call & "=> OK, read data = " & to_string(v_rx_data, HEX, SKIP_LEADING_0, INCL_RADIX) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
    end if;
  end;

  ---------------------------------------------------------------------------------
  -- spi_slave_transmit
  ---------------------------------------------------------------------------------  
  procedure spi_slave_transmit(
    constant tx_data      : in    std_logic_vector;
    constant msg          : in    string;
    signal spi_if         : inout t_spi_if;
    constant scope        : in    string           := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in    t_spi_bfm_config := C_SPI_BFM_CONFIG_DEFAULT
    ) is
    constant local_proc_name : string := "spi_slave_transmit";
    constant local_proc_call : string := local_proc_name & "(" & to_string(tx_data, HEX, AS_IS, INCL_RADIX) & ")";
    -- Helper variables
    variable v_rx_data       : std_logic_vector(tx_data'length-1 downto 0);  -- := (others => '0');
  begin
    spi_slave_transmit_and_receive(tx_data, v_rx_data, msg, spi_if, scope, msg_id_panel, config, local_proc_call);
  end procedure;

  ---------------------------------------------------------------------------------
  -- spi_slave_receive
  ---------------------------------------------------------------------------------
  procedure spi_slave_receive (
    variable rx_data      : out   std_logic_vector;
    constant msg          : in    string;
    signal spi_if         : inout t_spi_if;
    constant scope        : in    string           := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in    t_spi_bfm_config := C_SPI_BFM_CONFIG_DEFAULT
    ) is
    constant local_proc_name : string                                      := "spi_slave_receive";
    constant local_proc_call : string                                      := local_proc_name & "(" & to_string(rx_data, HEX, AS_IS, INCL_RADIX) & ")";
    -- Helper variables    
    variable v_tx_data       : std_logic_vector(rx_data'length-1 downto 0) := (others => '0');
  begin
    spi_slave_transmit_and_receive(v_tx_data, rx_data, msg, spi_if, scope, msg_id_panel, config, local_proc_call);
  end;

  ---------------------------------------------------------------------------------
  -- spi_slave_check
  ---------------------------------------------------------------------------------
  procedure spi_slave_check (
    constant data_exp     : in    std_logic_vector;
    constant msg          : in    string;
    signal spi_if         : inout t_spi_if;
    constant alert_level  : in    t_alert_level    := error;
    constant scope        : in    string           := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in    t_spi_bfm_config := C_SPI_BFM_CONFIG_DEFAULT
    ) is
    constant local_proc_name : string                                       := "spi_slave_check";
    constant local_proc_call : string                                       := local_proc_name & "(" & to_string(data_exp, HEX, AS_IS, INCL_RADIX) & ")";
    -- Helper variables
    variable v_rx_data       : std_logic_vector(data_exp'length-1 downto 0) := (others => 'X');
    variable v_tx_data       : std_logic_vector(data_exp'length-1 downto 0) := (others => '0');
    variable v_check_ok      : boolean;
  begin
    spi_slave_transmit_and_receive(v_tx_data, v_rx_data, msg, spi_if, scope, msg_id_panel, config, local_proc_call);

    -- Compare values, but ignore any leading zero's if widths are different.
    -- Use ID_NEVER so that check_value method does not log when check is OK,
    -- log it here instead.
    v_check_ok := check_value(v_rx_data, data_exp, alert_level, msg, scope, HEX_BIN_IF_INVALID, SKIP_LEADING_0, ID_NEVER, msg_id_panel, local_proc_call);
    if v_check_ok then
      log(config.id_for_bfm, local_proc_call & "=> OK, read data = " & to_string(v_rx_data, HEX, SKIP_LEADING_0, INCL_RADIX) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
    end if;
  end procedure;


end package body spi_bfm_pkg;
