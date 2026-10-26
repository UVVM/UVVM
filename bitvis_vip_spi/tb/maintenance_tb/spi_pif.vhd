-------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

-- Include Verification IPs
library bitvis_vip_sbi;
use bitvis_vip_sbi.sbi_bfm_pkg.all;

entity spi_pif is
  generic(
    GC_SLAVE_ADDR : unsigned(7 downto 0) := "10101010";
    GC_DATA_WIDTH : natural              := 32
  );
  port(
    clk        : in    std_logic;
    arst       : in    std_logic;
    -- SBI
    sbi_if     : inout t_sbi_if(addr(7 downto 0), wdata(GC_DATA_WIDTH - 1 downto 0), rdata(GC_DATA_WIDTH - 1 downto 0)) := (addr   => (others => 'Z'),
                                                                                                                            wdata  => (others => 'Z'),
                                                                                                                            rdata  => (others => '0'),
                                                                                                                            ready  => '0',
                                                                                                                            others => 'Z');
    -- SPI
    spi_ss     : in    std_logic;       -- need this to detect if an operation is in progress
    ---- parallel interface ----
    -- di_req_i   : in std_logic;                                       -- preload lookahead data request line
    di_o       : out   std_logic_vector(GC_DATA_WIDTH - 1 downto 0)                                                     := (others => 'X'); -- parallel data in (clocked on rising spi_clk after last bit)
    wren_o     : out   std_logic                                                                                        := 'X'; -- user data write enable, starts transmission when interface is idle
    wr_ack_i   : in    std_logic;       -- write acknowledge
    do_valid_i : in    std_logic;       -- do_o data valid signal, valid during one spi_clk rising edge.
    do_i       : in    std_logic_vector(GC_DATA_WIDTH - 1 downto 0) -- parallel output (clocked on rising spi_clk after last bit)
  );
end entity spi_pif;

--=================================================================================================
--=================================================================================================

architecture struct of spi_pif is

  signal sbi_wr_rdy : std_logic := '0';
  signal sbi_rd_rdy : std_logic := '0';

  signal spi_to_sbi_data     : std_logic_vector(GC_DATA_WIDTH - 1 downto 0);
  signal spi_ss_active_level : std_logic := '0';

  type t_sbi_write_state is (IDLE, AWAIT_ACK);
  signal sbi_write_state : t_sbi_write_state := IDLE;

begin

  sbi_if.ready <= sbi_wr_rdy or sbi_rd_rdy;

  p_sbi_read_reg : process(sbi_if.cs, sbi_if.addr, sbi_if.rena, spi_to_sbi_data)
  begin
    -- default values
    sbi_if.rdata(GC_DATA_WIDTH - 1 downto 0) <= (others => '0');
    sbi_rd_rdy                               <= '0';

    if sbi_if.cs = '1' and sbi_if.rena = '1' then
      if to_integer(sbi_if.addr) = to_integer(GC_SLAVE_ADDR) then
        sbi_rd_rdy   <= '1';
        sbi_if.rdata <= spi_to_sbi_data;
      end if;
    end if;
  end process p_sbi_read_reg;

  p_sbi_write_reg : process(clk, arst)
  begin
    if arst = '1' then
      di_o            <= (others => '0');
      wren_o          <= '0';
      sbi_wr_rdy      <= '0';
      sbi_write_state <= IDLE;
    elsif rising_edge(clk) then
      sbi_wr_rdy <= '0';                -- default
      case sbi_write_state is
        when IDLE =>
          if to_X01(spi_ss) = not spi_ss_active_level then -- SPI idle. Will wait until finished if SPI is active.
            if sbi_if.cs = '1' and sbi_if.wena = '1' then
              if to_integer(sbi_if.addr) = to_integer(GC_SLAVE_ADDR) then
                if sbi_wr_rdy /= '1' then
                  di_o            <= sbi_if.wdata;
                  wren_o          <= '1';
                  sbi_wr_rdy      <= '1'; -- sbi wr ack
                  sbi_write_state <= AWAIT_ACK;
                end if;
              end if;
            end if;
          end if;
        when AWAIT_ACK =>
          if wr_ack_i = '1' then
            wren_o          <= '0';
            sbi_write_state <= IDLE;
          end if;
      end case;
    end if;
  end process p_sbi_write_reg;

  -- p_i2c_slave_din_rdy : process(clk, arst)
  -- begin
  -- if arst = '1' then
  -- i2c_slave_din_rdy   <= '1';
  -- elsif rising_edge(clk) then
  -- if di_req_i = '1' then
  -- i2c_slave_din_rdy <= '1';
  -- end if;

  -- if sbi_wr_rdy = '1' then -- ready only high when accepting data, more like an ack actually
  -- -- New value written from SBI. No longer ready.
  -- i2c_slave_din_rdy <= '0';
  -- end if;
  -- end if;
  -- end process p_i2c_slave_din_rdy;

  p_spi_receive_reg : process(clk, arst)
  begin
    if arst = '1' then
      spi_to_sbi_data <= (others => '0');
    elsif rising_edge(clk) then
      if do_valid_i = '1' then
        spi_to_sbi_data <= do_i;
      end if;
    end if;
  end process p_spi_receive_reg;

end struct;
