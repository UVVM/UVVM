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
-- Description   : This is NOT an example of how to implement a UART core. This is just
--                 a simple test vehicle that can be used to demonstrate the functionality
--                 of the UVVM VVC Framework.
--
--                 See library quick reference (under 'doc') and README-file(s)
------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.uart_pif_pkg.all;
use work.uart_pkg.all;

entity uart_core is
  generic(
    GC_START_BIT                 : std_logic := '0';
    GC_STOP_BIT                  : std_logic := '1';
    GC_CLOCKS_PER_BIT            : integer   := 16;
    GC_MIN_EQUAL_SAMPLES_PER_BIT : integer   := 15); -- Number of equal samples needed for valid bit, uart samples on every clock
  port(
    -- DSP interface and general control signals
    clk  : in  std_logic;
    arst : in  std_logic;
    -- PIF-core interface
    p2c  : in  t_p2c;
    c2p  : out t_c2p;
    -- Interrupt related signals
    rx_a : in  std_logic;
    tx   : out std_logic
  );
end entity uart_core;

architecture rtl of uart_core is
  type t_slv_array is array (3 downto 0) of std_logic_vector(7 downto 0);

  -- tx signals
  signal tx_data       : t_slv_array                  := (others => (others => '0'));
  signal tx_buffer     : std_logic_vector(7 downto 0) := (others => '0');
  signal tx_data_valid : std_logic                    := '0';

  signal tx_ready       : std_logic                                        := '0';
  signal tx_active      : std_logic                                        := '0';
  signal tx_clk_counter : unsigned(f_log2(GC_CLOCKS_PER_BIT) - 1 downto 0) := (others => '0');
  -- count through the bits (12 total)
  signal tx_bit_counter : unsigned(3 downto 0)                             := (others => '0');

  -- receive signals
  signal rx_buffer      : std_logic_vector(7 downto 0)                     := (others => '0');
  signal rx_active      : std_logic                                        := '0';
  signal rx_clk_counter : unsigned(f_log2(GC_CLOCKS_PER_BIT) - 1 downto 0) := (others => '0');
  -- count through the bits (12 total)
  signal rx_bit_counter : unsigned(3 downto 0)                             := (others => '0');
  signal rx_bit_samples : std_logic_vector(GC_CLOCKS_PER_BIT - 1 downto 0) := (others => '0');

  signal rx_data       : t_slv_array := (others => (others => '0'));
  signal rx_data_valid : std_logic   := '0';
  signal rx_data_full  : std_logic   := '0';

  -- rx synced to clk
  signal rx_s : std_logic_vector(1 downto 0) := (others => '1'); -- synchronized serial data input

  signal rx_just_active : boolean;      -- helper signal when we start receiving

  signal parity_err    : std_logic := '0'; -- parity error detected
  signal stop_err      : std_logic := '0'; -- stop error detected
  signal transient_err : std_logic := '0'; -- data value is transient

  signal c2p_i : t_c2p;                 -- Internal version of output
