#================================================================================================================================
# Copyright 2020 Bitvis
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
def_args = [{"short" : "-r", "long" : "--requirement_list",     "type" : "in-file",   "help" : "-r              Path/requirements.csv contains requirements", "default" : "NA"},
            {"short" : "-p", "long" : "--partial_cov",          "type" : "in-file",   "help" : "-p              Path/testcase_result.csv partial coverage file from VHDL simulations", "default" : "NA"},
            {"short" : "-m", "long" : "--requirement_map_list", "type" : "in-file",   "help" : "-m              Optional: path/subrequirements.csv requirement map file", "default" : "NA"},
            {"short" : "-s", "long" : "--spec_cov",             "type" : "out-file",  "help" : "-s              Path/spec_cov.csv specification coverage file", "default" : "NA"},
            {"short" : "",   "long" : "--strictness",           "type" : "setting",   "help" : "--strictness N  Optional: will set specification coverage to strictness (1-2) (0=default)", "default" : "X"},
            {"short" : "",   "long" : "--config",               "type" : "config",    "help" : "--config        Optional: configuration file with all arguments", "default" : "NA"},
            {"short" : "",   "long" : "--clean",                "type" : "household", "help" : "--clean         Will clean any/all partial coverage file(s)", "default" : "NA"},
            {"short" : "-h", "long" : "--help",                 "type" : "help",      "help" : "--help          This help screen", "default" : "NA"} 
            ]

# Default, non-configured run
run_parameter_default = {"requirement_list" : None, "partial_cov" : None, "requirement_map_list" : None, "spec_cov" : None, "clean" : False, "strictness" : 'X', "config" : None}


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

    def __init__(self, req_name = None):
        self.__req_name                   = req_name
        self.__expected_testcase_list     = []
        self.__actual_testcase_list       = []
        self.__sub_requirement_list       = []
        self.__super_requirement_list     = []
        self.__requirement_description    = None
        self.__req_compliance             = not_tested_compliant_string
        self.__testcases_are_or_listed    = False
        self.__req_is_defined_in_req_file = False
        self.__req_file_idx               = 0
        self.__req_is_user_omitted        = False


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
        # Update testcase result if testcase already exists
        else:
            for actual_testcase in self.__actual_testcase_list:
                if actual_testcase.name.upper() == testcase.name.upper():
                    actual_testcase.result = testcase.result

        # Update for any super-requirement
        for super_requirement in self.__super_requirement_list:
            super_requirement.add_expected_testcase(testcase)


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
        # Update for any super-requirement
        for super_requirement in self.__super_requirement_list:
            super_requirement.add_actual_testcase(testcase)


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

        testcase_list = self.__actual_testcase_list + self.__expected_testcase_list
        for testcase in testcase_list:
            if (testcase.result == testcase_pass_string) and not(testcase in passing_testcase_list):
                passing_testcase_list.append(testcase)
            elif (testcase.result == testcase_fail_string) and not(testcase in failing_testcase_list):
                failing_testcase_list.append(testcase)
            elif (testcase.result == testcase_not_run_string) and not(testcase in not_run_testcase_list):
                not_run_testcase_list.append(testcase)

        all_testcase_list = passing_testcase_list + failing_testcase_list + not_run_testcase_list
        return all_testcase_list

        
    def add_super_requirement(self, super_requirement) -> None :
        if self.is_user_omitted: return
        
        if not(super_requirement in self.__super_requirement_list):
            self.__super_requirement_list.append(super_requirement)


    def get_supert_requirement_list(self) -> list :
        return self.__super_requirement_list


    def add_sub_requirement(self, sub_requirement) -> None :
        if self.is_user_omitted: return

        if not(sub_requirement in self.__sub_requirement_list):
            self.__sub_requirement_list.append(sub_requirement)


    def get_sub_requirement_list(self) -> list :
        return self.__sub_requirement_list


    @property
    def is_user_omitted(self) -> bool:
        return self.__req_is_user_omitted
    @is_user_omitted.setter
    def is_user_omitted(self, is_omitted):
        self.__req_is_user_omitted = is_omitted

    @property
    def compliance(self) -> str :
        # Update if dependent on any sub-requirements
        for sub_requirement in self.__sub_requirement_list:
            # Do not overwrite NON_COMPLIANT
            if not(self.__req_compliance == non_compliant_string):
                if not(sub_requirement.is_user_omitted):
                    if sub_requirement.compliance == not_tested_compliant_string:
                        self.__req_compliance = non_compliant_string
                    else:    
                        self.__req_compliance = sub_requirement.compliance
        return self.__req_compliance

    @compliance.setter
    def compliance(self, req_compliance) -> None :
        if self.is_user_omitted: return

        # COMPLIANT should not be allowed to overwrite a NON_COMPLIANT
        if not(self.__req_compliance == non_compliant_string):
            self.__req_compliance = req_compliance
        # Update any super-requirements
        for requirement in self.__super_requirement_list:
            requirement.compliance = req_compliance


    @property
    def is_or_listed(self) -> bool :
        return self.__testcases_are_or_listed

    @is_or_listed.setter
    def is_or_listed(self, set) -> None :
        self.__testcases_are_or_listed = set


    def is_super_requirement(self) -> bool :
        if self.__sub_requirement_list:
            return True
        return False
    
    def is_sub_requirement(self) -> bool :
        if self.__super_requirement_list:
            return True
        return False

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
        self.__expected_requirement_list.append(requirement)


    def get_expected_requirement_list(self) -> list :
        return self.__expected_requirement_list


    def add_actual_requirement(self, requirement) -> None :
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
        requirement = Requirement(name)
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
delimiter                           = "," # Default delimiter - will be updated from partial coverage file


