-------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

-- Include Verification IPs
library bitvis_vip_i2c;
use bitvis_vip_i2c.i2c_bfm_pkg.all;

library bitvis_vip_wishbone;
use bitvis_vip_wishbone.wishbone_bfm_pkg.all;

entity i2c_master_dut is
  generic(
    GC_WISHBONE_DATA_WIDTH : natural;
    GC_WISHBONE_ADDR_WIDTH : natural
    );
  port(
    clk             : in    std_logic;
    arst            : in    std_logic;
    -- wishbone_vvc_if : inout t_wishbone_if(adr_o(GC_WISHBONE_ADDR_WIDTH - 1 downto 0), dat_o(GC_WISHBONE_DATA_WIDTH - 1 downto 0), dat_i(GC_WISHBONE_DATA_WIDTH - 1 downto 0));   
    adr_i           : in    std_logic_vector(GC_WISHBONE_ADDR_WIDTH - 1 downto 0);
    dat_i           : in    std_logic_vector(GC_WISHBONE_DATA_WIDTH - 1 downto 0);
    dat_o           : out   std_logic_vector(GC_WISHBONE_DATA_WIDTH - 1 downto 0);
    we_i            : in    std_logic;
    stb_i           : in    std_logic;
    cyc_i           : in    std_logic;
    ack_o           : out   std_logic;
    wb_inta_o       : out   std_logic;    
    i2c_vvc_if      : inout t_i2c_if
  );
end entity i2c_master_dut;


--=================================================================================================
--=================================================================================================

architecture struct of i2c_master_dut is

  signal scl_pad_o : std_logic;
  signal scl_padoen_o : std_logic;
  signal sda_pad_o : std_logic;
  signal sda_padoen_o : std_logic;
begin

  i2c_vvc_if.scl <= scl_pad_o when (scl_padoen_o = '0') else 'Z';
  i2c_vvc_if.sda <= sda_pad_o when (sda_padoen_o = '0') else 'Z';

  i_i2c_master_top : entity work.i2c_master_top
    generic map(
            ARST_LVL => '1'
    )
    port map (
      -- wishbone
      wb_clk_i  => clk,
      wb_rst_i  => '0',
      arst_i    => arst,
      wb_adr_i  => adr_i, --wishbone_vvc_if.adr_o,
      wb_dat_i  => dat_i, --wishbone_vvc_if.dat_o,
      wb_dat_o  => dat_o, --wishbone_vvc_if.dat_i,
      wb_we_i   => we_i,  --wishbone_vvc_if.we_o,
      wb_stb_i  => stb_i, --wishbone_vvc_if.stb_o,
      wb_cyc_i  => cyc_i, --wishbone_vvc_if.cyc_o,
      wb_ack_o  => ack_o, --wishbone_vvc_if.ack_i,
      wb_inta_o => wb_inta_o, -- What does this do? Interrupt request output signal. Not in the standard...
      -- i2c
      scl_pad_i    => i2c_vvc_if.scl,
      scl_pad_o    => scl_pad_o,
      scl_padoen_o => scl_padoen_o,
      sda_pad_i    => i2c_vvc_if.sda,
      sda_pad_o    => sda_pad_o,
      sda_padoen_o => sda_padoen_o
   );
end struct;
