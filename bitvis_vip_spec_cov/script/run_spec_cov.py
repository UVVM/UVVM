import os
# csv - Comma Separated Values - This format is most common format for import and export for spreadsheets and databases
import csv
# sys - SYSstem specific parameters - sys.argv the list of command line arguments
import sys


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

    def __init__(self, name = None):
        self.name = name
        self.super_requirement = None
        self.expected_testcase_list = []
        self.actual_testcase_list = []
        self.sub_requirement_list = []
        self.description = None
        self.compliance = None

    def set_name(self, name):
        self.name = name
    def get_name(self):
        return self.name

    def set_description(self, description):
        self.description = description
    def get_description(self):
        return self.description

    # Testcase from requirement file
    def add_expected_testcase(self, testcase):
        if not(testcase in self.expected_testcase_list):
           self.expected_testcase_list.append(testcase)
    def get_expected_testcase_list(self):
        return self.expected_testcase_list

    # Testcase from partial coverage file
    def add_actual_testcase(self, testcase):
        self.actual_testcase_list.append(testcase)
    def get_actual_testcase_list(self):
        return self.actual_testcase_list

    def get_from_actual_testcase_list(self, testcase_name):
        for actual_testcase in self.actual_testcase_list:
            if actual_testcase.get_name().upper() == testcase_name.upper():
                return actual_testcase
        return None

    # This requirement will be sub-requirement
    def set_super_requirement(self, super_requirement):
        self.super_requirement = super_requirement
    def get_supert_requirement(self):
        return self.super_requirement

    # This requirement will have sub-requirement(s)
    def add_sub_requirement(self, sub_requirement):
        self.sub_requirement_list.append(sub_requirement)
    def get_sub_requirement_list(self):
        return self.sub_requirement_list
    def sub_requirement_exist(self, sub_requirement):
        if sub_requirement in self.sub_requirement_list:
            return True
        else:
            return False

    def set_compliance(self, compliance):
        self.compliance = compliance
    def get_compliance(self):
        return self.compliance


class Testcase():

    def __init__(self, name = None):
        self.name = name
        self.expected_requirement_list = []
        self.actual_requirement_list = []
        self.result = None

    def set_name(self, name):
        self.name = name
    def get_name(self):
        return self.name

    def add_expected_requirement(self, requirement):
        self.expected_requirement_list.append(requirement)
    def get_expected_requirement(self, requirement_name):
        for requirement in self.expected_requirement_list:
            if requirement.get_name().upper() == requirement_name.upper():
                return requirement
        return None
    def get_expected_requirement_list(self):
        return self.expected_requirement_list

    def add_actual_requirement(self, requirement):
        self.actual_requirement_list.append(requirement)
    def get_actual_requirement_list(self):
        return self.actual_requirement_list

    def set_result(self, result):
        self.result = result.upper()
    def get_result(self):
        return self.result


class Container():

    def __init__(self):
        self.list = []
        self.result = None

    def add(self, item):
        self.list.append(item)
    def get_list(self):
        return self.list

    def get_item(self, name):
        for item in self.list:
            if item.get_name().upper() == name.upper():
                return item
        return None



#==========================================================================
# Constants
#==========================================================================
pass_string                         = "PASS"
fail_string                         = "FAIL"
compliant_string                    = "COMPLIANT"
non_compliant_string                = "NON COMPLIANT"
not_tested_compliant_string         = "NA"
sub_requirement_compliant_string    = "SUB_REQUIREMENT"
delimiter                           = "," # Default delimiter - will be updated from partial coverage file







