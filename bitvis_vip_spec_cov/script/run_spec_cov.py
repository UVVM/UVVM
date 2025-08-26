#================================================================================================================================
# Copyright 2024 UVVM
# Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 and in the provided LICENSE.TXT.
#
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
# an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.
#================================================================================================================================
# Note : Any functionality not explicitly described in the documentation is subject to change at any time
#--------------------------------------------------------------------------------------------------------------------------------

import sys
# Raise an exception if Python version is < 3.0
if sys.version_info[0] < 3:
    raise Exception("Python version 3 is required to run this script!")

import os
import csv
import glob

#==========================================================================
# Settings
#==========================================================================
# Predefined arguments and run parameters
def_args = [{"short" : "-r", "long" : "--requirement_list",     "type" : "in-file",   "help" : "-r                  Path/requirements.csv contains requirements", "default" : "NA"},
            {"short" : "-p", "long" : "--partial_cov",          "type" : "in-file",   "help" : "-p                  Path/testcase_result.csv partial coverage file from VHDL simulations", "default" : "NA"},
            {"short" : "-m", "long" : "--requirement_map_list", "type" : "in-file",   "help" : "-m                  Optional: path/subrequirements.csv requirement map file", "default" : "NA"},
            {"short" : "-s", "long" : "--spec_cov",             "type" : "out-file",  "help" : "-s                  Path/spec_cov.csv specification coverage file", "default" : "NA"},
            {"short" : "",   "long" : "--strictness",           "type" : "setting",   "help" : "--strictness N      Optional: will set specification coverage to strictness (1-2) (0=default)", "default" : "X"},
            {"short" : "",   "long" : "--config",               "type" : "config",    "help" : "--config            Optional: configuration file with all arguments", "default" : "NA"},
            {"short" : "",   "long" : "--clean",                "type" : "household", "help" : "--clean (DIR)       Will clean any/all partial coverage file(s) (default=current directory)", "default" : "NA"},
            {"short" : "-h", "long" : "--help",                 "type" : "help",      "help" : "--help              This help screen", "default" : "NA"}]

# Default, non-configured run
run_parameter_default = {"requirement_list" : None, "partial_cov" : None, "requirement_map_list" : None, "spec_cov" : None, "clean" : None, "strictness" : 'X', "config" : None}


#==========================================================================
# Structures
#==========================================================================

class Requirement():
    """
    This class is for requirement objects, as defined in requirement and 
    partial coverage files.

    Attributes:
        name (str) : name of the requirement.
    """

    VALID_REQ_TYPES = {'NONCOMPOUND', 'COMPOUND', 'SUB'}

    def __init__(self, req_name = None, req_type = 'NONCOMPOUND'):
        self.__req_name                   = req_name
        self.__expected_testcase_list     = []
        self.__actual_testcase_list       = []
        self.__sub_requirement_list       = []
        self.__compound_requirement_list  = []
        self.__requirement_description    = None
        self.__req_compliance             = not_tested_compliant_string
        self.__req_is_defined_in_req_file = False
        self.__req_is_defined_in_map_file = False
        self.__req_file_idx               = 0
        self.__req_type                   = req_type
        self.__explicitly_failed          = False


    @property
    def name(self) -> str :
        return self.__req_name
    @name.setter
    def name(self, req_name) -> None :
        self.__req_name = req_name


    @property
    def description(self) -> str :
        return self.__requirement_description
    @description.setter
    def description(self, requirement_description) -> None :
        self.__requirement_description = requirement_description


    def add_expected_testcase(self, testcase) -> None :
        # Add if not already in list
        if not(testcase in self.__expected_testcase_list):
           self.__expected_testcase_list.append(testcase)


    def get_expected_testcase_list(self) -> list :
        return self.__expected_testcase_list


    def add_actual_testcase(self, testcase) -> None :
        # Add if not already in list
        if not(testcase in self.__actual_testcase_list):
            self.__actual_testcase_list.append(testcase)
        # Update testcase result if testcase already exists
        else:
            for actual_testcase in self.__actual_testcase_list:
                if actual_testcase.name.upper() == testcase.name.upper():
                    actual_testcase.result = testcase.result


    def get_actual_testcase_list(self) -> list :
        return self.__actual_testcase_list


    def get_from_actual_testcase_list(self, testcase_name):
        for actual_testcase in self.__actual_testcase_list:
            if actual_testcase.name.upper() == testcase_name.upper():
                return actual_testcase
        return None


    def get_sorted_testcase_list(self) -> list :
        """
        Sort all testcases in order:
          PASS,
          FAIL,
          NOT_EXECUTED
        """
        all_testcase_list = []
        passing_testcase_list = []
        failing_testcase_list = []
        not_run_testcase_list = []

        # Make one-dimensional version of expected_testcase_list
        expected_testcase_list_local = []
        for expected_testcase in self.__expected_testcase_list:
            if isinstance(expected_testcase, list): # Check if the element is a list of or-listed testcases
                for or_listed_testcase in expected_testcase:
                    if not(or_listed_testcase in expected_testcase_list_local):
                        expected_testcase_list_local.append(or_listed_testcase)
            else:
                if not(expected_testcase in expected_testcase_list_local):
                    expected_testcase_list_local.append(expected_testcase)

        testcase_list = self.__actual_testcase_list + expected_testcase_list_local
        for testcase in testcase_list:
            if (testcase.result == testcase_pass_string) and not(testcase in passing_testcase_list):
                passing_testcase_list.append(testcase)
            elif (testcase.result == testcase_fail_string) and not(testcase in failing_testcase_list):
                failing_testcase_list.append(testcase)
            elif (testcase.result == testcase_not_run_string) and not(testcase in not_run_testcase_list):
                not_run_testcase_list.append(testcase)

        all_testcase_list = passing_testcase_list + failing_testcase_list + not_run_testcase_list
        return all_testcase_list

        
    def add_compound_requirement(self, compound_requirement) -> None :
        if not(compound_requirement in self.__compound_requirement_list):
            self.__compound_requirement_list.append(compound_requirement)


    def get_compound_requirement_list(self) -> list :
        return self.__compound_requirement_list


    def add_sub_requirement(self, sub_requirement) -> None :
        if not(sub_requirement in self.__sub_requirement_list):
            self.__sub_requirement_list.append(sub_requirement)


    def get_sub_requirement_list(self) -> list :
        return self.__sub_requirement_list


    @property
    def compliance(self) -> str :
        return self.__req_compliance

    @compliance.setter
    def compliance(self, req_compliance) -> None :
        # COMPLIANT should not be allowed to overwrite a NON_COMPLIANT
        if not(self.__req_compliance == non_compliant_string):
            self.__req_compliance = req_compliance

    def is_noncompound_requirement(self) -> bool :
        if self.__req_type == 'NONCOMPOUND':
            return True
        return False

    def is_compound_requirement(self) -> bool :
        if self.__req_type == 'COMPOUND':
            return True
        return False
    
    def is_sub_requirement(self) -> bool :
        if self.__req_type == 'SUB':
            return True
        return False
    
    def is_listed(self) -> bool :
        if self.__req_is_defined_in_req_file or self.__req_is_defined_in_map_file:
            return True
        return False

    @property
    def found_in_map_file(self) -> bool :
        return self.__req_is_defined_in_map_file

    @found_in_map_file.setter
    def found_in_map_file(self, found) -> None :
        self.__req_is_defined_in_map_file = found

    @property
    def found_in_requirement_file(self) -> bool :
        return self.__req_is_defined_in_req_file

    @found_in_requirement_file.setter
    def found_in_requirement_file(self, found) -> None :
        self.__req_is_defined_in_req_file = found

    @property
    def requirement_file_idx(self) -> int :
        return self.__req_file_idx

    @requirement_file_idx.setter
    def requirement_file_idx(self, idx) -> None : 
        self.__req_file_idx = idx

    @property
    def requirement_type(self) -> str :
        return self.__req_type

    @requirement_type.setter
    def requirement_type(self, type) -> str :
        if type not in Requirement.VALID_REQ_TYPES:
            raise Exception("Invalid req_type. Must be one of: {', '.join(Requirement.VALID_REQ_TYPES)}")
        self.__req_type = type

    @property
    def explicitly_failed(self) -> bool :
        return self.__explicitly_failed

    @explicitly_failed.setter
    def explicitly_failed(self, failed) -> None :
        self.__explicitly_failed = failed


