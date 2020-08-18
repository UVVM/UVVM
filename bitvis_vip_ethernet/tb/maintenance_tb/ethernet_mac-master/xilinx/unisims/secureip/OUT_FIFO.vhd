-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/fuji/SMODEL/OUT_FIFO.vhd,v 1.9 2011/09/01 20:23:32 robh Exp $
-------------------------------------------------------
--  Copyright (c) 2010 Xilinx Inc.
--  All Right Reserved.
-------------------------------------------------------
--
--   ____  ____
--  /   /\/   / 
-- /___/  \  /     Vendor      : Xilinx 
-- \   \   \/      Version : 11.1
--  \   \          Description : Xilinx Functional Simulation Library Component
--  /   /                        Fujisan OUT FIFO
-- /___/   /\      Filename    : OUT_FIFO.vhd
-- \   \  /  \      
--  \__ \/\__ \                   
--                                 
--  Date:     Comment:
--  03JUN2010 Initial UNI/SIM version from yml
--  29JUN2010 enable encrypted rtl
--  10AUG2010 yml, rtl update
--  28SEP2010 minor clean up
--  28SEP2010 rtl update
--  05NOV2010 update defaults
--  15AUG2011 621681 remove SIM_SPEEDUP, make default
-------------------------------------------------------

----- CELL OUT_FIFO -----

library IEEE;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_1164.all;

library unisim;
use unisim.VCOMPONENTS.all;
use unisim.vpkg.all;