def write_specification_coverage_file(run_configuration, requirement_container, testcase_container, delimiter):
    """
    This method will write all the results to the specification_coverage CSV file.

    Parameters:
        
    run_configuration (dict) : selected configuration for this run.

    requirement_container (Containter()) : container for requirement objects
    
    testcase_container (Container()) : container for testcase objects

    delimiter (char) : CSV delimiter
    """
    #==========================================================================
    # Present a summary to terminal
    #==========================================================================
    testcase_pass_list = []
    testcase_fail_list = []
    testcase_not_run_list = []

    requirement_compliant_list = []
    requirement_non_compliant_list = []
    requirement_not_run_list = []

    # Check run testcases with all requirements
    for requirement in requirement_container.get_list():

        # Check with all testcases run with requirement
        for testcase in requirement.get_actual_testcase_list():
            if testcase.get_result() == None:
                testcase_not_run_list.append(testcase)
            elif testcase.get_result() == fail_string:
                testcase_fail_list.append(testcase)
            elif testcase.get_result() == pass_string:
                testcase_pass_list.append(testcase)
            else:
                print("WARNING! Unknown result for testcase : %s." %(testcase.get_name()))
                testcase_fail_list.append(testcase)

    # Check with all defined testcases, and verify if they have a result
    for testcase in testcase_container.get_list():
        if testcase.get_result() == None:
            testcase_not_run_list.append(testcase)

    # Check compliance for all requirements
    for requirement in requirement_container.get_list():
        if requirement.get_compliance() == not_tested_compliant_string:
            requirement_not_run_list.append(requirement)
        elif requirement.get_compliance() == None:
             requirement_not_run_list.append(requirement)
        elif requirement.get_compliance() == non_compliant_string:
            requirement_non_compliant_list.append(requirement)
        elif requirement.get_compliance() == compliant_string:
            requirement_compliant_list.append(requirement)
        else:
            print("WARNING! Unknown result for requirement : %s." %(requirement.get_name()))
            requirement_non_compliant_list.append(requirement)


    print("SUMMARY:")
    print("----------------------------------------------")
    print("Number of compliant requirements     : %d" %(len(requirement_compliant_list)))
    print("Number of non compliant requirements : %d" %(len(requirement_non_compliant_list)))
    print("Number of non verified requirements  : %d" %(len(requirement_not_run_list)))

    print("Number of passing testcases : %d" %(len(testcase_pass_list)))
    print("Number of failing testcases : %d" %(len(testcase_fail_list)))
    print("Number of not run testcases : %d" %(len(testcase_not_run_list)))

    print("\n")

    if requirement_compliant_list:
        print("Compliant requirement(s) :")
        for item in requirement_compliant_list:
            print("%s%s " %(item.get_name(), delimiter), end='')
        print("\n")

    if requirement_non_compliant_list:
        print("Non compliant requirement(s) :")
        for item in requirement_non_compliant_list:
            print("%s%s " %(item.get_name(), delimiter), end='')
        print("\n")

    if requirement_not_run_list:
        print("Not verified requirement(s) :")
        for item in requirement_not_run_list:
            print("%s%s " %(item.get_name(), delimiter), end='')
        print("\n")



    if testcase_pass_list:
        print("Passing testcase(s) :")
        for item in testcase_pass_list:
            print("%s%s " %(item.get_name(), delimiter), end='')
        print("\n")

    if testcase_fail_list:
        print("Failing testcase(s) :")
        for item in testcase_fail_list:
            print("%s%s " %(item.get_name(), delimiter), end='')
        print("\n")

    if testcase_not_run_list:
        print("Not run testcase(s) :")
        for item in testcase_not_run_list:
            print("%s%s " %(item.get_name(), delimiter), end='')
        print("\n")

    #==========================================================================
    # Write the results to CSV
    #==========================================================================

    try:
        with open(run_configuration.get("spec_cov"), mode='w', newline='') as spec_cov_file:
            csv_writer = csv.writer(spec_cov_file, delimiter=delimiter)

            csv_writer.writerow(["Requirement", "Testcase(s)"])
            for requirement in requirement_container.get_list():
                testcase_string = ""
                for testcase in requirement.get_actual_testcase_list():
                    testcase_string += testcase.get_name() + " "

                if requirement.get_actual_testcase_list() and (requirement.get_compliance() == compliant_string):
                    csv_writer.writerow([requirement.get_name(), testcase_string])

                # Insert blank line in CSV
            csv_writer.writerow([])
            csv_writer.writerow(["Requirement", "Sub-requirement(s)"])
            for requirement in requirement_container.get_list():
                sub_requirement_string = ""
                for sub_requirement in requirement.get_sub_requirement_list():
                    if sub_requirement.get_compliance() == compliant_string:
                        sub_requirement_string += sub_requirement.get_name() + " "

                if requirement.get_sub_requirement_list() and (requirement.get_compliance() == compliant_string):
                    csv_writer.writerow([requirement.get_name(), sub_requirement_string])

            # Insert blank line in CSV
            csv_writer.writerow([])
            csv_writer.writerow(["Testcase", "Requirement(s)"])
            for testcase in testcase_container.get_list():
                requirement_string = ""
                if testcase.get_result() == pass_string:
                    for requirement in testcase.get_actual_requirement_list():
                        requirement_string += requirement.get_name() + " "
                    if requirement_string:
                        csv_writer.writerow([testcase.get_name(), requirement_string])

    except:
        error_msg = ("Error %s occurred with file %s" %(sys.exc_info()[0], run_configuration.get("spec_cov")))
        abort(error_code = 1, msg = error_msg)






