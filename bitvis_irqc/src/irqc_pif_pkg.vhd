--========================================================================================================================
-- Copyright (c) 2017 by Bitvis AS.  All rights reserved.
-- You should have received a copy of the license file containing the MIT License (see LICENSE.TXT), if not, 
-- contact Bitvis AS <support@bitvis.no>.
--
-- UVVM AND ANY PART THEREOF ARE PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
-- WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
-- OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH UVVM OR THE USE OR OTHER DEALINGS IN UVVM.
--========================================================================================================================

------------------------------------------------------------------------------------------
-- VHDL unit     : Bitvis IRQC Library : irqc_pif_pkg
--
-- Description   : See dedicated powerpoint presentation and README-file(s)
------------------------------------------------------------------------------------------


Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package irqc_pif_pkg is

  -- Change this to a generic when generic in packages is allowed (VHDL 2008)
  constant C_NUM_SOURCES : integer := 6;  --  1 <= C_NUM_SOURCES <= Data width

  -- Notation for regs: (Included in constant name as info to SW)
  -- - RW: Readable and writable reg.
  -- - RO: Read only reg. (output from IP)
  -- - WO: Write only reg. (typically single cycle strobe to IP)

  -- Notation for signals (or fields in record) going between PIF and core:
  -- Same notations as for register-constants above, but
  -- a preceeding 'a' (e.g. awo) means the register is auxiliary to the PIF.
  -- This means no flop in the PIF, but in the core. (Or just a dummy-register with no flop)

  constant C_ADDR_IRR             : integer := 0;
  constant C_ADDR_IER             : integer := 1;
  constant C_ADDR_ITR             : integer := 2;
  constant C_ADDR_ICR             : integer := 3;
  constant C_ADDR_IPR             : integer := 4;
  constant C_ADDR_IRQ2CPU_ENA     : integer := 5;
  constant C_ADDR_IRQ2CPU_DISABLE : integer := 6;
  constant C_ADDR_IRQ2CPU_ALLOWED : integer := 7;

  -- Signals from pif to core
  type t_p2c is record
    rw_ier               : std_logic_vector(C_NUM_SOURCES-1 downto 0);
    awt_itr              : std_logic_vector(C_NUM_SOURCES-1 downto 0);
    awt_icr              : std_logic_vector(C_NUM_SOURCES-1 downto 0);
    awt_irq2cpu_ena      : std_logic;
    awt_irq2cpu_disable  : std_logic;
  end record t_p2c;

  -- Signals from core to PIF
  type t_c2p is record
    aro_irr              : std_logic_vector(C_NUM_SOURCES-1 downto 0);
    aro_ipr              : std_logic_vector(C_NUM_SOURCES-1 downto 0);
    aro_irq2cpu_allowed  : std_logic;
  end record t_c2p;

end package irqc_pif_pkg;

