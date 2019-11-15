-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/trilogy/VITAL/SPI_ACCESS.vhd,v 1.4 2011/03/24 16:50:17 robh Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2008 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Internal logic access to the Serial Peripheral Interface (SPI) PROM data
-- /___/   /\     SPI_ACCESS.vhd 
-- \   \  /  \    Timestamp : Fri Oct 12 10:43:26 PDT 2007
--  \___\/\___\
--
--
-- Revision:
--    10/12/07 - Initial version
--    06/03/08 - Fixed vcs compiler warning message about synopsys_off
--    07/09/08 - CR476247 - shorten simulation delays.
--               Change MISO out off state from H to 1.
--    07/20/10 - CR562075 - allow writes to unerased page.
--    03/23/11 - CR602484 - perform erase page before write on commnads 0x83 and 0x86.
-- End Revision

----- CELL SPI_ACCESS -----

library std;
    use std.textio.all;
library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.std_logic_textio.all;
    use IEEE.Std_logic_unsigned.all;
    use IEEE.numeric_std.all;


---entity declarations--------------
entity SPI_ACCESS is
  generic(
       
    SIM_DELAY_TYPE  : string := "SCALED";
    SIM_DEVICE      : string := "3S1400AN";  
    SIM_FACTORY_ID  : bit_vector :=X"00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
    SIM_USER_ID     : bit_vector := X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF";
    SIM_MEM_FILE    : string := "NONE"
     
    );

port(
    MISO            : out std_ulogic;
    CLK             : in std_ulogic;
    CSB             : in std_ulogic;
    MOSI            : in std_ulogic
    );

end SPI_ACCESS;

----architecture declarations------
architecture SPI_ACCESS_V of SPI_ACCESS is

constant SYNC_PATH_DELAY : time := 100 ps;

constant    InstancePath    : string := "SPI_ACCESS";
    
constant    binary_opt      : std_logic := '0';
--  unchanged time delays
constant     Tdis            : TIME := 0 ps ;
constant     Tv              : TIME := 0 ps ;
constant      Tspickh        : TIME := 6800 ps ;
constant      Tspickl        : TIME := 6800 ps ;

-- divided delays
constant    Tspiclkl        : STRING := "Tspiclkl";                     
constant    Tspiclkh        : STRING := "Tspiclkh";                     
constant    TCOMP           : STRING := "   tCOMP";     
constant    TXFR            : STRING := "    tXFR";
constant    TPEP            : STRING := "    tPEP";
constant    TP              : STRING := "      tP";
constant    TPE             : STRING := "     tPE";
constant    TSE             : STRING := "     tSE";
constant    TVCSL           : STRING := "   tVCSL";
constant    TPUW            : STRING := "    tPUW";

constant    Tsck            : Time := 15152 ps;   -- period of 66 MHz 
constant    Tsck33          : Time := 30304 ps;   --clk_period for 33 MHz 
constant    Tcs             : TIME := 50  ns;     -- 50 ns  Minimum CSB High Time
signal      scaled_flag     : boolean;

procedure validate_input(   
              SIM_DEVICE : in string;
               accuracy  : in string;
    signal     scal_flag : inout boolean
    ) is
    variable ln : Line;