reporting_dict = {}



def write_single_listed_spec_cov_files(run_configuration, container, delimiter):
    """
    Write minimalistic specification coverage files, i.e each requirement and each testcase once. 
    """
    
    filename = run_configuration.get("spec_cov")
    spec_cov_single_req_vs_single_tc_filename = filename[: filename.rfind(".")] + ".single_req_vs_single_tc.csv"
    spec_cov_single_tc_vs_single_req_filename = filename[: filename.rfind(".")] + ".single_tc_vs_single_req.csv"

    run_req_list     = []
    not_run_req_list = []
    for req in container.get_requirement_list():
        tc_list = req.get_sorted_testcase_list()
        tc = None
        if tc_list: tc = tc_list[0]
        if tc and not(tc.result == testcase_not_run_string):
            run_req_list.append([req, tc])
        else:
            not_run_req_list.append([req, None])

    run_test_case_list     = []
    not_run_test_case_list = []
    for tc in container.get_testcase_list():
        req_list = tc.get_all_requirement_list()
        req = None
        if req_list: req = req_list[0]
        if req and not(req.compliance == not_tested_compliant_string):
            run_test_case_list.append([tc, req])
        else:
            not_run_test_case_list.append([tc, None])

    try:
        with open(spec_cov_single_req_vs_single_tc_filename, mode='w', newline='') as to_file:
            csv_writer = csv.writer(to_file, delimiter=delimiter)
            csv_writer.writerow(["Requirement", "Testcase", "Compliance"])
            for req, tc in (run_req_list + not_run_req_list):
                if tc:
                    csv_writer.writerow([req.name, tc.name, req.compliance])
                else:
                    csv_writer.writerow([req.name, "", not_tested_compliant_string])
    except:
        error_msg = ("Error %s occurred with file %s" %(sys.exc_info()[0], spec_cov_single_req_vs_single_tc_filename))
        abort(error_code = 1, msg = error_msg)

    try:
        with open(spec_cov_single_tc_vs_single_req_filename, mode='w', newline='') as to_file:
            csv_writer = csv.writer(to_file, delimiter=delimiter)
            csv_writer.writerow(["Testcase", "Requirement", "Result"])
            for tc, req in (run_test_case_list + not_run_test_case_list):
                if req:
                    csv_writer.writerow([tc.name, req.name, tc.result])
                else:
                    csv_writer.writerow([tc.name, "", testcase_not_run_string])
    except:
        error_msg = ("Error %s occurred with file %s" %(sys.exc_info()[0], spec_cov_single_tc_vs_single_req_filename))
        abort(error_code = 1, msg = error_msg)



