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
    constant dummy  : in t_void
    ) return boolean;

  impure function show_uvvm_utility_library_info(
    constant dummy  : in t_void
    ) return boolean;

  impure function show_uvvm_utility_library_release_info(
    constant dummy  : in t_void
    ) return boolean;

end package license_pkg;

package body license_pkg is

  impure function show_license(
    constant dummy  : in t_void
    ) return boolean is
    constant C_SEPARATOR          : string  :=
      "*****************************************************************************************************";

    constant C_LICENSE_STR        : string :=
      LF & LF & LF &
      C_SEPARATOR                                                                                             & LF &
      " This is a *** LICENSED PRODUCT *** as given in the LICENSE.TXT in the root directory."                & LF &
      C_SEPARATOR                                                                                             & LF & LF;

  begin
    report (C_LICENSE_STR);
    return true;
  end;

  impure function show_uvvm_utility_library_info(
    constant dummy  : in t_void
    ) return boolean is
    constant C_SEPARATOR          : string  :=
      "=====================================================================================================";

    constant C_LICENSE_STR        : string :=
      LF & LF &
      C_SEPARATOR                                                                                             & LF &
      C_SEPARATOR & LF &
      "This info section may be turned off via C_SHOW_UVVM_UTILITY_LIBRARY_INFO in adaptations_pkg.vhd"  & LF & LF &
      "Important Simulator setup: " & LF &
      "- Set simulator to break on severity 'FAILURE' " & LF &
      "- Set simulator transcript to a monospace font (e.g. Courier new)" & LF & LF &
      "UVVM Utility Library setup:" & LF &
      "- It is recommended to go through the two powerpoint presentations provided with the download" & LF &
      "- There is a Quick-Reference in the doc-directory" & LF &
      "- In order to change layout or behaviour - please check the src*/adaptations_pkg.vhd" & LF &
      "  This is intended for personal or company customization" & LF & LF &
      "License conditions are given in LICENSE.TXT" & LF &
      C_SEPARATOR                                                                                             & LF &
      C_SEPARATOR                                                                                             & LF & LF;

  begin
    if C_SHOW_UVVM_UTILITY_LIBRARY_INFO then
      report (C_LICENSE_STR);
    end if;
    return true;
  end;


  impure function show_uvvm_utility_library_release_info(
    constant dummy  : in t_void
    ) return boolean is
    constant C_IMPORTANT_UPDATE_FOR_THIS_VERSION : boolean := false;   -- ***** NOTE: Evaluate a change here
    constant C_SEPARATOR          : string  :=
      "=====================================================================================================";

    constant C_LICENSE_STR        : string :=
      LF & LF &
      C_SEPARATOR                                                                                             & LF &
      C_SEPARATOR & LF &
      "This release info may be turned off via C_SHOW_UVVM_UTILITY_LIBRARY_INFO in adaptations_pkg.vhd"  & LF & LF &
      "Important Issues for this version update: " & LF &
      "- First release" & LF & LF & LF &
      C_SEPARATOR                                                                                             & LF &
      C_SEPARATOR                                                                                             & LF & LF;

  begin
    if  C_SHOW_UVVM_UTILITY_LIBRARY_INFO and C_IMPORTANT_UPDATE_FOR_THIS_VERSION then
      report (C_LICENSE_STR);
    end if;
    return true;
  end;


end package body license_pkg;