def build_specification_compliance_list(run_configuration, requirement_container, testcase_container, delimiter):
    """
    This method will build the specification_compliance_list, i.e. create a list 
    with all requirement objects marked as COMPLIANT / NON COMPLIANT based on
    requirement and testcase objects and strictness level.

    Parameters:
        
    run_configuration (dict) : selected configuration for this run.

    requirement_container (Containter()) : container for requirement objects
    
    testcase_container (Container()) : container for testcase objects

    delimiter (char) : CSV delimiter
    """
    # Get the configured strictness level
    strictness = run_configuration.get("strictness")

    #==========================================================================
    # Strictness = 0 : testcase can be run with any requirement
    #==========================================================================
    if strictness == '0':
        for requirement in requirement_container.get_list():
            # Set as no tested compliance if not already set
            if not(requirement.get_compliance()):
                requirement.set_compliance(not_tested_compliant_string)

            # Verify with all testcases
            for testcase in testcase_container.get_list():
                if requirement in testcase.get_actual_requirement_list():
                    if testcase.get_result() == fail_string:
                        requirement.set_compliance(non_compliant_string)

            # Verify with sub-reqiurements
            for sub_requirement in requirement.get_sub_requirement_list():
                if sub_requirement.get_compliance() == non_compliant_string:
                    requirement.set_compliance(non_compliant_string)
                elif requirement.get_compliance() == not_tested_compliant_string:
                    requirement.set_compliance(sub_requirement.get_compliance())

            # Update super-requirement
            super_requirement = requirement.get_supert_requirement()
            if super_requirement:
                if requirement.get_compliance() == non_compliant_string:
                    super_requirement.set_compliance(non_compliant_string)
                elif super_requirement.get_compliance() == not_tested_compliant_string:
                    super_requirement.set_compliance(requirement.get_compliance())


    #==========================================================================
    # Strictness = 1 : testcase has to be run with specified requirement,
    #                  any other requirement is also OK.
    #==========================================================================
    elif strictness == '1':

        for requirement in requirement_container.get_list():
            # Set as no tested compliance if not already set
            if not(requirement.get_compliance()):
                requirement.set_compliance(not_tested_compliant_string)

            # Verify with all testcases
            for testcase in testcase_container.get_list():
                if requirement in testcase.get_actual_requirement_list():
                    if testcase.get_result() == fail_string:
                        requirement.set_compliance(non_compliant_string)

            # Verify that requirement has been run with all testcases
            for testcase in requirement.get_expected_testcase_list():
                if not(requirement in testcase.get_actual_requirement_list()):
                    requirement.set_compliance(non_compliant_string)

            # Verify with sub-reqiurements
            for sub_requirement in requirement.get_sub_requirement_list():
                if sub_requirement.get_compliance() == non_compliant_string:
                    requirement.set_compliance(non_compliant_string)
                elif requirement.get_compliance() == not_tested_compliant_string:
                    requirement.set_compliance(sub_requirement.get_compliance())

            # Update super-requirement
            super_requirement = requirement.get_supert_requirement()
            if super_requirement:
                if requirement.get_compliance() == non_compliant_string:
                    super_requirement.set_compliance(non_compliant_string)
                elif super_requirement.get_compliance() == not_tested_compliant_string:
                    super_requirement.set_compliance(requirement.get_compliance())




    #==========================================================================
    # Strictness = 2 : all expected testcase should only be run, and
    #                  only with specified requirement.
    #==========================================================================
    elif strictness == '2':
        for requirement in requirement_container.get_list():
            # Set as no tested compliance if not already set
            if not(requirement.get_compliance()):
                requirement.set_compliance(not_tested_compliant_string)

            # Verify with all testcases
            for testcase in testcase_container.get_list():

                # 1. all expected testcases
                if requirement in testcase.get_expected_requirement_list():
                    if testcase.get_result() == fail_string:
                        requirement.set_compliance(non_compliant_string)

                # 2. all actual testcases
                if requirement in testcase.get_actual_requirement_list():
                    if testcase.get_result() == fail_string:
                        requirement.set_compliance(non_compliant_string)

                # 3. only this requirement in testcase actual list
                for testcase_requirement in testcase.get_actual_requirement_list():
                    if not(requirement.get_name().upper() == testcase_requirement.get_name().upper()):
                        requirement.set_compliance(non_compliant_string)

            # Verify that requirement has been run with all testcases
            for testcase in requirement.get_expected_testcase_list():
                if not(requirement in testcase.get_actual_requirement_list()):
                    requirement.set_compliance(non_compliant_string)

            # Verify with sub-reqiurements
            for sub_requirement in requirement.get_sub_requirement_list():
                if sub_requirement.get_compliance() == non_compliant_string:
                    requirement.set_compliance(non_compliant_string)
                elif requirement.get_compliance() == not_tested_compliant_string:
                    requirement.set_compliance(sub_requirement.get_compliance())

            # Update super-requirement
            super_requirement = requirement.get_supert_requirement()
            if super_requirement:
                if requirement.get_compliance() == non_compliant_string:
                    super_requirement.set_compliance(non_compliant_string)
                elif super_requirement.get_compliance() == not_tested_compliant_string:
                    super_requirement.set_compliance(requirement.get_compliance())


    else:
        msg = ("strictness level %d outside limits 0-2" %(strictness))
        abort(error_code = 1, msg = msg)