def terminal_present_results(container, delimiter) -> dict:
    testcase_pass_list = []
    testcase_fail_list = []
    testcase_not_run_list = []

    requirement_compliant_list = []
    requirement_non_compliant_list = []
    requirement_not_run_list = []
    requirement_omitted_list = []
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
        if requirement.compliance == not_tested_compliant_string:
            if requirement.is_user_omitted: requirement_omitted_list.append(requirement)
            else: requirement_not_run_list.append(requirement)
        elif requirement.compliance == non_compliant_string:
            requirement_non_compliant_list.append(requirement)
        elif requirement.compliance == compliant_string:
            requirement_compliant_list.append(requirement)
        else:
            print("WARNING! Unknown result for requirement : %s." %(requirement.name))
            requirement_non_compliant_list.append(requirement)
        if not(requirement.found_in_requirement_file) or not(requirement.is_sub_requirement):
            requirement_not_listed_list.append(requirement)


    # Add results to reporting dictionary
    reporting_dict["num_compliant_requirements"] = str(len(requirement_compliant_list))
    reporting_dict["compliant_requirements"] = requirement_compliant_list
    reporting_dict["num_non_compliant_requirements"] = str(len(requirement_non_compliant_list))
    reporting_dict["non_compliant_requirements"] = requirement_non_compliant_list
    reporting_dict["num_non_verified_requirements"] = str(len(requirement_not_run_list))
    reporting_dict["non_verified_requirements"] = requirement_not_run_list
    reporting_dict["num_omitted_requirements"] = str(len(requirement_omitted_list))
    reporting_dict["omitted_requirements"] = requirement_omitted_list
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
    print("Number of user omitted requirements  : %s" %(len(requirement_omitted_list)))
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
    if requirement_omitted_list:
        print("User omitted requirement(s) :")
        for item in requirement_omitted_list:
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




