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


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;    -- t_channel (RX/TX)

library bitvis_vip_sbi;
use bitvis_vip_sbi.transaction_pkg.all;
use bitvis_vip_sbi.vvc_methods_pkg.all;


library bitvis_vip_uart;
use bitvis_vip_uart.transaction_pkg.all;
use bitvis_vip_uart.vvc_methods_pkg.all;


library bitvis_uart;
library bitvis_vip_clock_generator;


-- Test harness entity
entity dtt_demo_th is
  generic (
    GC_SBI_VVC_IDX  : integer := 1;
    GC_UART_VVC_IDX : integer := 1
    );
end entity;

-- Test harness architecture
architecture struct of dtt_demo_th is

  -- DSP interface and general control signals
  signal clk  : std_logic := '0';
  signal arst : std_logic := '0';

  -- SBI VVC signals
  signal cs    : std_logic;
  signal addr  : unsigned(2 downto 0);
  signal wr    : std_logic;
  signal rd    : std_logic;
  signal wdata : std_logic_vector(7 downto 0);
  signal rdata : std_logic_vector(7 downto 0);
  signal ready : std_logic;

  -- UART VVC signals
  signal uart_vvc_rx : std_logic := '1';
  signal uart_vvc_tx : std_logic := '1';

  constant C_CLK_PERIOD : time    := 10 ns;  -- 100 MHz
  constant C_CLOCK_GEN  : natural := 1;

  signal debug : std_logic_vector(7 downto 0);

begin

  -----------------------------------------------------------------------------
  -- Instantiate the concurrent procedure that initializes UVVM
  -----------------------------------------------------------------------------
  i_ti_uvvm_engine : entity uvvm_vvc_framework.ti_uvvm_engine;

  -----------------------------------------------------------------------------
  -- Instantiate DUT
  -----------------------------------------------------------------------------
  i_uart : entity bitvis_uart.uart
    port map (
      -- DSP interface and general control signals
      clk   => clk,
      arst  => arst,
      -- CPU interface
      cs    => cs,
      addr  => addr,
      wr    => wr,
      rd    => rd,
      wdata => wdata,
      rdata => rdata,
      -- UART signals
      rx_a  => uart_vvc_tx,
      tx    => uart_vvc_rx
      );


  -----------------------------------------------------------------------------
  -- SBI VVC
  -----------------------------------------------------------------------------
  i1_sbi_vvc : entity bitvis_vip_sbi.sbi_vvc
    generic map(
      GC_ADDR_WIDTH   => 3,
      GC_DATA_WIDTH   => 8,
      GC_INSTANCE_IDX => GC_SBI_VVC_IDX
      )
    port map(
      clk                     => clk,
      sbi_vvc_master_if.cs    => cs,
      sbi_vvc_master_if.rena  => rd,
      sbi_vvc_master_if.wena  => wr,
      sbi_vvc_master_if.addr  => addr,
      sbi_vvc_master_if.wdata => wdata,
      sbi_vvc_master_if.ready => ready,
      sbi_vvc_master_if.rdata => rdata
      );


  -----------------------------------------------------------------------------
  -- UART VVC
  -----------------------------------------------------------------------------
  i1_uart_vvc : entity bitvis_vip_uart.uart_vvc
    generic map(
      GC_DATA_WIDTH   => 8,
      GC_INSTANCE_IDX => GC_UART_VVC_IDX
      )
    port map(
      uart_vvc_rx => uart_vvc_rx,
      uart_vvc_tx => uart_vvc_tx
      );

  -- Static '1' ready signal for the SBI VVC
  ready <= '1';

  -- Toggle the reset after 5 clock periods
  p_arst : arst <= '1', '0' after 5 *C_CLK_PERIOD;

  -----------------------------------------------------------------------------
  -- Clock Generator VVC
  -----------------------------------------------------------------------------
  i_clock_generator_vvc : entity bitvis_vip_clock_generator.clock_generator_vvc
    generic map(
      GC_INSTANCE_IDX    => C_CLOCK_GEN,
      GC_CLOCK_NAME      => "Clock",
      GC_CLOCK_PERIOD    => C_CLK_PERIOD,
      GC_CLOCK_HIGH_TIME => C_CLK_PERIOD / 2
      )
    port map(
      clk => clk
      );




  -----------------------------------------------------------------------------
  -- Model
  -----------------------------------------------------------------------------
  p_model : process is
    constant C_SBI_ADDR_RX_DATA : unsigned(2 downto 0) := "000";

    variable v_data  : std_logic_vector(7 downto 0);

    -- SBI DTT
    alias sbi_dtt : bitvis_vip_sbi.transaction_pkg.t_transaction_info_group is
      global_sbi_transaction_info(GC_SBI_VVC_IDX);

    -- UART DTT
    alias uart_rx_dtt : bitvis_vip_uart.transaction_pkg.t_transaction_info_group is
      global_uart_transaction_info(RX, GC_UART_VVC_IDX);
    alias uart_tx_dtt : bitvis_vip_uart.transaction_pkg.t_transaction_info_group is
      global_uart_transaction_info(TX, GC_UART_VVC_IDX);

    -- UART DUT flag
    alias uart_rx_data_valid is << signal i_uart.i_uart_core.rx_data_valid: std_logic >>;


  begin
    while true loop
      wait on sbi_dtt, uart_rx_dtt, uart_tx_dtt;

      ---------------------------------
      --  SBI
      ---------------------------------
      if sbi_dtt'event then

        case sbi_dtt.bt.operation is
          when WRITE =>
            log(ID_SEQUENCER_SUB, "Monitor request: UART_EXEPECT(), 0x" & to_string(sbi_dtt.bt.data(7 downto 0), HEX), C_SCOPE);
            uart_expect(UART_VVCT, GC_UART_VVC_IDX, RX, sbi_dtt.bt.data(7 downto 0), "Expecting data on UART RX");

          when READ =>

          when CHECK =>

          when others =>
            null;
        end case;
      end if;


      ---------------------------------
      --  UART TX
      ---------------------------------
      if uart_tx_dtt'event then

        case uart_tx_dtt.bt.operation is
          when TRANSMIT =>
            v_data := uart_tx_dtt.bt.data(7 downto 0); -- save expected data, will be set to default by VVC
            debug <= v_data;

            wait until uart_rx_data_valid = '1'; -- DUT UART data ready for SBI read

            log(ID_SEQUENCER_SUB, "Monitor request: SBI_CHECK(), 0x" & to_string(v_data, HEX), C_SCOPE);
            sbi_check(SBI_VVCT, GC_SBI_VVC_IDX, C_SBI_ADDR_RX_DATA, v_data, "RX_DATA");

          when others =>
            null;

        end case;
      end if;


      ---------------------------------
      --  UART RX
      ---------------------------------
      if uart_rx_dtt'event then

        case uart_rx_dtt.bt.operation is
          when RECEIVE =>

          when EXPECT =>

          when others =>
            null;
        end case;
      end if;


    end loop;
    wait;
  end process p_model;


end struct;