begin
  c2p                     <= c2p_i;
  c2p_i.aro_tx_ready      <= tx_ready;
  c2p_i.aro_rx_data_valid <= rx_data_valid;

  -- synchronize rx input (async)
  p_rx_s : process(clk, arst) is
  begin
    if arst = '1' then
      rx_s <= (others => '1');
    elsif rising_edge(clk) then
      rx_s <= rx_s(0) & rx_a;
    end if;
  end process p_rx_s;

  ---------------------------------------------------------------------------
  -- Transmit process; drives tx serial output.
  --
  -- Stores 4 pending bytes in the tx_data array, and the byte currently
  -- being output in the tx_buffer register.
  --
  -- Tx_buffer is filled with data from tx_data(0) if there is valid data
  -- available (tx_data_valid is active), and no other byte is currently
  -- being output (tx_active is inactive).
  --
  -- Data received via SBI is inserted in tx_data at the index pointed to
  -- by vr_tx_data_idx. vr_tx_data_idx is incremented when a new byte is
  -- received via SBI, and decremented when a new byte is loaded into
  -- tx_buffer.
  ---------------------------------------------------------------------------
  uart_tx : process(clk, arst) is
    variable vr_tx_data_idx : unsigned(2 downto 0) := (others => '0');
  begin                                 -- process uart_tx
    if arst = '1' then                  -- asynchronous reset (active high)
      tx_data        <= (others => (others => '0'));
      tx_buffer      <= (others => '0');
      tx_data_valid  <= '0';
      tx_ready       <= '1';
      tx_active      <= '0';
      tx_bit_counter <= (others => '0');
      tx_clk_counter <= (others => '0');
      tx             <= '1';
      vr_tx_data_idx := (others => '0');
    elsif rising_edge(clk) then         -- rising clock edge

      -- There is valid data in tx_data.
      -- Load the tx_buffer and activate TX operation.
      -- Decrement vr_tx_data_idx.
      if tx_data_valid = '1' and tx_active = '0' then
        tx_active <= '1';
        tx_buffer <= tx_data(0);
        tx_data   <= x"00" & tx_data(3 downto 1);

        if vr_tx_data_idx > 0 then
          -- Decrement idx
          if vr_tx_data_idx < 3 then
            vr_tx_data_idx := vr_tx_data_idx - 1;
          else                          -- vr_tx_data_idx = 3

            -- Special case for idx=3 (max).
            -- When tx_data is full (tx_ready = '0'), we do not wish to
            -- decrement the idx. The reason is that the idx points
            -- to where the next incoming data byte shall be stored,
            -- which is still idx 3.
            -- Therefore, only decrement when tx_ready = '1'.
            if tx_ready = '1' then
              vr_tx_data_idx := vr_tx_data_idx - 1;
            end if;
          end if;
        else
          -- vr_tx_data_idx already at 0,
          -- which means that the final byte in tx_data
          -- was just loaded into tx_buffer, no more valid
          -- data left in tx_data.
          tx_data_valid <= '0';
          tx_active     <= '0';
        end if;
        -- Tx is now ready to receive another byte.
        tx_ready <= '1';
      end if;

      -- loading the tx_data shift reg
      if tx_ready = '1' then
        if p2c.awo_tx_data_we = '1' then
          tx_data(to_integer(vr_tx_data_idx)) <= p2c.awo_tx_data;
          tx_data_valid                       <= '1';

          -- Increment idx if tx_data not full.
          if vr_tx_data_idx < 3 then
            vr_tx_data_idx := vr_tx_data_idx + 1;
          else                          -- tx_data full
            tx_ready <= '0';
          end if;
        end if;
      end if;

      if tx_active = '0' then
        -- default
        tx_clk_counter <= (others => '0');
        tx_bit_counter <= (others => '0');
        tx             <= '1';          -- idle as default
      else
        -- tx clock counter keeps running when active
        if tx_clk_counter <= GC_CLOCKS_PER_BIT - 1 then
          tx_clk_counter <= tx_clk_counter + 1;
        else
          tx_clk_counter <= (others => '0');
        end if;
        -- GC_CLOCKS_PER_BIT tx clocks per tx bit
        if tx_clk_counter >= GC_CLOCKS_PER_BIT - 1 then
          tx_bit_counter <= tx_bit_counter + 1;
        end if;

        -- Assign value to tx based on current value of tx_bit_counter
        if to_integer(tx_bit_counter) = 0 then
          tx <= GC_START_BIT;
        elsif to_integer(tx_bit_counter) <= p2c.rw_num_data_bits then
          -- mux out the correct tx bit
          tx <= tx_buffer(to_integer(tx_bit_counter) - 1);
        elsif to_integer(tx_bit_counter) = p2c.rw_num_data_bits + 1 then
          if p2c.rw_num_data_bits = 8 then
            tx <= odd_parity(tx_buffer);
          elsif p2c.rw_num_data_bits = 7 then
            tx <= odd_parity(tx_buffer(6 downto 0));
          end if;
        elsif to_integer(tx_bit_counter) = p2c.rw_num_data_bits + 2 then
          tx <= GC_STOP_BIT;
        else
          tx        <= '1';
          tx_active <= '0';
        end if;
      end if;
    end if;
  end process uart_tx;

  -- Data is set on the output when available on rx_data(0)
  c2p_i.aro_rx_data <= rx_data(0);

  ---------------------------------------------------------------------------
  -- Receive process
  ---------------------------------------------------------------------------
  uart_rx : process(clk, arst) is
    variable vr_rx_data_idx   : unsigned(2 downto 0) := (others => '0');
    variable v_error_detected : boolean              := false;
  begin                                 -- process uart_tx
    if arst = '1' then                  -- asynchronous reset (active high)
      rx_active        <= '0';
      rx_just_active   <= false;
      rx_data          <= (others => (others => '0'));
      rx_data_valid    <= '0';
      rx_bit_samples   <= (others => '1');
      rx_buffer        <= (others => '0');
      rx_clk_counter   <= (others => '0');
      rx_bit_counter   <= (others => '0');
      stop_err         <= '0';
      parity_err       <= '0';
      transient_err    <= '0';
      vr_rx_data_idx   := (others => '0');
      rx_data_full     <= '1';
      v_error_detected := false;
    elsif rising_edge(clk) then         -- rising clock edge

      -- Perform read.
      -- When there is data available in rx_data,
      -- output the data when read enable detected.
      if p2c.aro_rx_data_re = '1' and rx_data_valid = '1' then
        rx_data      <= x"00" & rx_data(3 downto 1);
        rx_data_full <= '0';

        if vr_rx_data_idx > 0 then
          vr_rx_data_idx := vr_rx_data_idx - 1;
          if vr_rx_data_idx = 0 then    -- rx_data empty
            rx_data_valid <= '0';
          end if;
        end if;
      end if;

      -- always shift in new synchronized serial data
      rx_bit_samples <= rx_bit_samples(GC_CLOCKS_PER_BIT - 2 downto 0) & rx_s(1);

      -- look for enough GC_START_BITs in rx_bit_samples vector
      if rx_active = '0' and (find_num_hits(rx_bit_samples, GC_START_BIT) >= GC_CLOCKS_PER_BIT - 1) then
        rx_active      <= '1';
        rx_just_active <= true;
      end if;

      if rx_active = '0' then
        -- defaults
        stop_err         <= '0';
        parity_err       <= '0';
        transient_err    <= '0';
        rx_clk_counter   <= (others => '0');
        rx_bit_counter   <= (others => '0');
        v_error_detected := false;
      else
        -- We could check when we first enter whether we find the full number
        -- of start samples and adjust the time we start rx_clk_counter by a
        -- clock cycle - to hit the eye of the rx data best possible.
        if rx_just_active then
          if find_num_hits(rx_bit_samples, GC_START_BIT) = GC_CLOCKS_PER_BIT then
            -- reset rx_clk_counter
            rx_clk_counter <= (others => '0');
          end if;
          rx_just_active <= false;
        else
          -- loop clk counter
          if rx_clk_counter <= GC_CLOCKS_PER_BIT - 1 then
            rx_clk_counter <= rx_clk_counter + 1;
          else
            rx_clk_counter <= (others => '0');
          end if;
        end if;

        -- shift in data, check for consistency and forward
        if rx_clk_counter >= GC_CLOCKS_PER_BIT - 1 then
          rx_bit_counter <= rx_bit_counter + 1;

          if transient_error(rx_bit_samples, GC_MIN_EQUAL_SAMPLES_PER_BIT) then
            transient_err    <= '1';
            v_error_detected := true;
          end if;

          -- are we done? not counting the start bit
          if to_integer(rx_bit_counter) >= p2c.rw_num_data_bits + 1 then
            rx_active <= '0';
          end if;

          if to_integer(rx_bit_counter) < p2c.rw_num_data_bits then
            -- mux in new bit
            rx_buffer(to_integer(rx_bit_counter)) <= find_most_repeated_bit(rx_bit_samples);
          elsif to_integer(rx_bit_counter) = p2c.rw_num_data_bits then
            -- check parity based on number of data bits
            if p2c.rw_num_data_bits = 8 then -- num_data_bits = 8
              if (odd_parity(rx_buffer(7 downto 0)) /= find_most_repeated_bit(rx_bit_samples)) then
                parity_err       <= '1';
                v_error_detected := true;
              end if;
            elsif p2c.rw_num_data_bits = 7 then -- num_data_bits = 7
              if (odd_parity(rx_buffer(6 downto 0)) /= find_most_repeated_bit(rx_bit_samples)) then
                parity_err       <= '1';
                v_error_detected := true;
              end if;
            end if;
          elsif to_integer(rx_bit_counter) = p2c.rw_num_data_bits + 1 then
            rx_data_valid <= '1';     -- ready for higher level protocol

            -- check stop bit, and end byte receive
            if find_most_repeated_bit(rx_bit_samples) /= GC_STOP_BIT then
              stop_err         <= '1';
              v_error_detected := true;
            end if;

            -- Data not valid on error
            if v_error_detected then
              rx_data_valid <= '0';
            else
              -- Add data bits to rx_data
              if p2c.rw_num_data_bits = 8 then -- num_data_bits = 8
                rx_data(to_integer(vr_rx_data_idx)) <= rx_buffer;
              elsif p2c.rw_num_data_bits = 7 then -- num_data_bits = 7
                rx_data(to_integer(vr_rx_data_idx)) <= ("0" & rx_buffer(p2c.rw_num_data_bits-1 downto 0));
              end if;
              if vr_rx_data_idx < 3 then
                vr_rx_data_idx := vr_rx_data_idx + 1;
              else
                rx_data_full <= '1';
              end if;
            end if;
          else
            rx_active      <= '0';
            rx_bit_samples <= (others => '1');
          end if;
        end if;
      end if;
    end if;
  end process uart_rx;

  p_busy_assert : process(clk) is
  begin
    if rising_edge(clk) then
      assert not (p2c.awo_tx_data_we = '1' and tx_ready = '0')
      report "Trying to transmit new UART data while transmitter is busy"
      severity error;
    end if;
  end process;

  assert stop_err /= '1'
  report "Stop bit error detected!"
  severity error;

  assert parity_err /= '1'
  report "Parity error detected!"
  severity error;

  assert transient_err /= '1'
  report "Transient error detected!"
  severity error;

end architecture rtl;
