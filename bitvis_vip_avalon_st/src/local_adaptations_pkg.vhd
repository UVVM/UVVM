--================================================================================================================================
-- Copyright (c) 2019 by Bitvis AS.  All rights reserved.
-- You should have received a copy of the license file containing the MIT License (see LICENSE.TXT), if not,
-- contact Bitvis AS <support@bitvis.no>.
--
-- UVVM AND ANY PART THEREOF ARE PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO
-- THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
-- OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH UVVM OR THE USE OR OTHER DEALINGS IN UVVM.
--================================================================================================================================

---------------------------------------------------------------------------------------------
-- Description : See library quick reference (under 'doc') and README-file(s)
---------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

package local_adaptations_pkg is

  -------------------------------------------------------------------------------
  -- Constants for this VIP
  -------------------------------------------------------------------------------
  -- This constant can be smaller than C_MAX_VVC_INSTANCE_NUM but not bigger.
  constant C_AVALON_ST_MAX_VVC_INSTANCE_NUM   : natural := C_MAX_VVC_INSTANCE_NUM;

  constant C_AVALON_ST_CHANNEL_MAX_LENGTH     : natural := 8;
  constant C_AVALON_ST_WORD_MAX_LENGTH        : natural := 512;
  constant C_AVALON_ST_DATA_MAX_WORDS         : natural := 1024;

end package local_adaptations_pkg;

package body local_adaptations_pkg is
end package body local_adaptations_pkg;