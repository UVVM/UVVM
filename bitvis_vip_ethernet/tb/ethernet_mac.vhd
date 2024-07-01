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

---------------------------------------------------------------------------------------------
-- Description : See library quick reference (under 'doc') and README-file(s)
---------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library bitvis_vip_ethernet;
use bitvis_vip_ethernet.support_pkg.all;

use work.ethernet_mac_pkg.all;

entity ethernet_mac is
  port(
    -- SBI interface
    clk       : in  std_logic;
    sbi_cs    : in  std_logic;
    sbi_addr  : in  unsigned(7 downto 0);
    sbi_rena  : in  std_logic;
    sbi_wena  : in  std_logic;
    sbi_wdata : in  std_logic_vector(7 downto 0);
    sbi_ready : out std_logic;
    sbi_rdata : out std_logic_vector(7 downto 0);
    -- GMII interface (only TX)
    gtxclk    : out std_logic;
    txd       : out std_logic_vector(7 downto 0);
    txen      : out std_logic
  );
end entity ethernet_mac;

architecture behave of ethernet_mac is
  signal mac_dest_addr   : std_logic_vector(47 downto 0) := (others => '0');
  signal mac_src_addr    : std_logic_vector(47 downto 0) := (others => '0');
  signal payload_len     : std_logic_vector(15 downto 0) := (others => '0');
  signal payload_len_int : integer;
  signal payload         : t_byte_array(0 to C_MAX_PAYLOAD_LENGTH - 1);
  signal dummy_reg       : std_logic_vector(7 downto 0)  := (others => '0');

  signal frame_ready : std_logic := '0';
  signal frame_sent  : std_logic := '0';
  signal read_ready  : std_logic := '0';

  type t_state is (s_idle, s_send_pkt);
  signal fsm_tx : t_state := s_idle;