def write_spec_cov_files(run_configuration, container, delimiter):
    """
    This method will write all the results to the specification coverage CSV files.
    The specification coverage file will have suffix : 
        .req_vs_single_tc : requirement(s) listed with a testcase and compliance
        .req_vs_tcs       : requirement(s) listed with testcase(s) and compliance
        .tc_vs_reqs       : testcase(s) listed with requirement(s) and result


    Parameters:
        
        run_configuration (dict) : selected configuration for this run.

        requirement_container (Container()) : container for requirement objects
    
        testcase_container (Container()) : container for testcase objects

        delimiter (char) : CSV delimiter
    """
    # Grab the global reporting dictionary
    global reporting_dict


    #==========================================================================
    # Write the results to CSVs
    #==========================================================================
    filename = run_configuration.get("spec_cov")
    spec_cov_req_vs_single_tc_filename = filename[: filename.rfind(".")] + ".req_vs_single_tc.csv"
    spec_cov_tc_vs_req_filename = filename[: filename.rfind(".")] + ".tc_vs_reqs.csv"
    spec_cov_req_vs_tc_filename = filename[: filename.rfind(".")] + ".req_vs_tcs.csv"

    # Write one requirement with one testcase per line
    try:
        with open(spec_cov_req_vs_single_tc_filename, mode='w', newline='') as to_file:
            csv_writer = csv.writer(to_file, delimiter=delimiter)

            csv_writer.writerow(["Requirement", "Testcase", "Compliance"])
            for requirement in container.get_requirement_list():
                for testcase in requirement.get_sorted_testcase_list():
                    csv_writer.writerow([requirement.name, testcase.name, requirement.compliance])
            # Create a table with the super-requirement mapping to sub-requirements
            csv_writer.writerow([])
            csv_writer.writerow([])
            csv_writer.writerow([])
            csv_writer.writerow(["Requirement", "Sub-Requirement(s)"])
            for requirement in container.get_requirement_list():
                sub_requirement_string = ""
                for sub_requirement in requirement.get_sub_requirement_list():
                    sub_requirement_string += " " + sub_requirement.name
                if sub_requirement_string:
                    csv_writer.writerow([requirement.name, sub_requirement_string])
            if reporting_dict.get("not_listed_requirements"):
                csv_writer.writerow(["Not listed requirement(s)"])
                for requirement in reporting_dict.get("not_listed_requirements"):
                    csv_writer.writerow([requirement.name])

            if reporting_dict.get("omitted_requirements"):
                csv_writer.writerow(["User omitted requirement(s)"])
                for requirement in reporting_dict.get("omitted_requirements"):
                    csv_writer.writerow([requirement.name])

    except:
        error_msg = ("Error %s occurred with file %s" %(sys.exc_info()[0], spec_cov_req_vs_single_tc_filename))
        abort(error_code = 1, msg = error_msg)


    # Write one requirement with all testcases per line
    try:
        with open(spec_cov_req_vs_tc_filename, mode='w', newline='') as to_file:
            csv_writer = csv.writer(to_file, delimiter=delimiter)

            csv_writer.writerow(["Requirement", "Testcase(s)", "Compliance"])
            for requirement in container.get_requirement_list():
                testcase_string = ""
                for testcase in requirement.get_sorted_testcase_list():
                    testcase_string += testcase.name + " "

                if not(testcase_string) and requirement.is_super_requirement():
                    for sub_requirement in requirement.get_sub_requirement_list():
                        for testcase in sub_requirement.get_sorted_testcase_list():
                            if not testcase.name in testcase_string:
                                testcase_string += testcase.name + " "

                csv_writer.writerow([requirement.name, testcase_string, requirement.compliance])

            # Create a table with the super-requirement mapping to sub-requirements
            csv_writer.writerow([])
            csv_writer.writerow([])
            csv_writer.writerow([])
            csv_writer.writerow(["Requirement", "Sub-Requirement(s)"])
            for requirement in container.get_requirement_list():
                sub_requirement_string = ""
                for sub_requirement in requirement.get_sub_requirement_list():
                    sub_requirement_string += " " + sub_requirement.name
                if sub_requirement_string:
                    csv_writer.writerow([requirement.name, sub_requirement_string])
            if reporting_dict.get("not_listed_requirements"):
                csv_writer.writerow(["Not listed requirement(s)"])
                for requirement in reporting_dict.get("not_listed_requirements"):
                    csv_writer.writerow([requirement.name])
            if reporting_dict.get("omitted_requirements"):
                csv_writer.writerow(["User omitted requirement(s)"])
                for requirement in reporting_dict.get("omitted_requirements"):
                    csv_writer.writerow([requirement.name])

    except:
        error_msg = ("Error %s occurred with file %s" %(sys.exc_info()[0], spec_cov_req_vs_tc_filename))
        abort(error_code = 1, msg = error_msg)


    # Write one testcase with all requirements per line
    try:
        with open(spec_cov_tc_vs_req_filename, mode='w', newline='') as to_file:
            csv_writer = csv.writer(to_file, delimiter=delimiter)

            csv_writer.writerow(["Testcase", "Requirement(s)", "Result"])

            for testcase in container.get_testcase_list():
                requirement_string = ""
                for requirement in testcase.get_all_requirement_list():
                    requirement_string += requirement.name + " "
                csv_writer.writerow([testcase.name, requirement_string, testcase.result])
                
    except:
        error_msg = ("Error %s occurred with file %s" %(sys.exc_info()[0], spec_cov_tc_vs_req_filename))
        abort(error_code = 1, msg = error_msg)





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

    #==========================================================================
    # Strictness = 0 : testcase can be run with any requirement
    #==========================================================================
    if strictness == '0':
        for requirement in container.get_requirement_list():
            if requirement.is_user_omitted:
                continue

            for testcase in requirement.get_actual_testcase_list():
                if testcase.result == testcase_fail_string:
                    requirement.compliance = non_compliant_string

            for sub_requirement in requirement.get_sub_requirement_list():
                requirement.compliance = sub_requirement.compliance

    #==========================================================================
    # Strictness = 1 : testcase has to be run with specified requirement,
    #                  any other requirement is also OK.
    #==========================================================================
    elif strictness == '1':

        for requirement in container.get_requirement_list():
            if requirement.is_user_omitted:
                continue

            if requirement.is_or_listed:
                # One of the listed testcases for the requirement has been run
                ok = any(tc in requirement.get_actual_testcase_list() for tc in requirement.get_expected_testcase_list())
            else:
                # All of the listed testcases for the requirement has been run
                ok =  all(tc in requirement.get_actual_testcase_list() for tc in requirement.get_expected_testcase_list())
            if not(ok):
                requirement.compliance = non_compliant_string

            # Super/sub-requirement(s) are updated automatically in the Requirement Object



    #==========================================================================
    # Strictness = 2 : all expected testcase should only be run, and
    #                  only with specified requirement.
    #==========================================================================
    elif strictness == '2':
        for requirement in container.get_requirement_list():
            if requirement.is_user_omitted:
                continue

            # Verify that required testcases have been run
            if requirement.is_or_listed:
                # One of the listed testcases for the requirement has been run
                ok =  any(tc in requirement.get_actual_testcase_list() for tc in requirement.get_expected_testcase_list())
            else:
                # All of the listed testcases for the requirement has been run
                ok =  all(tc in requirement.get_actual_testcase_list() for tc in requirement.get_expected_testcase_list())
            if not(ok):
                requirement.compliance = non_compliant_string

            # Verify that only this requirement has run this testcase
            for testcase in requirement.get_expected_testcase_list():               
                # All requirements that have been run with this testcase
                for testcase_requirement in testcase.get_actual_requirement_list():
                    # Check if any other requirements have been run with this testcase
                    if not(requirement.name.upper() == testcase_requirement.name.upper()):
                        requirement.compliance = non_compliant_string

            # Super/sub-requirement(s) are updated automatically in the Requirement Object

    else:
        msg = ("strictness level %d outside limits 0-2" %(strictness))
        abort(error_code = 1, msg = msg)