class Testcase():
    """
    This class is for testcase objects, as defined in requirement and 
    partial coverage files.

    Attributes:
        name (str) : name of the testcase.
    """

    def __init__(self, tc_name = None):
        self.__tc_name                    = tc_name
        self.__expected_requirement_list  = []
        self.__actual_requirement_list    = []
        self.__tc_result                  = testcase_not_run_string


    @property
    def name(self) -> str :
        return self.__tc_name

    @name.setter
    def name(self, tc_name) -> None :
        self.__tc_name = tc_name

    @property
    def result(self) -> None :
        return self.__tc_result
        
    @result.setter
    def result(self, result) -> str :
        # PASS should not be allowed to overwrite a FAIL.
        if not(self.__tc_result == testcase_fail_string):
            self.__tc_result = result.upper()

    def add_expected_requirement(self, requirement) -> None :
        if not(requirement in self.__expected_requirement_list):
            self.__expected_requirement_list.append(requirement)


    def get_expected_requirement_list(self) -> list :
        return self.__expected_requirement_list


    def add_actual_requirement(self, requirement) -> None :
        if not(requirement in self.__actual_requirement_list):
            self.__actual_requirement_list.append(requirement)


    def get_actual_requirement_list(self) -> list :
        return self.__actual_requirement_list


    def get_all_requirement_list(self) -> list :
        all_requirement_list = []
        for requirement in self.__actual_requirement_list:
            all_requirement_list.append(requirement)

        for requirement in self.__expected_requirement_list:
            if not requirement in all_requirement_list:
                all_requirement_list.append(requirement)
        return all_requirement_list


class Container():
    """
    This class is for holding objects, e.g. Requirement and Testcase objects.
    """

    def __init__(self):
        self.__testcase_list = []
        self.__requirement_list = []
        self.__sorted_requirement_list = []


    def get_requirement(self, name):
        """ Return requirement obj from list, create new and add if not found. """
        for requirement in self.__requirement_list:
            # Found, return object
            if requirement.name.upper() == name.upper():
                return requirement
        # Not found, create new, add to list and return object
        requirement = Requirement(name, 'NONCOMPOUND')
        self.add_requirement(requirement)
        return requirement


    def add_requirement(self, new_requirement) -> None :
        for requirement in self.__requirement_list:
            # Skip already listed
            if requirement.name.upper() == new_requirement.name.upper():
                return
        self.__requirement_list.append(new_requirement)


    def get_requirement_list(self) -> list :
        return self.__requirement_list


    def get_testcase(self, name):
        for testcase in self.__testcase_list:
            # Found, return object
            if testcase.name.upper() == name.upper():
                return testcase
        # Not found, create new, add to list and return object
        testcase = Testcase(name)
        self.add_testcase(testcase)
        return testcase


    def add_testcase(self, new_testcase) -> None :
        for testcase in self.__testcase_list:
            if testcase.name.upper() == new_testcase.name.upper():
                return
        self.__testcase_list.append(new_testcase)


    def get_testcase_list(self) -> list :
        return self.__testcase_list


    def add_requirement_to_organized_list(self, requirement) -> None :
        """ Create a list of requirements as listed in requirement file. """
        if not(requirement in self.__sorted_requirement_list):
            self.__sorted_requirement_list.append(requirement)


    def organize_requirements(self) -> None :
        """ Organize requirements with the ones found in requirement file first. """
        for req in self.__requirement_list:
            if not(req in self.__sorted_requirement_list):
                self.__sorted_requirement_list.append(req)
        self.__requirement_list = self.__sorted_requirement_list.copy()


#==========================================================================
# Constants
#==========================================================================
testcase_pass_string                = "PASS"
testcase_fail_string                = "FAIL"
testcase_not_run_string             = "NOT_EXECUTED"
compliant_string                    = "COMPLIANT"
non_compliant_string                = "NON_COMPLIANT"
not_tested_compliant_string         = "NOT_TESTED"
tested_ok_compliant_string          = "TESTED_OK"
parsed_string                       = "Has been parsed by run_spec_cov.py script for total coverage"
delimiter                           = "," # Default delimiter - will be updated from partial coverage file


reporting_dict = {}
previously_executed_coverage_list = []
messages_in_warnings_file = False
reqs_in_non_compliance_file = False


#----------------------------------------------------------------------------------------------
# Write warning file
# ---------------------------------------------------------------------------------------------
# The warning file will contain warnings about the following:
#  - Tickoff of requirements that are not listed in the requirement- or map files.
#  - In strictness 1 or 2: Requirement tickoff in a testcase not specified for that requirement

def write_warning_file(run_configuration,container):
    filename = run_configuration.get("spec_cov")
    strictness = run_configuration.get("strictness")
    warnings_filename = filename[: filename.rfind(".")] + ".warnings.csv"
    file_empty = True
    global messages_in_warnings_file

    try:
        with open(warnings_filename, mode='w', newline='') as to_file:
            csv_writer = csv.writer(to_file, delimiter=delimiter)
            # Write lines for reqs ticked off in non-specified testcase(s)
            for requirement in container.get_requirement_list():
                # Don't list this type of warning for non-listed reqs. These will be covered by a separate warning.
                if not (requirement in reporting_dict.get("not_listed_requirements")):
                    expected_tc_list = requirement.get_expected_testcase_list()
                    actual_tc_list = requirement.get_actual_testcase_list()
                    # Write warning for tickoff of compound requirement
                    if actual_tc_list and requirement.is_compound_requirement():
                        for actual_tc in actual_tc_list:
                            csv_writer.writerow([requirement.name + " specified for testing through sub-requirements. Ticked off directly in " + actual_tc.name])
                            file_empty = False
                    # If strictness 0 or strictness 1 with no expected_tc_list, tickoff in non-speced TC is ok, so no warning.
                    # Otherwise, for each actual tc, check if it is in expected tc list
                    if not (strictness == "0" or (strictness=="1" and not expected_tc_list)):
                        for actual_tc in actual_tc_list:
                            # "if actual_tc not in expected_tc_list"
                            if not any(actual_tc in element if isinstance(element, list) else actual_tc == element for element in expected_tc_list):
                                # Requirement ticked off in non-specified tc. Write warning line
                                csv_writer.writerow([requirement.name + " ticked off in non-specified testcase (" + actual_tc.name + ")"])
                                file_empty = False

                    # Strictness 2: Write warning if req defined without testcases
                    if strictness == "2" and not expected_tc_list:
                        if not requirement.is_compound_requirement():
                            csv_writer.writerow(["No testcases specified for requirement " + requirement.name + ". At least one testcase must be specified per requirement in strictness 2"])
                            file_empty = False

            # Write lines for non-listed requirements ticked off
            if reporting_dict.get("not_listed_requirements"):
                for requirement in reporting_dict.get("not_listed_requirements"):
                    # Make a string containing testcases where the requirement was ticked off
                    actual_tc_list = requirement.get_actual_testcase_list()
                    actual_tc_string = ""
                    first_item = True
                    for actual_tc in actual_tc_list:
                        if not first_item:
                            actual_tc_string += " & "
                        first_item = False
                        actual_tc_string += actual_tc.name
                    # Write line to warnings file
                    csv_writer.writerow([requirement.name + " not found in input requirement list (ticked off in " + actual_tc_string + ")"])
                    file_empty = False

            if file_empty:
                csv_writer.writerow(["<No warnings to report>"])

        if not file_empty:
            messages_in_warnings_file = True

    except:
        error_msg = ("Error %s occurred with file %s" %(sys.exc_info()[0], warnings_filename))
        abort(error_code = 26, msg = error_msg)


## Helper function. Write name of items in a list as a string, with each item separated by "&".
def tc_list_to_string(input_list, approved_list, separator = " & "):
    output_string = ""
    for item in input_list:
        if item in approved_list: # Only write items that are found in approved_list (will list all items if equal to input_list)
            if output_string == "": # First item in list
                output_string += item.name
            else:
                output_string += separator + item.name
    return output_string

def append_to_tc_string(tc_string, tc_name):
    if tc_string == "":
        tc_string = tc_name
    else:
        tc_string += " & " + tc_name
    return tc_string