def build_mapping_requirement_list(run_configuration, requirement_container, testcase_container, delimiter):
    """
    Constriuct the mapping_reqiurement_list by reading the requirement mapping file and add
    requirement_items with a list of sub_requirements (requirement_items).
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

                    # Firs cell is the super-requirement, find it
                    if idx == 0:
                        super_requirement_name = cell_item.strip()
                        super_requirement = requirement_container.get_item(super_requirement_name)
                        if not(super_requirement):
                            super_requirement = Requirement(super_requirement_name)
                            requirement_container.add(super_requirement)

                    # Rest of the cells are sub-requirements
                    else:
                        # Get the requirement (if it exists)
                        sub_requirement_name = cell_item.strip()
                        sub_requirement = requirement_container.get_item(sub_requirement_name)
                        if not(sub_requirement):
                            sub_requirement = Requirement(sub_requirement_name)
                            requirement_container.add(sub_requirement)

                        super_requirement.add_sub_requirement(sub_requirement)
                        sub_requirement.set_super_requirement(super_requirement)
            
    except:
        error_msg = ("Error %s occurred with file %s" %(sys.exc_info()[0], requirement_map_file))
        abort(error_code = 1, msg = error_msg)


def build_requirement_list(run_configuration, requirement_container, testcase_container, delimiter):
    """
    Contructs the requirement_list with requirement_items.

    Parameters:
        
    run_configuration (dict) : selected configuration for this run.

    requirement_container (Containter()) : container for requirement objects
    
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

            for row in csv_reader:
                for idx, cell in enumerate(row):
                    # Requirement name
                    if idx == 0:
                        requirement_name = cell.strip()
                        # Check if requirement exist, create if not
                        requirement = requirement_container.get_item(requirement_name)
                        if not(requirement):
                            requirement = Requirement(requirement_name) 
                            requirement_container.add(requirement)

                    # Requirement description
                    elif idx == 1:
                        requirement.set_description(row[idx])

                    # Testcase(s)
                    elif idx >= 2:
                        # Get testcase name
                        testcase_name = row[idx].strip()
                        # Fetch testcase from requirement actual testcase list
                        testcase = requirement.get_from_actual_testcase_list(testcase_name)
                        
                        # Testcase was not found, i.e. testcase has not been run.
                        if not(testcase):
                            testcase = Testcase(testcase_name)
                            testcase_container.add(testcase)
                                                        
                        # Connect: requirement <-> testcase
                        testcase.add_expected_requirement(requirement)
                        requirement.add_expected_testcase(testcase)    
                
    except:
        error_msg = ("Error %s occurred with file %s" %(sys.exc_info()[0], req_file))
        abort(error_code = 1, msg = error_msg)


def find_partial_coverage_summary(partial_coverage_file):
    """
    This method will search for the partial coverage file summary
    line and return True if found and summary reported PASS.

    Parameters:

    partial_coverage_file (str) : name of the partial coverage file

    Return:

    Boolean : True if summary report is PASS, else False is returned.
    """
    try:
        with open(partial_coverage_file) as csv_file:
            csv_reader = csv.reader(csv_file, delimiter=delimiter)
            for idx, row in enumerate(csv_reader):
                # Get the testcase summary
                if (idx > 3) and (row[0].upper() == "SUMMARY"):
                    result = row[2].strip().upper()
                    if result == pass_string:
                        return True
    except:
        error_msg = ("Error %s occurred with file %s" %(sys.exc_info()[0], partial_coverage_file))
        abort(error_code = 1, msg = error_msg)
    return False


