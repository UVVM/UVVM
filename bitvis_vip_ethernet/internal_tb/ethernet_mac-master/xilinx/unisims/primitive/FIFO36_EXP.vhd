-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/rainier/VITAL/FIFO36_EXP.vhd,v 1.1 2008/06/19 16:59:21 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2005 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  36K-Bit FIFO
-- /___/   /\     Filename : FIFO36_EXP.vhd
-- \   \  /  \    Timestamp : Tues October 18 16:43:59 PST 2005
--  \___\/\___\
--
-- Revision:
--    10/18/05 - Initial version.
--    06/14/07 - Implemented high performace version of the model.
-- End Revision

----- CELL FIFO36_EXP -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.VITAL_Timing.all;

library unisim;
use unisim.VCOMPONENTS.all;

entity FIFO36_EXP is
generic (

    ALMOST_EMPTY_OFFSET     : bit_vector := X"0080"; 
    ALMOST_FULL_OFFSET      : bit_vector := X"0080";
    DATA_WIDTH              : integer    := 4;
    DO_REG                  : integer    := 1;
    EN_SYN                  : boolean    := FALSE;
    FIRST_WORD_FALL_THROUGH : boolean    := FALSE;
    SIM_MODE                : string     := "SAFE"
    
  );

port (

    ALMOSTEMPTY : out std_ulogic;
    ALMOSTFULL  : out std_ulogic;
    DO          : out std_logic_vector (31 downto 0);
    DOP         : out std_logic_vector (3 downto 0);
    EMPTY       : out std_ulogic;
    FULL        : out std_ulogic;
    RDCOUNT     : out std_logic_vector (12 downto 0);
    RDERR       : out std_ulogic;
    WRCOUNT     : out std_logic_vector (12 downto 0);
    WRERR       : out std_ulogic;

    DI          : in  std_logic_vector (31 downto 0);
    DIP         : in  std_logic_vector (3 downto 0);
    RDCLKL      : in  std_ulogic;
    RDCLKU      : in  std_ulogic;
    RDEN        : in  std_ulogic;
    RDRCLKL     : in  std_ulogic;
    RDRCLKU     : in  std_ulogic;
    RST         : in  std_ulogic;
    WRCLKL      : in  std_ulogic;
    WRCLKU      : in  std_ulogic;
    WREN        : in  std_ulogic    
  );
end FIFO36_EXP;
                                                                        
architecture FIFO36_EXP_V of FIFO36_EXP is

  component AFIFO36_INTERNAL

      generic(
        ALMOST_FULL_OFFSET      : bit_vector := X"0080";
        ALMOST_EMPTY_OFFSET     : bit_vector := X"0080"; 
        DATA_WIDTH              : integer    := 4;
        DO_REG                  : integer    := 1;
        EN_ECC_READ : boolean := FALSE;
        EN_ECC_WRITE : boolean := FALSE;    
        EN_SYN                  : boolean    := FALSE;
        FIFO_SIZE               : integer    := 36;
        FIRST_WORD_FALL_THROUGH : boolean    := FALSE;
        SIM_MODE                : string     := "SAFE"
        );

      port(
        ALMOSTEMPTY : out std_ulogic;
        ALMOSTFULL  : out std_ulogic;
        DBITERR       : out std_ulogic;
        DO          : out std_logic_vector (63 downto 0);
        DOP         : out std_logic_vector (7 downto 0);
        ECCPARITY   : out std_logic_vector (7 downto 0);
        EMPTY       : out std_ulogic;
        FULL        : out std_ulogic;
        RDCOUNT     : out std_logic_vector (12 downto 0);
        RDERR       : out std_ulogic;
        SBITERR     : out std_ulogic;
        WRCOUNT     : out std_logic_vector (12 downto 0);
        WRERR       : out std_ulogic;

        DI          : in  std_logic_vector (63 downto 0);
        DIP         : in  std_logic_vector (7 downto 0);
        RDCLK       : in  std_ulogic;
        RDRCLK       : in  std_ulogic;
        RDEN        : in  std_ulogic;
        RST         : in  std_ulogic;
        WRCLK       : in  std_ulogic;
        WREN        : in  std_ulogic
        );
  end component;

    
  constant SYNC_PATH_DELAY : time := 100 ps;
  signal GND_4 : std_logic_vector(3 downto 0) := (others => '0');
  signal GND_32 : std_logic_vector(31 downto 0) := (others => '0');
  signal OPEN_4 : std_logic_vector(3 downto 0);
  signal OPEN_32 : std_logic_vector(31 downto 0);
  signal OPEN_8 : std_logic_vector(7 downto 0);
  signal do_dly : std_logic_vector(31 downto 0) :=  (others => '0');
  signal dop_dly : std_logic_vector(3 downto 0) :=  (others => '0');
  signal almostfull_dly : std_ulogic := '0';
  signal almostempty_dly : std_ulogic := '0';
  signal empty_dly : std_ulogic := '0';
  signal full_dly : std_ulogic := '0';
  signal rderr_dly : std_ulogic := '0';
  signal wrerr_dly : std_ulogic := '0';
  signal rdcount_dly : std_logic_vector(12 downto 0) :=  (others => '0');
  signal wrcount_dly : std_logic_vector(12 downto 0) :=  (others => '0');