## Helper function which writes line(s) with minimal testcase listing and compliance for a requirement
## For use when writing minimal compliance file
def write_minimal_req_entry(requirement, compound_req_name, run_configuration, csv_writer, req_type):
    strictness = run_configuration.get("strictness")

    if requirement.is_listed() and requirement.requirement_type == req_type:
        if requirement.compliance == compliant_string:
            expected_tc_list = requirement.get_expected_testcase_list()
            actual_tc_list   = requirement.get_actual_testcase_list()

            # If strictness 0 and/or no expected testcases, list all actual testcases
            if strictness == "0" or not expected_tc_list: # No expected testcases
                    # For strictness 0, or with strictness 1 when no expected TCs, any actual TC is covering.
                    # Write single testcase, since that is the minimum of covering TCs in this case
                    testcase_string = actual_tc_list[0].name # Use first entry in list of actual testcases

            # If strictness 1 or 2, list minimum of covering testcases
            # Minimum means that if several OR-listed testcases are ticked off, only one of them is listed.
            # Single line per requirement
            else:
                testcase_string = ""
                for tc_entry in expected_tc_list:
                    # Check if the entry is a list of OR-listed testcases or a single, AND-listed testcase
                    if isinstance(tc_entry, list): # OR-listed testcases
                        for or_listed_tc in tc_entry:
                            if or_listed_tc in actual_tc_list:
                                testcase_string = append_to_tc_string(testcase_string, or_listed_tc.name)
                                break # Write only the first OR-listed TC that was ticked off
                    else: # AND-listed testcase
                        if tc_entry in actual_tc_list:
                            testcase_string = append_to_tc_string(testcase_string, tc_entry.name)

            # Write requirement line to CSV file
            if req_type == "NONCOMPOUND":
                csv_writer.writerow([requirement.name, testcase_string, requirement.compliance]) 
            elif req_type == "SUB":
                csv_writer.writerow([compound_req_name, requirement.name, testcase_string, requirement.compliance])

        # NON-COMPLIANT or NOT_TESTED reqs. List without testcases    
        else:
            if req_type == "NONCOMPOUND":
                csv_writer.writerow([requirement.name, "check *.req_non_compliance.csv", requirement.compliance])
            elif req_type == "SUB":
                csv_writer.writerow([compound_req_name, requirement.name, "check *.req_non_compliance.csv", requirement.compliance])


## Helper function which writes line(s) with extended testcase listing and compliance for a requirement
## For use when writing extended compliance file
def write_extended_req_entry(requirement, compound_req_name, run_configuration, csv_writer, req_type):
    strictness = run_configuration.get("strictness")

    if requirement.is_listed() and requirement.requirement_type == req_type:

        # COMPLIANT reqs. List with all covering testcases
        if requirement.compliance == compliant_string:
            first_tc_in_list = True
            expected_tc_list = requirement.get_expected_testcase_list()
            actual_tc_list = requirement.get_actual_testcase_list()

            # If strictness 0 and/or no expected testcases, list all actual testcases
            # (In strictness 1, when no expected testcases, any actual testcase is covering)
            if strictness == "0" or not expected_tc_list: # No expected testcases
                    testcase_string = tc_list_to_string(actual_tc_list, actual_tc_list)
                    if req_type == "NONCOMPOUND":
                        csv_writer.writerow([requirement.name, testcase_string, requirement.compliance]) 
                    elif req_type == "SUB":
                        csv_writer.writerow([compound_req_name, requirement.name, testcase_string, requirement.compliance])

            # If expected testcases and strictness 1/2, list according to AND/OR-listing.
            # One line per AND-listed testcase, and one line per group of OR-listed testcases
            # (i.e. one line per entry in expected_tc_list)
            else:
                for tc_entry in expected_tc_list:
                    if isinstance(tc_entry, list): # OR-listed requirements
                        # For OR-listed TCs, write all where the req was actually tested
                        testcase_string = tc_list_to_string(tc_entry, actual_tc_list)

                    else: # AND-listed requirement. Write if found in actual TC list
                        if tc_entry in actual_tc_list:
                            testcase_string = tc_entry.name

                    # Check that testcase_string isn't empty. Will only occur if tc_entry was not found in actual_tc_list, which should
                    # never occur, since all expected_tc_list entries must be covered by actual_tc_list for the req to be compliant.
                    # If this check fails, it means there is a bug somewhere.
                    if testcase_string == "":
                        error_msg = ("Bug alert: Error in write_extended_req_entry. Empty testcase_string. Shouldn't occur for compliant req.")
                        abort(error_code = 10, msg = error_msg)

                    # Write line to CSV file
                    if req_type == "NONCOMPOUND":
                        csv_writer.writerow([requirement.name, testcase_string, requirement.compliance]) 
                    elif req_type == "SUB":
                        csv_writer.writerow([compound_req_name, requirement.name, testcase_string, requirement.compliance]) 

        # NON-COMPLIANT or NOT_TESTED reqs. List without testcases    
        else:
            if req_type == "NONCOMPOUND":
                csv_writer.writerow([requirement.name, "check *.req_non_compliance.csv", requirement.compliance])
            elif req_type == "SUB":
                csv_writer.writerow([compound_req_name, requirement.name, "check *.req_non_compliance.csv", requirement.compliance])



def write_req_compliance_files(run_configuration, container, delimiter):

    filename = run_configuration.get("spec_cov")
    req_compliance_minimal_filename = filename[: filename.rfind(".")] + ".req_compliance_minimal.csv"
    req_compliance_extended_filename = filename[: filename.rfind(".")] + ".req_compliance_extended.csv"


    #----------------------------------------------------------------------------------------------
    # Write minimal compliance file - one requirement per line, only minimum covering TCs listed
    # ---------------------------------------------------------------------------------------------
    # This file will list one requirement per line, with just the testcases that qualifies the 
    # requirement to be compliant. For requirements that are not compliant, no testcases will be listed.

    try:
        with open(req_compliance_minimal_filename, mode='w', newline='') as to_file:
            csv_writer = csv.writer(to_file, delimiter=delimiter)
            csv_writer.writerow(["Requirement", "Covering testcases(minimum)", "Compliance"])
            listed_requirement_found = False

            # Write one line for each listed main level requirement requirement (not sub-reqs)
            for requirement in container.get_requirement_list():
                if requirement.is_noncompound_requirement():
                    write_minimal_req_entry(requirement, "", run_configuration, csv_writer, "NONCOMPOUND")
                elif requirement.is_compound_requirement() and requirement.is_listed():
                    csv_writer.writerow([requirement.name, "tested through sub-requirement(s)", requirement.compliance])

                if requirement.is_listed():
                    listed_requirement_found = True

            if not listed_requirement_found:
                csv_writer.writerow(["<Requirement file empty or missing>"])

            csv_writer.writerow([])
            csv_writer.writerow([])

            # Write sub requirement section 
            first_subreq_line = True
            for requirement in container.get_requirement_list():
                if requirement.is_compound_requirement():
                    # Write header before first line
                    if first_subreq_line:
                        csv_writer.writerow(["Requirement", "Sub-requirement", "Covering testcases(minimum)", "Sub-req compliance"])
                        first_subreq_line = False
                    for sub_requirement in requirement.get_sub_requirement_list():
                        write_minimal_req_entry(sub_requirement, requirement.name, run_configuration, csv_writer, "SUB")

    except:
        error_msg = ("Error %s occurred with file %s" %(sys.exc_info()[0], req_compliance_minimal_filename))
        abort(error_code = 27, msg = error_msg)


    #----------------------------------------------------------------------------------------------
    # Write extended compliance file - requirements listed as in requirement file, all covering testcases
    # ---------------------------------------------------------------------------------------------
    # This file will list the requirements with all testcases that are both expected and have req tickoff.
    # AND-listed testcases will be listed on a separate line, while OR-listed testcases are listed on the same line. 

    try:
        with open(req_compliance_extended_filename, mode='w', newline='') as to_file:
            csv_writer = csv.writer(to_file, delimiter=delimiter)
            csv_writer.writerow(["Requirement", "Covering testcases(all)", "Compliance"])
            listed_requirement_found = False

            # Write one line for each listed main level requirement requirement (not sub-reqs)
            for requirement in container.get_requirement_list():
                if requirement.requirement_type == "NONCOMPOUND":
                    write_extended_req_entry(requirement, "", run_configuration, csv_writer, "NONCOMPOUND")

                # Compound requirements: Write single line per req, with text indicating testing through sub-requirements
                elif requirement.is_listed() and requirement.is_compound_requirement():
                    csv_writer.writerow([requirement.name, "tested through sub-requirement(s)", requirement.compliance])

                if requirement.is_listed():
                    listed_requirement_found = True

            if not listed_requirement_found:
                csv_writer.writerow(["<Requirement file empty or missing>"])

            csv_writer.writerow([])
            csv_writer.writerow([])

            # Write sub-requirement section
            first_subreq_line = True
            for requirement in container.get_requirement_list():
                if requirement.is_compound_requirement():
                    for sub_requirement in requirement.get_sub_requirement_list():
                        if first_subreq_line:
                            csv_writer.writerow(["Requirement", "Sub-requirement", "Covering testcases(all)", "Sub-req compliance"])
                            first_subreq_line = False
                        write_extended_req_entry(sub_requirement, requirement.name, run_configuration, csv_writer, "SUB")

    except:
        error_msg = ("Error %s occurred with file %s" %(sys.exc_info()[0], req_compliance_extended_filename))
        abort(error_code = 9, msg = error_msg)