def build_partial_coverage_list(run_configuration, requirement_container, testcase_container):
    """
    This method will read the delimiter written by the spec_cov_pkg.vhd to 
    the partial_coverage CSV files, and updated the global delimiter.
    The method will requirement objects and testcase objects, update requirement and testcase
    result based on testcase result and partial coverage summary line. The objects are stored
    in the requirement and testcase containers.

    Parameters:
        
    run_configuration (dict) : selected configuration for this run.

    requirement_container (Containter()) : container for requirement objects
    
    testcase_container (Container()) : container for testcase objects
    """
    # For setting the global defined delimiter setting for CSV files.
    global delimiter

    # Get the partial coverage file - note: can be a txt file with
    # a list of partial coverage files.
    partial_coverage_file_name = run_configuration.get("partial_cov")
    if not(partial_coverage_file_name):
        msg = "partial coverage file missing"
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
        error_msg = ("Error %s occurred with file %s" %(sys.exc_info()[0], map_partial_coverage_file_namename))
        abort(error_code = 1, msg = error_msg)

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
        error_msg = ("Error %s occurred with file %s" %(sys.exc_info()[0], partial_coverage_file_name))
        abort(error_code = 1, msg = error_msg)


    #==========================================================================
    # Read requirements, testcases and results
    #==========================================================================
    try:
        for partial_coverage_file in partial_coverage_files:

            # Find the SUMMARY: PASS line in current file
            partial_coverage_pass = find_partial_coverage_summary(partial_coverage_file)

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

                        # Create requirement object
                        requirement = requirement_container.get_item(requirement_name)
                        if not(requirement):
                            requirement = Requirement(requirement_name)
                            requirement_container.add(requirement)

                        # Create testcase object
                        testcase = Testcase(testcase_name)
                        testcase_container.add(testcase)
                        testcase.set_result(testcase_result)

                        # Connect testcase <-> requirement
                        testcase.add_actual_requirement(requirement)
                        requirement.add_actual_testcase(testcase)

                        # Set the requirement intermediate compliance.
                        if partial_coverage_pass:
                            requirement.set_compliance(compliant_string)
                        else:
                            requirement.set_compliance(non_compliant_string)

    except:
        error_msg = ("Error %s occurred with file %s" %(sys.exc_info()[0], partial_coverage_file))
        abort(error_code = 1, msg = error_msg)



def abort(error_code = 0, msg = ""):
    """
    This method will list all available arguments and exit the program.

    Parameters:

    error_code (int)    : exit code set when stopping program.
        
    msg (str)           : string displayed prior to listing arguments.
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
    Check command line arguments and set the run parameter list.

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
        error_msg = ("Error %s occurred with file %s" %(sys.exc_info()[0], config_file_name))
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
    # Validate 
    if run_configuration.get("strictness") > 0:
        if run_configuration.get("requirement_file") == None:
            msg = ("Strictness level %d require a requiement file" %(run_configuration.get("strictness")))
            abort(error_code = 1, msg = msg)

    if run_configuration.get("partial_cov") == None:
        msg = ("Missing argument for parital coverage file")
        abort(error_code = 1, msg = msg)

    if run_configuration.get("spec_cov") == None:
        msg = ("Missing argument for specification coverage file")
        abort(error_code = 1, msg = msg)
    return

def run_housekeeping(run_configuration):
    """
    This method will delete all CSV files in current dir.
    The method will check, an abort, if the --clean argument was
    used in combination with another legal argument.

    Parameters:

    run_configuration (dict) : the configuration setting for this run, 
                            constructed from the command line arguments. 
    """ 
    
    # Abort cleaning if --clean argument was passed along with
    # other legal arguments.
    if (
        run_configuration.get("requirement_file") or 
        run_configuration.get("partial_cov") or 
        run_configuration.get("requiremenet_map_list") or 
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
    # Grab the global variables
    global delimiter
    global requirement_container
    global testcase_container

    requirement_container = Container()
    testcase_container = Container()



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

    build_partial_coverage_list(run_configuration, requirement_container, testcase_container)
    build_requirement_list(run_configuration, requirement_container, testcase_container, delimiter)
    build_mapping_requirement_list(run_configuration, requirement_container, testcase_container, delimiter)
    build_specification_compliance_list(run_configuration, requirement_container, testcase_container, delimiter)

    #==========================================================================
    # Write the results to CSV file
    #==========================================================================
    write_specification_coverage_file(run_configuration, requirement_container, testcase_container, delimiter)




if __name__ == "__main__":
    main()