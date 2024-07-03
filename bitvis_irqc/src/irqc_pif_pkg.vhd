--================================================================================================================================
-- Copyright 2024 UVVM
-- Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 and in the provided LICENSE.TXT.
--
-- Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
-- an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and limitations under the License.
--================================================================================================================================
-- Note : Any functionality not explicitly described in the documentation is subject to change at any time
----------------------------------------------------------------------------------------------------------------------------------

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
  constant C_NUM_SOURCES : integer := 6; --  1 <= C_NUM_SOURCES <= Data width

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
    rw_ier              : std_logic_vector(C_NUM_SOURCES - 1 downto 0);
    awt_itr             : std_logic_vector(C_NUM_SOURCES - 1 downto 0);
    awt_icr             : std_logic_vector(C_NUM_SOURCES - 1 downto 0);
    awt_irq2cpu_ena     : std_logic;
    awt_irq2cpu_disable : std_logic;
  end record t_p2c;

  -- Signals from core to PIF
  type t_c2p is record
    aro_irr             : std_logic_vector(C_NUM_SOURCES - 1 downto 0);
    aro_ipr             : std_logic_vector(C_NUM_SOURCES - 1 downto 0);
    aro_irq2cpu_allowed : std_logic;
  end record t_c2p;

end package irqc_pif_pkg;

