------------------------------------------------------------------------------
--
--     Purpose : AXI Slave model - a simple memory for write/read access
-- 
--      Author : Jorgen Krohn <jk@inventas.no>
--
-- Description : A simple AXI slave model.
--               - Will reorder write responses if a new write command with a
--                 different ID is started before the first one is done. This
--                 is to test that the master can handled out of order write
--                 responses
--
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library work;
use work.axi_slave_model_pkg.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

entity axi_slave_model is
  generic(
    C_MEMORY_SIZE   : integer := 4096; -- size in bytes
    C_MEMORY_START  : unsigned(31 downto 0) := x"00000000"  -- address offset to start on
    );
  port (
    aclk           : in  std_logic;
    aresetn        : in  std_logic;
    wr_port_in     : in  t_axi_wr_slave_in_if;
    wr_port_out    : out t_axi_wr_slave_out_if;
    rd_port_in     : in  t_axi_rd_slave_in_if;
    rd_port_out    : out t_axi_rd_slave_out_if
    );
end entity axi_slave_model;

architecture behav of axi_slave_model is

  constant C_SCOPE : string := "AXI SLAVE MODEL";

  constant C_BURST_TYPE_FIXED : std_logic_vector(1 downto 0) := "00";
  constant C_BURST_TYPE_INCR  : std_logic_vector(1 downto 0) := "01";
  constant C_BURST_TYPE_WRAP  : std_logic_vector(1 downto 0) := "10";

  constant C_WDATA_WIDTH : natural := wr_port_in.wdata'length;
  constant C_RDATA_WIDTH : natural := rd_port_out.rdata'length;

  type   t_read_state is (WAIT_FOR_ADDRESS, WAIT_FOR_NEXT_DATA, WAIT_FOR_LAST_DATA);
  type   t_write_state is (WAIT_FOR_ADDRESS, WAIT_FOR_NEXT_DATA, SEND_RESPONSE);

  type   memory is array (INTEGER range <>) of std_logic_vector(7 downto 0);
  shared variable v_mem_model : memory(0 to C_MEMORY_SIZE) := (others=>(others=>'0'));

  signal rd_state   : t_read_state;
  signal wr_state   : t_write_state;
  signal wdata      : std_logic_vector(C_WDATA_WIDTH-1 downto 0);

  -- Getting burst size from a axsize value
  function get_burst_size (
    axsize : std_logic_vector(2 downto 0)
  ) return positive is
    variable v_burst_size : positive;
  begin
    case axsize is
      when "000" =>
        v_burst_size := 1;
      when "001" =>
        v_burst_size := 2;
      when "010" =>
        v_burst_size := 4;
      when "011" =>
        v_burst_size := 8;
      when "100" =>
        v_burst_size := 16;
      when "101" =>
        v_burst_size := 32;
      when "110" =>
        v_burst_size := 64;
      when "111" =>
        v_burst_size := 128;
      when others =>
        alert(tb_error, "Illegal burst size: " & to_string(axsize), C_SCOPE);
    end case;
    return v_burst_size;
  end function get_burst_size;

  -- Increment address in a burst. This depends on the burst type and the burst size
  function increment_address (
    current_address : unsigned;
    axburst         : std_logic_vector(1 downto 0);
    axsize          : std_logic_vector(2 downto 0)
  ) return unsigned is
    variable v_address        : unsigned(current_address'length-1 downto 0) := (others=>'0');
    variable v_increment      : integer := get_burst_size(axsize);
    variable v_increment_bits : integer := integer(ceil(log2(real(v_increment))));
  begin
    case axburst is
      when C_BURST_TYPE_FIXED =>
        v_address := current_address;
      when C_BURST_TYPE_INCR =>
        -- Align the address by setting the lsbs to zero (depending on axsize/v_increment)
        v_address(v_address'length-1 downto 0 + v_increment_bits) := current_address(v_address'length-1 downto 0 + v_increment_bits);
        -- Increment
        v_address := v_address + v_increment;
      when C_BURST_TYPE_WRAP =>
        alert(tb_error, "Wrap burst not supported", C_SCOPE);
      when others =>
        alert(tb_error, "Illegal burst type: " & to_string(axburst), C_SCOPE);
    end case;
    return v_address;
  end function increment_address;
  
begin

  -- Handling write accesses
  axi_write_states : process (aclk, aresetn)
    variable v_mem_addr         : unsigned(wr_port_in.awaddr'length-1 downto 0);
    variable v_awlen            : unsigned(7 downto 0);
    variable v_awsize           : std_logic_vector(2 downto 0);
    variable v_awburst          : std_logic_vector(1 downto 0);
    variable v_awid             : std_logic_vector(wr_port_in.awid'length-1 downto 0);
    variable v_buffered_bid     : std_logic_vector(wr_port_out.bid'length-1 downto 0);
    variable v_bid_is_buffered  : boolean := false;
  begin
    if aresetn = '0' then -- slave reset state
      wr_port_out.bvalid  <= '0';
      wr_port_out.awready <= '1';
      wr_port_out.wready  <= '1';
      wr_port_out.bresp   <= (others => '0');
      wr_port_out.bid     <= (wr_port_out.bid'range => '0');
      wr_port_out.buser   <= (wr_port_out.buser'range => '0');
    elsif rising_edge(aclk) then
      case wr_state is
        when WAIT_FOR_ADDRESS =>
          -- Write address access
          if wr_port_in.awvalid = '1' and wr_port_out.awready = '1' then
            v_awlen     := unsigned(wr_port_in.awlen);
            v_awsize    := wr_port_in.awsize;
            v_awburst   := wr_port_in.awburst;
            v_awid      := wr_port_in.awid;
            v_mem_addr  := unsigned(wr_port_in.awaddr);
            check_value(v_mem_addr < C_MEMORY_SIZE, tb_error, "Checking if the memory address is within the memory size", C_SCOPE);
            wr_port_out.awready <= '0';
            -- Store write data if write data is written
            if wr_port_out.wready = '0' or (wr_port_in.wvalid = '1' and wr_port_out.wready = '1') then -- Data written
              if wr_port_out.wready = '0' then
                -- Writing previously written data to memory
                for i in 0 to (C_WDATA_WIDTH/8)-1 loop
                  if (wr_port_in.wstrb(i) = '1') then
                    v_mem_model(to_integer(v_mem_addr)+i) := wdata((i+1)*8-1 downto i*8);
                  end if;
                end loop;
              else
                -- Writing new data to memory
                for i in 0 to (C_WDATA_WIDTH/8)-1 loop
                  if (wr_port_in.wstrb(i) = '1') then
                    v_mem_model(to_integer(v_mem_addr)+i) := wr_port_in.wdata((i+1)*8-1 downto i*8);
                  end if;
                end loop;
              end if;
              if v_awlen = 0 then
                -- Last data word
                wr_port_out.bvalid  <= '1';
                wr_port_out.bid     <= v_awid;
                wr_port_out.awready <= '0';
                wr_port_out.wready <= '0';
                check_value(wr_port_in.wlast, '1', error, "Checking WLAST on the last word", C_SCOPE);
                wr_state <= SEND_RESPONSE;
              else
                -- More data words expected
                wr_port_out.awready <= '0';
                wr_port_out.wready <= '1';
                v_mem_addr := increment_address(v_mem_addr, v_awburst, v_awsize);
                v_awlen := v_awlen - 1;
                wr_state <= WAIT_FOR_NEXT_DATA;
              end if;
            else -- No data written yet
              wr_state <= WAIT_FOR_NEXT_DATA;
            end if;
          elsif wr_port_in.wvalid = '1' and wr_port_out.wready = '1' then
            -- Data written before address
            wdata <= wr_port_in.wdata;
            wr_port_out.wready <= '0';
          end if;

        when WAIT_FOR_NEXT_DATA =>
          if wr_port_in.wvalid = '1' and wr_port_out.wready = '1' then
            -- Writing new data to memory
            for i in 0 to (C_WDATA_WIDTH/8)-1 loop
              if (wr_port_in.wstrb(i) = '1') then
                v_mem_model(to_integer(v_mem_addr)+i) := wr_port_in.wdata((i+1)*8-1 downto i*8);
              end if;
            end loop;
            if v_awlen = 0 then
              -- Last data word
              if wr_port_in.awvalid = '1' and wr_port_in.awid /= v_awid and not v_bid_is_buffered then
                -- We are receiving another request with a different ID, so we are waiting 
                -- to send response until after the next one. This is to test that the master is 
                -- able to receive write responses out of order
                v_bid_is_buffered   := true;
                wr_port_out.wready  <= '1';
                wr_port_out.awready <= '1';
                v_buffered_bid      := v_awid;
                wr_state <= WAIT_FOR_ADDRESS;
              else
                wr_port_out.bvalid  <= '1';
                wr_port_out.bid     <= v_awid;
                wr_port_out.wready  <= '0';
                check_value(wr_port_in.wlast, '1', error, "Checking WLAST on the last word", C_SCOPE);
                wr_state <= SEND_RESPONSE;
              end if;
            else
              -- More data words expected
              wr_port_out.wready <= '1';
              v_mem_addr := increment_address(v_mem_addr, v_awburst, v_awsize);
              v_awlen := v_awlen - 1;
            end if;
          end if;

        when SEND_RESPONSE =>
          -- Write response
          if wr_port_out.bvalid = '1' and wr_port_in.bready = '1' then
            if v_bid_is_buffered then
              -- Sending a second response
              wr_port_out.bid <= v_buffered_bid;
              v_bid_is_buffered := false;
            else
              -- Access completed
              wr_port_out.bvalid  <= '0';
              wr_port_out.bid     <= (wr_port_out.bid'range => '0');
              wr_port_out.wready  <= '1';
              wr_port_out.awready <= '1';
              wr_state <= WAIT_FOR_ADDRESS;
            end if;
          end if;

      end case;
    end if;
  end process;

  -- Handling read accesses
  axi_read_states : process (aclk, aresetn)
    variable i          : integer;
    variable v_mem_addr : unsigned(rd_port_in.araddr'length-1 downto 0);
    variable v_arlen    : unsigned(7 downto 0);
    variable v_arsize   : std_logic_vector(2 downto 0);
    variable v_arburst  : std_logic_vector(1 downto 0);
    variable v_arid     : std_logic_vector(rd_port_in.arid'length-1 downto 0);

    variable v_delayed_addr         : unsigned(rd_port_in.araddr'length-1 downto 0);
    variable v_delayed_arlen        : unsigned(7 downto 0);
    variable v_delayed_arsize       : std_logic_vector(2 downto 0);
    variable v_delayed_arburst      : std_logic_vector(1 downto 0);
    variable v_delayed_arid         : std_logic_vector(rd_port_in.arid'length-1 downto 0);
    variable v_response_is_delayed  : boolean := false;
  begin
    if aresetn = '0' then -- slave reset state
      rd_port_out.rvalid  <= '0';
      rd_port_out.rlast   <= '0';
      rd_port_out.arready <= '1';
      rd_port_out.rdata   <= (rd_port_out.rdata'range => '0');
      rd_port_out.rresp   <= (others => '0');
      rd_port_out.rid     <= (rd_port_out.rid'range => '0');
      rd_port_out.ruser   <= (rd_port_out.ruser'range => '0');
      rd_state            <= WAIT_FOR_ADDRESS;
    elsif rising_edge(aclk) then
      case rd_state is
        when WAIT_FOR_ADDRESS =>
          -- read address channel
          if rd_port_in.arvalid = '1' and rd_port_out.arready = '1' then
            v_arlen   := unsigned(rd_port_in.arlen);
            v_arsize  := rd_port_in.arsize;
            v_arburst := rd_port_in.arburst;
            v_arid    := rd_port_in.arid;
            rd_port_out.arready <= '0';
            rd_port_out.rvalid <= '1';
            rd_port_out.rid <= v_arid;
            -- check that address is in valid region (within memory model)
            v_mem_addr := unsigned(rd_port_in.araddr);
            check_value(v_mem_addr < C_MEMORY_SIZE, tb_error, "Checking if the memory address is within the memory size", C_SCOPE);
            for i in 0 to (C_RDATA_WIDTH/8)-1 loop
              rd_port_out.rdata((i+1)*8-1 downto i*8) <= v_mem_model(to_integer(v_mem_addr)+i);
            end loop;
            if v_arlen = 0 then
              -- Last data word
              rd_port_out.rlast <= '1';
              rd_state <= WAIT_FOR_LAST_DATA;
            else
              v_arlen := v_arlen - 1;
              v_mem_addr := increment_address(v_mem_addr, v_arburst, v_arsize);
              rd_state <= WAIT_FOR_NEXT_DATA;
            end if;
          end if;

        when WAIT_FOR_NEXT_DATA =>
          if (rd_port_in.rready = '1') then
            -- If a new read command is started with a different ID, we start responding to the new one
            -- in order to test "out of order" read data response
            if rd_port_in.arvalid = '1' and not v_response_is_delayed and rd_port_in.arid /= v_arid then
              -- Store the current state
              v_response_is_delayed := true;
              v_delayed_addr        := v_mem_addr;
              v_delayed_arlen       := v_arlen;
              v_delayed_arsize      := v_arsize;
              v_delayed_arburst     := v_arburst;
              v_delayed_arid        := v_arid;
              -- Return to the WAIT_FOR_ADDRESS state to respond to the new command
              rd_port_out.rid       <= (rd_port_out.rid'range => '0');
              rd_port_out.rdata     <= (rd_port_out.rdata'range => '0');
              rd_port_out.rlast     <= '0';
              rd_port_out.rvalid    <= '0';
              rd_port_out.arready   <= '1';
              rd_state              <= WAIT_FOR_ADDRESS;
            else
              -- We continue with the transfer:
              -- Previous data word has been read. We output the next data word
              for i in 0 to (C_RDATA_WIDTH/8)-1 loop
                rd_port_out.rdata((i+1)*8-1 downto i*8) <= v_mem_model(to_integer(v_mem_addr)+i);
              end loop;
                -- Updating the memory address and the remaining words
              if v_arlen = 0 then
                -- Last data word
                rd_port_out.rlast <= '1';
                rd_state <= WAIT_FOR_LAST_DATA;
              else
                v_arlen := v_arlen - 1;
                v_mem_addr := increment_address(v_mem_addr, v_arburst, v_arsize);
              end if;
            end if;
          end if;

        when WAIT_FOR_LAST_DATA =>
          if (rd_port_in.rready = '1') then
            if v_response_is_delayed then
              -- We need to finish the response that was aborted earlier
              v_response_is_delayed := false;
              v_mem_addr            := v_delayed_addr;
              v_arlen               := v_delayed_arlen;
              v_arsize              := v_delayed_arsize;
              v_arburst             := v_delayed_arburst;
              v_arid                := v_delayed_arid;
              rd_port_out.rid       <= v_arid;
              for i in 0 to (C_RDATA_WIDTH/8)-1 loop
                rd_port_out.rdata((i+1)*8-1 downto i*8) <= v_mem_model(to_integer(v_mem_addr)+i);
              end loop;
              if v_arlen > 0 then
                -- We have more then one word left, we go back to the WAIT_FOR_NEXT_DATA state
                v_arlen           := v_arlen - 1;
                v_mem_addr        := increment_address(v_mem_addr, v_arburst, v_arsize);
                rd_port_out.rlast <= '0';
                rd_state          <= WAIT_FOR_NEXT_DATA;
              end if;
            else
              rd_port_out.rid     <= (rd_port_out.rid'range => '0');
              rd_port_out.rdata   <= (rd_port_out.rdata'range => '0');
              rd_port_out.rlast   <= '0';
              rd_port_out.rvalid  <= '0';
              rd_port_out.arready <= '1';
              rd_state            <= WAIT_FOR_ADDRESS;
            end if;
          end if;

      end case;

    end if;
  end process;
  
end behav;