begin
   if (accuracy = "SCALED" ) then
       scal_flag <= TRUE;
       wait for 1 ps;
   elsif  (accuracy ="ACCURATE") then 
       scal_flag <= FALSE;
       wait for 1 ps;
   else
        write(ln, string'(" Attribute Syntax Error : "));
        write(ln, string'(" SIM_DELAY_TYPE "));
        write(ln, string'( " in "));
        write(ln, InstancePath);
        write(ln, string'( " The Legal values for this attribute are ACCURATE or SCALED "));
        assert false report ln.all severity failure;
        DEALLOCATE (ln);        
    end if;
    if (SIM_DEVICE /=  "3S50AN")and(SIM_DEVICE /=  "3S200AN")and(SIM_DEVICE /=  "3S400AN")and(SIM_DEVICE /=  "3S700AN")and(SIM_DEVICE /= "3S1400AN") then
        write(ln, string'(" Attribute Syntax Error :  The allowed values for SIM_DEVICE in "));
        write(ln, InstancePath);
        write(ln, string'(" are 3S50AN, 3S200AN, 3S400AN, 3S700AN or 3S1400AN"));
        assert false report ln.all severity failure;
        DEALLOCATE (ln);        
    end if;
end validate_input ;   



----------------------Convert integer subroutine -------------------------------------------
subtype SMALL_INT is INTEGER range 0 to 1;
-- synopsys synthesis_off
type tbl_type is array (STD_ULOGIC) of STD_ULOGIC;
constant tbl_BINARY : tbl_type :=
('X', 'X', '0', '1', 'X', 'X', '0', '1', 'X');
-- synopsys synthesis_on
function CONV_INTEGER(ARG: STD_ULOGIC) return SMALL_INT;
-- attribute foreign of CONV_INTEGER[UNSIGNED return INTEGER]:function is "Conv_Integer_Unsigned";
function CONV_INTEGER(ARG: STD_ULOGIC) return SMALL_INT is
variable tmp: STD_ULOGIC;
-- synopsys built_in SYN_FEED_THRU
-- synopsys subpgm_id 370
begin
-- synopsys synthesis_off
tmp := tbl_BINARY(ARG);
if tmp = '1' then
    return 1;
else
    return 0;
end if;
-- synopsys synthesis_on
end;
-----------------------------------------------------------------------------------------------------


function delay_cal (DELAY_NAME : in string(1 to 8);
                    scaled_flag : in boolean
                    ) return TIME is
variable delay_time  : TIME := 50 ns;
begin
   case scaled_flag is
       when  FALSE =>
         case DELAY_NAME is
            when "Tspiclkl" => delay_time :=     6800 ps;      
            when "Tspiclkh" => delay_time :=     6800 ps;        
            when "   tCOMP" => delay_time :=    400000 ns;  -- 400 us Buffer Compare Time     
            when "    tXFR" => delay_time :=    400000 ns;  -- 400 us Page to Bufer Xfer UG pg 33,34
            when "    tPEP" => delay_time :=  40000000 ns;  -- 40 ms
            when "      tP" => delay_time :=   6000000 ns;  -- 6 ms
            when "     tPE" => delay_time :=  35000000 ns;  -- 32 ms
            when "     tSE" => delay_time := 500000000 ns;  -- 5 s divided by 10 since num too large, loop 10x
            when "   tVCSL" => delay_time :=        50 ns;  -- 50 us
            when "    tPUW" => delay_time :=        50 ns;  --          20000000 ns;  -- 20 ms
            when OTHERS    => delay_time := 500000000 ns;  -- maximum
         end case;
      when  TRUE => -- arbitrary
         case DELAY_NAME is
             when "Tspiclkl" => delay_time :=    6800 ps;      
            when "Tspiclkh" => delay_time :=    6800 ps;        
            when "   tCOMP" => delay_time :=      500 ns;  -- = tXFR
            when "    tXFR" => delay_time :=      500 ns;  -- = tCOMP
            when "    tPEP" => delay_time :=     2500 ns;  -- > tPE + tP
            when "      tP" => delay_time :=     1000 ns;  -- 2 x tCOMP
            when "     tPE" => delay_time :=     1000 ns;  -- 2 x tCOMP
            when "     tSE" => delay_time :=     4000 ns;  -- 4 x tPE
            when "   tVCSL" => delay_time :=       50 ns;  -- 
            when "    tPUW" => delay_time :=       50 ns;  -- 
            when OTHERS     => delay_time :=    40000 ns;  -- 10 x tSE
         end case;
    end case;         
    return  delay_time;
end delay_cal;

function device_Sel1  (SIM_DEVICE : in string
                         ) return std_logic is
    variable status3  : std_logic;
begin
    if    (SIM_DEVICE =   "3S50AN") then  status3 := '1';
    elsif (SIM_DEVICE =  "3S200AN") then  status3 := '1';
    elsif (SIM_DEVICE =  "3S400AN") then  status3 := '1';
    elsif (SIM_DEVICE =  "3S700AN") then  status3 := '0';
    elsif (SIM_DEVICE = "3S1400AN") then  status3 := '1' ;
    else                                  status3 := '1';
    end if;                               
return status3;
end device_sel1;

function device_Sel2  (SIM_DEVICE : in string
                         ) return std_logic is
    variable status4  : std_logic;
begin
    if    (SIM_DEVICE =   "3S50AN") then  status4 := '0';     
    elsif (SIM_DEVICE =  "3S200AN") then  status4 := '1';     
    elsif (SIM_DEVICE =  "3S400AN") then  status4 := '1';      
    elsif (SIM_DEVICE =  "3S700AN") then  status4 := '0';     
    elsif (SIM_DEVICE = "3S1400AN") then  status4 := '0' ;        
    else                                  status4 := '0';     
    end if;                               
    return status4;
end device_sel2;

function device_Sel3         (SIM_DEVICE : in string
                         ) return std_logic is
    variable status5  : std_logic;
begin
    if    (SIM_DEVICE =   "3S50AN") then  status5 := '0';
    elsif (SIM_DEVICE =  "3S200AN") then  status5 := '0';
    elsif (SIM_DEVICE =  "3S400AN") then  status5 := '0';
    elsif (SIM_DEVICE =  "3S700AN") then  status5 := '1';
    elsif (SIM_DEVICE = "3S1400AN") then  status5 := '1' ;
    else                                  status5 := '0';
    end if;                               
    return status5;
end device_sel3;

function page_cal        (SIM_DEVICE : in string
                         ) return integer is
    variable pages  : integer range 1 to 8192 := 2048;
begin
    if    (SIM_DEVICE =   "3S50AN") then  pages := 512;
    elsif (SIM_DEVICE =  "3S200AN") then  pages := 2048;   
    elsif (SIM_DEVICE =  "3S400AN") then  pages := 2048;
    elsif (SIM_DEVICE =  "3S700AN") then  pages := 4096;
    elsif (SIM_DEVICE = "3S1400AN") then  pages := 4096;
    else                                  pages := 512;
    end if;                               
    return  pages;
end page_cal;

function pageper_sector (SIM_DEVICE : in string
                  ) return integer is
    variable page_per_sector :  integer range 1 to 256 :=256;
begin
    if    (SIM_DEVICE =   "3S50AN") then  page_per_sector := 128;  
    elsif (SIM_DEVICE =  "3S200AN") then  page_per_sector := 256;   
    elsif (SIM_DEVICE =  "3S400AN") then  page_per_sector := 256;  
    elsif (SIM_DEVICE =  "3S700AN") then  page_per_sector := 256;  
    elsif (SIM_DEVICE = "3S1400AN") then  page_per_sector := 256;  
    else                                  page_per_sector := 128;  
    end if;                               
    return  page_per_sector;
end pageper_sector;

function sec_tors (SIM_DEVICE : in string
                  ) return integer is
    variable sectors :  integer range 1 to 64 :=8;
begin
    if    (SIM_DEVICE =   "3S50AN") then  sectors := 4;
    elsif (SIM_DEVICE =  "3S200AN") then  sectors := 8;   
    elsif (SIM_DEVICE =  "3S400AN") then  sectors := 8;
    elsif (SIM_DEVICE =  "3S700AN") then  sectors := 16;
    elsif (SIM_DEVICE = "3S1400AN") then  sectors := 16;
    else                                  sectors := 4;
    end if;                               
    return  sectors;
end sec_tors;          

function pagesize_forbuffer (SIM_DEVICE : in string
                  ) return integer is
    variable page_size :  integer range 1 to 1056 :=264;
begin
    if    (SIM_DEVICE =   "3S50AN") then  page_size := 264;
    elsif (SIM_DEVICE =  "3S200AN") then  page_size := 264;
    elsif (SIM_DEVICE =  "3S400AN") then  page_size := 264;
    elsif (SIM_DEVICE =  "3S700AN") then  page_size := 264;
    elsif (SIM_DEVICE = "3S1400AN") then  page_size := 528;
    else                                  page_size := 264;
    end if;
    return  page_size;
end pagesize_forbuffer;


function pagesize (SIM_DEVICE : in string;
    binary_page : in std_logic
) return integer is
variable page_size :  integer range 1 to 1056 :=264;
begin
    if    (SIM_DEVICE =   "3S50AN") then  page_size := (264 - (conv_integer(binary_page) * 8));
    elsif (SIM_DEVICE =  "3S200AN") then  page_size := (264 - (conv_integer(binary_page) * 8));
    elsif (SIM_DEVICE =  "3S400AN") then  page_size := (264 - (conv_integer(binary_page) * 8));
    elsif (SIM_DEVICE =  "3S700AN") then  page_size := (264 - (conv_integer(binary_page) * 8));
    elsif (SIM_DEVICE = "3S1400AN") then  page_size := (528 - (conv_integer(binary_page) * 16));
    else                                  page_size:=  (264 - (conv_integer(binary_page) * 8));
    end if;                               
    return  page_size;
end pagesize;


function buffers  (
            SIM_DEVICE : in string
          ) return integer is
variable buf  : integer := 2;
begin
    if    (SIM_DEVICE =   "3S50AN") then  buf := 1;
    elsif (SIM_DEVICE =  "3S200AN") then  buf := 2;
    elsif (SIM_DEVICE =  "3S400AN") then  buf := 2;
    elsif (SIM_DEVICE =  "3S700AN") then  buf := 2;
    elsif (SIM_DEVICE = "3S1400AN") then  buf := 2;
    else                                  buf := 1;
    end if;                               
    return  buf;
end buffers;

function b_address (SIM_DEVICE : in string;
            binary_opt : in std_logic
                     ) return integer is
variable baddress : integer range 1 to 11 := 9; 
begin
    if    (SIM_DEVICE =   "3S50AN") then  baddress := (9 - (conv_integer(binary_opt) * 1));
    elsif (SIM_DEVICE =  "3S200AN") then  baddress := (9 - (conv_integer(binary_opt) * 1));   
    elsif (SIM_DEVICE =  "3S400AN") then  baddress := (9 - (conv_integer(binary_opt) * 1));
    elsif (SIM_DEVICE =  "3S700AN") then  baddress := (9 - (conv_integer(binary_opt) * 1));
    elsif (SIM_DEVICE = "3S1400AN") then  baddress := (10 -(conv_integer(binary_opt) * 1));
    else                                  baddress := (9 - (conv_integer(binary_opt) * 1));
    end if;                               
    return  baddress;
end b_address;
    
function p_address (SIM_DEVICE : in string
                             ) return integer is
variable paddress : integer range 1 to 14 := 11; 
begin
    if    (SIM_DEVICE =   "3S50AN") then  paddress := 9;
    elsif (SIM_DEVICE =  "3S200AN") then  paddress := 11;   
    elsif (SIM_DEVICE =  "3S400AN") then  paddress := 11;
    elsif (SIM_DEVICE =  "3S700AN") then  paddress := 12;
    elsif (SIM_DEVICE = "3S1400AN") then  paddress := 12;
    else                                  paddress := 9;
    end if;                               
    return  paddress;
end p_address;

function s_address (SIM_DEVICE : in string
                             ) return integer is
variable saddress : integer range 1 to 6 := 3; 
begin
    if    (SIM_DEVICE =   "3S50AN") then  saddress := 2;
    elsif (SIM_DEVICE =  "3S200AN") then  saddress := 3;   
    elsif (SIM_DEVICE =  "3S400AN") then  saddress := 3;
    elsif (SIM_DEVICE =  "3S700AN") then  saddress := 4;
    elsif (SIM_DEVICE = "3S1400AN") then  saddress := 4;
    else                                  saddress := 2;
    end if;                               
    return  saddress;
end s_address;

function manid (SIM_DEVICE : in string
                             ) return std_logic_vector is
variable man_id : std_logic_vector(31 downto 0); 
begin
    if    (SIM_DEVICE =   "3S50AN") then  man_id := X"1F_22_00_00";
    elsif (SIM_DEVICE =  "3S200AN") then  man_id := X"1F_24_00_00";   
    elsif (SIM_DEVICE =  "3S400AN") then  man_id := X"1F_24_00_00";
    elsif (SIM_DEVICE =  "3S700AN") then  man_id := X"1F_25_00_00";
    elsif (SIM_DEVICE = "3S1400AN") then  man_id := X"1F_26_00_00";
    else                                  man_id := X"1F_22_01_00";
    end if;                               
    return  man_id;
end manid;


function memsize (page_size : in integer range 1 to 1056;
                  pages    : in integer range 1 to 8192
             ) return integer is
variable mem_size : integer range 1 to 69206016;
begin
    mem_size := page_size * pages;
    return mem_size;
end memsize;

constant binary_page : std_logic :='0';    
signal status2 : std_logic :='1';
signal status3 : std_logic ;
signal status4 : std_logic ;
signal status5 : std_logic ;

------------------------------------------------ 
signal  TsckRp,TsckRpa , TsckRp33, TsckRpx ,TsckFp, TsckRw , TsckF , TcsR , TcsF , Tsckm , Tsim , TsckRh  : time := 0 ns ;
signal  TsckRpcsb  , TsckFcsb  : time := 0 ns ;

signal  clk_err: std_logic;
signal  clk_err33: std_logic;
signal  csb_err: std_logic;
signal  clk_erra: std_logic;
signal  backgnd_while_busy_err: std_logic;


------------- global signal declarations---------

signal  MMCAR : std_logic;        
signal  MMPTBT : std_logic;      
signal  MMPTBC : std_logic;      
signal  B1W : std_logic;          
signal  B2W : std_logic;          
signal  BTMMPP : std_logic;
signal  PE : std_logic;           
signal  SE : std_logic;           
signal  MMPPB : std_logic;       
signal  security_flag : std_logic:='0'; 
signal tmp_reg1 : std_logic_vector(7 downto 0);
signal tmp_reg2 : std_logic_vector(7 downto 0);
signal buff_num : std_logic_vector(1 downto 0);  -- buffer number
signal buff_nump : std_logic_vector(1 downto 0);  -- buffer number
signal erase_flag: std_logic;   -- Flag for whether command performs erase
signal cmd_name  : string(1 to 40) :="        Initialize                      ";  
signal cycle_mode  : string(1 to 5) :="idle ";  
signal test_33mhz  : Boolean := FALSE ;  -- flag to on 33 MHz 
signal random     : Boolean :=   FALSE;  -- flag for random read

------------------------------------------------------------------------------
-- Signal       ____/------\_______/----
--              <-------------->
procedure checkclk(
    signal      TestSignal          : in std_logic;
                TestSignalName      : in string; 
                expectedDelay       : in time;
                expectedDelayName   : in string;
    signal      LastSignalRise      : inout time;
    signal      LastSignalFall      : inout time;    
    signal      clk_err             :inout std_logic;
                fullPathName        : in string;
    signal      valid               :in Boolean;
    signal      pos_check           :in Boolean;
    signal      neg_check           :in Boolean    
              )  is
    variable ln : Line;
    variable  per_flag: boolean;
    
begin

if (TestSignal'event ) then
    if ((((now - LastSignalRise) < expectedDelay and pos_check )or (now - LastSignalFall < expectedDelay and neg_check))
          and (clk_err /= '1' and (valid = TRUE) and (now > expectedDelay))) then
        write(ln, string'("DRC Error : In "));
        write(ln, fullPathName);
        write(ln, string'(": '"));
        write(ln, string'(TestSignalName));
        write(ln, string'("' high/low time violation at: "));
        write(ln, now);
        write(ln, string'(", "));
        write(ln, string'(" signal width: "));
        if (now - LastSignalFall <  delay_cal(Tspiclkl,scaled_flag)) then 
            write(ln, now - LastSignalFall);
        else
            write(ln, now - LastSignalRise);
        end if;  
        write(ln, string'(" Minimum Width: "));          
            write(ln, expectedDelay);
        writeline(output, ln);
        clk_err <= '1';
        assert false report ln.all severity warning;
        DEALLOCATE (ln);        
    else
        clk_err <= '0';
    end if;     
    if (TestSignal = '1'    ) then
        LastSignalRise <= now;
    else
      LastSignalFall <= now;
    end if;
end if;
end checkclk;


procedure checkPeriod(
    signal      TestSignal      : in std_logic;
                TestSignalName      : in string;
                expectedDelay       : in time;
                expectedDelayName   : in string;
    signal      LastSignalRise      : inout time;
    signal      clk_err             :inout std_logic;
                fullPathName        : in string;
    signal      valid          :in Boolean
              )  is
    variable ln : Line;
    variable  per_flag: boolean;
    
begin

if (TestSignal'event and TestSignal = '1') then
   if   (now - lastSignalRise < expectedDelay) and ( lastSignalRise /= 0 ns ) and
       (now > 0 ns) and (expectedDelay /= 0 ns) and (clk_err /= '1') and (valid = TRUE) then 
      write(ln, string'("DRC Error : In "));
      write(ln, fullPathName);
      write(ln, string'(": '"));
      write(ln, string'(TestSignalName));
      write(ln, string'("' Period violation at: "));
      write(ln, now);
      write(ln, string'(", "));
      write(ln, string'(expectedDelayName));
      write(ln, string'(" expected: "));
      write(ln, expectedDelay);
      write(ln, string'(", "));
      write(ln, string'(expectedDelayName));
      write(ln, string'(" actual: "));
      write(ln, now - lastSignalRise);
      writeline(output, ln);
      clk_err <= '1';
      assert false report ln.all severity warning;
      DEALLOCATE (ln);        
    end if;
    if (now - lastSignalRise > expectedDelay) and ( lastSignalRise /= 0 ns ) and
       (now > 0 ns) and (expectedDelay /= 0 ns)then 
        clk_err <= '0';
    end if;     
    if (valid = FALSE) then 
        clk_err <= '0';
    end if;     
    LastSignalRise <= now;
end if;
end checkPeriod;

procedure write_busy_message is 
variable Message :line;
begin
    Write ( Message, string'("DRC Error : In "));
    Write ( Message, InstancePath); 
    Write ( Message, string'(" access not allowed -- busy"));
    assert false report Message.all severity failure;
    DEALLOCATE (Message);       
end write_busy_message; 


procedure write_opcode_message is
variable Message :line;
begin
    Write ( Message, string'("DRC Error : In "));
    Write ( Message, InstancePath); 
    Write ( Message, string'(" opcode is not supported in the simulation model"));
    assert false report Message.all severity warning;
    DEALLOCATE (Message);       
end write_opcode_message;
    
    
procedure write_tpuw_message is
variable Message:line;
begin
    Write ( Message, string'("DRC Error : In "));
    Write ( Message, InstancePath); 
    Write ( Message, string'(" write operations are not allowed before a delay of :")); 
    Write ( Message, delay_cal(TPUW,scaled_flag) );
    Write ( Message,string'(" ms"));
    assert false report Message.all severity failure;
    DEALLOCATE (Message);       
end write_tpuw_message;
-------------------------------------------------------------------
-------------------------------------------------------------------
    FUNCTION integer_to_bit_vector   (VAL, width    : INTEGER)      RETURN BIT_VECTOR IS
    VARIABLE result : BIT_VECTOR (width-1 downto 0) := (OTHERS=>'0');
        VARIABLE bits   : INTEGER := width;
    BEGIN
        IF (bits > 31) THEN              --  Avoid overflow errors.
          bits := 31;
        ELSE
      ASSERT 2**bits > VAL REPORT
        "Value too big FOR BIT_VECTOR width"
        SEVERITY WARNING;
        END IF;
    FOR i IN 0 TO bits - 1 LOOP
        IF ((val/(2**i)) MOD 2 = 1) THEN
        result(i) := '1';
        END IF;
    END LOOP;
    RETURN (result);
    END integer_to_bit_vector ;  

 PROCEDURE removespace(VARIABLE l : IN line; pos : OUT integer) IS
    BEGIN
         pos := l'low;
         FOR i IN l'low TO l'high LOOP
              CASE l(i) IS
                  WHEN ' ' | ht  =>
                      pos := i + 1;
                  WHEN OTHERS =>
                      EXIT;
              END CASE;
         END LOOP;
    END;
    PROCEDURE removeline(l : INOUT line; pos : integer) IS
        VARIABLE tmpl : line;
    BEGIN
        tmpl := l;
        l := NEW string'(tmpl(pos TO tmpl'high));
        deallocate(tmpl);
    END;
    PROCEDURE hexa_to_bit_vector(l: INOUT line; u: in integer; value: OUT bit_vector) IS
        CONSTANT not_digit : integer := -999;
        FUNCTION digit_value(c : character) RETURN integer IS
        BEGIN
            IF (c >= '0') AND (c <= '9') THEN
                RETURN (character'pos(c) - character'pos('0'));
            ELSIF (c >= 'a') AND (c <= 'f') THEN
                RETURN (character'pos(c) - character'pos('a') + 10);
            ELSIF (c >= 'A') AND (c <= 'F') THEN
                RETURN (character'pos(c) - character'pos('A') + 10);
            ELSE
                RETURN not_digit;
            END IF;
        END;
        VARIABLE digit  : bit_vector(4 downto 1);
        VARIABLE digit1 : bit_vector(u downto 1);
        VARIABLE digitx : integer;
        VARIABLE pos    : integer;
        VARIABLE t      : integer := u/4;
    BEGIN
        removespace(l, pos);
        FOR i IN pos TO l'right LOOP
            digitx := digit_value(l(i));
            EXIT WHEN (digitx = not_digit) OR (digitx >= 16);
            digit := integer_to_bit_vector(digitx,4);
            if t >= 1 then
                digit1 := digit1(u-4 downto 1) & digit;
                t := t - 1;
            else
            end if;
            pos := i + 1;
        END LOOP;
        value := digit1;
        removeline(l, pos);
    END;    

--******************************************---
--******************************************--
signal page : std_logic_vector(p_address(SIM_DEVICE)-1 downto 0) := (others=> '0');
--signal temp_reg2 : std_logic_vector(7 downto 0);
--signal temp_page : std_logic_vector(p_address(SIM_DEVICE)-1 downto 0);
signal byte : integer;
---protected/locked status reg-----
signal sector : std_logic_vector(s_address(SIM_DEVICE)-1 downto 0);
type buffer1 is array(pagesize_forbuffer(SIM_DEVICE)-1 downto 0) of std_logic_vector(7 downto 0);
type buffer2 is array(pagesize_forbuffer(SIM_DEVICE)-1 downto 0) of std_logic_vector(7 downto 0);
--memory initalization--
constant N : integer range 1 to 69206016 := memsize(pagesize_forbuffer(SIM_DEVICE),page_cal(SIM_DEVICE));
constant M : integer := 8;
type memtype is array(N-1 downto 0) of std_logic_vector(7 downto 0);
constant p : integer := sec_tors(SIM_DEVICE);
type factory_type is array(63 downto 0 ) of std_logic_vector(7 downto 0);
signal factory_reg : factory_type;

--security reg--
type security_type is array(63 downto 0) of std_logic_vector(7 downto 0);
signal security_reg : security_type;

--------------comp page address function implementation---------------
function comp_page_addr     (    paddress : in integer range 1 to 14;
                    binary_page : in std_logic;
                    page_addr0 : in std_logic_vector( 7 downto 0);
                    page_addr1 : in std_logic_vector( 7 downto 0);
                    man_id : in std_logic_vector(31 downto 0)      
                ) return std_logic_vector is
variable page1 : std_logic_vector((P_ADDRESS(SIM_DEVICE))-1 DOWNTO 0);
begin
    case(PADDRESS) is
        when 12=>
                                         ---16mb----
            if (MAN_ID = X"1F260000") then
                if (binary_page = '1') then
                    page1 := page_addr0(4 downto 0) & page_addr1(7 downto 1);
                else        
                    page1 := page_addr0(5 downto 0) & page_addr1(7 downto 2);
                end if;
            end if;
                                            --8mb--
            if (MAN_ID = X"1F250000") then
                if (binary_page = '1') then
                    page1 := page_addr0(3 downto 0) & page_addr1(7 downto 0);
                else        
                    page1 := page_addr0(4 downto 0) &  page_addr1(7 downto 1);
                end if;
            end if;
                                          ---4 mb---
        when 11=>
            if (binary_page = '1') then
                page1 := page_addr0(2 downto 0) &  page_addr1(7 downto 0);
            else        
                page1 := page_addr0(3 downto 0) &  page_addr1(7 downto 1);
            end if;
                                          --1mb---
        when 9=>
            if (binary_page ='1') then
                 page1 := page_addr0(0) & page_addr1(7 downto 0);
            else  
                page1 := page_addr0(1 downto 0) & page_addr1(7 downto 1);   
            end if;
        when others =>
    end case;
    return page1;
end comp_page_addr;


----------------------------
function comp_byte_addr
    (baddress : integer range 1 to 11 ;
    signal page_addr1 : in std_logic_vector( 7 downto 0);
    signal byte_addr : in std_logic_vector( 7 downto 0);
     binary_opt : in std_logic
    ) return integer is
variable byte_ad : integer;-- range 1 to 11 := 8;              
begin
    case(baddress)is
        when 11 =>  byte_ad :=  conv_integer(page_addr1(2 downto 0)  &  byte_addr) ;
        when 10 =>  byte_ad := conv_integer(page_addr1(1 downto 0) &  byte_addr) ; 
        when 9 =>   byte_ad := conv_integer(page_addr1(0) &  byte_addr) ; 
        when others=>  byte_ad := conv_integer(byte_addr) ;
    end case;
    return byte_ad;
end comp_byte_addr;     


procedure compute_address  ( 
    page : in std_logic_vector((P_ADDRESS(SIM_DEVICE))-1 DOWNTO 0);
    page_size : in integer range 1 to 1056;
    byte : in integer;
    page_boundary_low : out integer;
    page_boundary_high : out integer;
    current_address : out integer;
    mem_no : out integer;
    binary_page : in std_logic
) is
variable temp_low : integer ;
begin
    temp_low := (conv_integer(page) * pagesize(SIM_DEVICE,binary_page));
    page_boundary_low := temp_low;
    page_boundary_high := temp_low + (pagesize(SIM_DEVICE,binary_page) - 1);
    current_address := temp_low + byte;
    --memno 10 is for memory access---
    mem_no := 10;
end compute_address;


procedure read_out_array 
                (signal CLK,CSB : in std_logic;
                page_size : in integer range 1 to 1056;
                mem_size  : in integer range 1 to 69206016;
                page_boundary_low : in integer;
                page_boundary_high :in integer;
                current_address : in integer;
                memory : in memtype;
                signal so_reg : out std_logic;
                binary_page : in std_logic;
                signal so_on1  : out std_logic
                )
                 is
variable temp_reg1 : std_logic_vector(7 downto 0);
variable temp_high : integer;
variable temp_low  : integer;
variable temp_add  : integer;
begin               
    temp_high := page_boundary_high;
    temp_low := page_boundary_low;
    temp_add := current_address;
    temp_reg1 :=  memory(temp_add);
    read_array_loop : loop
        for i in 7 downto 0 loop
            wait until (CLK'EVENT and CLK ='0') or (CSB'EVENT and CSB='1');
            exit read_array_loop when (CSB='1' ) ;
            SO_reg <= temp_reg1(i); 
            so_on1 <= '1';
        end loop;
        temp_add := temp_add + 1;
        if (temp_add >= N)then  -- N = size of memory
            temp_add := 0; --Note that rollover occurs at end of memory,
            temp_high := pagesize(SIM_DEVICE,binary_page) - 1; -- and not at the end of the page
            temp_low := 0;
        end if;
        if (temp_add > temp_high) then-- going to next page
            temp_high := temp_high + pagesize(SIM_DEVICE,binary_page);
            temp_low  := temp_low + pagesize(SIM_DEVICE,binary_page);
        end if;
        temp_reg1 :=  memory(temp_add);
    end loop;
    SO_reg <= '0';
    so_on1 <= '0';  
end read_out_array;


procedure transfer_to_buffer  
            (
             buf_type : in std_logic_vector(1 downto 0);
             page_boundary_low : in integer;
            memory : in memtype;
            buf1 : inout buffer1;
            binary_page : in std_logic;
            buf2 : inout buffer2
            ) is    
begin   
if (buf_type = "01") then
    for i in 0 to pagesize(SIM_DEVICE,binary_page)-1 LOOP
       buf1(i) := memory(page_boundary_low + i);
    end loop;   
  elsif (buf_type = "10") then
    for  i in 0 to pagesize(SIM_DEVICE,binary_page)-1 loop
       buf2(i) := memory(page_boundary_low + i);
       end loop;
end if;
end transfer_to_buffer;


procedure compare_with_buffer
(
    buf_type : in std_logic_vector(1 downto 0);
    page_boundary_low : in integer;
    memory : in memtype;
    buf1 : in buffer1;
    buf2 : in buffer2;
    binary_page : in std_logic;
    signal status : out std_logic
) is
variable tmp1,tmp2 : std_logic_vector(7 downto 0);
begin
    status <='0';
    if(buf_type = "01")then
        for i in 0 to pagesize(SIM_DEVICE,binary_page)-1 loop
        tmp1 := memory(page_boundary_low  + i);
        tmp2 := buf1(i);
        for k in 0 to 7 loop
        if(tmp1(k) /= tmp2(k) ) then
            status <= '1';
            exit;
            end if;
            end loop;
        end loop;
        elsif  (buf_type = "10") then
        for i in 0 to pagesize(SIM_DEVICE,binary_page)-1 loop
            tmp1 := memory(page_boundary_low  + i);
            tmp2 := buf2(i);
            for k in 0 to 7 loop
                if(tmp1(k) /= tmp2(k) ) then
                    status <= '1';
                    exit;
                end if;
            end loop;
        end loop;
    end if;
end compare_with_buffer;


-----------write_data------------
procedure write_data 
            ( current_address : inout integer;
             page_boundary_low : in integer;
             page_boundary_high : in integer;
             buf1 : inout buffer1;
             buf2 : inout buffer2; 
             buf_type : in std_logic_vector(1 downto 0);
             signal CSB,CLK,MOSI   : in std_logic
             ) is
variable buf_temp_reg : std_logic_vector(7 downto 0);
variable temp :std_logic := '0';
begin
    write_loop : loop
        for i in 7 downto 0 loop
            wait until (CLK'EVENT and CLK ='1') or (CSB'EVENT and CSB='1');
            if (CSB='1') then
                exit write_loop;
            end if;
            buf_temp_reg(i):=MOSI;
        end loop;   
        if (buf_type="01") then
            buf1(current_address):= buf_temp_reg;  
        elsif(buf_type="10") then
            buf2(current_address):= buf_temp_reg;  
        end if;
        current_address := current_address + 1;
        wait for 1 ps;
        if (current_address > page_boundary_high) then  
            current_address := page_boundary_low;
            wait for 1 ps;
        end if;
    end loop;
end write_data;


procedure write_to_memory 
                (
                buf_type : in std_logic_vector(1 downto 0);
                 page : in std_logic_vector((P_ADDRESS(SIM_DEVICE))-1 DOWNTO 0);
                 page_size : in integer range 1 to 1056;
                buf1 : in buffer1;
                buf2 : in  buffer2;
                
                 page_boundary_low : in integer;
                memory : inout memtype
                    ) is
variable Message : line;
variable display_warning : integer;
begin
display_warning := 0;
if (buf_type = "01") then
    for i in 0 to page_size-1 loop
       memory(page_boundary_low+i) := buf1(i) and  memory(page_boundary_low+i);
       if (buf1(i) /= memory(page_boundary_low+i)) then
          display_warning := 1;
       end if;
    end loop;   
  elsif (buf_type = "10") then
    for i in 0 to page_size-1 loop
       memory(page_boundary_low+i) := buf2(i) and  memory(page_boundary_low+i);
       if (buf2(i) /= memory(page_boundary_low+i)) then
          display_warning := 1;
       end if;
    end loop;
end if;
if (display_warning = 1) then
   Write ( Message, string'("DRC Warning : In "));
   Write ( Message, InstancePath); 
   Write ( Message, string'(" at: "));
   Write ( Message, now);
   Write ( Message, string'(", attempt to program bits to 1 on page "));
   Write ( Message, conv_integer(page));
   Write ( Message, string'(" without an erase. Overwriting 0 with 1 requires a page erase first."));
   assert false report Message.all severity warning;
   DEALLOCATE (Message);       
   display_warning := 0;
end if;
end write_to_memory;


procedure erase_page  
            (
            page : in std_logic_vector((P_ADDRESS(SIM_DEVICE))-1 DOWNTO 0);
            page_size : in integer range 1 to 1056;
            page_boundary_low : in integer;
            memory : inout memtype;
            binary_page : in std_logic;
            page_status : out std_logic 
            ) is
variable buf1 : buffer1;
variable buf2 : buffer2;
begin
for i in 0 to pagesize(SIM_DEVICE,binary_page)-1 loop
    memory(page_boundary_low + i ) := X"FF";
    page_status :='0';
end loop;
end erase_page;


----------read_out_reg--------
procedure read_out_reg 
            ( reg_type : in integer;
              add      : in integer;
              high     : in integer;
            security_reg : in security_type ;    
            signal CSB,CLK       : in std_logic;
            signal so_reg    : out std_logic;
            signal  so_on1     : out std_logic
            ) is
variable temp_add : integer;
variable t_reg1 : std_logic_vector(7 downto 0);
begin
    temp_add := add;
    t_reg1 := security_reg(temp_add);
    read_out_reg_loop : loop
        for i in 7 downto 0 loop
            wait until (CLK'EVENT and CLK ='0') or (CSB'EVENT and CSB='1');
            exit read_out_reg_loop when (CSB='1' ) ;
            so_reg <= t_reg1(i);
            so_on1   <= '1';
        end loop;   
        temp_add := temp_add + 1;
        if ( temp_add > high)then
            t_reg1 := (others => 'X' );
        else
            if (reg_type=23) then 
                if (temp_add < 64) then
                    t_reg1 := security_reg(temp_add);   
                else
                    t_reg1 := factory_reg(temp_add-64); 
                end if;
            end if;
        end if;     
     end loop;
     so_reg <= '1';
     so_on1 <= '0';
end read_out_reg;       


function getbyte    (
            IP : in bit_vector(511 downto 0);
            byte_num  : in integer
            ) return bit_vector is

variable temp : bit_vector( 7 downto 0);                
begin

    for i in 0 to 7 loop
    temp(i) := IP((byte_num-1)*8+i);
    end loop;           
return temp;

end getbyte;

procedure read_mem_file (
            --signal memory : inout memtype;
            memory : inout memtype;
            inbuf : inout line
            )is                
     file LOAD_FILE1 : text open read_mode is SIM_MEM_FILE;
     variable numword : integer := 0;
     variable value : bit_vector(7 downto 0);
begin                          
    if(SIM_MEM_FILE /= "NONE")then 
        while not ENDFILE(LOAD_FILE1) loop 
            READLINE(LOAD_FILE1,inbuf);
            hexa_to_bit_vector(inbuf, 8, value);
            memory(numword) := to_stdlogicvector(value);
            numword := numword + 1;
            if(numword = (N-1)) then
                 exit;         
            end if;            
        end loop;              
    end if;                    
end read_mem_file;             
                               
--******************************************---
--******************************************--
signal temp_reg1 : std_logic_vector(7 downto 0);
signal reset_sig : std_logic:= '0';
signal skip : std_logic := '1';
signal skip_be : std_logic := '0';
signal skip_end : std_logic := '0';
signal opcode_temp : std_logic_vector(7 downto 0) := "00000000";
signal page_addr0 : std_logic_vector(7 downto 0) := "00000000";
signal page_addr1 : std_logic_vector(7 downto 0) := "00000000";
signal byte_addr  : std_logic_vector(7 downto 0) := "00000000";
signal t : std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
signal rd_data1 : std_logic_vector(7 downto 0);
signal arr_rd_dummybyte : integer := 0;
signal buff_rd_dummybyte : integer:= 0;

signal valid : Boolean := TRUE;
signal no_test : Boolean := FALSE;
signal  MIR : std_logic :='0';  
signal  SRR : std_logic:='0';  
signal  SRP : std_logic:='0';  
signal  err_flg : std_logic:='0';
signal mem_initialized : std_logic;
signal deep_power_down : std_logic := '0';
signal  SR : std_logic:= '0';  
signal RDYBSY_reg : std_logic :='1'; 
signal foreground_op_enable : std_logic :='0';
signal background_op_enable : std_logic:='0';
signal status_read : std_logic :='0';
signal so_reg : std_logic := '1';
signal so_on : std_logic :='0';
signal so_reg1 : std_logic := '1';
signal so_on1 : std_logic :='0';
signal so_reg2 : std_logic := '1';
signal so_on2 : std_logic :='0';
signal so_reg3 : std_logic := '1';
signal so_on3 : std_logic :='0';
signal status : std_logic_vector(7 downto 0):= ('1' & '0' &  Device_sel3(SIM_DEVICE) & Device_sel2(SIM_DEVICE) & Device_sel1(SIM_DEVICE)& '1' & '0' & '0');

-----------status signal-------------

signal status_B1C_s6 : std_logic;
signal status_B2C_s6 : std_logic;


  signal        MISO_zd          : std_ulogic := '1';

  signal        CLK_ipd          : std_ulogic := '0';
  signal        CSB_ipd          : std_ulogic := '0';
  signal        MOSI_ipd         : std_ulogic := '0';

  signal        CLK_dly          : std_ulogic := 'X';
  signal        CSB_dly          : std_ulogic := 'X';
  signal        csbx             : std_ulogic := 'X';
  
  signal        MOSI_dly         : std_ulogic := '0';
  signal        Violation        : std_ulogic := '0';

--**************** begin of Architecture **************---


begin

  ---------------------
  --  INPUT PATH DELAYs
  --------------------

  prcs_input:process(MOSI,CSB,CLK)
  begin
      MOSI_dly   <= MOSI ;
      CSB_dly    <= CSB ; 
      CLK_dly    <= CLK ;
  end process prcs_input;

  --------------------
  --  BEHAVIOR SECTION
  --------------------

--comparing the opcodes--
process(CLK_dly,MOSI_dly,CSB_dly)
begin
    if ( CSB_dly ='1') then
        t <="00000000000000000000000000000000";
        rd_data1 <= "00000000";
    elsif(CLK_dly = '1' and CLK_dly'event) then
        t(0) <= '1';
        t(1) <= t(0);
        t(2) <= t(1);
        t(3) <= t(2);
        t(4) <= t(3);
        t(5) <= t(4);
        t(6) <= t(5); 
        t(7) <= t(6);         -- t(6) == 1 and t(7) ==0 opcode
        t(8) <= t(7);
        t(9) <= t(8);
        t(10) <= t(9);
        t(11) <= t(10);
        t(12) <= t(11);
        t(13) <= t(12);
        t(14) <= t(13);
        t(15) <= t(14);       -- t(14) == 1 and t(15) ==0 page address 
        t(16) <= t(15);      
        t(17) <= t(16);
        t(18) <= t(17);
        t(19) <= t(18);
        t(20) <= t(19);
        t(21) <= t(20);
        t(22) <= t(21);
        t(23) <= t(22);     -- t(22) == 1 and t(23) ==0 page address 
        t(24) <= t(23);
        t(25) <= t(24);
        t(26) <= t(25);
        t(27) <= t(26);
        t(28) <= t(27);
        t(29) <= t(28);
        t(30) <= t(29);
        t(31) <= t(30);     -- t(30) == 1 and t(31) == 0  byte address 
            rd_data1(0) <= MOSI_dly;
            rd_data1(1) <= rd_data1(0);
            rd_data1(2) <= rd_data1(1);
            rd_data1(3) <= rd_data1(2);
            rd_data1(4) <= rd_data1(3);
            rd_data1(5) <= rd_data1(4);
            rd_data1(6) <= rd_data1(5);
            rd_data1(7) <= rd_data1(6);
        
        end if;
end process ;

opcode_temp  <=   rd_data1(6) & rd_data1(5) & rd_data1(4) & rd_data1(3) & rd_data1(2) & rd_data1(1) & rd_data1(0) & MOSI_dly ; 
process(CLK_dly,opcode_temp, t)
begin
    if (CSB_dly = '1' ) then
    page_addr0 <= "00000000";
    page_addr1 <= "00000000";
    byte_addr <= "00000000";

    elsif ((CLK_dly = '1' and CLK_dly'event)) then
        if (t(14) = '1' and t(15) = '0') then    
        page_addr0 <= opcode_temp;
        end if;
        if (t(22) = '1' and t(23) = '0') then    
        page_addr1 <= opcode_temp;
        end if;
        if (t(30) = '1' and t(31) = '0') then    
        byte_addr <= opcode_temp;
        end if;
    end if;
end process;


process(CLK_dly,opcode_temp, t)
variable opcode_message : string(1 to 52);
variable Message : line;
begin
    if (CSB_dly = '1' )  then
            skip <='1';
            arr_rd_dummybyte <= 0;  --not used in their code
            buff_rd_dummybyte <= 0;
            MMCAR <='0';
            MMPTBT <='0'; --Main Memory Page To Buffer 1 Transfer
            MMPTBC <='0';--Main Memory Page To Buffer 1 Compare
            B1W <='0'; -- Buffer 1 Write
            B2W <='0'; 
            BTMMPP <= '0' ;--Buffer 1 To Main Memory Page Prog With Built-In Erase
            PE<='0';  -- Page Erase
            SE <='0';  -- Sector Erase
            MMPPB<='0';   -- Main Memory Page Prog. Through Buffer 1
            SR<='0' ; -- Status Register Read
            MIR<='0'; -- Manufecturing ID Read
            SRR<='0';  -- Security Register Read
            SRP<='0';  -- Secturity Register Program
            backgnd_while_busy_err<='0';
    elsif (CLK_dly = '1' and CLK_dly'event) then
        if (t(6) = '1' and t(7) = '0' ) then    
            if(foreground_op_enable='0')then
                Write ( Message, string'("DRC Error : In "));
                Write ( Message, InstancePath); 
                Write ( Message, string'(" No opcode is allowed. "));
                Write ( Message, delay_cal(TVCSL,scaled_flag) );
                Write ( Message, string'( "delay is required before device can be selected"));
                assert false report Message.all severity warning;
                DEALLOCATE (Message);        
            elsif(cycle_mode="MODE0")then
                Write ( Message, string'("DRC Error : In "));
                Write ( Message, InstancePath); 
                Write ( Message, string'( " must drive CSB LOW while CLK is HIGH."));
                assert false report Message.all severity failure;
                DEALLOCATE (Message);        
            else    
                case opcode_temp is
                    when X"03" =>
                        cmd_name <="Random Read                             ";
                        random <= TRUE;
                        if(RDYBSY_reg='0')then
                           backgnd_while_busy_err<='1';
                           write_busy_message;
                        else
                            skip <='0';
                            arr_rd_dummybyte <= 0;
                            MMCAR <='1';
                        end if;
                     when X"0B" =>
                        cmd_name<="Main Memory Continuous Array Read       ";
                        random <= FALSE;
                        if(RDYBSY_reg='0')then 
                           backgnd_while_busy_err<='1';
                           write_busy_message;
                        else
                            skip <='0';
                            arr_rd_dummybyte <= 1;
                            MMCAR <='1';
                        end if;
                    when X"53" =>
                        cmd_name<="Main Memory Page To Buffer 1 Transfer   ";
                        if(background_op_enable='0') then
                            write_tpuw_message;
                        elsif(RDYBSY_reg='0')then 
                           backgnd_while_busy_err<='1';
                           write_busy_message;
                        else
                           buff_num <= "01";  -- buffer 1
                           MMPTBT <='1'; --Main Memory Page To Buffer 1 Transfer
                        end if;
                    when X"55" =>
                        cmd_name<="Main Memory Page To Buffer Transfer     ";
                        if(buffers(SIM_DEVICE) = 1 )then
                            write_opcode_message;
                        elsif(background_op_enable='0') then
                            write_tpuw_message;
                        elsif(RDYBSY_reg='0')then 
                            backgnd_while_busy_err<='1';
                            write_busy_message;
                        else
                            buff_num <= "10";  --buffer 2
                            MMPTBT<='1'; --Main Memory Page To Buffer 2 Transfer
                        end if;
                    when X"60" =>
                        cmd_name<="Main Memory Page To Buffer 1 Compare    ";
                        if(background_op_enable='0') then
                            write_tpuw_message;
                        elsif(RDYBSY_reg='0')then 
                            backgnd_while_busy_err<='1';
                            write_busy_message;
                        else
                           buff_num <= "01";  -- buffer 1
                           MMPTBC <='1';--Main Memory Page To Buffer Compare
                        end if;
                    when X"61" =>
                          cmd_name<="Main Memory Page To Buffer 2 Compare    ";
                        if(buffers(SIM_DEVICE) = 1 )then
                            write_opcode_message;
                        elsif(background_op_enable='0') then
                            write_tpuw_message;
                        elsif(RDYBSY_reg='0')then 
                           backgnd_while_busy_err<='1';
                           write_busy_message;
                        else
                            buff_num <= "10";  --buffer 2
                            MMPTBC <='1';--Main Memory Page To Buffer Compare
                        end if;
                    when X"84" =>
                           cmd_name <= "Buffer 1 Write                          ";
                           buff_num<= "01"; -- use buffer 1
                           B1W <='1'; -- Buffer 1 Write
                    when X"87" =>
                        cmd_name<="Buffer 2 Write                          ";
                        if(buffers(SIM_DEVICE) = 1 )then
                            write_opcode_message;
                        else   
                           buff_num<= "10"; -- use buffer 2
                           B2W <='1'; -- Buffer 2 Write
                        end if;     
                    when X"83" =>
                        cmd_name <="Buffer 1 To Main Memory Page Prog Erase ";
                        if(background_op_enable='0') then
                            write_tpuw_message;
                        elsif(RDYBSY_reg='0')then 
                           backgnd_while_busy_err<='1';
                           write_busy_message;
                        else
                             erase_flag <= '1';
                             buff_nump<= "01"; -- use buffer 1
                           BTMMPP <= '1' ;--Buffer 1 To Main Memory Page Prog With Built-In Erase
                        end if;
                    when X"86" =>
                        cmd_name <="Buffer 2 To Main Memory Page Prog Erase ";
                        if(buffers(SIM_DEVICE) = 1 )then
                            write_opcode_message;
                        elsif(background_op_enable='0') then
                            write_tpuw_message;
                        elsif(RDYBSY_reg='0')then 
                            backgnd_while_busy_err<='1';
                            write_busy_message;
                        else
                            erase_flag <= '1';
                            buff_nump<= "10"; -- use buffer 2
                            BTMMPP <= '1';-- t(14) == 1 and t(15) ==0 page address --Buffer 2 To
                                  -- Main Memory Page Prog With Built-In Erase
                        end if;
                    when X"88" =>
                        cmd_name <="Buffer 1 To Main Memory Page Prog       ";
                        if(background_op_enable='0') then
                            write_tpuw_message;
                        elsif(RDYBSY_reg='0')then 
                           backgnd_while_busy_err<='1';
                           write_busy_message;
                        else
                             erase_flag <= '0';
                             buff_nump<= "01"; -- use buffer 1
                             BTMMPP<='1';--- t(14) == 1 and t(15) ==0 page address -Buffer 1 To 
                                  --Main Memory Page Prog Without Built-In Erase
                        end if;
                    when X"89" =>
                        cmd_name <="Buffer 2 To Main Memory Page Prog       ";
                        if(buffers(SIM_DEVICE) = 1 )then
                            write_opcode_message;
                        elsif(background_op_enable='0') then
                            write_tpuw_message;
                        elsif(RDYBSY_reg='0')then 
                            backgnd_while_busy_err<='1';
                            write_busy_message;
                        else
                            erase_flag <= '0';
                            buff_nump<= "10"; -- use buffer 2
                            BTMMPP<='1' ;--Buffer 2 To Main Memory Page Prog Without Built-In Erase
                        end if;
                    when X"81" =>
                        cmd_name <="Page Erase                              ";
                        if(background_op_enable='0') then
                            write_tpuw_message;
                        elsif(RDYBSY_reg='0')then 
                           backgnd_while_busy_err<='1';
                           write_busy_message;
                        else
                           PE<='1';  -- Page Erase
                        end if;
                    when X"82" =>
                        cmd_name <="Main Memory Page Prog. Through Buffer 1 ";
                        if(background_op_enable='0') then
                            write_tpuw_message;
                        elsif(RDYBSY_reg='0')then 
                           backgnd_while_busy_err<='1';
                           write_busy_message;
                        else
                             buff_num <= "01";
                           MMPPB<='1';   -- Main Memory Page Prog. Through Buffer 1
                        end if;
                    when X"7C" =>
                        cmd_name <="Sector Erase                            ";
                        if(background_op_enable='0') then
                            write_tpuw_message;
                        elsif(RDYBSY_reg='0')then 
                           backgnd_while_busy_err<='1';
                           write_busy_message;
                        else
                           SE <='1';  -- Sector Erase
                        end if;
                    when X"85" =>
                        cmd_name <="Main Memory Page Prog. Through Buffer 2 ";
                        if(buffers(SIM_DEVICE) = 1 )then
                             write_opcode_message;
                        elsif(background_op_enable='0') then
                            write_tpuw_message;
                        elsif(RDYBSY_reg='0')then 
                           backgnd_while_busy_err<='1';
                           write_busy_message;
                        else
                            buff_num <= "10";
                            MMPPB<='1' ;  -- Main Memory Page Prog. Through Buffer 2
                        end if;
                    when X"D7" =>
                        cmd_name <="Status Register Read                    ";
                        skip <='0';
                        SR<='1'; -- Status Register Read
                    when X"9F" =>
                        cmd_name <="Manufacturer ID Read                    ";
                        skip <='0';
                        MIR<='1'; -- Manufacturing ID Read
                    when X"9B" =>
                        cmd_name <="Security Register Program               ";
                        if(background_op_enable='0') then
                            write_tpuw_message;
                        elsif(RDYBSY_reg='0')then 
                           backgnd_while_busy_err<='1';
                           write_busy_message;
                        else
                            SRP<='1';  -- 4-Byte Opcode Starting From 9B this is for Security register program
                        end if;
                    when X"77" =>
                        cmd_name <="Security Register Read                  ";
                        if(RDYBSY_reg='0')then 
                           backgnd_while_busy_err<='1';
                           write_busy_message;
                        else
                            SRR<='1';  -- Security Register Read
                        end if;
                    when others =>
                        if (opcode_temp=X"D2" or opcode_temp=X"E8" or opcode_temp=X"D4" or opcode_temp=X"D6" or 
                          opcode_temp=X"D1" or opcode_temp=X"D3" or opcode_temp=X"54" or opcode_temp=X"56" or 
                          opcode_temp=X"52" or opcode_temp=X"59" or opcode_temp=X"68" or opcode_temp=X"50" or 
                          opcode_temp=X"B9" or opcode_temp=X"AB" or opcode_temp=X"3D" or opcode_temp=X"80" or 
                          opcode_temp=X"A6" or opcode_temp=X"58" or opcode_temp=X"30" or opcode_temp=X"35" or
                          opcode_temp=X"9A" or opcode_temp=X"32" ) then
                            write_opcode_message;
                        else
                            Write ( Message, string'("DRC Error : In "));
                            Write ( Message, InstancePath); 
                            Write ( Message, string'(" opcode is not recognized "));
                            assert false report Message.all severity failure;
                            DEALLOCATE (Message);       
                        end if;
                end case;
            end if;
        end if;
    end if;
end process;

-------------------------------------------------------------------------------------
----------------------------------------Main Process --------------------------------
process(CLK_dly,CSB_dly)
begin
   if(CSB_dly='0' and CSB_dly'event)then
      if (CLK_dly = '0') then
      skip_be <= '1';
      cycle_mode <= "MODE0";
      else 
      skip_be <= '0';
      cycle_mode <= "MODE3";
      end if;
  elsif(CSB_dly='1') then
      cycle_mode <= "idle ";
  end if;   
end process ;
skip_end <= skip_be and skip;
background_op_enable <= '1'  after delay_cal(TPUW,scaled_flag) ;
reset_sig <=  '0', '1' after  1 ns;
process
variable tbuffer1 : buffer1;
variable tbuffer2 : buffer2;
variable inbuf : line;
variable word : string(1 to 8);
variable i : integer;
----------
variable inbuf1 : line;
variable numword1 : integer := 0;
variable value1 : bit_vector(7 downto 0);

variable jerase : integer;
 ---------------
variable inbuf2 : line;
variable outbuf12 : line;
variable numword2 : integer := 0;
variable value2 : bit_vector(7 downto 0);
---------------------
variable inbuf3 : line;
variable numword3 : integer := 0;
variable value3 : bit_vector(7 downto 0);
------------------
variable MMPPB_mem_page : std_logic_vector(p_address(SIM_DEVICE)-1 downto 0);
variable MMPPB_buf_page : std_logic_vector(p_address(SIM_DEVICE)-1 downto 0);
variable buf_temp_reg1 : std_logic_vector(7 downto 0);
variable message1 : string(1 to 45);
variable message2 : string(1 to 30); 
variable current_address : integer; 
variable page_boundary_low : integer := 0;
variable page_boundary_high : integer;
variable mem_no : integer;
variable memory : memtype;
-- variable security_reg : security_type;

-- variable binary_page : std_logic;
variable never_set : std_logic := '0';
variable temp_page_status : std_logic;
variable buffer_number : integer;
variable page_status : std_logic_vector(page_cal(SIM_DEVICE)-1 downto 0);
variable Message : line;
variable value_fact : bit_vector(511 downto 0);
variable value_user : bit_vector(511 downto 0);

begin

if (foreground_op_enable = '0') then  ---- Enable foreground op_codes
wait on reset_sig ;
wait for 1 ps;
for i in 0 to (memsize(pagesize(SIM_DEVICE,binary_page),page_cal(SIM_DEVICE))-1) loop  
memory(i) := (others=>'1');
end loop;

mem_initialized <= '0';
wait for 1 ps;
If(SIM_MEM_FILE /= "NONE") then
    read_mem_file(memory,inbuf);
mem_initialized <= '1';
end if;
wait for 1 ps;
if (mem_initialized = '1') then
  for j in 0 to page_cal(SIM_DEVICE)-1 loop
    page_status(j) := '1'; -- memory was initialized, so, Pages are Not Erased.
  end loop;
  else
  for j in 0 to page_cal(SIM_DEVICE)-1 loop
    page_status(j) := '0';
  end loop;
  
end if;
wait for 1 ps;

---------------initialization of factory reg------------

wait for 1 ps;
--hexa_to_bit_vector(SIM_FACTORY_ID, 512, value_fact);
--hexa_to_bit_vector(SIM_USER_ID, 512, value_user);
for j in 0 to 63 loop
--    factory_reg(j)  <= To_stdlogicvector(getbyte(to_bitvector(SIM_FACTORY_ID),j+1));
--    security_reg(j) <= To_stdlogicvector(getbyte(to_bitvector(SIM_USER_ID),j+1));
    factory_reg(j)  <= To_stdlogicvector(getbyte(SIM_FACTORY_ID,j+1));
    security_reg(j) <= To_stdlogicvector(getbyte(SIM_USER_ID,j+1));
    wait for 1 ps;
         security_flag <='0';
     if(security_reg(j) /= X"FF")then
        security_flag <= '1';
      end if;
end loop;     

wait for 1 ps;


--**************************
--wait for delay_cal(TVCSL,scaled_flag);
foreground_op_enable <= '1' ; ---- Enable foreground op_codes
end if;
--**************************
    
    wait on t(31);
if(MMCAR='1' and t(31) = '1')then
    if (random=TRUE) then
      test_33mhz <= TRUE;
      wait for 1 ps;
    end if;
    compute_address(comp_page_addr(p_address(SIM_DEVICE),binary_page,page_addr0,page_addr1,manid(SIM_DEVICE)),pagesize(SIM_DEVICE,binary_page),
        comp_byte_addr(b_address(SIM_DEVICE,binary_opt),page_addr1,byte_addr,binary_page),
        page_boundary_low,page_boundary_high,current_address,mem_no,binary_page);
    if (arr_rd_dummybyte = 1) then
        for j in 1 to 8 loop
            wait until CLK_dly'event and CLK_dly ='1';
        end loop; 
    end if;
    read_out_array(CLK_dly,CSB_dly,pagesize(SIM_DEVICE,binary_page),memsize(pagesize(SIM_DEVICE,binary_page),page_cal(SIM_DEVICE)),page_boundary_low,
               page_boundary_high,current_address,memory,so_reg,binary_page,so_on);
    test_33mhz <= FALSE ;  -- leave the test on long enough to capture an error
    wait for 1 ps;
elsif(MMPTBT='1'and t(31) = '1')then
    test_33mhz <= TRUE;  -- test for 33 Mhz
    compute_address(comp_page_addr(p_address(SIM_DEVICE),binary_page,page_addr0,page_addr1,manid(SIM_DEVICE)),pagesize(SIM_DEVICE,binary_page),
                           comp_byte_addr(b_address(SIM_DEVICE,binary_opt),page_addr1,byte_addr,binary_page),page_boundary_low,
                           page_boundary_high, current_address,mem_no,binary_page);
    if (CSB_dly ='0')then
       wait until CSB_dly'event and CSB_dly ='1';
    end if; 
    RDYBSY_reg <= '0';  --SIM_DEVICE is busy
    status(7)  <= '0';
    transfer_to_buffer(buff_num, page_boundary_low,memory,tbuffer1,binary_page,tbuffer2);
    wait for 1 ps;
    RDYBSY_reg <= '1' after delay_cal(TXFR,scaled_flag);  
    status(7)  <= '1' after delay_cal(TXFR,scaled_flag);
    test_33mhz <= FALSE  after delay_cal(TXFR,scaled_flag) ;
    wait for 1 ps;
elsif(MMPTBC='1' and t(31) = '1')then
    compute_address(comp_page_addr(p_address(SIM_DEVICE),binary_page,page_addr0,page_addr1,manid(SIM_DEVICE)),pagesize(SIM_DEVICE,binary_page),
    comp_byte_addr(b_address(SIM_DEVICE,binary_opt),page_addr1,byte_addr,binary_page),
        page_boundary_low,page_boundary_high, current_address,mem_no,binary_page);
    if (CSB_dly ='0')then
       wait until CSB_dly'event and CSB_dly = '1';
    end if; 
    RDYBSY_reg <= '0';  --device is busy
    status(7)  <= '0';
    wait for 1 ps; --assignments won't take hold without a delay
    compare_with_buffer(buff_num,page_boundary_low,memory,tbuffer1,tbuffer2,binary_page,status_B1C_s6);
    wait for 1 ps;
    RDYBSY_reg <= '1'after delay_cal(TCOMP,scaled_flag);   -- device is now ready
    status(7) <= '1' after delay_cal(TCOMP,scaled_flag);
    status(6)  <= status_B1C_s6 after delay_cal(TCOMP,scaled_flag);
    wait for 1 ps;
elsif(B1W='1' and t(31) = '1')then
    byte <= comp_byte_addr(b_address(SIM_DEVICE,binary_opt),page_addr1,byte_addr,binary_page);
    compute_address(comp_page_addr(p_address(SIM_DEVICE),binary_page,page_addr0,page_addr1,manid(SIM_DEVICE)),pagesize(SIM_DEVICE,binary_page),
              comp_byte_addr(b_address(SIM_DEVICE,binary_opt),page_addr1,byte_addr,binary_page),
              page_boundary_low,page_boundary_high, current_address,mem_no,binary_page);
    write_data(current_address,page_boundary_low,page_boundary_high,tbuffer1,tbuffer2,"01",CSB_dly,CLK_dly,MOSI_dly);
elsif(B2W='1' and t(31) = '1')then
    byte <= comp_byte_addr(b_address(SIM_DEVICE,binary_opt),page_addr1,byte_addr,binary_page);
    compute_address(comp_page_addr(p_address(SIM_DEVICE),binary_page,page_addr0,page_addr1,manid(SIM_DEVICE)),pagesize(SIM_DEVICE,binary_page),
              comp_byte_addr(b_address(SIM_DEVICE,binary_opt),page_addr1,byte_addr,binary_page),
              page_boundary_low,page_boundary_high, current_address,mem_no,binary_page);
    write_data(current_address,page_boundary_low,page_boundary_high,tbuffer1,tbuffer2,"10",CSB_dly,CLK_dly,MOSI_dly);
elsif(BTMMPP='1'and t(31) = '1')then
    compute_address(comp_page_addr(p_address(SIM_DEVICE),binary_page,page_addr0,page_addr1,manid(SIM_DEVICE)),pagesize(SIM_DEVICE,binary_page),
            comp_byte_addr(b_address(SIM_DEVICE,binary_opt),page_addr1,byte_addr,binary_page),
            page_boundary_low,page_boundary_high, current_address,mem_no,binary_page);
    if (CSB_dly ='0')then
       wait until CSB_dly'event and CSB_dly ='1';
    end if; 
    RDYBSY_reg <= '0'; -- device is busy
    status(7) <= '0';
    if (erase_flag = '1') then
        erase_page(comp_page_addr(p_address(SIM_DEVICE),binary_page,page_addr0,page_addr1,manid(SIM_DEVICE)),
            pagesize(SIM_DEVICE,binary_page),page_boundary_low,memory,binary_page,temp_page_status);
        page_status(conv_integer(comp_page_addr(p_address(SIM_DEVICE),binary_page,page_addr0,page_addr1,manid(SIM_DEVICE)))) := temp_page_status;
    end if;
    write_to_memory(buff_nump,comp_page_addr(p_address(SIM_DEVICE),binary_page,page_addr0,page_addr1,manid(SIM_DEVICE)),
         pagesize(SIM_DEVICE,binary_page),tbuffer1,tbuffer2,page_boundary_low,memory);
    if (erase_flag = '0') then
--        if (page_status(conv_integer(comp_page_addr(p_address(SIM_DEVICE),binary_page,page_addr0,
--                                           page_addr1,manid(SIM_DEVICE)))) = '1') then  --page is not erased
--            Write ( Message, string'("DRC Error : In "));
--            Write ( Message, InstancePath); 
--            Write ( Message, string'(" trying to write into a Page which is not erased"));
--            assert false report Message.all severity failure;
--            DEALLOCATE (Message);       
--        end if;
        wait for 1 ps;
        RDYBSY_reg <= '1' after delay_cal(TP,scaled_flag);   -- device is now ready
        status(7) <= '1'  after delay_cal(TP,scaled_flag);
        wait for 1 ps;
    else
        page_status(conv_integer(comp_page_addr(p_address(SIM_DEVICE),binary_page,page_addr0,page_addr1,manid(SIM_DEVICE)))) := '1';
        wait for 1 ps;
        RDYBSY_reg <= '1' after delay_cal(TPEP,scaled_flag) ;   -- device is now ready
        status(7) <= '1'  after delay_cal(TPEP,scaled_flag) ;
        wait for 1 ps;   
    end if;
elsif(MMPPB='1' and t(31)='1' and RDYBSY_reg='1')then
    MMPPB_mem_page := comp_page_addr(p_address(SIM_DEVICE),binary_page,page_addr0,page_addr1,manid(SIM_DEVICE));
    -- page value has been stored for main memory page program
    MMPPB_buf_page := (others=>'0');--buffer has zero pages
    compute_address(MMPPB_buf_page,pagesize(SIM_DEVICE,binary_page),comp_byte_addr(b_address(SIM_DEVICE,binary_opt),
                   page_addr1,byte_addr,binary_page),page_boundary_low,page_boundary_high,current_address,mem_no,binary_page);
    write_data(current_address,page_boundary_low,page_boundary_high,tbuffer1,tbuffer2,buff_num,CSB_dly,CLK_dly,MOSI_dly);
          -- this will write to buffer  -- it will proceed to next step, when, posedge of CSB.
          -- This is complicated, and, hence, explained here: At posedge of CSB, the write_data will get disabled.
          -- At this time, writing to buffer needs to stop, and, writing into memory should start.

    compute_address(MMPPB_mem_page,pagesize(SIM_DEVICE,binary_page),comp_byte_addr(b_address(SIM_DEVICE,binary_opt),page_addr1,byte_addr,
                    binary_page),page_boundary_low,page_boundary_high,current_address,mem_no,binary_page);
    RDYBSY_reg <= '0'; -- device is busy
    status(7) <='0';
    write_to_memory(buff_num,comp_page_addr(p_address(SIM_DEVICE),binary_page,page_addr0,page_addr1,manid(SIM_DEVICE)),
                    pagesize(SIM_DEVICE,binary_page),tbuffer1,tbuffer2,page_boundary_low,memory);
    page_status(conv_integer(comp_page_addr(p_address(SIM_DEVICE),binary_page,page_addr0,page_addr1,manid(SIM_DEVICE)))) := '1';
    wait for 1 ps;
    RDYBSY_reg <= '1' after delay_cal(TPEP,scaled_flag) ;    -- device is now ready
    status(7) <= '1'  after delay_cal(TPEP,scaled_flag);
    wait for 1 ps;
----------------page erase------------------

elsif (PE = '1')then
        compute_address(comp_page_addr(p_address(SIM_DEVICE),binary_page,page_addr0,page_addr1,manid(SIM_DEVICE)),pagesize(SIM_DEVICE,binary_page),
        comp_byte_addr(b_address(SIM_DEVICE,binary_opt),page_addr1,byte_addr,binary_page),page_boundary_low,page_boundary_high,
        current_address,mem_no,binary_page);
        if (CSB_dly ='0')then
           wait until CSB_dly'event and CSB_dly='1';
        end if; 
        RDYBSY_reg <= '0';  --device is busy
        status(7) <= '0';
        erase_page(comp_page_addr(p_address(SIM_DEVICE),binary_page,page_addr0,page_addr1,manid(SIM_DEVICE)),
            pagesize(SIM_DEVICE,binary_page),page_boundary_low,memory,binary_page,temp_page_status);
        page_status(conv_integer(comp_page_addr(p_address(SIM_DEVICE),binary_page,page_addr0,page_addr1,manid(SIM_DEVICE)))) := temp_page_status;
        wait for 1 ps;
        RDYBSY_reg <= '1'  after delay_cal(TPE,scaled_flag)  ; --device is now ready
        status(7) <= '1'   after delay_cal(TPE,scaled_flag)   ;
        wait for 1 ps;
----------------sector erase------------------
    
elsif (SE = '1')then
    compute_address(comp_page_addr(p_address(SIM_DEVICE),binary_page,page_addr0,page_addr1,manid(SIM_DEVICE)),pagesize(SIM_DEVICE,binary_page),
                          comp_byte_addr(b_address(SIM_DEVICE,binary_page),page_addr1,byte_addr,binary_page),page_boundary_low,
                          page_boundary_high,current_address,mem_no,binary_page);
    if (CSB_dly ='0')then
       wait until CSB_dly'event and CSB_dly = '1';  
    end if; 
    RDYBSY_reg <= '0';  --device is busy
    status(7) <= '0';
               --******************************--
    if (conv_integer(comp_page_addr(p_address(SIM_DEVICE),binary_page,page_addr0,page_addr1,manid(SIM_DEVICE))) < 8 ) then
        page_boundary_low := 0;
        jerase := page_boundary_low;
        loop_sectorerase: loop 
            if (jerase < page_boundary_low+8*pagesize(SIM_DEVICE,binary_page) ) then
                erase_page(comp_page_addr(p_address(SIM_DEVICE),binary_page,page_addr0,page_addr1,manid(SIM_DEVICE)),
                               pagesize(SIM_DEVICE,binary_page),jerase,memory,binary_page,temp_page_status);   -- erase 8 pages, i.e. a block
                page_status(conv_integer(comp_page_addr(p_address(SIM_DEVICE),binary_page,page_addr0,page_addr1,manid(SIM_DEVICE)))) := temp_page_status;
                jerase := jerase+pagesize(SIM_DEVICE,binary_page);
            else
                exit loop_sectorerase;  -------------sector Eraseexit ----------------------
            end if; 
        end loop;
        for j in 0 to 7 loop  -- erase_page will only change the status of one-page 
            page_status(j) := '0'; 
        end loop;
         --************************************----
    elsif (comp_page_addr(p_address(SIM_DEVICE),binary_page,page_addr0,page_addr1,manid(SIM_DEVICE)) < pageper_sector(SIM_DEVICE)) then
        page_boundary_low := 8*pagesize(SIM_DEVICE,binary_page);
        jerase := page_boundary_low;
        loop_sector1erase : loop
            if (jerase < page_boundary_low+((pageper_sector(SIM_DEVICE)-8)*pagesize(SIM_DEVICE,binary_page)) ) then
                erase_page(comp_page_addr(p_address(SIM_DEVICE),binary_page,page_addr0,page_addr1,manid(SIM_DEVICE)),
                pagesize(SIM_DEVICE,binary_page),jerase,memory,binary_page,temp_page_status);   --erase 248/120 pages, i.e. a block
            page_status(conv_integer(comp_page_addr(p_address(SIM_DEVICE),binary_page,
            page_addr0,page_addr1,manid(SIM_DEVICE)))) := temp_page_status;
            jerase := jerase+pagesize(SIM_DEVICE,binary_page);
            else
                exit loop_sector1erase;  -----------sector1 Eraseexit ------------------------
            end if; 
        end loop;   
        for j in 8 to pageper_sector(SIM_DEVICE)-1 loop    --erase_page will only change the status of one-page 
            page_status(j) := '0'; 
        end loop;
        --**************************** 
    else
        page((p_address(SIM_DEVICE)- s_address(SIM_DEVICE))-1) <= '0';
        jerase := page_boundary_low;
        loop_sector2erase : loop
            if (jerase < page_boundary_low+(pageper_sector(SIM_DEVICE)*pagesize(SIM_DEVICE,binary_page))) then
                erase_page(comp_page_addr(p_address(SIM_DEVICE),binary_page,page_addr0,page_addr1,manid(SIM_DEVICE)),
                                  pagesize(SIM_DEVICE,binary_page),jerase,memory,binary_page,temp_page_status);   --erase 256/128 pages, i.e. a block
                page_status(conv_integer(comp_page_addr(p_address(SIM_DEVICE),binary_page,page_addr0,page_addr1,manid(SIM_DEVICE)))) := temp_page_status;
                jerase := jerase +pagesize(SIM_DEVICE,binary_page);
            else
                exit loop_sector2erase;   ----------sector2 Eraseexit ------------------------
            end if;
        end loop;
        for j in 0 to pageper_sector(SIM_DEVICE)-1 loop 
                page_status(conv_integer(comp_page_addr(p_address(SIM_DEVICE),binary_page,page_addr0,page_addr1,manid(SIM_DEVICE)))+j) := '0'; 
        end loop;
    end if;
    wait for 1 ps;
    RDYBSY_reg <= '1' after delay_cal(TSE,scaled_flag)  ; --device is now ready
    status(7) <= '1' after delay_cal(TSE,scaled_flag)  ;
elsif(SRR='1' and t(31)='1')then
      read_out_reg(23,0,127,security_reg,CSB_dly,CLK_dly,so_reg,so_on);
elsif(SRP ='1' and t(31)='1' and page_addr0=X"00" and page_addr1= X"00" and byte_addr = X"00" )then
        current_address :=0;
        page_boundary_low :=0;
        page_boundary_high := 63;
        write_data(current_address,page_boundary_low,page_boundary_high,tbuffer1,tbuffer2,"01",CSB_dly,CLK_dly,MOSI_dly);    
                    -- this will write to buffer
                      -- it will proceed to next step, when, posedge of CSB.
                       -- This is complicated, and, hence, explained here:
                       -- At posedge of CSB, the write_data will get disabled.
                       -- At this time, writing to buffer needs to stop, and,
                       -- writing into memory should start.
        --writing in to security_reg
        if (security_flag = '0') then  --Security Register has not been programmed before
            for j in 0 to 63 loop
                security_reg(j) <= tbuffer1(j);
            end loop;  
            security_flag <= '1';
            RDYBSY_reg <= '0'; --device is busy
            status(7) <= '0';
            wait for 1 ps;
            RDYBSY_reg <= '1' after delay_cal(TP,scaled_flag) ; --device is now ready
            status(7) <= '1'  after delay_cal(TP,scaled_flag) ;
            wait for 1 ps;
        else
            Write ( Message, string'("DRC Error : In "));
            Write ( Message, InstancePath); 
            Write ( Message, string'(" Security register can only be programmed once")); 
            assert false report Message.all severity failure;
            DEALLOCATE (Message);
        end if;
end if;
end process;

--------------------status register read--------
process    
    variable j_tmp : integer := 8;
begin
    wait on SR ;
    if( SR = '1' ) then
        status_read <='1';--reading status reg
    --    for i in 0 to 7 loop
    --    wait until CLK_dly'event and CLK_dly='0';
    --    so_reg1 <= '1'; -- the reg is set to one when data is invalid
    --    so_on1  <= '1';
    --    end loop;
        status_loop : loop
            wait until ((CLK_dly'event and CLK_dly ='0') or  (CSB_dly'event and CSB_dly='1'));
            if(CSB_dly='1') then 
                j_tmp:=0;
                exit status_loop;
            end if;
            if(j_tmp > 0)then
                j_tmp := j_tmp - 1; 
            else
                j_tmp := 7;
            end if;
                so_reg1 <= status(j_tmp);
                so_on1  <= '1';
           end loop;
           so_on1  <= '0';
           status_read <='0';
    end if;
end process;

------------manufacturing ID-----------
process   --(MIR)--,MANID(SIM_DEVICE))
    variable j : integer:= 32 ;
    variable m_id : std_logic_vector(31 downto 0):= manid(SIM_DEVICE); 
begin
wait on MIR;
    if(MIR='1')then
        MIR_loop : loop
            wait until ((CLK_dly'event and CLK_dly ='0') or  (CSB_dly'event and CSB_dly='1'));
            exit MIR_loop when CSB_dly = '1';
            if(J > 0)then
                SO_reg2 <= m_id(j-1);
                so_on2 <= '1';
                J := J - 1;
            elsif( j = 0) then
                So_on2 <= '1';
                So_reg2 <= 'X'; -- only if the cs extends more than available man ID
            end if;
        end loop;
    so_on2 <= '0';
    So_reg2 <= '0';   
    end if;
end process;

        ------------------------ CLK check
checkPeriod ( CLK_dly  , "CLK" , Tsck    , "Tsck" , TsckRp  , clk_err   , InstancePath, valid ) ;
checkPeriod ( CLK_dly  , "CLK" , Tsck33  , "Tsck" , TsckRp33, clk_err33 , InstancePath, test_33mhz ) ;
checkclk    ( CLK_dly  , "CLK" , Tspickh , "Tsck" ,TsckRpx  , TsckFp , clk_erra , InstancePath, valid, valid, valid ) ;
checkclk    ( CSB_dly  , "CSB" , Tcs     , "Tsck" ,TsckRpcsb , TsckFcsb , csb_err , InstancePath, valid, valid, no_test) ;
validate_input(SIM_DEVICE, SIM_DELAY_TYPE , scaled_flag);  -- validates inputs and set scaled_flag

process(so_on1,so_reg1,so_on2,so_reg2,so_reg, so_on)
begin
    if(so_on1='1')then
        MISO_zd <= so_reg1 after SYNC_PATH_DELAY;
    elsif(so_on2='1')then
        MISO_zd <= so_reg2 after SYNC_PATH_DELAY;
    elsif (so_on='1') then
        MISO_zd <= so_reg after SYNC_PATH_DELAY;
    else  
        MISO_zd <= '1' after Tdis;
    end if;
end process;   

--####################################################################
--#####                   TIMING CHECKS & OUTPUT                 #####
--####################################################################

--####################################################################
--#####                           OUTPUT                         #####
--####################################################################
  prcs_output:process(MISO_zd)
  begin
      MISO     <= MISO_zd ;
  end process prcs_output;


end SPI_ACCESS_V;
