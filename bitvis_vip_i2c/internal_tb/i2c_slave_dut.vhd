-------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

-- Include Verification IPs
library bitvis_vip_i2c;
use bitvis_vip_i2c.i2c_bfm_pkg.all;

library bitvis_vip_sbi;
use bitvis_vip_sbi.sbi_bfm_pkg.all;

entity i2c_slave_dut is
  generic (
    GC_SLAVE_ADDR : unsigned(6 downto 0) := "0101010"
  );
  port(
    clk             : in    std_logic;
    arst            : in    std_logic;
    -- SBI
    sbi_cs          : in    std_logic;
    sbi_addr        : in    unsigned(6 downto 0);
    sbi_rd          : in    std_logic;
    sbi_wr          : in    std_logic;
    sbi_wdata       : in    std_logic_vector(7 downto 0);
    sbi_ready       : out   std_logic;
    sbi_rdata       : out   std_logic_vector(7 downto 0);
    -- I2C
    i2c_vvc_if      : inout t_i2c_if
  );
end entity i2c_slave_dut;


--=================================================================================================
--=================================================================================================

architecture struct of i2c_slave_dut is

  signal i2c_slave_din_req    : std_logic;
  signal i2c_slave_din        : std_logic_vector(7 downto 0);
  signal i2c_slave_din_rdy    : std_logic;
  signal i2c_slave_dout_valid : std_logic;
  signal i2c_slave_dout       : std_logic_vector(7 downto 0);

  signal i2c_to_sbi : std_logic_vector(7 downto 0);

  signal sbi_wr_rdy : std_logic := '0';
  signal sbi_rd_rdy : std_logic := '0';

begin

  sbi_ready <= sbi_wr_rdy or sbi_rd_rdy;

  p_sbi_read_reg : process(sbi_cs, sbi_addr, sbi_rd, i2c_to_sbi)
  begin
    -- default values
    sbi_rdata(7 downto 0)   <= (others => '0');
    sbi_rd_rdy <= '0';

      if sbi_cs = '1' and sbi_rd = '1' then
        if sbi_addr = GC_SLAVE_ADDR then
          sbi_rd_rdy <= '1';
          sbi_rdata <= i2c_to_sbi;
        end if;
      end if;
  end process p_sbi_read_reg;

  p_sbi_write_reg : process(clk, arst)
  begin
    if arst = '1' then
     i2c_slave_din       <= (others => '0');
     sbi_wr_rdy          <= '0';
    elsif rising_edge(clk) then
      sbi_wr_rdy <= '0';

      if sbi_cs = '1' and sbi_wr = '1' then
        if sbi_addr = GC_SLAVE_ADDR then
          if i2c_slave_din_rdy = '1' then
            if sbi_wr_rdy /= '1' or (sbi_wr_rdy = '1' and i2c_slave_din_req = '1') then -- shall only be high for 1 clk at a time, unless i2c_slave_din_req is '1'.
              i2c_slave_din <= sbi_wdata;
              sbi_wr_rdy    <= '1';
            end if;
          end if;
        end if;
      end if;
    end if;
  end process p_sbi_write_reg;

  p_i2c_slave_din_rdy : process(clk, arst)
  begin
    if arst = '1' then
     i2c_slave_din_rdy   <= '1';
    elsif rising_edge(clk) then
      if i2c_slave_din_req = '1' then
        i2c_slave_din_rdy <= '1';
      end if;

      if sbi_wr_rdy = '1' then -- ready only high when accepting data, more like an ack actually
        -- New value written from SBI. No longer ready.
        i2c_slave_din_rdy <= '0';
      end if;
    end if;
  end process p_i2c_slave_din_rdy;

  p_i2c_receive_reg : process(clk, arst)
  begin
    if arst = '1' then
     i2c_to_sbi       <= (others => '0');
    elsif rising_edge(clk) then
      if i2c_slave_dout_valid = '1' then
        i2c_to_sbi <= i2c_slave_dout;
      end if;
    end if;
  end process p_i2c_receive_reg;

  i_I2C_slave : entity work.I2C_slave
    generic map(
      SLAVE_ADDR => std_logic_vector(GC_SLAVE_ADDR)
    )
    port map (
      scl              => i2c_vvc_if.scl,
      sda              => i2c_vvc_if.sda,
      clk              => clk,
      rst              => arst,
      -- User interface
      read_req         => i2c_slave_din_req,    -- output
      data_to_master   => i2c_slave_din,        -- input
      data_valid       => i2c_slave_dout_valid, -- output
      data_from_master => i2c_slave_dout        -- output
   );
end struct;