begin

  ------------------------------------------------------------------------------------
  -- SBI interface
  ------------------------------------------------------------------------------------
  -- Write SBI data to the Ethernet MAC registers (can only hold one frame at a time).
  -- Data is transmitted with the LSB first.
  p_sbi_write_regs : process(clk)
    variable v_mac_dest_byte : integer range 0 to 6                    := 0;
    variable v_mac_src_byte  : integer range 0 to 6                    := 0;
    variable v_pay_len_byte  : integer range 0 to 2                    := 0;
    variable v_payload_byte  : integer range 0 to C_MAX_PAYLOAD_LENGTH := 0;
  begin
    if rising_edge(clk) then
      if sbi_cs = '1' and sbi_wena = '1' and sbi_ready = '1' then
        -- Registers are expected to be written in order (payload being the last).
        case sbi_addr is
          when C_ETH_ADDR_MAC_DEST =>
            if v_mac_dest_byte < 6 then
              mac_dest_addr   <= mac_dest_addr(39 downto 0) & sbi_wdata;
              v_mac_dest_byte := v_mac_dest_byte + 1;
            else
              alert(WARNING, "Ethernet MAC: Overwriting register C_ETH_ADDR_MAC_DEST!");
            end if;

          when C_ETH_ADDR_MAC_SRC =>
            if v_mac_src_byte < 6 then
              mac_src_addr   <= mac_src_addr(39 downto 0) & sbi_wdata;
              v_mac_src_byte := v_mac_src_byte + 1;
            else
              alert(WARNING, "Ethernet MAC: Overwriting register C_ETH_ADDR_MAC_SRC!");
            end if;

          when C_ETH_ADDR_PAY_LEN =>
            if v_pay_len_byte < 2 then
              payload_len    <= payload_len(7 downto 0) & sbi_wdata;
              v_pay_len_byte := v_pay_len_byte + 1;
            else
              alert(WARNING, "Ethernet MAC: Overwriting register C_ETH_ADDR_PAY_LEN!");
            end if;

          when C_ETH_ADDR_PAYLOAD =>
            if v_payload_byte < payload_len_int then
              payload(v_payload_byte) <= sbi_wdata;
              v_payload_byte          := v_payload_byte + 1;
            else
              alert(WARNING, "Ethernet MAC: Overwriting register C_ETH_ADDR_PAYLOAD!");
            end if;
            -- Once a complete frame is written, it will be sent via the GMII interface.
            if v_payload_byte = payload_len_int then
              v_mac_dest_byte := 0;
              v_mac_src_byte  := 0;
              v_pay_len_byte  := 0;
              v_payload_byte  := 0;
              frame_ready     <= '1';
            end if;

          when C_ETH_ADDR_DUMMY =>
            dummy_reg <= sbi_wdata;

          when others =>
            alert(ERROR, "Ethernet MAC: SBI write address " & to_hstring(sbi_addr) & " not supported!");
        end case;
      end if;

      if frame_sent = '1' then
        frame_ready <= '0';
      end if;
    end if;
  end process p_sbi_write_regs;

  -- Read the Ethernet MAC dummy register
  p_sbi_read_regs : process(sbi_cs, sbi_rena, sbi_addr)
  begin
    sbi_rdata  <= (others => '0');
    read_ready <= '0';
    if sbi_cs = '1' and sbi_rena = '1' then
      -- Decode read address
      case sbi_addr is
        when C_ETH_ADDR_DUMMY =>
          sbi_rdata  <= dummy_reg;
          read_ready <= '1';

        when others =>
          alert(ERROR, "Ethernet MAC: SBI read address " & to_hstring(sbi_addr) & " not supported!");
      end case;
    end if;
  end process p_sbi_read_regs;

  -- Make sure to receive and send the padding bytes
  payload_len_int <= to_integer(unsigned(payload_len)) when to_integer(unsigned(payload_len)) > C_MIN_PAYLOAD_LENGTH else
                     C_MIN_PAYLOAD_LENGTH;
  -- Only accept new SBI writes after the frame is transmitted
  sbi_ready       <= not frame_ready or read_ready;

  ------------------------------------------------------------------------------------
  -- GMII interface
  ------------------------------------------------------------------------------------
  -- Send Ethernet frames once they have been completely stored in the internal registers.
  p_gmii_send_frame : process(clk)
    variable v_byte_idx : integer range 0 to C_MAX_PACKET_LENGTH := 0;
    variable v_packet   : t_byte_array(0 to C_MAX_PACKET_LENGTH - 1);
    variable v_crc_32   : std_logic_vector(31 downto 0)          := (others => '0');
  begin
    if rising_edge(clk) then
      txd        <= (others => '0');
      txen       <= '0';
      frame_sent <= '0';

      case fsm_tx is
        when s_idle =>
          if frame_ready = '1' and frame_sent = '0' then
            -- Preamble (LSb first)
            v_packet(0 to 6)                                               := convert_slv_to_byte_array(C_PREAMBLE, LOWER_BYTE_LEFT);
            -- SFD (LSb first)
            v_packet(7)                                                    := C_SFD;
            -- MAC destination (LSb first)
            v_packet(8 to 13)                                              := convert_slv_to_byte_array(mac_dest_addr, LOWER_BYTE_LEFT);
            -- MAC source (LSb first)
            v_packet(14 to 19)                                             := convert_slv_to_byte_array(mac_src_addr, LOWER_BYTE_LEFT);
            -- Payload length (LSb first)
            v_packet(20 to 21)                                             := convert_slv_to_byte_array(payload_len, LOWER_BYTE_LEFT);
            -- Payload (LSb first)
            v_packet(22 to 22 + payload_len_int - 1)                       := payload(0 to payload_len_int - 1);
            -- Calculate the FCS with the MAC addresses, payload length and payload data
            v_crc_32                                                       := generate_crc_32(v_packet(8 to 22 + payload_len_int - 1));
            -- Post complement the CRC according to Ethernet standard
            v_crc_32                                                       := not (v_crc_32);
            -- FCS (MSb first). Convert slv to byte_array with MSB first and then reverse the bits in each byte so MSb is transmitted first
            v_packet(22 + payload_len_int to 22 + payload_len_int + 4 - 1) := reverse_vectors_in_array(convert_slv_to_byte_array(v_crc_32, LOWER_BYTE_LEFT));

            v_byte_idx := 0;
            fsm_tx     <= s_send_pkt;
          end if;

        when s_send_pkt =>
          txd  <= v_packet(v_byte_idx);
          txen <= '1';
          if v_byte_idx = 22 + payload_len_int + 4 - 1 then
            frame_sent <= '1';
            fsm_tx     <= s_idle;
          else
            v_byte_idx := v_byte_idx + 1;
          end if;
      end case;
    end if;
  end process p_gmii_send_frame;

  -- Use the same clock for both interfaces
  gtxclk <= clk;

end architecture behave;
