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

use std.textio.all;

use work.csv_file_reader_pkg.all;
use work.local_adaptations_pkg.all;


package spec_cov_pkg is  


  alias config is shared_spec_cov_config;

  file RESULT_FILE : text;

  --
  -- initialize_req_cov()
  --   Starts the requirement coverage process by reading the requirement 
  --   file and opening the output file.
  --
  procedure initialize_req_cov(
    constant testcase       : string;
    constant req_to_tc_map  : string;
    constant output_file    : string
  );
  -- Overloading procedure, no req_to_tc_map
  procedure initialize_req_cov(
    constant testcase       : string;
    constant output_file    : string
  );

  --
  -- log_req_cov()
  --   Log requirement and testcase to file. 
  --   This function checks the global error mismatch counter for mismatch 
  --   between expected and observed alerts.
  --
  procedure log_req_cov(
    constant requirement : string;
    constant testcase    : string;
    constant test_status : t_test_status := PASS
  );
  -- Overloading procedure without testcase and optional test_status
  procedure log_req_cov(
    constant requirement : string;
    constant test_status : t_test_status := PASS
  );
  
  --
  -- finalize_req_cov()
  --   Ends the requirement coverage by writing a check-string to the result file, 
  --   closing all files and cleaning up the memory.
  --
  procedure finalize_req_cov(
    constant VOID : t_void
  );
  
  

  --=================================================================================================  
  -- Functions and procedures declared below this line are intended as internal functions
  --=================================================================================================  

  type t_line_vector is array(0 to config.max_testcases_per_req-1) of line;
  type t_requirement_entry is record
    valid         : boolean;
    requirement   : line;
    description   : line;
    num_tcs       : natural;
    tc_list       : t_line_vector;
  end record;
  type t_requirement_entry_array is array (natural range <>) of t_requirement_entry;

  -- Shared variables used internally in this context
  shared variable shared_csv_file               : csv_file_reader_type;
  shared variable shared_requirement_array      : t_requirement_entry_array(0 to config.max_testcases_per_req);
  shared variable shared_requirements_in_array  : natural := 0;

  constant C_FAIL_STRING                : string := "FAIL";
  constant C_PASS_STRING                : string := "PASS";
  constant C_SCOPE                      : string := "SPEC_COV";

  procedure priv_log_entry(
    constant index : natural
  );

  procedure priv_read_and_parse_csv_file(
    constant req_to_tc_map  : string
  );

  procedure priv_initialize_result_file(
    constant file_name : string
  );

  impure function priv_requirement_exists(
      requirement : string
  ) return boolean;

  impure function priv_requirement_and_tc_exists(
      requirement : string;
      testcase    : string
  ) return boolean;

  impure function priv_get_description(
      requirement : string;
      testcase    : string
  ) return string;

  function priv_test_status_to_string(
    constant test_status : t_test_status
  ) return string;

  impure function priv_get_summary_string 
  return string;

end package spec_cov_pkg;


--=================================================================================================
--=================================================================================================
--=================================================================================================