begin

FIFO36_EXP_inst : AFIFO36_INTERNAL
  generic map (
    ALMOST_FULL_OFFSET => ALMOST_FULL_OFFSET,
    ALMOST_EMPTY_OFFSET => ALMOST_EMPTY_OFFSET, 
    DATA_WIDTH => DATA_WIDTH,
    DO_REG => DO_REG,
    EN_SYN => EN_SYN,
    SIM_MODE => SIM_MODE,
    FIRST_WORD_FALL_THROUGH => FIRST_WORD_FALL_THROUGH
    )

  port map (
    DO(31 downto 0) => do_dly,
    DO(63 downto 32) => OPEN_32,
    DOP(3 downto 0) => dop_dly,
    DOP(7 downto 4) => OPEN_4,
    ALMOSTEMPTY => almostempty_dly,
    ALMOSTFULL => almostfull_dly,
    ECCPARITY => OPEN_8,
    EMPTY => empty_dly,
    FULL => full_dly,
    RDCOUNT => rdcount_dly,
    WRCOUNT => wrcount_dly,
    RDERR => rderr_dly,
    SBITERR => OPEN,
    DBITERR => OPEN,
    WRERR => wrerr_dly,
    DI(31 downto 0) => DI,
    DI(63 downto 32) => GND_32,
    DIP(3 downto 0) => DIP,
    DIP(7 downto 4) => GND_4,
    WREN => WREN,
    RDEN => RDEN,
    RDCLK => RDCLKL,
    RDRCLK => RDRCLKL,
    WRCLK => WRCLKL,
    RST => RST
    );

   prcs_output_wtiming: process (do_dly, dop_dly, almostempty_dly, almostfull_dly, empty_dly, full_dly, rdcount_dly, wrcount_dly, rderr_dly, wrerr_dly)
   begin  -- process prcs_output_wtiming

     ALMOSTEMPTY <= almostempty_dly after SYNC_PATH_DELAY;
     ALMOSTFULL <= almostfull_dly after SYNC_PATH_DELAY;
     empty <= empty_dly after SYNC_PATH_DELAY;
     full <= full_dly after SYNC_PATH_DELAY;
     DO <= do_dly after SYNC_PATH_DELAY;
     DOP <= dop_dly after SYNC_PATH_DELAY;
     RDCOUNT <= rdcount_dly after SYNC_PATH_DELAY;
     WRCOUNT <= wrcount_dly after SYNC_PATH_DELAY;
     RDERR <= rderr_dly after SYNC_PATH_DELAY;
     WRERR <= wrerr_dly after SYNC_PATH_DELAY;
     
   end process prcs_output_wtiming;

end FIFO36_EXP_V;
