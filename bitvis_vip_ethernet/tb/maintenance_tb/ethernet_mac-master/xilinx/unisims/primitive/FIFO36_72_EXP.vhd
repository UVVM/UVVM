-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/rainier/VITAL/FIFO36_72_EXP.vhd,v 1.1 2008/06/19 16:59:21 vandanad Exp $
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
-- /___/   /\     Filename : FIFO36_72_EXP.vhd
-- \   \  /  \    Timestamp : Tues October 18 16:43:59 PST 2005
--  \___\/\___\
--
-- Revision:
--    10/18/05 - Initial version.
--    06/14/07 - Implemented high performace version of the model.
-- End Revision

----- CELL FIFO36_72_EXP -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.VITAL_Timing.all;

library unisim;
use unisim.VCOMPONENTS.all;

entity FIFO36_72_EXP is
generic (

    ALMOST_FULL_OFFSET      : bit_vector := X"080";
    ALMOST_EMPTY_OFFSET     : bit_vector := X"080"; 
    DO_REG                  : integer    := 1;
    EN_ECC_READ             : boolean    := FALSE;
    EN_ECC_WRITE            : boolean    := FALSE;  
    EN_SYN                  : boolean    := FALSE;
    FIRST_WORD_FALL_THROUGH : boolean    := FALSE;
    SIM_MODE                : string     := "SAFE"
    
  );

port (

    ALMOSTEMPTY : out std_ulogic;
    ALMOSTFULL  : out std_ulogic;
    DBITERR     : out std_ulogic;
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
end FIFO36_72_EXP;
                                                                        
architecture FIFO36_72_EXP_V of FIFO36_72_EXP is

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
  signal do_dly : std_logic_vector(63 downto 0) :=  (others => '0');
  signal dop_dly : std_logic_vector(7 downto 0) :=  (others => '0');
  signal almostfull_dly : std_ulogic := '0';
  signal almostempty_dly : std_ulogic := '0';
  signal empty_dly : std_ulogic := '0';
  signal full_dly : std_ulogic := '0';
  signal rderr_dly : std_ulogic := '0';
  signal wrerr_dly : std_ulogic := '0';
  signal rdcount_dly : std_logic_vector(12 downto 0) :=  (others => '0');
  signal wrcount_dly : std_logic_vector(12 downto 0) :=  (others => '0');
  signal sbiterr_dly : std_ulogic := '0';
  signal dbiterr_dly : std_ulogic := '0';
  signal eccparity_dly : std_logic_vector(7 downto 0) :=  (others => '0');
  
begin

FIFO36_72_EXP_inst : AFIFO36_INTERNAL
  generic map (
    ALMOST_FULL_OFFSET => ALMOST_FULL_OFFSET,
    ALMOST_EMPTY_OFFSET => ALMOST_EMPTY_OFFSET, 
    DATA_WIDTH => 72,
    DO_REG => DO_REG,
    EN_ECC_READ => EN_ECC_READ, 
    EN_ECC_WRITE => EN_ECC_WRITE,
    EN_SYN => EN_SYN,
    SIM_MODE => SIM_MODE,
    FIRST_WORD_FALL_THROUGH => FIRST_WORD_FALL_THROUGH
    )

  port map (
    DO => do_dly,
    DOP => dop_dly,
    ALMOSTEMPTY => almostempty_dly,
    ALMOSTFULL => almostfull_dly,
    ECCPARITY => eccparity_dly,
    EMPTY => empty_dly,
    FULL => full_dly,
    RDCOUNT => rdcount_dly,
    WRCOUNT => wrcount_dly,
    RDERR => rderr_dly,
    SBITERR => sbiterr_dly,
    DBITERR => dbiterr_dly,
    WRERR => wrerr_dly,
    DI => DI,
    DIP => DIP,
    WREN => WREN,
    RDEN => RDEN,
    RDCLK => RDCLKL,
    RDRCLK => RDRCLKL,
    WRCLK => WRCLKL,
    RST => RST
    );

   prcs_output_wtiming: process (do_dly, dop_dly, almostempty_dly, almostfull_dly,
                                 empty_dly, full_dly, rdcount_dly, wrcount_dly, rderr_dly,
                                 wrerr_dly, eccparity_dly, sbiterr_dly, dbiterr_dly)
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
     ECCPARITY <= eccparity_dly after SYNC_PATH_DELAY;
     SBITERR <= sbiterr_dly after SYNC_PATH_DELAY;
     DBITERR <= dbiterr_dly after SYNC_PATH_DELAY;

   end process prcs_output_wtiming;

end FIFO36_72_EXP_V;
