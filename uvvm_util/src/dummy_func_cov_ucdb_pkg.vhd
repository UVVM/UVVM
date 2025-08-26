use std.env.all;


package func_cov_ucdb_pkg is
    subtype t_ucdb_cp_handle is integer;
    subtype t_ucdb_bin_index is integer;

    type ucdb_range_type is record
        min: integer;
        max: integer;
    end record;

    constant C_UCDB_ACTION_COUNT   :  integer := 1;
    constant C_UCDB_ACTION_IGNORE  :  integer := 0;
    constant C_UCDB_ACTION_ILLEGAL :  integer := -1;

    type ucdb_range_array_type is array (integer range <>) of ucdb_range_type;
    
  --  Create Initial Data Structure for Point/Item Functional Coverage Model
  --  Sets initial name of the coverage model if available
  --  This procedure is used by fli_create_ucdb_coverpoint function
	procedure fli_create_ucdb_coverpoint( obj: OUT t_ucdb_cp_handle; name: IN string );

     
  --  Sets/Updates the name of the Coverage Model.
  --  Should not be called until the data structure is created by fli_create_ucdb_coverpoint or VendorCovCrossCreate.
  --  Replaces name that was set by fli_create_ucdb_coverpoint or VendorCovCrossCreate.
  procedure fli_set_ucdb_coverpoint_name( obj: t_ucdb_cp_handle; name: string );


  --  Add a bin or set of bins to either a Point/Item or Cross Functional Coverage Model
  --  Checking for sizing that is different from original sizing already done in OSVVM CoveragePkg
  --  It is important to maintain an index that corresponds to the order the bins were entered as 
  --  that is used when coverage is recorded.
  procedure fli_add_ucdb_bin( obj: t_ucdb_cp_handle; Action: integer; atleast: integer; name: string; index: OUT t_ucdb_bin_index );


  --  Increment the coverage of bin identified by index number.
  --  Index ranges from 1 to Number of Bins.  
  --  Index corresponds to the order the bins were entered (starting from 1)
  procedure fli_increment_ucdb_bin( obj: t_ucdb_cp_handle; index: integer );


end package;

package body func_cov_ucdb_pkg is

  --  Create Initial Data Structure for Point/Item Functional Coverage Model
  --  Sets initial name of the coverage model if available
  --  This procedure is used by fli_create_ucdb_coverpoint function
	procedure fli_create_ucdb_coverpoint( obj: OUT t_ucdb_cp_handle; name: IN string )  is
  begin
    report "EMPTY PROCEDURE CALL: inside Create_CP procedure, name --" & name & "--" severity note ;
  end  procedure fli_create_ucdb_coverpoint;
    
     
  --  Sets/Updates the name of the Coverage Model.
  --  Should not be called until the data structure is created by fli_create_ucdb_coverpoint or VendorCovCrossCreate.
  --  Replaces name that was set by fli_create_ucdb_coverpoint or VendorCovCrossCreate.
	procedure fli_set_ucdb_coverpoint_name( obj: t_ucdb_cp_handle; name: string ) is 
  begin
    report "EMPTY PROCEDURE CALL: inside fli_set_ucdb_coverpoint_name procedure, name --" & name & "--" severity note ;
  end procedure fli_set_ucdb_coverpoint_name ;

    
  --  Add a bin or set of bins to either a Point/Item or Cross Functional Coverage Model
  --  Checking for sizing that is different from original sizing already done in OSVVM CoveragePkg
  --  It is important to maintain an index that corresponds to the order the bins were entered as 
  --  that is used when coverage is recorded.
	procedure fli_add_ucdb_bin( obj: t_ucdb_cp_handle; Action: integer; atleast: integer; name: string; index: OUT t_ucdb_bin_index )is 
  begin
    report "EMPTY PROCEDURE CALL: inside fli_add_ucdb_bin procedure, name --" & name & "--" severity note ;
  end procedure fli_add_ucdb_bin ;
    
  --  Increment the coverage of bin identified by index number.
  --  Index ranges from 1 to Number of Bins.  
  --  Index corresponds to the order the bins were entered (starting from 1)
	procedure fli_increment_ucdb_bin( obj: t_ucdb_cp_handle; index: integer )is 
  begin
    report "EMPTY PROCEDURE CALL: inside fli_increment_ucdb_bin procedure, index --" & to_string(index) & "--" severity note ;
  end procedure fli_increment_ucdb_bin ;

end package body;