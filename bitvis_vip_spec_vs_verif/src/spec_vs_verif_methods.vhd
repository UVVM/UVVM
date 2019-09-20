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

package spec_vs_verif_methods is  
  file RESULT_FILE : text;

  -- A requirement will be reported as failed if there is a mismatch on the error counters. 
  -- This type is used to specify if a mismatch of severity level warning will cause the requirement to fail, or if a mismatch of severity error is needed.
  type t_fail_on_alert_mismatch_severity is (WARNING, ERROR);

  -- Log requirement and testcase to file. 
  -- This function checks the global error mismatch counter for mismatch between expected and observed alerts of severity 'fail_on_alert_mismatch_severity'.
  procedure log_req_cov(
    constant requirement : string;
    constant testcase    : string;
    constant passed      : boolean := true;
    constant fail_on_alert_mismatch_severity : t_fail_on_alert_mismatch_severity := ERROR
  );
  
  -- Starts the requirement coverage process by reading the requirement file and opening the output file
  procedure start_req_cov(
    constant req_to_tc_map  : string;
    constant output_file    : string := C_DEFAULT_RESULT_FILE_NAME
  );
  
  -- Ends the requirement coverage by writing a check-string to the result file, closing all files and cleaning up the memory.
  procedure end_req_cov(
    constant VOID : t_void
  );
  
  
--=================================================================================================  
-- Functions and procedures declared below this line are intended as internal functions
--=================================================================================================  

type t_line_vector is array(0 to C_MAX_NUM_TC_PR_REQUIREMENT-1) of line;
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
shared variable shared_requirement_array      : t_requirement_entry_array(0 to C_MAX_NUM_REQUIREMENTS);
shared variable shared_requirements_in_array  : natural := 0;

constant C_PASS_STRING : string := "PASS";
constant C_FAIL_STRING : string := "FAIL";
constant C_SCOPE       : string := "SPEC_VS_VERIF";
constant C_REQ_COV_SUCCESSFUL_STRING : string := "Requirement coverage completed successfully";

procedure log_entry(
  constant index : natural
);

procedure read_and_parse_csv_file(
  constant req_to_tc_map  : string
);

procedure initialize_result_file(
  constant file_name : string
);

impure function requirement_exists(
    requirement : string
) return boolean;

impure function requirement_and_tc_exists(
    requirement : string;
    testcase    : string
) return boolean;

function boolean_to_pass_fail_string(
    passed : boolean
) return string;

impure function get_description(
    requirement : string;
    testcase    : string
) return string;

end package spec_vs_verif_methods;


--=================================================================================================
--=================================================================================================
--=================================================================================================

package body spec_vs_verif_methods is

  procedure log_req_cov(
    constant requirement : string;
    constant testcase    : string;
    constant passed      : boolean := true;
    constant fail_on_alert_mismatch_severity : t_fail_on_alert_mismatch_severity := ERROR
  ) is
    variable v_requirement_to_file_line : line;
    variable v_requirement_passed : boolean := passed;
  begin
    if shared_requirements_in_array = 0 then
      alert(TB_ERROR, "Requirements not been parsed. Please used start_req_cov() before calling log_req_cov().", C_SCOPE);
      return;
    end if;
    
    -- Check if requirement exists
    if shared_req_vs_cov_strict_testcase_checking then
      check_value(requirement_and_tc_exists(requirement, testcase), C_REQ_TC_MISMATCH_SEVERITY, "Checking that requirement and testcase exists in requirement list", C_SCOPE);
    else
      check_value(requirement_exists(requirement), C_REQ_TC_MISMATCH_SEVERITY, "Checking that requirement exists in requirement list", C_SCOPE);
    end if;

    -- Check if there were any errors globally
    if (fail_on_alert_mismatch_severity = ERROR) then
      if (shared_uvvm_status.found_unexpected_simulation_errors_or_worse = 1) then
        v_requirement_passed := false;
      end if;
    else
      if (shared_uvvm_status.found_unexpected_simulation_warnings_or_worse = 1) then
        v_requirement_passed := false;
      end if;
    end if;

    -- Log result to transcript
    log(ID_SPEC_VS_VERIF, "Logging requirement " & requirement & " [" & boolean_to_pass_fail_string(v_requirement_passed) & "]. '" & get_description(requirement, testcase) & "'.", C_SCOPE);

    -- Log to file
    write(v_requirement_to_file_line, requirement & C_CSV_DELIMITER & testcase & C_CSV_DELIMITER & boolean_to_pass_fail_string(v_requirement_passed));
    writeline(RESULT_FILE, v_requirement_to_file_line);
  end procedure;
    

  procedure start_req_cov(
    constant req_to_tc_map  : string;
    constant output_file    : string := C_DEFAULT_RESULT_FILE_NAME
  ) is
  begin
    read_and_parse_csv_file(req_to_tc_map);    
    initialize_result_file(output_file);
  end procedure;
  
  
  procedure end_req_cov(
    constant VOID : t_void
  ) is
    variable v_checksum_string : line;
  begin

    log(ID_SPEC_VS_VERIF, "Freeing stored requirements from memory", C_SCOPE);
    for i in 0 to shared_requirements_in_array-1 loop
      deallocate(shared_requirement_array(i).requirement);
      deallocate(shared_requirement_array(i).description);
      for tc in 0 to shared_requirement_array(i).num_tcs-1 loop
        deallocate(shared_requirement_array(i).tc_list(tc));
      end loop;
      shared_requirement_array(i).num_tcs := 0;
      shared_requirement_array(i).valid := false;
    end loop;
    shared_requirements_in_array := 0;
        
    log(ID_SPEC_VS_VERIF, "Marking requirement coverage results as successful", C_SCOPE);
    write(v_checksum_string, C_REQ_COV_SUCCESSFUL_STRING);
    writeline(RESULT_FILE, v_checksum_string);

    log(ID_SPEC_VS_VERIF, "Closing requirement to testcase map file", C_SCOPE);
    file_close(RESULT_FILE);

    log(ID_SPEC_VS_VERIF, "Requirement coverage ended succesfully", C_SCOPE);
  end procedure;
  
  
