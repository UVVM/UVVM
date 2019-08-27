--========================================================================================================================
-- Copyright (c) 2018 by Bitvis AS.  All rights reserved.
-- You should have received a copy of the license file containing the MIT License (see LICENSE.TXT), if not,
-- contact Bitvis AS <support@bitvis.no>.
--
-- UVVM AND ANY PART THEREOF ARE PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
-- WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
-- OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH UVVM OR THE USE OR OTHER DEALINGS IN UVVM.
--========================================================================================================================

------------------------------------------------------------------------------------------
-- Description   : See library quick reference (under 'doc') and README-file(s)
------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

library bitvis_vip_gmii;
context bitvis_vip_gmii.vvc_context;

package ethernet_to_sub_vvc is

--  procedure send_to_sub_vvc(
--    constant instance_idx : in integer;
--    constant data         : in t_byte_array
--  );
--
--  procedure receive_from_sub_vvc(
--    constant instance_idx : in integer;
--    variable data         : out t_byte_array;
--    constant msg          : in string := ""
--  );


end package ethernet_to_sub_vvc;

package body ethernet_to_sub_vvc is

--  procedure send_to_sub_vvc(
--    constant instance_idx : in integer;
--    constant data         : in t_byte_array
--  ) is
--  begin
--    gmii_write(GMII_VVCT, instance_idx, TRANSMITTER, data, "Send ethernet packet to GMII");
--  end procedure send_to_sub_vvc;
--
--  procedure receive_from_sub_vvc(
--    constant instance_idx : in integer;
--    variable data         : out t_byte_array;
--    constant msg          : in string := ""
--  ) is
--    variable v_cmd_idx        : natural;
--    variable v_data_from_gmii : t_byte_array(0 to C_VVC_CMD_DATA_MAX_BYTES-1);
--  begin
--    gmii_read(GMII_VVCT, instance_idx, RECEIVER, data'length, msg);
--    v_cmd_idx := shared_cmd_idx;
--    await_completion(GMII_VVCT, instance_idx, RECEIVER, 1 us, "Ethernet: wait for read to finish.");
--    fetch_result(GMII_VVCT, instance_idx, RECEIVER, v_cmd_idx, v_data_from_gmii, "Ethernet: fetching received data.");
--    data := v_data_from_gmii(0 to data'length-1);
--  end procedure receive_from_sub_vvc;

end package body ethernet_to_sub_vvc;