library secureip;
use secureip.all;

  entity OUT_FIFO is
    generic (
      ALMOST_EMPTY_VALUE : integer := 1;
      ALMOST_FULL_VALUE : integer := 1;
      ARRAY_MODE : string := "ARRAY_MODE_8_X_4";
      OUTPUT_DISABLE : string := "FALSE";
      SYNCHRONOUS_MODE : string := "FALSE"
    );

    port (
      ALMOSTEMPTY          : out std_ulogic;
      ALMOSTFULL           : out std_ulogic;
      EMPTY                : out std_ulogic;
      FULL                 : out std_ulogic;
      Q0                   : out std_logic_vector(3 downto 0);
      Q1                   : out std_logic_vector(3 downto 0);
      Q2                   : out std_logic_vector(3 downto 0);
      Q3                   : out std_logic_vector(3 downto 0);
      Q4                   : out std_logic_vector(3 downto 0);
      Q5                   : out std_logic_vector(7 downto 0);
      Q6                   : out std_logic_vector(7 downto 0);
      Q7                   : out std_logic_vector(3 downto 0);
      Q8                   : out std_logic_vector(3 downto 0);
      Q9                   : out std_logic_vector(3 downto 0);
      D0                   : in std_logic_vector(7 downto 0);
      D1                   : in std_logic_vector(7 downto 0);
      D2                   : in std_logic_vector(7 downto 0);
      D3                   : in std_logic_vector(7 downto 0);
      D4                   : in std_logic_vector(7 downto 0);
      D5                   : in std_logic_vector(7 downto 0);
      D6                   : in std_logic_vector(7 downto 0);
      D7                   : in std_logic_vector(7 downto 0);
      D8                   : in std_logic_vector(7 downto 0);
      D9                   : in std_logic_vector(7 downto 0);
      RDCLK                : in std_ulogic;
      RDEN                 : in std_ulogic;
      RESET                : in std_ulogic;
      WRCLK                : in std_ulogic;
      WREN                 : in std_ulogic      
    );
  end OUT_FIFO;

  architecture OUT_FIFO_V of OUT_FIFO is
    component SIP_OUT_FIFO
      port (
        ALMOST_EMPTY_VALUE : in std_logic_vector(7 downto 0);
        ALMOST_FULL_VALUE : in std_logic_vector(7 downto 0);
        ARRAY_MODE : in std_ulogic;
        OUTPUT_DISABLE : in std_ulogic;
        SLOW_RD_CLK : in std_ulogic;
        SLOW_WR_CLK : in std_ulogic;
        SPARE : in std_logic_vector(3 downto 0);
        SYNCHRONOUS_MODE : in std_ulogic;        

        ALMOSTEMPTY          : out std_ulogic;
        ALMOSTFULL           : out std_ulogic;
        EMPTY                : out std_ulogic;
        FULL                 : out std_ulogic;
        Q0                   : out std_logic_vector(3 downto 0);
        Q1                   : out std_logic_vector(3 downto 0);
        Q2                   : out std_logic_vector(3 downto 0);
        Q3                   : out std_logic_vector(3 downto 0);
        Q4                   : out std_logic_vector(3 downto 0);
        Q5                   : out std_logic_vector(7 downto 0);
        Q6                   : out std_logic_vector(7 downto 0);
        Q7                   : out std_logic_vector(3 downto 0);
        Q8                   : out std_logic_vector(3 downto 0);
        Q9                   : out std_logic_vector(3 downto 0);
        SCANOUT              : out std_logic_vector(3 downto 0);
        D0                   : in std_logic_vector(7 downto 0);
        D1                   : in std_logic_vector(7 downto 0);
        D2                   : in std_logic_vector(7 downto 0);
        D3                   : in std_logic_vector(7 downto 0);
        D4                   : in std_logic_vector(7 downto 0);
        D5                   : in std_logic_vector(7 downto 0);
        D6                   : in std_logic_vector(7 downto 0);
        D7                   : in std_logic_vector(7 downto 0);
        D8                   : in std_logic_vector(7 downto 0);
        D9                   : in std_logic_vector(7 downto 0);
        RDCLK                : in std_ulogic;
        RDEN                 : in std_ulogic;
        RESET                : in std_ulogic;
        SCANENB              : in std_ulogic;
        SCANIN               : in std_logic_vector(3 downto 0);
        TESTMODEB            : in std_ulogic;
        TESTREADDISB         : in std_ulogic;
        TESTWRITEDISB        : in std_ulogic;
        WRCLK                : in std_ulogic;
        WREN                 : in std_ulogic;
        GSR                  : in std_ulogic
      );
    end component;
    
    constant IN_DELAY : time := 1 ps;
    constant OUT_DELAY : time := 10 ps;
    constant INCLK_DELAY : time := 0 ps;
    constant OUTCLK_DELAY : time := 0 ps;
    constant MODULE_NAME : string  := "OUT_FIFO";

    constant SPARE_BINARY : std_logic_vector(3 downto 0) := "0000";
    signal ALMOST_EMPTY_VALUE_BINARY : std_logic_vector(7 downto 0);
    signal ALMOST_FULL_VALUE_BINARY : std_logic_vector(7 downto 0);
    signal ARRAY_MODE_BINARY : std_ulogic;
    signal OUTPUT_DISABLE_BINARY : std_ulogic;
    signal SLOW_RD_CLK_BINARY : std_ulogic;
    signal SLOW_WR_CLK_BINARY : std_ulogic;
    signal SYNCHRONOUS_MODE_BINARY : std_ulogic;
    
    signal ALMOSTEMPTY_out : std_ulogic;
    signal ALMOSTFULL_out : std_ulogic;
    signal EMPTY_out : std_ulogic;
    signal FULL_out : std_ulogic;
    signal Q0_out : std_logic_vector(3 downto 0);
    signal Q1_out : std_logic_vector(3 downto 0);
    signal Q2_out : std_logic_vector(3 downto 0);
    signal Q3_out : std_logic_vector(3 downto 0);
    signal Q4_out : std_logic_vector(3 downto 0);
    signal Q5_out : std_logic_vector(7 downto 0);
    signal Q6_out : std_logic_vector(7 downto 0);
    signal Q7_out : std_logic_vector(3 downto 0);
    signal Q8_out : std_logic_vector(3 downto 0);
    signal Q9_out : std_logic_vector(3 downto 0);
    
    signal ALMOSTEMPTY_outdelay : std_ulogic;
    signal ALMOSTFULL_outdelay : std_ulogic;
    signal EMPTY_outdelay : std_ulogic;
    signal FULL_outdelay : std_ulogic;
    signal Q0_outdelay : std_logic_vector(3 downto 0);
    signal Q1_outdelay : std_logic_vector(3 downto 0);
    signal Q2_outdelay : std_logic_vector(3 downto 0);
    signal Q3_outdelay : std_logic_vector(3 downto 0);
    signal Q4_outdelay : std_logic_vector(3 downto 0);
    signal Q5_outdelay : std_logic_vector(7 downto 0);
    signal Q6_outdelay : std_logic_vector(7 downto 0);
    signal Q7_outdelay : std_logic_vector(3 downto 0);
    signal Q8_outdelay : std_logic_vector(3 downto 0);
    signal Q9_outdelay : std_logic_vector(3 downto 0);
    signal SCANOUT_outdelay : std_logic_vector(3 downto 0);
    
    signal D0_in : std_logic_vector(7 downto 0);
    signal D1_in : std_logic_vector(7 downto 0);
    signal D2_in : std_logic_vector(7 downto 0);
    signal D3_in : std_logic_vector(7 downto 0);
    signal D4_in : std_logic_vector(7 downto 0);
    signal D5_in : std_logic_vector(7 downto 0);
    signal D6_in : std_logic_vector(7 downto 0);
    signal D7_in : std_logic_vector(7 downto 0);
    signal D8_in : std_logic_vector(7 downto 0);
    signal D9_in : std_logic_vector(7 downto 0);
    signal RDCLK_in : std_ulogic;
    signal RDEN_in : std_ulogic;
    signal RESET_in : std_ulogic;
    signal WRCLK_in : std_ulogic;
    signal WREN_in : std_ulogic;
    
    signal D0_indelay : std_logic_vector(7 downto 0);
    signal D1_indelay : std_logic_vector(7 downto 0);
    signal D2_indelay : std_logic_vector(7 downto 0);
    signal D3_indelay : std_logic_vector(7 downto 0);
    signal D4_indelay : std_logic_vector(7 downto 0);
    signal D5_indelay : std_logic_vector(7 downto 0);
    signal D6_indelay : std_logic_vector(7 downto 0);
    signal D7_indelay : std_logic_vector(7 downto 0);
    signal D8_indelay : std_logic_vector(7 downto 0);
    signal D9_indelay : std_logic_vector(7 downto 0);
    signal RDCLK_indelay : std_ulogic;
    signal RDEN_indelay : std_ulogic;
    signal RESET_indelay : std_ulogic;
    signal SCANENB_indelay : std_ulogic := '1';
    signal SCANIN_indelay : std_logic_vector(3 downto 0) := "1111";
    signal TESTMODEB_indelay : std_ulogic := '1';
    signal TESTREADDISB_indelay : std_ulogic := '1';
    signal TESTWRITEDISB_indelay : std_ulogic := '1';
    signal WRCLK_indelay : std_ulogic;
    signal WREN_indelay : std_ulogic;
    signal GSR_indelay : std_ulogic := '0';
    
    begin
    ALMOSTEMPTY_out <= ALMOSTEMPTY_outdelay after OUT_DELAY;
    ALMOSTFULL_out <= ALMOSTFULL_outdelay after OUT_DELAY;
    EMPTY_out <= EMPTY_outdelay after OUT_DELAY;
    FULL_out <= FULL_outdelay after OUT_DELAY;
    Q0_out <= Q0_outdelay after OUT_DELAY;
    Q1_out <= Q1_outdelay after OUT_DELAY;
    Q2_out <= Q2_outdelay after OUT_DELAY;
    Q3_out <= Q3_outdelay after OUT_DELAY;
    Q4_out <= Q4_outdelay after OUT_DELAY;
    Q5_out <= Q5_outdelay after OUT_DELAY;
    Q6_out <= Q6_outdelay after OUT_DELAY;
    Q7_out <= Q7_outdelay after OUT_DELAY;
    Q8_out <= Q8_outdelay after OUT_DELAY;
    Q9_out <= Q9_outdelay after OUT_DELAY;
    
    RDCLK_in <= RDCLK;
    WRCLK_in <= WRCLK;
    
    D0_in <= D0;
    D1_in <= D1;
    D2_in <= D2;
    D3_in <= D3;
    D4_in <= D4;
    D5_in <= D5;
    D6_in <= D6;
    D7_in <= D7;
    D8_in <= D8;
    D9_in <= D9;
    RDEN_in <= RDEN;
    RESET_in <= RESET;
    WREN_in <= WREN;
    
    RDCLK_indelay <= RDCLK_in after INCLK_DELAY;
    WRCLK_indelay <= WRCLK_in after INCLK_DELAY;
    
    D0_indelay <= D0_in after IN_DELAY;
    D1_indelay <= D1_in after IN_DELAY;
    D2_indelay <= D2_in after IN_DELAY;
    D3_indelay <= D3_in after IN_DELAY;
    D4_indelay <= D4_in after IN_DELAY;
    D5_indelay <= D5_in after IN_DELAY;
    D6_indelay <= D6_in after IN_DELAY;
    D7_indelay <= D7_in after IN_DELAY;
    D8_indelay <= D8_in after IN_DELAY;
    D9_indelay <= D9_in after IN_DELAY;
    RDEN_indelay <= RDEN_in after IN_DELAY;
    RESET_indelay <= RESET_in after IN_DELAY;
    WREN_indelay <= WREN_in after IN_DELAY;
    GSR_indelay <= GSR;
    
    OUT_FIFO_INST : SIP_OUT_FIFO
      port map (
        ALMOST_EMPTY_VALUE   => ALMOST_EMPTY_VALUE_BINARY,
        ALMOST_FULL_VALUE    => ALMOST_FULL_VALUE_BINARY,
        ARRAY_MODE           => ARRAY_MODE_BINARY,
        OUTPUT_DISABLE       => OUTPUT_DISABLE_BINARY,
        SLOW_RD_CLK          => SLOW_RD_CLK_BINARY,
        SLOW_WR_CLK          => SLOW_WR_CLK_BINARY,
        SPARE                => SPARE_BINARY,
        SYNCHRONOUS_MODE     => SYNCHRONOUS_MODE_BINARY,

        ALMOSTEMPTY          => ALMOSTEMPTY_outdelay,
        ALMOSTFULL           => ALMOSTFULL_outdelay,
        EMPTY                => EMPTY_outdelay,
        FULL                 => FULL_outdelay,
        Q0                   => Q0_outdelay,
        Q1                   => Q1_outdelay,
        Q2                   => Q2_outdelay,
        Q3                   => Q3_outdelay,
        Q4                   => Q4_outdelay,
        Q5                   => Q5_outdelay,
        Q6                   => Q6_outdelay,
        Q7                   => Q7_outdelay,
        Q8                   => Q8_outdelay,
        Q9                   => Q9_outdelay,
        SCANOUT              => SCANOUT_outdelay,
        D0                   => D0_indelay,
        D1                   => D1_indelay,
        D2                   => D2_indelay,
        D3                   => D3_indelay,
        D4                   => D4_indelay,
        D5                   => D5_indelay,
        D6                   => D6_indelay,
        D7                   => D7_indelay,
        D8                   => D8_indelay,
        D9                   => D9_indelay,
        RDCLK                => RDCLK_indelay,
        RDEN                 => RDEN_indelay,
        RESET                => RESET_indelay,
        SCANENB              => SCANENB_indelay,
        SCANIN               => SCANIN_indelay,
        TESTMODEB            => TESTMODEB_indelay,
        TESTREADDISB         => TESTREADDISB_indelay,
        TESTWRITEDISB        => TESTWRITEDISB_indelay,
        WRCLK                => WRCLK_indelay,
        WREN                 => WREN_indelay,
        GSR                  => GSR_indelay
      );
    
    INIPROC : process
    begin
    -- case ARRAY_MODE is
      if((ARRAY_MODE = "ARRAY_MODE_8_X_4") or (ARRAY_MODE = "array_mode_8_x_4")) then
        ARRAY_MODE_BINARY <= '1';
      elsif((ARRAY_MODE = "ARRAY_MODE_4_X_4") or (ARRAY_MODE = "array_mode_4_x_4")) then
        ARRAY_MODE_BINARY <= '0';
      else
        assert FALSE report "Error : ARRAY_MODE = is not ARRAY_MODE_8_X_4 or ARRAY_MODE_4_X_4." severity error;
      end if;
    -- end case;
    -- case OUTPUT_DISABLE is
      if((OUTPUT_DISABLE = "FALSE") or (OUTPUT_DISABLE = "false")) then
        OUTPUT_DISABLE_BINARY <= '0';
      elsif((OUTPUT_DISABLE = "TRUE") or (OUTPUT_DISABLE= "true")) then
        OUTPUT_DISABLE_BINARY <= '1';
      else
        assert FALSE report "Error : OUTPUT_DISABLE = is not FALSE or TRUE." severity error;
      end if;
    -- end case;
      SLOW_RD_CLK_BINARY <= '0';
      SLOW_WR_CLK_BINARY <= '0';
    -- case SYNCHRONOUS_MODE is
      if((SYNCHRONOUS_MODE = "FALSE") or (SYNCHRONOUS_MODE = "false")) then
        SYNCHRONOUS_MODE_BINARY <= '0';
      else
        assert FALSE report "Error : SYNCHRONOUS_MODE = is not FALSE." severity error;
      end if;
    -- end case;
    -- case ALMOST_EMPTY_VALUE is
      if(ALMOST_EMPTY_VALUE = 1) then
        ALMOST_EMPTY_VALUE_BINARY <= "01000001";
      elsif(ALMOST_EMPTY_VALUE = 2) then
        ALMOST_EMPTY_VALUE_BINARY <= "01100011";
      else
        assert FALSE report "Error : ALMOST_EMPTY_VALUE is not 1 or 2." severity error;
      end if;
    -- end case;
    -- case ALMOST_FULL_VALUE is
      if(ALMOST_FULL_VALUE = 1) then
        ALMOST_FULL_VALUE_BINARY <= "01000001";
      elsif(ALMOST_FULL_VALUE = 2) then
        ALMOST_FULL_VALUE_BINARY <= "01100011";
      else
        assert FALSE report "Error : ALMOST_FULL_VALUE is not 1 or 2." severity error;
      end if;
    -- end case;
    wait;
    end process INIPROC;
    ALMOSTEMPTY <= ALMOSTEMPTY_out;
    ALMOSTFULL <= ALMOSTFULL_out;
    EMPTY <= EMPTY_out;
    FULL <= FULL_out;
    Q0 <= Q0_out;
    Q1 <= Q1_out;
    Q2 <= Q2_out;
    Q3 <= Q3_out;
    Q4 <= Q4_out;
    Q5 <= Q5_out;
    Q6 <= Q6_out;
    Q7 <= Q7_out;
    Q8 <= Q8_out;
    Q9 <= Q9_out;
  end OUT_FIFO_V;