def write_non_compliance_file(run_configuration, container, delimiter):
    # For each NON-COMPLIANT or NOT_TESTED requirement, write a line with status and reason for lack of compliance
    filename = run_configuration.get("spec_cov")
    strictness = run_configuration.get("strictness")
    non_compliance_filename = filename[: filename.rfind(".")] + ".req_non_compliance.csv"

    try:
        with open(non_compliance_filename, mode='w', newline='') as to_file:
            csv_writer = csv.writer(to_file, delimiter=delimiter)
            csv_writer.writerow(["Requirement", "Compliance status", "Reason"])
            list_empty = True
            global reqs_in_non_compliance_file

            #########################################
            ## Write main section - noncompliance
            #########################################
            for requirement in container.get_requirement_list():
                if requirement.is_listed() and not (requirement.compliance == compliant_string):
                    expected_tc_list = requirement.get_expected_testcase_list()
                    actual_tc_list = requirement.get_actual_testcase_list()

                    #------------
                    # NOT_TESTED
                    #------------
                    if requirement.compliance == not_tested_compliant_string:
                        # NONCOMPOUND: List missing tickoffs
                        if requirement.is_noncompound_requirement():
                            # Report which testcases are missing (unless strictness 0 or no expected TCs)
                            if expected_tc_list and not strictness == "0":
                                for tc_entry in expected_tc_list:
                                    if isinstance(tc_entry, list): # OR-listed testcases
                                        # Check if any of the OR-listed testcases are in actual_tc_list
                                        if not any(or_listed_tc in actual_tc_list for or_listed_tc in tc_entry):
                                            testcase_string = tc_list_to_string(tc_entry, tc_entry, " or ")
                                            csv_writer.writerow([requirement.name, requirement.compliance, "Missing tickoff in " + testcase_string])
                                            list_empty = False
                                    else: # AND-listed testcase
                                        if tc_entry not in actual_tc_list:
                                            csv_writer.writerow([requirement.name, requirement.compliance, "Missing tickoff in " + tc_entry.name])
                                            list_empty = False
                            # No expected TC list -> NOT_TESTED status must mean that there are no tickoffs.
                            # If strictness 0, any TC would be covering, so just report that there are no tickoffs.
                            else: 
                                if not actual_tc_list:
                                    csv_writer.writerow([requirement.name, requirement.compliance, "No requirement tickoffs"])
                                    list_empty = False
                                else:
                                    print("ERROR: This shouldn't occur! (NOT_TESTED, expected_tc_list empty, but actual_tc_list not empty)")                            

                        # COMPOUND: list subreqs with NOT_TESTED status
                        if requirement.is_compound_requirement():
                            for sub_requirement in requirement.get_sub_requirement_list():
                                if sub_requirement.compliance == not_tested_compliant_string:
                                    csv_writer.writerow([requirement.name, requirement.compliance, "Sub-req " + sub_requirement.name + " not tested"])
                                    list_empty = False

                    #---------------
                    # NON-COMPLIANT
                    #---------------
                    if (not requirement.is_sub_requirement()) and requirement.compliance == non_compliant_string:
                        # Check for tickoff in failed TC
                        for actual_tc in actual_tc_list:
                            if actual_tc.result == testcase_fail_string:
                                csv_writer.writerow([requirement.name, requirement.compliance, actual_tc.name + " failed"])
                                list_empty = False

                        # Check for explicit fail of requirement at tickoff
                        if requirement.explicitly_failed:
                            csv_writer.writerow([requirement.name, requirement.compliance, "Requirement explicitly failed at tickoff"])
                            list_empty = False


                        # Strictness 2: Check for tickoff in non-speced TC or no TCs in req listing
                        if strictness == "2":
                            for actual_tc in actual_tc_list:
                                # Check if actual_tc is in expected_tc_list
                                if not any(actual_tc in element if isinstance(element, list) else actual_tc == element for element in expected_tc_list):
                                    csv_writer.writerow([requirement.name, requirement.compliance, "Ticked off in non-specified testcase (" + actual_tc.name + ")"])
                                    list_empty = False
                            if not expected_tc_list and not requirement.is_compound_requirement():
                                csv_writer.writerow([requirement.name, requirement.compliance, "No testcases specified for requirement (mandatory in strictness 2)"])
                                list_empty = False

                        # COMPOUND: Check for failing subreq
                        if requirement.is_compound_requirement():
                            for sub_requirement in requirement.get_sub_requirement_list():
                                if sub_requirement.compliance == non_compliant_string:
                                    csv_writer.writerow([requirement.name, requirement.compliance, "Sub-req " + sub_requirement.name + " failed"])
                                    list_empty = False

            if list_empty:
                csv_writer.writerow(["<No non-compliant requirements>"])
            else:
                reqs_in_non_compliance_file = True

            ##################################################
            ## Write sub requirement section - noncompliance
            ##################################################
            csv_writer.writerow([])
            csv_writer.writerow([])
            first_subreq_line = True
            for requirement in container.get_requirement_list():
                if requirement.is_listed() and not (requirement.compliance == compliant_string):
                    # Write line(s) for each non-compliant or not tested sub-requirement 
                    if requirement.is_sub_requirement():
                        expected_tc_list = requirement.get_expected_testcase_list()
                        actual_tc_list = requirement.get_actual_testcase_list()
                        # Write header before first line
                        if first_subreq_line:
                            csv_writer.writerow(["Sub-requirement", "Compliance status", "Reason"])
                            first_subreq_line = False

                        #---------------------
                        # Sub-req NOT_TESTED
                        #---------------------
                        if requirement.compliance == not_tested_compliant_string:
                            if expected_tc_list: # Check which TCs are missing
                                for tc_entry in expected_tc_list:
                                    if isinstance(tc_entry, list): # OR-listed testcases
                                        # Check if any of the OR-listed testcases are in actual_tc_list
                                        if not any(or_listed_tc in actual_tc_list for or_listed_tc in tc_entry):
                                            testcase_string = tc_list_to_string(tc_entry, tc_entry, " or ")
                                            csv_writer.writerow([requirement.name, requirement.compliance, "Missing tickoff in " + testcase_string])
                                    else: # AND-listed testcase
                                        if tc_entry not in actual_tc_list:
                                            csv_writer.writerow([requirement.name, requirement.compliance, "Missing tickoff in " + tc_entry.name])
                            else: # No expected TCs -> NOT_TESTED status must mean that there are no tickoffs at all. 
                                if not actual_tc_list:
                                    csv_writer.writerow([requirement.name, requirement.compliance, "No requirement tickoffs"])
                                else:
                                    print("ERROR: This shouldn't occur! (NOT_TESTED, expected_tc_list empty, but actual_tc_list not empty)") 

                        #-----------------------
                        # Sub-req NON-COMPLIANT
                        #-----------------------
                        elif requirement.compliance == non_compliant_string:
                            # Check for tickoff in failed TC
                            for actual_tc in actual_tc_list:
                                if actual_tc.result == testcase_fail_string:
                                    csv_writer.writerow([requirement.name, requirement.compliance, actual_tc.name + " failed"])
                            if not expected_tc_list:
                                csv_writer.writerow([requirement.name, requirement.compliance, "No testcases specified for requirement (mandatory in strictness 2)"])

                            # Check for explicit fail of requirement at tickoff
                            if requirement.explicitly_failed:
                                csv_writer.writerow([requirement.name, requirement.compliance, "Requirement explicitly failed at tickoff"])

                            # Strictness 2: Check for tickoff in non-speced TC
                            if strictness == "2":
                                for actual_tc in actual_tc_list:
                                    # Check if actual_tc is in expected_tc_list
                                    if not any(actual_tc in element if isinstance(element, list) else actual_tc == element for element in expected_tc_list):
                                        csv_writer.writerow([requirement.name, requirement.compliance, "Ticked off in non-specified TC (" + actual_tc.name + ")"])


    except:
        error_msg = ("Error %s occurred with file %s" %(sys.exc_info()[0], non_compliance_filename))
        abort(error_code = 1, msg = error_msg)

def write_testcase_list_file(run_configuration, container, delimiter):
    filename = run_configuration.get("spec_cov")
    testcase_list_filename = filename[: filename.rfind(".")] + ".testcase_list.csv"

    try:
        with open(testcase_list_filename, mode='w', newline='') as to_file:
            csv_writer = csv.writer(to_file, delimiter=delimiter)
            csv_writer.writerow(["Testcase", "Testcase status", "Actual tickoffs", "Missing tickoffs"])

            for testcase in container.get_testcase_list():
                actual_requirement_list = testcase.get_actual_requirement_list()
                expected_requirement_list = testcase.get_expected_requirement_list()
                actual_req_string = tc_list_to_string(actual_requirement_list, actual_requirement_list)
                missing_req_string = ""
                for expected_req in expected_requirement_list:
                    if expected_req not in actual_requirement_list:
                        missing_req_string = append_to_tc_string(missing_req_string, expected_req.name)

                csv_writer.writerow([testcase.name, testcase.result, actual_req_string, missing_req_string])

    except:
        error_msg = ("Error %s occurred with file %s" %(sys.exc_info()[0], testcase_list_filename))
        abort(error_code = 1, msg = error_msg)

