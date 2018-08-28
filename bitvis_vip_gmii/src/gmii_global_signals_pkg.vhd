------------------------------------------------------------------------------------------
--  Copyright (c) 2017 by Bitvis AS.  All rights reserved.
--  Verbatim copies of this source file may be used and distributed internally by licensed
--  customers. Licensed customers may also make modifications to any part of this file apart
--  from this Copyright notice at the first 6 lines.
------------------------------------------------------------------------------------------

-- VHDL unit     : *****
--
-- Author        : Dag Sverre Skjelbreid (dss), Bitvis AS
--
-- Revision      : 0.0.1 Draft
--                 GIT revision ???
--
-- VHDL info     : Using VHDL 2002
--
-- Description   : A package specific for the current test harness
--
--
------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library bitvis_bfmcs;
use bitvis_bfmcs.common_pkg.all;       -- t_vip_trigger,

package gmii_global_signals_pkg  is

  constant C_CLK_PERIOD         : time := 8 ns;

  -- Signals used for TLM - Executor/BFM communication
  -- Used to trigger executor and TLM. Must be a resolved type
  -- The signal is used in the sequencer and test harness

  -- Make one bit per instance of GMII:
  constant C_GMII_INSTANCES   : natural := 2;
--  signal global_gmii_trigger  : std_logic_vector(1 to C_GMII_INSTANCES) := (others => 'Z');
  signal vip_gmii : t_vip_trigger := C_TRIGGER_RECORD_DEFAULT;

end package gmii_global_signals_pkg ;


package body gmii_global_signals_pkg is

  ------------------------------------------------------------------------
  ------------------------------------------------------------------------

end package body gmii_global_signals_pkg;
--=================================================================================================
--=================================================================================================
--=================================================================================================