package body spec_cov_pkg is

  -- This testcase string will be used when no testcase is given when using the log_req_cov() method.
  shared variable priv_default_testcase_name  : string(1 to C_TESTCASE_NAME_MAX_LENGTH) := (others => NUL);
  shared variable priv_testcase_passed        : boolean;
  
  --
  -- initialize_req_cov()
  --   Starts the requirement coverage process by reading the requirement 
  --   file and opening the output file.
  --
  --   Note! If skip_requirement_list is TRUE then any given requirement list
  --         will be ignored.
  --
  procedure initialize_req_cov(
    constant testcase       : string;
    constant req_to_tc_map  : string;
    constant output_file    : string
  ) is
  begin
    priv_default_testcase_name(1 to testcase'length) := testcase;

    if config.skip_requirement_list = false then
      priv_read_and_parse_csv_file(req_to_tc_map);    
    end if;

    priv_initialize_result_file(output_file);

    priv_testcase_passed := true;
  end procedure initialize_req_cov;
  
  -- Overloading procedure, no req_to_tc_map
  procedure initialize_req_cov(
    constant testcase       : string;
    constant output_file    : string
  ) is
  begin
    log(ID_SPEC_COV, "Requirement Coverage initialized with no requirement file.", C_SCOPE);
    priv_default_testcase_name(1 to testcase'length) := testcase;
    priv_initialize_result_file(output_file);

    priv_testcase_passed := true;
  end procedure initialize_req_cov;
  
  --
  -- log_req_cov()
  --   Log requirement and testcase to file. 
  --   This function checks the global error mismatch counter for mismatch 
  --   between expected and observed alerts.
  --
  procedure log_req_cov(
    constant requirement : string;
    constant testcase    : string;
    constant test_status : t_test_status := PASS
  ) is
    variable v_requirement_to_file_line : line;
    variable v_requirement_status       : t_test_status := test_status;
  begin

    if shared_requirements_in_array = 0 and config.skip_requirement_list = false then
      alert(TB_ERROR, "Requirements not been parsed. Please used initialize_req_cov() with a requirement file before calling log_req_cov().", C_SCOPE);
      return;
    end if;

    ---- Check if there were any errors globally
    if (shared_uvvm_status.found_unexpected_simulation_errors_or_worse = 1) then
      v_requirement_status := FAIL;
    end if;

    if v_requirement_status = FAIL then
      priv_testcase_passed := false;
    end if;

    -- Log result to transcript
    log(ID_SPEC_COV, "Logging requirement " & requirement & " [" & priv_test_status_to_string(v_requirement_status) & "]. '" & priv_get_description(requirement, testcase) & "'.", C_SCOPE);

    -- Log to file
    write(v_requirement_to_file_line, requirement & C_CSV_DELIMITER & testcase & C_CSV_DELIMITER & priv_test_status_to_string(v_requirement_status));
    writeline(RESULT_FILE, v_requirement_to_file_line);
  end procedure log_req_cov;

  -- Overloading procedure without testcase and optional test_status
  procedure log_req_cov(
    constant requirement : string;
    constant test_status : t_test_status := PASS
  ) is 
  begin
    log_req_cov(requirement, priv_default_testcase_name, test_status);
  end procedure log_req_cov;
  
  
  --
  -- finalize_req_cov()
  --   Ends the requirement coverage by writing a check-string to the result file, 
  --   closing all files and cleaning up the memory.
  --
  procedure finalize_req_cov(
    constant VOID : t_void
  ) is
    variable v_checksum_string : line;
    constant c_summary_string  : string := priv_get_summary_string;

  begin

    -- Free used memory
    log(ID_SPEC_COV, "Freeing stored requirements from memory", C_SCOPE);
    for i in 0 to shared_requirements_in_array-1 loop
      deallocate(shared_requirement_array(i).requirement);
      deallocate(shared_requirement_array(i).description);
      for tc in 0 to shared_requirement_array(i).num_tcs-1 loop
        deallocate(shared_requirement_array(i).tc_list(tc));
      end loop;
      shared_requirement_array(i).num_tcs := 0;
      shared_requirement_array(i).valid   := false;
    end loop;
    shared_requirements_in_array := 0;
        
    -- Add closing line
    log(ID_SPEC_COV, "Marking requirement coverage result.", C_SCOPE);
    write(v_checksum_string, c_summary_string);

    writeline(RESULT_FILE, v_checksum_string);

    file_close(RESULT_FILE);
    log(ID_SPEC_COV, "Requirement coverage finalized.", C_SCOPE);
  end procedure finalize_req_cov;
  


  
--=================================================================================================  
-- Functions and procedures declared below this line are intended as internal functions
--=================================================================================================  


procedure priv_initialize_result_file(
  constant file_name : string
) is
  variable v_file_open_status : FILE_OPEN_STATUS;
begin
  file_open(v_file_open_status, RESULT_FILE, file_name, write_mode);
  check_file_open_status(v_file_open_status, file_name);
end procedure;

procedure priv_read_and_parse_csv_file(
    constant req_to_tc_map  : string
) is 
  variable v_tc_valid : boolean;
begin
  log(ID_SPEC_COV, "Reading and parsing requirement to testcase map file, " & req_to_tc_map, C_SCOPE);

  if shared_requirements_in_array > 0 then
    alert(TB_ERROR, "Requirements have already been read from file, please call finalize_req_cov before starting a new requirement coverage process.", C_SCOPE);
    return;
  end if;
  shared_csv_file.initialize(req_to_tc_map, C_CSV_DELIMITER);

  while not shared_csv_file.end_of_file loop
    shared_csv_file.readline;

    -- Read requirement
    shared_requirement_array(shared_requirements_in_array).requirement := new string'(shared_csv_file.read_string);
    -- Read description
    shared_requirement_array(shared_requirements_in_array).description := new string'(shared_csv_file.read_string);
    -- Read testcases
    v_tc_valid := true;
    shared_requirement_array(shared_requirements_in_array).num_tcs := 0;
    while v_tc_valid loop
      shared_requirement_array(shared_requirements_in_array).tc_list(shared_requirement_array(shared_requirements_in_array).num_tcs) := new string'(shared_csv_file.read_string);  
      if (shared_requirement_array(shared_requirements_in_array).tc_list(shared_requirement_array(shared_requirements_in_array).num_tcs).all(1) /= NUL) then
        shared_requirement_array(shared_requirements_in_array).num_tcs := shared_requirement_array(shared_requirements_in_array).num_tcs + 1;
      else
        v_tc_valid := false;
      end if;
    end loop;
    -- Validate entry
    shared_requirement_array(shared_requirements_in_array).valid := true;

    priv_log_entry(shared_requirements_in_array);
    shared_requirements_in_array := shared_requirements_in_array + 1;
  end loop;
  
  log(ID_SPEC_COV, "Closing requirement to testcase map file", C_SCOPE);
  shared_csv_file.dispose;

end procedure;

procedure priv_log_entry(
    constant index : natural
  ) is
  begin
    if shared_requirement_array(index).valid then
      log(ID_SPEC_COV, "Requirement: " & shared_requirement_array(index).requirement.all, C_SCOPE);
      log(ID_SPEC_COV, "Description: " & shared_requirement_array(index).description.all, C_SCOPE);
      for i in 0 to shared_requirement_array(index).num_tcs-1 loop
        log(ID_SPEC_COV, "  TC: " & shared_requirement_array(index).tc_list(i).all, C_SCOPE);
      end loop;
    else
      log(ID_SPEC_COV, "Requirement entry was not valid", C_SCOPE);
    end if;
end procedure;

impure function priv_requirement_exists(
  requirement : string
) return boolean is
begin
  for i in 0 to shared_requirements_in_array-1 loop
    if (shared_requirement_array(i).requirement.all(1 to requirement'length) = requirement(1 to requirement'length)) then
      return true;
    end if;
  end loop;
  return false;
end function;

impure function priv_requirement_and_tc_exists(
    requirement : string;
    testcase    : string
) return boolean is
begin
  for i in 0 to shared_requirements_in_array-1 loop
    if to_upper(shared_requirement_array(i).requirement.all(1 to requirement'length)) = to_upper(requirement(1 to requirement'length)) then
      for tc in 0 to shared_requirement_array(i).num_tcs-1 loop
        if to_upper(shared_requirement_array(i).tc_list(tc).all(1 to testcase'length)) = to_upper(testcase(1 to testcase'length)) then
          return true;
        end if;
      end loop;
    end if;
  end loop;
  return false;
end;

impure function priv_get_description(
    requirement : string;
    testcase    : string
) return string is
begin
  for i in 0 to shared_requirements_in_array-1 loop
    if shared_requirement_array(i).requirement.all(1 to requirement'length) = requirement(1 to requirement'length) then
      -- Found requirement
      for tc in 0 to shared_requirement_array(i).num_tcs-1 loop
        if shared_requirement_array(i).tc_list(tc).all(1 to testcase'length) = testcase(1 to testcase'length) then
          -- Found both requirement AND testcase
          return shared_requirement_array(i).description.all;
        end if;
      end loop;
    end if;
  end loop;

  if config.skip_requirement_list = true then
    return "";
  else
    return "DESCRIPTION NOT FOUND";
  end if;
end;


function priv_test_status_to_string(
  constant test_status : t_test_status
) return string is
begin
  if test_status = PASS then
    return C_PASS_STRING;
  else -- test_status = FAIL
    return C_FAIL_STRING;
  end if;
end function priv_test_status_to_string;



impure function priv_get_summary_string 
  return string is
begin
  if (priv_testcase_passed = true) and (shared_uvvm_status.found_unexpected_simulation_errors_or_worse = 0) then
    return "SUMMARY, " & priv_default_testcase_name & ", " & C_PASS_STRING;
  else
  return "SUMMARY, " & priv_default_testcase_name & ", " & C_FAIL_STRING;
  end if;
end function priv_get_summary_string;



end package body spec_cov_pkg;