def terminal_present_results(container, delimiter) -> dict:
    testcase_pass_list = []
    testcase_fail_list = []
    testcase_not_run_list = []

    requirement_compliant_list = []
    requirement_non_compliant_list = []
    requirement_not_run_list = []
    requirement_not_listed_list = []

    # Build testcase lists
    for testcase in container.get_testcase_list():
        if testcase.result == testcase_not_run_string:
            testcase_not_run_list.append(testcase)
        elif testcase.result == testcase_fail_string:
            testcase_fail_list.append(testcase)
        elif testcase.result == testcase_pass_string:
            testcase_pass_list.append(testcase)
        else:
            print("WARNING! Unknown result for testcase : %s." %(testcase.name))
            testcase_fail_list.append(testcase)

    # Build requirement lists
    for requirement in container.get_requirement_list():
        # Include listed requirements only in compliant, non-compliant and not tested lists
        if requirement.found_in_requirement_file or requirement.found_in_map_file:
            if requirement.compliance == not_tested_compliant_string:
                requirement_not_run_list.append(requirement)
            elif requirement.compliance == non_compliant_string:
                requirement_non_compliant_list.append(requirement)
            elif requirement.compliance == compliant_string:
                requirement_compliant_list.append(requirement)
            else:
                print("WARNING! Unknown result for requirement : %s." %(requirement.name))
                requirement_non_compliant_list.append(requirement)
        else: # Add non-listed requirements to separate list
            requirement_not_listed_list.append(requirement)


    # Add results to reporting dictionary
    reporting_dict["num_compliant_requirements"] = str(len(requirement_compliant_list))
    reporting_dict["compliant_requirements"] = requirement_compliant_list
    reporting_dict["num_non_compliant_requirements"] = str(len(requirement_non_compliant_list))
    reporting_dict["non_compliant_requirements"] = requirement_non_compliant_list
    reporting_dict["num_non_verified_requirements"] = str(len(requirement_not_run_list))
    reporting_dict["non_verified_requirements"] = requirement_not_run_list
    reporting_dict["num_not_listed_requirements"] = str(len(requirement_not_listed_list))
    reporting_dict["not_listed_requirements"] = requirement_not_listed_list

    reporting_dict["num_passing_testcases"] = str(len(testcase_pass_list))
    reporting_dict["passing_testcases"] = testcase_pass_list
    reporting_dict["num_failing_testcases"] = str(len(testcase_fail_list))
    reporting_dict["failing_testcases"] = testcase_fail_list
    reporting_dict["num_not_run_testcases"] = str(len(testcase_not_run_list))
    reporting_dict["not_run_testcases"] = testcase_not_run_list

    #==========================================================================
    # Present a summary to terminal
    #==========================================================================
    print("SUMMARY:")
    print("----------------------------------------------")
    print("Number of compliant requirements     : %d" %(len(requirement_compliant_list)))
    print("Number of non compliant requirements : %d" %(len(requirement_non_compliant_list)))
    print("Number of non verified requirements  : %d" %(len(requirement_not_run_list)))
    print("Number of not listed requirements    : %s" %(len(requirement_not_listed_list)))
    print("Number of passing testcases : %d" %(len(testcase_pass_list)))
    print("Number of failing testcases : %d" %(len(testcase_fail_list)))
    print("Number of not run testcases : %d" %(len(testcase_not_run_list)))
    print("\n")

    if requirement_compliant_list:
        print("Compliant requirement(s) :")
        for item in requirement_compliant_list:
            print("%s%s " %(item.name, delimiter), end='')
        print("\n")
    if requirement_non_compliant_list:
        print("Non compliant requirement(s) :")
        for item in requirement_non_compliant_list:
            print("%s%s " %(item.name, delimiter), end='')
        print("\n")
    if requirement_not_run_list:
        print("Not verified requirement(s) :")
        for item in requirement_not_run_list:
            print("%s%s " %(item.name, delimiter), end='')
        print("\n")
    if requirement_not_listed_list:
        print("Not listed requirement(s) :")
        for item in requirement_not_listed_list:
            print("%s%s " %(item.name, delimiter), end='')
        print("\n")

    if testcase_pass_list:
        print("Passing testcase(s) :")
        for item in testcase_pass_list:
            print("%s%s " %(item.name, delimiter), end='')
        print("\n")
    if testcase_fail_list:
        print("Failing testcase(s) :")
        for item in testcase_fail_list:
            print("%s%s " %(item.name, delimiter), end='')
        print("\n")
    if testcase_not_run_list:
        print("Not run testcase(s) :")
        for item in testcase_not_run_list:
            print("%s%s " %(item.name, delimiter), end='')
        print("\n")

    if previously_executed_coverage_list:
        print("Following %d partial coverage file(s) have been previously executed :" %len(previously_executed_coverage_list))
        for item in previously_executed_coverage_list:
            print(item)
        print("\n")




def build_spec_compliance_list(run_configuration, container, delimiter):
    """
    This method will update all requirements with COMPLIANT / NON COMPLIANT / NON VERIFIED based on 
    strictness level, testcase OR / AND listing and run, and sub-requirement compliance.

    Parameters:
        
        run_configuration (dict) : selected configuration for this run.

        requirement_container (Container()) : container for requirement objects
    
        testcase_container (Container()) : container for testcase objects

        delimiter (char) : CSV delimiter
    """
    # Get the configured strictness level
    strictness = run_configuration.get("strictness")

    # All strictnesses: Update requirement compliance based on testcase result
    for requirement in container.get_requirement_list():
        for testcase in requirement.get_actual_testcase_list():
            if testcase.result == testcase_fail_string:
                requirement.compliance = non_compliant_string

    #==========================================================================
    # Strictness = 1 : Requirement has to be tested in specified testcase(s).
    #                  Any other testcase is also OK.
    #==========================================================================
    if strictness == '1':

        for requirement in container.get_requirement_list():

            # Check each element in the list of expected testcases.
            # If the element is a single testcase, that testcase must be run for the requirement ot be compliant.
            # If the element is a list of testcases, at least one of them must be run for the requirement to be compliant.
            ok = True
            for tc_element in requirement.get_expected_testcase_list():
                if isinstance(tc_element, list): # Or-listed testcases. On of them must be in actual-list
                    if not(any(or_listed_tc in requirement.get_actual_testcase_list() for or_listed_tc in tc_element)):
                        ok = False
                else: # Single testcase
                    if not(tc_element in requirement.get_actual_testcase_list()):
                        ok = False

            if not(ok):
                requirement.compliance = not_tested_compliant_string

            # Super/sub-requirement(s) are updated automatically in the Requirement Object



    #==========================================================================
    # Strictness = 2 : Requirement is non-compliant if tested in a testcase
    #                  that is not specified for that requirement.
    #==========================================================================
    elif strictness == '2':
        for requirement in container.get_requirement_list():

            # Check each element in the list of expected testcases.
            # If the element is a single testcase, that testcase must be run for the requirement ot be compliant.
            # If the element is a list of testcases, at least one of them must be run for the requirement to be compliant.
            ok = True
            for tc_element in requirement.get_expected_testcase_list():
                if isinstance(tc_element, list): # Or-listed testcases. On of them must be in actual-list
                    if not(any(or_listed_tc in requirement.get_actual_testcase_list()) for or_listed_tc in tc_element):
                        ok = False
                else: # Single testcase
                    if not(tc_element in requirement.get_actual_testcase_list()):
                        ok = False

            if not(ok):
                requirement.compliance = not_tested_compliant_string

            # Verify that requirement hasn't been tested in non-specified testcase
            # Go through all testcases that have ticked off this requirement
            for actual_testcase in requirement.get_actual_testcase_list():
                ok = False # Initial value. Will be set to true if tested TC found in expected TC list.
                # Check if actual testcase is in list of specified testcases
                for expected_testcase in requirement.get_expected_testcase_list():
                    if isinstance(expected_testcase, list): # Element is list of or-listed TCs
                        for or_listed_tc in expected_testcase: # Check each testcase
                            if actual_testcase.name.upper() == or_listed_tc.name.upper():
                                ok = True # Testcase found in list of expected testcases
                    else: # Element is single testcase
                        if actual_testcase.name.upper() == expected_testcase.name.upper():
                            ok = True # Testcase found in list of expected testcases
                if not(ok): # Set as non-compliant if tested testcase not found in list of expected testcases
                    requirement.compliance = non_compliant_string
            
            # Force requirement to NON-COMPLIANT if listed without any testcases
            if (not requirement.get_expected_testcase_list()) and (not requirement.is_compound_requirement()):
                requirement.compliance = non_compliant_string


            # Super/sub-requirement(s) are updated automatically in the Requirement Object

    elif not strictness == '0': # Strictness neither 0, 1 or 2
        msg = ("strictness level %s outside limits 0-2" %(strictness))
        abort(error_code = 7, msg = msg)

    # Set requirement status based on sub-requirements
    for requirement in container.get_requirement_list():
        not_tested_subreq_found = False
        for sub_requirement in requirement.get_sub_requirement_list():
            if sub_requirement.compliance == not_tested_compliant_string:
                not_tested_subreq_found = True
            # If requirement is already non-compliant, no subreq status can overwrite it. This is handled by the compliance setter.
            # If any sub-requirement is NOT_TESTED, requirement status will also be NOT_TESTED (unless NON_COMPLIANT)
            # If requirement is COMPLIANT, any subreq status can overwrite it
            if not_tested_subreq_found:
                if sub_requirement.compliance == non_compliant_string:
                    requirement.compliance = non_compliant_string # NON_COMPLIANT can overwrite all other statuses
                else:
                    requirement.compliance = not_tested_compliant_string
            else:
                requirement.compliance = sub_requirement.compliance