--=================================================================================================  
-- Functions and procedures declared below this line are intended as internal functions
--=================================================================================================  

function boolean_to_pass_fail_string(
    passed : boolean
  ) return string is
  begin
    if passed then
      return C_PASS_STRING;
    end if;
    return C_FAIL_STRING;
  end;

procedure initialize_result_file(
  constant file_name : string
) is
  variable v_file_open_status : FILE_OPEN_STATUS;
begin
  file_open(v_file_open_status, RESULT_FILE, file_name, write_mode);
  check_file_open_status(v_file_open_status, file_name);
end procedure;

procedure read_and_parse_csv_file(
    constant req_to_tc_map  : string
) is 
  variable v_tc_valid : boolean;
begin
  log(ID_SPEC_VS_VERIF, "Reading and parsing requirement to testcase map file, " & req_to_tc_map, C_SCOPE);

  if shared_requirements_in_array > 0 then
    alert(TB_ERROR, "Requirements have already been read from file, please call end_req_cov before starting a new requirement coverage process.", C_SCOPE);
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

    log_entry(shared_requirements_in_array);
    shared_requirements_in_array := shared_requirements_in_array + 1;
  end loop;
  
  log(ID_SPEC_VS_VERIF, "Closing requirement to testcase map file", C_SCOPE);
  shared_csv_file.dispose;

end procedure;

procedure log_entry(
    constant index : natural
  ) is
  begin
    if shared_requirement_array(index).valid then
      log(ID_SPEC_VS_VERIF, "Requirement: " & shared_requirement_array(index).requirement.all, C_SCOPE);
      log(ID_SPEC_VS_VERIF, "Description: " & shared_requirement_array(index).description.all, C_SCOPE);
      for i in 0 to shared_requirement_array(index).num_tcs-1 loop
        log(ID_SPEC_VS_VERIF, "  TC: " & shared_requirement_array(index).tc_list(i).all, C_SCOPE);
      end loop;
    else
      log(ID_SPEC_VS_VERIF, "Requirement entry was not valid", C_SCOPE);
    end if;
end procedure;

impure function requirement_exists(
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

impure function requirement_and_tc_exists(
    requirement : string;
    testcase    : string
) return boolean is
begin
  for i in 0 to shared_requirements_in_array-1 loop
    if shared_requirement_array(i).requirement.all(1 to requirement'length) = requirement(1 to requirement'length) then
      for tc in 0 to shared_requirement_array(i).num_tcs-1 loop
        if shared_requirement_array(i).tc_list(tc).all(1 to testcase'length) = testcase(1 to testcase'length) then
          return true;
        end if;
      end loop;
    end if;
  end loop;
  return false;
end;

impure function get_description(
    requirement : string;
    testcase    : string
) return string is
begin
  for i in 0 to shared_requirements_in_array-1 loop
    if shared_requirement_array(i).requirement.all(1 to requirement'length) = requirement(1 to requirement'length) then
      -- Found requirement
      if shared_req_vs_cov_strict_testcase_checking then
        for tc in 0 to shared_requirement_array(i).num_tcs-1 loop
          if shared_requirement_array(i).tc_list(tc).all(1 to testcase'length) = testcase(1 to testcase'length) then
            -- Found both requirement AND testcase
            return shared_requirement_array(i).description.all;
          end if;
        end loop;
      else 
        -- Strict testcase checking not required, returning description for testcase only
        return shared_requirement_array(i).description.all;
      end if;
    end if;
  end loop;
  return "DESCRIPTION NOT FOUND";
end;

end package body spec_vs_verif_methods;