def build_mapping_req_list(run_configuration, container, delimiter):
    """
    This method will create super-requirement(s) and connect super-requirement(s) with
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
                for idx, cell_item in enumerate(row):

                    # Firs cell is the super-requirement
                    if idx == 0:
                        super_requirement_name = cell_item.strip()
                        
                        super_requirement = container.get_requirement(super_requirement_name)
                        super_requirement.found_in_requirement_file = True

                    # Rest of the cells are sub-requirements
                    else:
                        # Get the requirement (if it exists)
                        sub_requirement_name = cell_item.strip()
                        sub_requirement = container.get_requirement(sub_requirement_name)

                        super_requirement.add_sub_requirement(sub_requirement)
                        sub_requirement.add_super_requirement(super_requirement)
            
    except:
        error_msg = ("Error %s occurred with file %s" %(sys.exc_info()[0], requirement_map_file))
        abort(error_code = 1, msg = error_msg)


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

            for row in csv_reader:
                num_req_found += 1
                for idx, cell in enumerate(row):
                    user_omitted = False

                    # Requirement name
                    if idx == 0:
                        requirement_name = cell.strip()
                        if requirement_name.startswith('#'): 
                            user_omitted = True
                            requirement_name = requirement_name.replace('#', '')

                        # Will get an existing or a new requirement object
                        requirement = container.get_requirement(requirement_name)
                        requirement.found_in_requirement_file = True
                        requirement.requirement_file_idx = row

                        # Check, and mark, if user has chosen to omit this requirement.
                        if user_omitted: 
                            requirement.is_user_omitted = True

                        # Add requirement to the container
                        container.add_requirement_to_organized_list(requirement)

                    # Requirement description
                    elif idx == 1:
                        requirement.description = row[idx]

                    # Testcase(s)
                    elif idx >= 2:
                        # Get testcase name
                        testcase_name = row[idx].strip()

                        # Will get an existing or a new testcase object
                        testcase = container.get_testcase(testcase_name)            

                        # OR-listed requirements
                        if len(row) > 3:
                            requirement.is_or_listed = False
                        # AND-listed requirements
                        else:
                            requirement.is_or_listed = True

                        # Connect: requirement <-> testcase
                        if not(requirement.is_user_omitted):
                            requirement.add_expected_testcase(testcase)
                            testcase.add_expected_requirement(requirement)

        container.organize_requirements()
    except:
        error_msg = ("Error %s occurred with file %s" %(sys.exc_info()[0], req_file))
        abort(error_code = 1, msg = error_msg)



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
        abort(error_code = 1, msg = error_msg)
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
                if (idx > 3) and (row[0].upper() == "SUMMARY"):
                    result = row[2].strip().upper()
                    if result == testcase_pass_string:
                        return True
                else:
                    continue
    except:
        error_msg = ("Error %s occurred with file %s when searching for PC summary line" %(sys.exc_info()[0], partial_coverage_file))
        abort(error_code = 1, msg = error_msg)
    return False


def build_partial_cov_list(run_configuration, container):
    """
    This method will read the delimiter written by the spec_cov_pkg.vhd to 
    the partial_coverage CSV files, and updated the global delimiter.
    The method will create requirement and testcase objects, setrequirement compliance 
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
    if not(partial_coverage_file_name):
        msg = "partial coverage file missing: " + partial_coverage_file_name
        abort(error_code = 1, msg = msg)

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
        abort(error_code = 1, msg = error_msg)

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
    try:
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
        error_msg = ("Error %s occurred with file %s when searching for CSV delimiter in PC file %s" %(sys.exc_info()[0], partial_coverage_file_name, partial_coverage_files[0]))
        abort(error_code = 1, msg = error_msg)

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

                    # Skip partial_coveage_file header info on the 4 first lines and
                    # summary line at the end (if it exists)
                    if (idx > 3) and (row[0].upper() != "SUMMARY"):

                        # Read 3 cells: requirement name, testcase name, testcase result
                        requirement_name = row[0]
                        testcase_name    = row[1]
                        testcase_result  = row[2]

                        # Will get an existing or a new requirement object
                        requirement = container.get_requirement(requirement_name)
                        # Set the requirement intermediate compliance.
                        if partial_coverage_pass:
                            requirement.compliance = compliant_string
                        else:
                            requirement.compliance = non_compliant_string

                        # Will get an existing or a new testcase object
                        testcase = container.get_testcase(testcase_name)
                        if partial_coverage_pass:
                            testcase.result = testcase_result
                        else:
                            testcase.result = testcase_fail_string
                        
                        # Connect: requirement <-> testcase
                        testcase.add_actual_requirement(requirement)
                        requirement.add_actual_testcase(testcase)
                    else:
                        continue

    except:
        error_msg = ("Error %s occurred with file %s when reading PC file" %(sys.exc_info()[0], partial_coverage_file))
        abort(error_code = 1, msg = error_msg)



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
                    run_configuration[key_word] = True

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
        abort(error_code = 1, msg = error_msg)

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
    if run_configuration.get("strictness") > 0:
        if run_configuration.get("requirement_list") == None:
            msg = ("Strictness level %d require a requirement file" %(run_configuration.get("strictness")))
            abort(error_code = 1, msg = msg)

    if run_configuration.get("partial_cov") == None:
        msg = ("Missing argument for partial coverage file")
        abort(error_code = 1, msg = msg)

    if run_configuration.get("spec_cov") == None:
        msg = ("Missing argument for specification coverage file")
        abort(error_code = 1, msg = msg)
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
       abort(error_code = 1, msg = error_msg)

    else:
        try:
            num_files_removed = 0
            for filename in os.listdir("."):
                if filename.endswith(".csv"):
                    os.remove(filename)
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
    if run_configuration.get("clean"):
        run_housekeeping(run_configuration)

    # If --config parameter is applied
    if run_configuration.get("config"):
        run_configuration = set_run_config_from_file(run_configuration)


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
    build_mapping_req_list(run_configuration, container, delimiter)
    build_spec_compliance_list(run_configuration, container, delimiter)


    #==========================================================================
    # Write the results to CSV files
    #==========================================================================
    terminal_present_results(container, delimiter)

    write_spec_cov_files(run_configuration, container, delimiter)
    write_single_listed_spec_cov_files(run_configuration, container, delimiter)



if __name__ == "__main__":
    main()