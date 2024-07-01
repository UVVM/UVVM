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
-- Description   : See library quick reference (under 'doc') and README-file(s)
------------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

use work.types_pkg.all;
use work.string_methods_pkg.all;
use work.adaptations_pkg.all;

package license_pkg is

  impure function show_license(
    constant dummy : in t_void
  ) return boolean;

  impure function show_uvvm_utility_library_info(
    constant dummy : in t_void
  ) return boolean;

  impure function show_uvvm_utility_library_release_info(
    constant dummy : in t_void
  ) return boolean;

end package license_pkg;

package body license_pkg is

  impure function show_license(
    constant dummy : in t_void
  ) return boolean is
    constant C_SEPARATOR : string := "*****************************************************************************************************";

    constant C_LICENSE_STR : string :=
      LF & LF & LF &
      C_SEPARATOR & LF &
      " This is a *** LICENSED PRODUCT *** as given in the LICENSE.TXT in the root directory." & LF &
      C_SEPARATOR & LF & LF;

  begin
    report (C_LICENSE_STR);
    return true;
  end;

  impure function show_uvvm_utility_library_info(
    constant dummy : in t_void
  ) return boolean is
    constant C_SEPARATOR : string := "=====================================================================================================";

    constant C_LICENSE_STR : string :=
      LF & LF &
      C_SEPARATOR & LF &
      C_SEPARATOR & LF &
      "This info section may be turned off via C_SHOW_UVVM_UTILITY_LIBRARY_INFO in adaptations_pkg.vhd" & LF & LF &
      "Important Simulator setup: " & LF &
      "- Set simulator to break on severity 'FAILURE' " & LF &
      "- Set simulator transcript to a monospace font (e.g. Courier new)" & LF & LF &
      "UVVM Utility Library setup:" & LF &
      "- It is recommended to go through the two powerpoint presentations provided with the download" & LF &
      "- There is a Quick-Reference in the doc-directory" & LF &
      "- In order to change layout or behaviour - please check the src*/adaptations_pkg.vhd" & LF &
      "  This is intended for personal or company customization" & LF & LF &
      "License conditions are given in LICENSE.TXT" & LF &
      C_SEPARATOR & LF &
      C_SEPARATOR & LF & LF;

  begin
    if C_SHOW_UVVM_UTILITY_LIBRARY_INFO then
      report (C_LICENSE_STR);
    end if;
    return true;
  end;

  impure function show_uvvm_utility_library_release_info(
    constant dummy : in t_void
  ) return boolean is
    constant C_IMPORTANT_UPDATE_FOR_THIS_VERSION : boolean := false; -- ***** NOTE: Evaluate a change here
    constant C_SEPARATOR                         : string  := "=====================================================================================================";

    constant C_LICENSE_STR : string :=
      LF & LF &
      C_SEPARATOR & LF &
      C_SEPARATOR & LF &
      "This release info may be turned off via C_SHOW_UVVM_UTILITY_LIBRARY_INFO in adaptations_pkg.vhd" & LF & LF &
      "Important Issues for this version update: " & LF &
      "- First release" & LF & LF & LF &
      C_SEPARATOR & LF &
      C_SEPARATOR & LF & LF;

  begin
    if C_SHOW_UVVM_UTILITY_LIBRARY_INFO and C_IMPORTANT_UPDATE_FOR_THIS_VERSION then
      report (C_LICENSE_STR);
    end if;
    return true;
  end;

end package body license_pkg;

