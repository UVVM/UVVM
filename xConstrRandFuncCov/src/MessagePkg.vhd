--
--  File Name:         MessagePkg.vhd
--  Design Unit Name:  MessagePkg
--  Revision:          STANDARD VERSION,  revision 2015.01
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis          SynthWorks
--
--
--  Package Defines
--      Data structure for multi-line name/message to be associated with a data structure.
--
--  Developed for:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        11898 SW 128th Ave.  Tigard, Or  97223
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    06/2010   0.1        Initial revision
--    07/2014   2014.07    Moved specialization required by CoveragePkg to CoveragePkg
--    07/2014   2014.07a   Removed initialized pointers which can lead to memory leaks.
--    01/2015   2015.01    Removed initialized parameter from Get
--    04/2018   2018.04    Minor updates to alert message
--    01/2020   2020.01    Updated Licenses to Apache
--
--
--  This file is part of OSVVM.
--  
--  Copyright (c) 2010 - 2020 by SynthWorks Design Inc.  
--  
--  Licensed under the Apache License, Version 2.0 (the "License");
--  you may not use this file except in compliance with the License.
--  You may obtain a copy of the License at
--  
--      https://www.apache.org/licenses/LICENSE-2.0
--  
--  Unless required by applicable law or agreed to in writing, software
--  distributed under the License is distributed on an "AS IS" BASIS,
--  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--  See the License for the specific language governing permissions and
--  limitations under the License.
--  
use work.OsvvmGlobalPkg.all ;
use work.AlertLogPkg.all ;

library ieee ;
use ieee.std_logic_1164.all ;
use ieee.numeric_std.all ;
use ieee.math_real.all ;
use std.textio.all ;

package MessagePkg is

  type MessagePType is protected

    procedure Set (MessageIn : String) ;
    impure function Get (ItemNumber : integer) return string ;
    impure function GetCount return integer ;
    impure function IsSet return boolean ;
    procedure Clear ; -- clear message
    procedure Deallocate ; -- clear message

  end protected MessagePType ;

end package MessagePkg ;

--- ///////////////////////////////////////////////////////////////////////////
--- ///////////////////////////////////////////////////////////////////////////
--- ///////////////////////////////////////////////////////////////////////////

package body MessagePkg is

  -- Local Data Structure Types
  type LineArrayType is array (natural range <>) of line ;
  type LineArrayPtrType is access LineArrayType ;

  type MessagePType is protected body

    variable MessageCount : integer := 0 ;
    constant INITIAL_ITEM_COUNT : integer := 16 ;
    variable MaxMessageCount : integer := 0 ;
    variable MessagePtr : LineArrayPtrType ;

    ------------------------------------------------------------
    procedure Set (MessageIn : String) is
    ------------------------------------------------------------
      variable NamePtr : line ;
      variable OldMaxMessageCount : integer ;
      variable OldMessagePtr : LineArrayPtrType ;
    begin
      MessageCount := MessageCount + 1 ;
      if MessageCount > MaxMessageCount then
        OldMaxMessageCount := MaxMessageCount ;
        MaxMessageCount := MaxMessageCount + INITIAL_ITEM_COUNT ;
        OldMessagePtr := MessagePtr ;
        MessagePtr := new LineArrayType(1 to MaxMessageCount) ;
        for i in 1 to OldMaxMessageCount loop
          MessagePtr(i) := OldMessagePtr(i) ;
        end loop ;
        Deallocate( OldMessagePtr ) ;
      end if ;
      MessagePtr(MessageCount) := new string'(MessageIn) ;
    end procedure Set ;

    ------------------------------------------------------------
    impure function Get (ItemNumber : integer) return string is
    ------------------------------------------------------------
    begin
      if MessageCount > 0 then
        if ItemNumber >= 1 and ItemNumber <= MessageCount then
          return MessagePtr(ItemNumber).all ;
        else
          Alert(OSVVM_ALERTLOG_ID, "OSVVM.MessagePkg.Get input value out of range", FAILURE) ;
          return "" ; -- error if this happens
        end if ;
      else
        Alert(OSVVM_ALERTLOG_ID, "OSVVM.MessagePkg.Get message is not set", FAILURE) ;
        return "" ; -- error if this happens
      end if ;
    end function Get ;

    ------------------------------------------------------------
    impure function GetCount return integer is
    ------------------------------------------------------------
    begin
      return MessageCount ;
    end function GetCount ;

    ------------------------------------------------------------
    impure function IsSet return boolean is
    ------------------------------------------------------------
    begin
      return MessageCount > 0 ;
    end function IsSet ;

    ------------------------------------------------------------
    procedure Deallocate is  -- clear message
    ------------------------------------------------------------
      variable CurPtr : LineArrayPtrType ;
    begin
      for i in 1 to MessageCount loop
        deallocate( MessagePtr(i) ) ;
      end loop ;
      MessageCount := 0 ;
      MaxMessageCount := 0 ;
      deallocate( MessagePtr ) ;
    end procedure Deallocate ;

    ------------------------------------------------------------
    procedure Clear is  -- clear
    ------------------------------------------------------------
    begin
      Deallocate ;
    end procedure Clear ;

  end protected body MessagePType ;

end package body MessagePkg ;