def build_mapping_req_list(run_configuration, container, delimiter):
    """
    This method will create compound requirement(s) and connect compound requirement(s) with
    sub-requirement(s) as defined in the mapping requirement file.

    Parameters:
        
        run_configuration (dict) : selected configuration for this run.

        requirement_container (Container()) : container for requirement objects
    
        testcase_container (Container()) : container for testcase objects

        delimiter (char) : CSV delimiter
    """
    requirement_map_file = run_configuration.get("requirement_map_list")

    # Skip if not specified in the run_configuration
    if not(requirement_map_file):
        return

    #==========================================================================
    # Build the mapping requirement list
    #==========================================================================

    # Read the requirement mapping file and create a list
    try:
        with open(requirement_map_file) as csv_map_file:
            csv_reader = csv.reader(csv_map_file, delimiter=delimiter)

            for row in csv_reader:
                or_listed_testcases = False
                or_listed_tc_list = []
                for idx, cell_item in enumerate(row):
                    if idx == 0:
                        requirement_name = cell_item.strip()
                        if requirement_name.startswith('#'): # Comment
                            break # Ignore row if it starts with comment symbol (#)

                        requirement = container.get_requirement(requirement_name)
                        requirement.found_in_map_file = True

                        if requirement.found_in_requirement_file:
                            # Mapping line. Super requirement defined in req list.
                            requirement.requirement_type = 'COMPOUND'



                    # The rest of the cells are either sub-requirements (if mapping line) or
                    # sub-requirement details (if subreq definition line)
                    else:
                        if requirement.requirement_type == 'SUB': # Subreq definition line

                            # Check if TCs are OR-listed
                            if len(row) > 3: # Two or more TCs listed
                                or_listed_testcases = True
                            # AND-listed requirements
                            elif len(row) == 3: # Single TC listed
                                or_listed_testcases = False
                            else: # No TCs listed
                                or_listed_testcases = False


                            # Requirement description
                            if idx == 1:
                                requirement.description = row[idx]

                            # Testcase(s)
                            elif idx >= 2:
                                # Get testcase name
                                testcase_name = row[idx].strip()
                                if testcase_name == "": # Empty TC column
                                    break

                                # Will get an existing or a new testcase object
                                testcase = container.get_testcase(testcase_name)

                                # Connect: requirement <-> testcase
                                testcase.add_expected_requirement(requirement)
                                if or_listed_testcases == True:
                                    # Add to or_listed_tc_list. This list will be added to expected_testcase_list later
                                    or_listed_tc_list.append(testcase)
                                else:
                                    # Add testcase to TC list
                                    requirement.add_expected_testcase(testcase)
                        else: # Mapping line
                            # Get the sub-requirement if it exists. Otherwise, a new one will be created.
                            sub_requirement_name = cell_item.strip()
                            sub_requirement = container.get_requirement(sub_requirement_name)

                            requirement.requirement_type = 'COMPOUND'
                            sub_requirement.requirement_type = 'SUB'
                            sub_requirement.found_in_map_file = True
                            requirement.add_sub_requirement(sub_requirement)
                            sub_requirement.add_compound_requirement(requirement)


                # If requirement line had or-listed TCs, add list of these TCs to expected_testcase_list
                if (or_listed_testcases == True):
                    requirement.add_expected_testcase(or_listed_tc_list.copy())
            
    except:
        error_msg = ("Error %s occurred with file %s" %(sys.exc_info()[0], requirement_map_file))
        abort(error_code = 8, msg = error_msg)


def build_req_list(run_configuration, container, delimiter):
    """
    This method will create any requirement and testcase objects which have not been 
    created when reading the partial coverage file(s).
    Requirement objects are defined as OR listed or AND listed, depending on how
    the testcases are listed with the requirements.

    Parameters:
        
        run_configuration (dict) : selected configuration for this run.

        requirement_container (Container()) : container for requirement objects
    
        testcase_container (Container()) : container for testcase objects

        delimiter (char) : CSV delimiter    
    """
    # Get the requirement list file
    req_file = run_configuration.get("requirement_list")

    # Check if requirement file has been specified
    if not(req_file):
        return

    #==========================================================================
    # Read the requirements and save to requirement_list
    #==========================================================================
    try:    
        with open(req_file) as req_file:
            csv_reader = csv.reader(req_file, delimiter=delimiter)
            
            num_req_found = 0
            or_listed_tc_list = []
            or_listed_testcases = False

            for row in csv_reader:
                num_req_found += 1
                or_listed_tc_list.clear()
                comment_line = False

                # OR-listed requirements
                if len(row) > 3: # Two or more TCs listed
                    or_listed_testcases = True
                # AND-listed requirements
                elif len(row) == 3: # Single TC listed
                    or_listed_testcases = False
                else: # No TCs listed
                    or_listed_testcases = False

                for idx, cell in enumerate(row):

                    # Requirement name
                    if idx == 0:
                        requirement_name = cell.strip()
                        if requirement_name.startswith('#'): # Comment
                            comment_line = True
                            break # Ignore row if it starts with comment symbol (--)

                        # Will get an existing or a new requirement object
                        requirement = container.get_requirement(requirement_name)
                        requirement.found_in_requirement_file = True
                        requirement.requirement_file_idx = row

                        # Add requirement to the container
                        container.add_requirement_to_organized_list(requirement)

                    # Requirement description
                    elif idx == 1:
                        requirement.description = row[idx]

                    # Testcase(s)
                    elif idx >= 2:
                        # Get testcase name
                        testcase_name = row[idx].strip()
                        if testcase_name == "sub-requirement" or testcase_name == "":
                            # Requirement is tested through sub-reqs. No TCs defined for compound req.
                            # or testcase field is empty (e.g. "REQ_1, Requirement 1,")
                            break 

                        # Will get an existing or a new testcase object
                        testcase = container.get_testcase(testcase_name)

                        # Connect: requirement <-> testcase
                        testcase.add_expected_requirement(requirement)
                        if or_listed_testcases == True:
                            # Add to or_listed_tc_list. This list will be added to expected_testcase_list later
                            or_listed_tc_list.append(testcase)
                        else:
                            # Add testcase to TC list
                            requirement.add_expected_testcase(testcase)

                # If requirement line had or-listed TCs, add list of these TCs to expected_testcase_list
                if not(comment_line): # Need to check first is line is a comment line. Otherwise, there is no requirement object to check
                    if (or_listed_testcases == True):
                        requirement.add_expected_testcase(or_listed_tc_list.copy())


        container.organize_requirements()
    except:
        error_msg = ("Error %s occurred with file %s" %(sys.exc_info()[0], req_file))
        abort(error_code = 10, msg = error_msg)



def find_testcase_in_pc_header(partial_coverage_file, container):
    """
    The method will extract the testcase name(s) from the 
    partial coverage file info header and create testcase object(s)
    and add to container list.

    Parameters:

    partial_coverage_file (str)      : name of the partial coverage file
    testcase_container (Container()) : container for testcase objects
    """

    global delimiter
    
    try:
        with open(partial_coverage_file) as csv_file:
            csv_reader = csv.reader(csv_file, delimiter=delimiter)
            for idx, row in enumerate(csv_reader):
                # Get testcase name(s) from PC header
                if idx == 0:
                    testcases = row[1:len(row)-1]
                    for testcase in testcases:
                        testcase_name = testcase.strip()
                        # This will create a new testcase object and add to container list
                        testcase_object = container.get_testcase(testcase_name)
                    return 
    except:
        error_msg = ("Error %s occurred with file %s while collection testcase names from PC header" %(sys.exc_info()[0], partial_coverage_file))
        abort(error_code = 11, msg = error_msg)
    return



