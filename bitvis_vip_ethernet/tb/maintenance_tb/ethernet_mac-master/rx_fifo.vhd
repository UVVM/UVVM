-- This file is part of the ethernet_mac project.
--
-- For the full copyright and license information, please read the
-- LICENSE.md file that was distributed with this source code.

-- Storage for packet reception with FIFO user interface

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ethernet_types.all;
use work.crc32.all;

entity rx_fifo is
	generic(
		-- Bits to use for the size of the memory
		-- The total size is then 2^(MEMORY_SIZE_BITS)
		-- The generic is given as bit count because only sizes
		-- that are a power of two are supported
		MEMORY_SIZE_BITS : positive := 12
	);
	port(
		clock_i                : in  std_ulogic;

		mac_rx_reset_i         : in  std_ulogic;
		mac_rx_clock_i         : in  std_ulogic;
		mac_rx_frame_i         : in  std_ulogic;
		mac_rx_data_i          : in  t_ethernet_data;
		mac_rx_byte_received_i : in  std_ulogic;
		mac_rx_error_i         : in  std_ulogic;

		empty_o                : out std_ulogic;
		rd_en_i                : in  std_ulogic;
		data_o                 : out t_ethernet_data
	);
end entity;

architecture rtl of rx_fifo is
	type t_write_state is (
		WRITE_WAIT,
		WRITE_PACKET,
		WRITE_LENGTH_HIGH,
		WRITE_LENGTH_LOW,
		WRITE_PACKET_VALID,
		WRITE_PACKET_INVALID,
		WRITE_SKIP_FRAME
	);
	signal write_state : t_write_state := WRITE_PACKET_INVALID;

	type t_read_state is (
		READ_WAIT_PACKET,
		READ_WAIT_ACK,
		READ_LENGTH_LOW,
		READ_PACKET
	);
	signal read_state : t_read_state := READ_WAIT_PACKET;

	constant MEMORY_SIZE : positive := 2 ** MEMORY_SIZE_BITS;

	constant FLAG_BYTES          : positive := 1;
	constant PACKET_LENGTH_BYTES : positive := 2;

	type t_memory is array (0 to (MEMORY_SIZE - 1)) of t_ethernet_data;

	-- Use unsigned here instead of simple integer variables to guarantee identical behavior in behavioral and post-translate simulation
	-- Integer variables will wrap around only on reaching 2^32 in behavioral simulation, unsigned will always wrap around correctly.
	subtype t_memory_address is unsigned((MEMORY_SIZE_BITS - 1) downto 0);
	-- Ethernet frames have to be smaller than ~1500 bytes, so 11 bits will suffice for the packet length
	subtype t_packet_length is unsigned(10 downto 0);

	signal memory : t_memory;

	-- Signals in write side clock domain
	signal write_start_address           : t_memory_address;
	signal write_address                 : t_memory_address;
	signal write_packet_length           : t_packet_length;
	signal write_safe_address            : t_memory_address;
	signal write_update_safe_address_req : std_ulogic;
	signal write_update_safe_address_ack : std_ulogic;
	signal write_reset_read_side         : std_ulogic;

	-- Signals in read side clock domain
	signal read_reset                   : std_ulogic := '1';
	signal read_data                    : t_ethernet_data;
	signal read_address                 : t_memory_address;
	-- Address of the last byte that is still part of the currently processed frame in the read process
	signal read_end_address             : t_memory_address;
	signal read_packet_length_high      : unsigned(2 downto 0);
	signal read_update_safe_address_req : std_ulogic;
	signal read_update_safe_address_ack : std_ulogic;

	-- Signals crossing clock domains
	signal update_safe_address : t_memory_address;

	-- Counts the elements in [a, b) in a ring buffer of given size
	-- a and b should have the same range
	function pointer_difference(a : unsigned; b : unsigned; size : positive) return unsigned is
		-- Make sure the result has a matching range
		variable result : unsigned(a'range);
	begin
		if b >= a then
			result := b - a;
		else
			result := size - a + b;
		end if;
		return result;
	end function;
begin
	data_o <= read_data;

	sync_req_inst : entity work.single_signal_synchronizer
		port map(
			clock_target_i => mac_rx_clock_i,
			signal_i       => read_update_safe_address_req,
			signal_o       => write_update_safe_address_req
		);

	sync_ack_inst : entity work.single_signal_synchronizer
		port map(
			clock_target_i => clock_i,
			signal_i       => write_update_safe_address_ack,
			signal_o       => read_update_safe_address_ack
		);

	sync_reset_inst : entity work.single_signal_synchronizer
		port map(
			clock_target_i => clock_i,
			signal_i       => write_reset_read_side,
			signal_o       => read_reset
		);

	write_get_safe_address : process(mac_rx_reset_i, mac_rx_clock_i)
	begin
		if mac_rx_reset_i = '1' then
			write_update_safe_address_ack <= '0';
			write_safe_address            <= (others => '1');
		elsif rising_edge(mac_rx_clock_i) then
			-- Data is read when the read process changes the level on write_update_safe_address_req
			if write_update_safe_address_req /= write_update_safe_address_ack then
				-- Read new safe address
				write_safe_address            <= update_safe_address;
				-- Signal read process that the change was detected
				write_update_safe_address_ack <= not write_update_safe_address_ack;
			end if;
		end if;
	end process;

	write_memory : process(mac_rx_reset_i, mac_rx_clock_i)
		variable write_address_now        : t_memory_address;
		variable write_data               : t_ethernet_data;
		variable write_enable             : boolean;
		variable packet_length_calculated : t_packet_length;
		variable enough_room              : boolean;
	begin
		if mac_rx_reset_i = '1' then
			write_state           <= WRITE_PACKET_INVALID;
			write_start_address   <= (others => '0');
			write_address         <= (others => '0');
			write_reset_read_side <= '1';
		elsif rising_edge(mac_rx_clock_i) then
			-- Default values for variables so no storage is inferred
			write_address_now        := write_address;
			write_enable             := FALSE;
			write_data               := (others => '0');
			packet_length_calculated := (others => '0');
			enough_room              := TRUE;

			case write_state is
				when WRITE_WAIT =>
					-- First byte has definitely been written invalid, read side can go into action now
					write_reset_read_side <= '0';
					if mac_rx_frame_i = '1' then
						if mac_rx_error_i = '1' then
							write_state <= WRITE_SKIP_FRAME;
						else
							if mac_rx_byte_received_i = '1' then
								-- Check whether the 3 header bytes can be written safely to the buffer afterwards
								for i in 0 to 2 loop
									if write_start_address + i = write_safe_address then
										enough_room := FALSE;
									end if;
								end loop;

								if enough_room then
									-- Write first byte
									-- Leave 3 bytes room for data validity indication and packet length
									write_address_now := write_start_address + PACKET_LENGTH_BYTES + FLAG_BYTES;
									write_data        := mac_rx_data_i;
									write_enable      := TRUE;
									write_address     <= write_address_now + 1;

									write_state <= WRITE_PACKET;
								else
									write_state <= WRITE_SKIP_FRAME;
								end if;
							end if;
						end if;
					end if;
				when WRITE_PACKET =>
					if mac_rx_error_i = '1' then
						write_state <= WRITE_SKIP_FRAME;
					end if;
					-- Calculate packet length
					-- Resize as packet_length'length can be greater than memory_address_t'length for small memories
					packet_length_calculated := resize(pointer_difference(write_start_address, write_address, MEMORY_SIZE), packet_length_calculated'length);

					if mac_rx_frame_i = '1' then
						if mac_rx_byte_received_i = '1' then
							-- Write data
							write_data    := mac_rx_data_i;
							write_enable  := TRUE;
							write_address <= write_address + 1;
						end if;

						-- Packet length will overflow after this clock cycle
						if packet_length_calculated = (packet_length_calculated'range => '1') then
							-- Throw frame away
							write_state <= WRITE_SKIP_FRAME;
						end if;

						-- Buffer memory will overflow after this clock cycle
						-- This is always an error as at least one byte must be available even
						-- after the frame has ended to mark the next packet invalid in the buffer.
						if write_address = write_safe_address then
							-- Throw frame away
							write_state <= WRITE_SKIP_FRAME;
						end if;
					-- Error flag is irrelevant if rx_frame_i is low already
					else
						if packet_length_calculated <= (CRC32_BYTES + PACKET_LENGTH_BYTES + FLAG_BYTES) then
							-- Frame is way too short, ignore
							write_state <= WRITE_WAIT;
						end if;
						packet_length_calculated := packet_length_calculated - CRC32_BYTES - PACKET_LENGTH_BYTES - FLAG_BYTES;
						write_packet_length      <= packet_length_calculated;

						-- Write next packet invalid before doing anything else
						-- Read process could read past this packet faster than we can flag the following packet invalid otherwise
						-- for very low network speed/system clock speed ratios
						write_address_now := write_start_address + PACKET_LENGTH_BYTES + FLAG_BYTES + to_integer(packet_length_calculated);
						write_data        := (others => '0');
						write_enable      := TRUE;

						-- Write data length low byte next
						write_state <= WRITE_LENGTH_LOW;
					end if;
				when WRITE_LENGTH_LOW =>
					-- Write length low byte
					write_address_now := write_start_address + 2;
					write_data        := std_ulogic_vector(write_packet_length(7 downto 0));
					write_enable      := TRUE;

					-- Write high byte next
					write_state <= WRITE_LENGTH_HIGH;
				when WRITE_LENGTH_HIGH =>
					-- Write length high byte
					write_address_now := write_start_address + 1;
					write_data        := "00000" & std_ulogic_vector(write_packet_length(10 downto 8));
					write_enable      := TRUE;

					-- Write packet validity indicator next
					write_state <= WRITE_PACKET_VALID;
				when WRITE_PACKET_VALID =>
					write_address_now := write_start_address;
					write_data        := (others => '1'); -- mark valid
					write_enable      := TRUE;

					-- Packet received correctly and completely, move start pointer for next packet ->
					-- Move write pointer past the data of the current frame (excluding FCS) so the next
					-- packet can be written
					-- The FCS will get overwritten as it is not needed for operation of the higher layers.
					write_start_address <= write_start_address + PACKET_LENGTH_BYTES + FLAG_BYTES + to_integer(write_packet_length);
					write_state         <= WRITE_WAIT;
				when WRITE_PACKET_INVALID =>
					-- Mark current/first packet as invalid
					-- This cannot be merged into the WRITE_WAIT state, as WRITE_WAIT needs to write an incoming data byte
					-- into the buffer immediately.
					write_address_now := write_start_address;
					write_data        := (others => '0');
					write_enable      := TRUE;
					write_state       <= WRITE_WAIT;
				when WRITE_SKIP_FRAME =>
					if mac_rx_frame_i = '0' then
						report "Skipped frame" severity error;
						write_state <= WRITE_WAIT;
					end if;
			end case;

			if write_enable then
				memory(to_integer(write_address_now)) <= write_data;
			end if;
		end if;
	end process;

	read_memory : process(clock_i)
		variable read_address_now : t_memory_address;
	begin
		if rising_edge(clock_i) then
			-- Default output value
			empty_o <= '1';

			-- Default variable value to avoid storage
			read_address_now := read_address;

			if read_reset = '1' then
				read_state                    <= READ_WAIT_PACKET;
				read_address                  <= (others => '0');
				read_end_address              <= (others => '0');
				read_data                     <= (others => '0');
				read_update_safe_address_req <= '0';
			else
				case read_state is
					when READ_WAIT_PACKET =>
						-- Wait until data is ready, nobody is trying to get data out (in case the previous state was READ_PACKET)
						-- to prevent read overruns, and the write FSM has ack'ed the update request
						if read_data = (read_data'range => '1') and rd_en_i = '0' and read_update_safe_address_req = read_update_safe_address_ack then
							read_state       <= READ_WAIT_ACK;
							-- Advance to address high byte
							read_address_now := read_address + 1;
							-- Tell the receiver that something is here
							empty_o          <= '1';
						end if;
					when READ_WAIT_ACK =>
						empty_o <= '0';

						if rd_en_i = '1' then
							-- Read address high byte
							read_address_now        := read_address + 1;
							read_state              <= READ_LENGTH_LOW;
							read_packet_length_high <= unsigned(read_data(2 downto 0));
						end if;
					when READ_LENGTH_LOW =>
						empty_o <= '0';
						if rd_en_i = '1' then
							-- Read address low byte
							read_address_now := read_address + 1;
							read_state       <= READ_PACKET;
							-- The end address is the address of the last byte that is still valid, so one byte
							-- needs to be subtracted.
							read_end_address <= read_address_now + to_integer(read_packet_length_high & unsigned(read_data)) - 1;
						end if;
					when READ_PACKET =>
						empty_o <= '0';

						if read_address = read_end_address then
							-- Wait for the last byte to be read out
							if rd_en_i = '1' then
								-- Guarantee that rx_empty_o is high for at least one clock cycle (needed so that the
								-- receiver can sense the end of the packet)
								empty_o                      <= '1';
								read_state                   <= READ_WAIT_PACKET;
								-- Update safe address for write process
								update_safe_address          <= read_end_address;
								read_update_safe_address_req <= not read_update_safe_address_req;
							end if;
						end if;

						if rd_en_i = '1' then
							-- If this was the last byte: go to the first byte following this packet (-> header of the next packet)
							-- No need to skip the FCS here, this is already taken care of in the write process.
							read_address_now := read_address + 1;
						end if;
				end case;

				-- Read data at new address in this clock cycle,
				-- save the value to the signal for the next clock cycle.
				read_data    <= memory(to_integer(read_address_now));
				read_address <= read_address_now;
			end if;
		end if;
	end process;

end architecture;
