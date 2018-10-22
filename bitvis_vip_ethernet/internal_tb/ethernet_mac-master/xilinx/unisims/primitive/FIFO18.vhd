-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/rainier/VITAL/FIFO18.vhd,v 1.1 2008/06/19 16:59:21 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2005 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  18K-Bit FIFO
-- /___/   /\     Filename : FIFO18.vhd
-- \   \  /  \    Timestamp : Tues October 18 16:43:59 PST 2005
--  \___\/\___\
--
-- Revision:
--    10/18/05 - Initial version.
--    06/14/07 - Implemented high performace version of the model.
-- End Revision

----- CELL FIFO18 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.VITAL_Timing.all;

library unisim;
use unisim.VCOMPONENTS.all;
use unisim.vpkg.all;

entity FIFO18 is
generic (

    ALMOST_FULL_OFFSET      : bit_vector := X"080";
    ALMOST_EMPTY_OFFSET     : bit_vector := X"080"; 
    DATA_WIDTH              : integer    := 4;
    DO_REG                  : integer    := 1;
    EN_SYN                  : boolean    := FALSE;
    FIRST_WORD_FALL_THROUGH : boolean    := FALSE;
    SIM_MODE                : string     := "SAFE"
    
  );

port (

    ALMOSTEMPTY : out std_ulogic;
    ALMOSTFULL  : out std_ulogic;
    DO          : out std_logic_vector (15 downto 0);
    DOP         : out std_logic_vector (1 downto 0);
    EMPTY       : out std_ulogic;
    FULL        : out std_ulogic;
    RDCOUNT     : out std_logic_vector (11 downto 0);
    RDERR       : out std_ulogic;
    WRCOUNT     : out std_logic_vector (11 downto 0);
    WRERR       : out std_ulogic;

    DI          : in  std_logic_vector (15 downto 0);
    DIP         : in  std_logic_vector (1 downto 0);
    RDCLK       : in  std_ulogic;
    RDEN        : in  std_ulogic;
    RST         : in  std_ulogic;
    WRCLK       : in  std_ulogic;
    WREN        : in  std_ulogic    
  );
end FIFO18;
                                                                        
architecture FIFO18_V of FIFO18 is

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
  signal GND_6 : std_logic_vector(5 downto 0) := (others => '0');
  signal GND_48 : std_logic_vector(47 downto 0) := (others => '0');
  signal OPEN_1 : std_logic_vector(0 downto 0);
  signal OPEN_6 : std_logic_vector(5 downto 0);
  signal OPEN_48 : std_logic_vector(47 downto 0);
  signal OPEN_8 : std_logic_vector(7 downto 0);
  signal do_dly : std_logic_vector(15 downto 0) :=  (others => '0');
  signal dop_dly : std_logic_vector(1 downto 0) :=  (others => '0');
  signal almostfull_dly : std_ulogic := '0';
  signal almostempty_dly : std_ulogic := '0';
  signal empty_dly : std_ulogic := '0';
  signal full_dly : std_ulogic := '0';
  signal rderr_dly : std_ulogic := '0';
  signal wrerr_dly : std_ulogic := '0';
  signal rdcount_dly : std_logic_vector(11 downto 0) :=  (others => '0');
  signal wrcount_dly : std_logic_vector(11 downto 0) :=  (others => '0');


begin

FIFO18_inst : AFIFO36_INTERNAL
  generic map (
    ALMOST_FULL_OFFSET => ALMOST_FULL_OFFSET,
    ALMOST_EMPTY_OFFSET => ALMOST_EMPTY_OFFSET, 
    DATA_WIDTH => DATA_WIDTH,
    DO_REG => DO_REG,
    EN_SYN => EN_SYN,
    FIFO_SIZE => 18,
    SIM_MODE => SIM_MODE,
    FIRST_WORD_FALL_THROUGH => FIRST_WORD_FALL_THROUGH
    )

  port map (
    DO(15 downto 0) => do_dly,
    DO(63 downto 16) => OPEN_48,
    DOP(1 downto 0) => dop_dly,
    DOP(7 downto 2) => OPEN_6,
    ALMOSTEMPTY => almostempty_dly,
    ALMOSTFULL => almostfull_dly,
    ECCPARITY => OPEN_8,
    EMPTY => empty_dly,
    FULL => full_dly,
    RDCOUNT(11 downto 0) => rdcount_dly,
    RDCOUNT(12 downto 12) => OPEN_1,
    WRCOUNT(11 downto 0) => wrcount_dly,
    WRCOUNT(12 downto 12) => OPEN_1,
    RDERR => rderr_dly,
    SBITERR => OPEN,
    DBITERR => OPEN,
    WRERR => wrerr_dly,
    DI(15 downto 0) => DI,
    DI(63 downto 16) => GND_48,
    DIP(1 downto 0) => DIP,
    DIP(7 downto 2) => GND_6,
    WREN => WREN,
    RDEN => RDEN,
    RDCLK => RDCLK,
    RDRCLK => RDCLK,
    WRCLK => WRCLK,
    RST => RST
    );


   prcs_initialize:process
     variable first_time        : boolean    := true;

     begin
       if (first_time) then
         case DATA_WIDTH is
            when 4 | 9 | 18 => null;
            when others =>
                    GenericValueCheckMessage
                      ( HeaderMsg            => " Attribute Syntax Error ",
                        GenericName          => " DATA_WIDTH ",
                        EntityName           => "FIFO18",
                        GenericValue         => DATA_WIDTH,
                        Unit                 => "",
                        ExpectedValueMsg     => " The Legal values for this attribute are ",
                        ExpectedGenericValue => " 4, 9 and 18 ",
                        TailMsg              => "",
                        MsgSeverity          => error
                        );
         end case;
         first_time := false;
       end if;
       wait;
     end process prcs_initialize;




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

end FIFO18_V;