def find_pc_summary(partial_coverage_file, container):
    """
    This method will search for the partial coverage file summary
    line and return True if found and summary reported PASS.

    Parameters:

    partial_coverage_file (str)      : name of the partial coverage file
    testcase_container (Container()) : container for testcase objects

    Return:

    Boolean : True if summary report is PASS, else False is returned.
    """
    global delimiter

    try:
        with open(partial_coverage_file) as csv_file:
            csv_reader = csv.reader(csv_file, delimiter=delimiter)
            for idx, row in enumerate(csv_reader):
                # Get the testcase summary
                if (idx > 3) and (row != []) and (row[0].upper() == "SUMMARY"):
                    result = row[2].strip().upper()
                    if result == testcase_pass_string:
                        return True
                else:
                    continue
    except:
        error_msg = ("Error %s occurred with file %s when searching for PC summary line" %(sys.exc_info()[0], partial_coverage_file))
        abort(error_code = 12, msg = error_msg)
    return False

def find_parsed_string(partial_coverage_file):
    """
    This method will search for the parsed string in the
    partial coverage file and return True if found.

    Parameters:

    partial_coverage_file (str) : name of the partial coverage file

    Return:

    Boolean : True if the parsed string is found, else False is returned.
    """
    try:
        with open(partial_coverage_file) as csv_file:
            csv_reader = csv.reader(csv_file)
            for idx, row in enumerate(csv_reader):
                # Find the parsed string
                if (idx > 3) and (row != []) and (row[0] == parsed_string):
                    return True
                else:
                    continue
    except:
        error_msg = ("Error %s occurred with file %s when searching for the parsed string" %(sys.exc_info()[0], partial_coverage_file))
        abort(error_code = 13, msg = error_msg)
    return False

def build_partial_cov_list(run_configuration, container):
    """
    This method will read the delimiter written by the spec_cov_pkg.vhd to 
    the partial_coverage CSV files, and updated the global delimiter.
    The method will create requirement and testcase objects, set requirement compliance
    and testcase results.
    The objects are stored in the requirement and testcase containers.

    Parameters:

        run_configuration (dict) : selected configuration for this run.
        container (Container()) : container for requirement objects and testcase objects
    """
    # For setting the global defined delimiter setting for CSV files.
    global delimiter

    # For updating the reporting dictionary
    global reporting_dict

    # Get the partial coverage file - note: can be a txt file with
    # a list of partial coverage files.
    partial_coverage_file_name = run_configuration.get("partial_cov")

    # Check if partial coverage file has been specified
    if not(partial_coverage_file_name):
        msg = "Error partial coverage file not specified"
        abort(error_code = 14, msg = msg)

    # Check if partial coverage file is missing
    if not(os.path.isfile(partial_coverage_file_name)):
        msg = "Error partial coverage file not found: " + partial_coverage_file_name
        abort(error_code = 15, msg = msg)

    # Check if partial coverage file is empty
    if (os.path.getsize(partial_coverage_file_name) == 0):
        msg = "Error partial coverage file empty: " + partial_coverage_file_name
        abort(error_code = 16, msg = msg)

    #==========================================================================
    # Create a list of partial_cov_files to read
    #==========================================================================
    partial_coverage_files = []
    try:
        # Check if partial_cov_file is a TXT file, i.e. a list of files.
        if ".txt" in partial_coverage_file_name.lower():
            with open(partial_coverage_file_name) as partial_coverage_file:
                lines = partial_coverage_file.readlines()
            for line in lines:
                partial_coverage_files.append(line.strip())
        # Partial_cov_file is a CSV file - add it as a single item to the list.
        else:
            partial_coverage_files.append(partial_coverage_file_name)
    except:
        error_msg = ("Error %s occurred with file %s when creating list of PC files" %(sys.exc_info()[0], partial_coverage_file_name))
        abort(error_code = 17, msg = error_msg)

    #==========================================================================
    # Check if listed files are files, i.e. files listed using wildcards,
    # and add any wildcard matches.
    #==========================================================================
    not_found_pc_file_list = []
    for pc_file in partial_coverage_files[:]:
        if not(os.path.isfile(pc_file)):
            # Remove the wildcard item from list
            partial_coverage_files.remove(pc_file)
            not_found_pc_file_list.append(pc_file)
            # Search for files matching wildcard
            for wildcard_file in glob.glob(pc_file):
                # Add any matching files if not already in list
                if os.path.isfile(wildcard_file) and not(wildcard_file in partial_coverage_files):
                    # Adjust path for windows and add to list
                    wildcard_file = wildcard_file.replace('\\', '/')
                    partial_coverage_files.append(wildcard_file)
                elif not(os.path.isfile(wildcard_file)):
                    not_found_pc_file_list.append(wildcard_file)          

    reporting_dict["pc_missing"] = not_found_pc_file_list

    #==========================================================================
    # Get the delimiter from the partial_cov file
    #==========================================================================
    partial_coverage_pass = False
    pc_file_name = ""
    try:
        if len(partial_coverage_files) == 0:
            pc_file_name = "NO_FILE_FOUND"
            msg = "Error: No valid partial coverage files found"
            abort(error_code = 15, msg = msg)

        pc_file = partial_coverage_files[0]

        with open(partial_coverage_files[0]) as partial_coverage_file:
            lines = partial_coverage_file.readlines()

        # Extract the delimiter
        for idx, line in enumerate(lines):
            # Delimiter statement should be on line 3
            if ("DELIMITER:" in line) and (idx == 2):
                # Delimiter char should be in CSV cell 2
                delimiter = line.split()[1]
                continue

    except:
        error_msg = ("Error %s occurred with file %s when searching for CSV delimiter in PC file %s" %(sys.exc_info()[0], partial_coverage_file_name, pc_file_name))
        abort(error_code = 18, msg = error_msg)

    #==========================================================================
    # Read requirements, testcases and results
    #==========================================================================
    try:
        for partial_coverage_file in partial_coverage_files:

            # Find the SUMMARY: PASS line in current file and the testcase object
            partial_coverage_pass = find_pc_summary(partial_coverage_file, container)

            # Create testcase objects of all testcases in PC file header
            find_testcase_in_pc_header(partial_coverage_file, container)


            with open(partial_coverage_file) as csv_file:
                csv_reader = csv.reader(csv_file, delimiter=delimiter)

                for idx, row in enumerate(csv_reader):

                    # Skip partial_coveage_file header info on the 4 first lines,
                    # empty line, summary line, and parsed string (if these exist)
                    if (idx > 3) and (row != []) and (row[0].upper() != "SUMMARY") and (row[0] != parsed_string):

                        # Read 3 cells: requirement name, testcase name, tickoff result
                        requirement_name = row[0]
                        testcase_name    = row[1]
                        tickoff_result   = row[2]

                        # Will get an existing or a new requirement object
                        requirement = container.get_requirement(requirement_name)
                        # Set the requirement intermediate compliance.
                        if tickoff_result == testcase_pass_string:
                            requirement.compliance = compliant_string
                        else:
                            requirement.compliance = non_compliant_string
                            if partial_coverage_pass: # If TC passed, but tickoff_result is FAIL, req must have been explicitly failed at tickoff
                                requirement.explicitly_failed = True

                        # Will get an existing or a new testcase object
                        testcase = container.get_testcase(testcase_name)
                        if partial_coverage_pass:
                            testcase.result = testcase_pass_string
                        else:
                            testcase.result = testcase_fail_string
                        
                        # Connect: requirement <-> testcase
                        testcase.add_actual_requirement(requirement)
                        requirement.add_actual_testcase(testcase)
                    else:
                        continue

    except:
        error_msg = ("Error %s occurred with file %s when reading PC file" %(sys.exc_info()[0], partial_coverage_file))
        abort(error_code = 19, msg = error_msg)

    #==========================================================================
    # Write the parsed string at the bottom of the partial_cov files
    #==========================================================================
    try:
        for partial_coverage_file in partial_coverage_files:

            # Find the parsed string
            if not(find_parsed_string(partial_coverage_file)):
                # Write the parsed string if not found
                with open(partial_coverage_file, mode='a', newline='') as csv_file:
                    csv_writer = csv.writer(csv_file, delimiter=delimiter)
                    csv_writer.writerow([])
                    csv_writer.writerow([parsed_string])
            # Put the partial_cov file name in a list if the parsed string already exists
            else:
                previously_executed_coverage_list.append(partial_coverage_file)

    except:
        error_msg = ("Error %s occurred with file %s when writing a parsed message to PC file" %(sys.exc_info()[0], partial_coverage_file))
        abort(error_code = 20, msg = error_msg)

