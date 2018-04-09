--
--  File Name:         VendorCovApiPkg_Aldec.vhd
--  Design Unit Name:  VendorCovApiPkg
--  Revision:          ALDEC VERSION
--
--  Maintainer:
--
--  Package Defines
--     A set of foreign procedures that link OSVVM's CoveragePkg
--     coverage model creation and coverage capture with the
--     built-in capability of a simulator.
--
--
--  Revision History:      For more details, see CoveragePkg_release_notes.pdf
--    Date      Version    Description
--    11/2016:  2016.11    Initial revision
--    12/2016   2016.11a   Fixed an issue with attributes
--
--
--  Copyright (c) 2016 by Aldec.  All rights reserved.
--
--  Verbatim copies of this source file may be used and
--  distributed without restriction.
--
--  Modified copies of this source file may be distributed
--  under the terms of the ARTISTIC License as published by
--  The Perl Foundation; either version 2.0 of the License,
--  or (at your option) any later version.
--
--  This source is distributed in the hope that it will be
--  useful, but WITHOUT ANY WARRANTY; without even the implied
--  warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
--  PURPOSE. See the Artistic License for details.
--
--  You should have received a copy of the license with this source.
--  If not download it from,
--     http://www.perlfoundation.org/artistic_license_2_0
--                                                                      --
--------------------------------------------------------------------------

package VendorCovApiPkg is

  subtype VendorCovHandleType is integer;

  -- Types for how coverage bins are represented.  Matches OSVVM types.
  type VendorCovRangeType is record
      min: integer;
      max: integer;
  end record;

  type VendorCovRangeArrayType is array ( integer range <> ) of VendorCovRangeType;

  --  Create Initial Data Structure for Point/Item Functional Coverage Model
  --  Sets initial name of the coverage model if available
  impure function VendorCovPointCreate( name: string ) return VendorCovHandleType;
  attribute foreign of VendorCovPointCreate[ string return VendorCovHandleType ]: function is "VHPI systf; cvg_CvpCreate";

  --  Create Initial Data Structure for Cross Functional Coverage Model
  --  Sets initial name of the coverage model if available
  impure function VendorCovCrossCreate( name: string ) return VendorCovHandleType;
  attribute foreign of VendorCovCrossCreate[ string return VendorCovHandleType ]: function is "VHPI systf; cvg_CrCreate";

  --  Sets/Updates the name of the Coverage Model.
  --  Should not be called until the data structure is created by VendorCovPointCreate or VendorCovCrossCreate.
  --  Replaces name that was set by VendorCovPointCreate or VendorCovCrossCreate.
  procedure VendorCovSetName( obj: VendorCovHandleType; name: string );
  attribute foreign of VendorCovSetName[ VendorCovHandleType, string ]: procedure is "VHPI systf; cvg_SetCoverName";

  --  Add a bin or set of bins to either a Point/Item or Cross Functional Coverage Model
  --  Checking for sizing that is different from original sizing already done in OSVVM CoveragePkg
  --  It is important to maintain an index that corresponds to the order the bins were entered as
  --  that is used when coverage is recorded.
  procedure VendorCovBinAdd( obj: VendorCovHandleType; bins: VendorCovRangeArrayType; Action: integer; atleast: integer; name: string );
  attribute foreign of VendorCovBinAdd[ VendorCovHandleType, VendorCovRangeArrayType, integer, integer, string ]: procedure is "VHPI systf; cvg_CvpCrBinCreate";

  --  Increment the coverage of bin identified by index number.
  --  Index ranges from 1 to Number of Bins.
  --  Index corresponds to the order the bins were entered (starting from 1)
  procedure VendorCovBinInc( obj: VendorCovHandleType; index: integer );
  attribute foreign of VendorCovBinInc[ VendorCovHandleType, integer ]: procedure is "VHPI systf; cvg_CvpCrBinIncr";

  -- Action (integer):
  -- constant COV_COUNT   : integer := 1;
  -- constant COV_IGNORE  : integer := 0;
  -- constant COV_ILLEGAL : integer := -1;

end package;

package body VendorCovApiPkg is
   -- Replace any existing package body for this package 
    
end package body VendorCovApiPkg ;