def abort(error_code = 0, msg = ""):
    """
    This method will list all available arguments and exit the program
    with an exit code.

    Parameters:

        error_code (int) : exit code set when stopping program.
        
        msg (str) : string displayed prior to listing arguments.
    """
    global def_args

    if msg:
        print(msg)

    print("\nrun_spec_cov command line arguments (see QuickReference for more details):\n")
    for item in def_args:
        print(item.get("help"))
    sys.exit(error_code)

def arg_parser(arguments):
    """
    This method will check command line arguments and set the run parameter list.

    Parameters:

        arguments (list)    : a list of arguments from the command line.

    Return:
        
        run_configuration (dict) : the configuration set for this run by
                                the applied arguments.
    """
    global def_args
    global run_parameter_default

    run_configuration = run_parameter_default.copy()

    #==========================================================================
    # Check all arguments
    #==========================================================================
    for idx, arg in enumerate(arguments):

        for dict in def_args:
            argument = None
            # Search for argument in predefined arguments list
            if arg.lower() in dict.values():

                # Set the argument keyword (long version) and type
                argument = [dict.get("long"), dict.get("type"), dict]

            # Have a match
            if argument:
                # Remove keyword leading dashes '-'
                key_word = argument[0].replace('-', '')

                # Check with argument keywords which require an additional argument
                if argument[1] in ["in-file", "out-file", "setting", "config"]:

                    # Check if a next argument exists
                    if (idx + 1) >= len(arguments):
                        msg = ("missing argument after keyword : %s" %(arg))
                        abort(msg = msg)
                    # and is not a possible keyword
                    elif arguments[idx+1][0] == '-':
                        msg = ("argument can not start with '-'")
                        abort(msg = msg)
                    else:
                        run_configuration[key_word] = arguments[idx + 1]

                elif argument[1] == "household":

                    # Check if a next argument exists
                    if (idx + 1) >= len(arguments):
                        arg_value = "."
                    # and is not a possible keyword
                    elif arguments[idx+1][0] == '-':
                        arg_value = "."
                    else:
                        arg_value = arguments[idx + 1]

                    run_configuration[key_word] = arg_value

                elif argument[1] == "help":
                    abort(error_code = 0)

    # No legal arguments given - present help and exit
    if run_configuration == run_parameter_default:
        abort(error_code = 0, msg = "Please call script with one of the following arguments.")
    else:
        if run_configuration.get("strictness") == "X": run_configuration["strictness"] = '0' 
        return run_configuration

def set_run_config_from_file(run_configuration):
    """
    This method will set the run_configuration from a text file.

    Parameters:

        run_configuration (dict) : the configuration setting for this run, 
                            constructed from the command line arguments. 

    Returns:

        configuration (dict) : the configuration setting for this run,
                            constructed from the configuration file.     
    """
    config_file_name = run_configuration.get("config")
    arguments_lists = []

    try:
        with open(config_file_name) as config_file:
            lines = config_file.readlines()
    except:
        error_msg = ("Error %s occurred with configuration file %s" %(sys.exc_info()[0], config_file_name))
        abort(error_code = 21, msg = error_msg)

    # Add each line in the config file as a list to the arguments_lists
    for line in lines:
        arguments_lists.append(line.strip().split())

    # Add the config file
    arguments_lists.append(["config", config_file_name])

    # Convert the arguments_lists [[arg1, arg2], [arg3, arg4], ....] to a flat list,
    # i.e. [agr1, arg2, arg3, arg4, ...]
    arguments = [argument for sub_argument_list in arguments_lists for argument in sub_argument_list]


    # Pass the arguments list to the argument parser and return the result
    configuration = arg_parser(arguments)
    return configuration

def validate_run_configuration(run_configuration):
    """
    This method will validate the run configuration setting, 
    i.e. check that required files are given and that 
    a requirement file is set when strictness level is > 0. 
    """
    # Validate
    strictness = run_configuration.get("strictness")
    if not (strictness in ["0", "1", "2"]):
        msg = ("Strictness level %s is outside the valid range 0-2" %(strictness))
        abort(error_code = 28, msg = msg)

    if run_configuration.get("strictness") != "0":
        if run_configuration.get("requirement_list") == None:
            msg = ("Strictness level %s requires a requirement file" %(run_configuration.get("strictness")))
            abort(error_code = 22, msg = msg)

    if run_configuration.get("partial_cov") == None:
        msg = ("Missing argument for partial coverage file")
        abort(error_code = 23, msg = msg)

    if run_configuration.get("spec_cov") == None:
        msg = ("Missing argument for specification coverage file")
        abort(error_code = 24, msg = msg)

    return

def run_housekeeping(run_configuration):
    """
    This method will delete all CSV files in current dir.
    The method will check, and abort, if the --clean argument was
    used in combination with another legal argument.

    Parameters:

        run_configuration (dict) : the configuration setting for this run, 
                            constructed from the command line arguments. 
    """ 
    
    # Abort cleaning if --clean argument was passed along with
    # other legal arguments.
    if (
        run_configuration.get("requirement_list") or 
        run_configuration.get("partial_cov") or 
        run_configuration.get("requirement_map_list") or 
        run_configuration.get("spec_cov") or
        run_configuration.get("strictness") != '0' or
        run_configuration.get("config")
        ):
       error_msg = ("ERROR! --clean argument used in combination with other arguments.")
       abort(error_code = 25, msg = error_msg)

    else:
        clean_dir = run_configuration.get("clean")
        try:
            num_files_removed = 0
            for filename in os.listdir(clean_dir):
                if filename.endswith(".csv"):
                    file_path = os.path.join(clean_dir, filename)
                    os.remove(file_path)
                    num_files_removed += 1
                
            msg = ("Successfully removed %d CSV files." %(num_files_removed))
            exit_code = 0
        except:
            msg = ("Error %s occurred" %(sys.exc_info()[0]))
            exit_code = 1


        if exit_code == 1:
            # Done, exit
            abort(error_code = exit_code, msg = msg)
        else:
            print(msg)
            sys.exit(exit_code)

def version_check():
    """
    Check if Python version is at least version 3.0, will throw an 
    exception if lower than version 3.
    """
    if sys.version_info[0] < 3:
        raise Exception("Python version 3 is required to run this script!")


def main():
    # Grab the globally defined variables
    global delimiter

    # Grab the reporting dictionary
    global reporting_dict

    container = Container()

    #==========================================================================
    # Verify that correct Python version is used
    #==========================================================================
    # Check Python version >= 3.0
    version_check()   

    #==========================================================================
    # Parse the command line arguments, set the configuration, and
    # validate the settings.
    #==========================================================================

    # Parse arguments and get run selection
    run_configuration = arg_parser(sys.argv[1:])

    # If --clean parameter is applied
    if run_configuration.get("clean") is not None:
        run_housekeeping(run_configuration)

    # If --config parameter is applied
    if run_configuration.get("config"):
        run_configuration = set_run_config_from_file(run_configuration)

    validate_run_configuration(run_configuration)


    #==========================================================================
    # Show the configuration for current run
    #==========================================================================
    reporting_dict["config"] = run_configuration

    print("\nConfiguration:")
    print("----------------------------------------------")
    for key, value in run_configuration.items():
        print("%-20s : %s" %(key, value))
    print("\n")


    #==========================================================================
    # Build structure and process results
    #
    #   Note that partial_coverage files will have to be read first so
    #   that the CSV delimiter can be determined.
    #==========================================================================

    build_partial_cov_list(run_configuration, container)
    build_req_list(run_configuration, container, delimiter)
    build_mapping_req_list(run_configuration, container, delimiter) # build_req_list() must be run first!
    build_spec_compliance_list(run_configuration, container, delimiter)


    #==========================================================================
    # Write the results to CSV files
    #==========================================================================
    terminal_present_results(container, delimiter)

    write_req_compliance_files(run_configuration, container, delimiter)
    write_warning_file(run_configuration, container)
    write_non_compliance_file(run_configuration, container, delimiter)
    write_testcase_list_file(run_configuration, container, delimiter)

    file_name, extension = os.path.splitext(run_configuration.get("spec_cov"))
    if messages_in_warnings_file:
        print("Potential problems found. Please see " + file_name + ".warnings.csv.")
    if reqs_in_non_compliance_file:
        print("Non-compliant or not verified requirements found. Please see " + file_name + ".req_non_compliance.csv for details.")

if __name__ == "__main__":
    main()
    