import os
# csv - Comma Separated Values - This format is most common format for import and export for spreadsheets and databases
import csv
# sys - SYSstem specific parameters - sys.argv the list of command line arguments
import sys


# Default delimiter - will be updated from partial coverage file
delimiter = ","

# Predefined arguments and run parameters
def_args = [{"short" : "-r", "long" : "--requirement_list",     "type" : "in-file",   "help" : "-r              Path/requirements.csv contains requirements", "default" : "NA"},
            {"short" : "-i", "long" : "--input_cov",            "type" : "in-file",   "help" : "-i              Path/testcase_result.csv partial coverage file from VHDL simulations", "default" : "NA"},
            {"short" : "-m", "long" : "--requirement_map_list", "type" : "in-file",   "help" : "-m              Optional: path/subrequirements.csv requirement map file", "default" : "NA"},
            {"short" : "-s", "long" : "--spec_cov",             "type" : "out-file",  "help" : "-s              Path/spec_cov.csv specification coverage file", "default" : "NA"},
            {"short" : "",   "long" : "--strictness",           "type" : "setting",   "help" : "--strictness N  Optional: will set specification coverage to strictness (1-2) (0=default)", "default" : "X"},
            {"short" : "",   "long" : "--config",               "type" : "config",    "help" : "--config        Optional: configuration file with all arguments", "default" : "NA"},
            {"short" : "",   "long" : "--clean",                "type" : "household", "help" : "--clean         Will clean any/all partial coverage file(s)", "default" : "NA"},
            {"short" : "-h", "long" : "--help",                 "type" : "help",      "help" : "--help          This help screen", "default" : "NA"} 
            ]

# Default, non-configured run
run_parameter_default = {"requirement_list" : None, "input_cov" : None, "requirement_map_list" : None, "spec_cov" : None, "clean" : False, "strictness" : 'X', "config" : None}



requirement_item_struct = { 
    "name"          : None,     # string
    "description"   : None,     # string
    "testcase"      : [],       # list of testcase names
    "result"        : None,     # string (PASS / FAIL)
    "sub_requirement" : []      # list of requirement_items
    }

testcase_item_struct = {    
    "name"          : None,     # string (name of testcase)
    "requirement"   : None,     # string (name of requirement)
    "result"        : None      # string (PASS / FAIL)
    }

partial_coverage_item_struct = {
    "requirement"   : None,     # requirement_item_struct
    "compliance"    : None      # string (COMPLIANT / NON COMPLIANT)
}

requirement_list                = []    # List of requirement_item
partial_coverage_list           = []    # List of testcase_item, final entry is SUMMARY: PASS/FAIL
specification_compliance_list   = []    # List of partial_coverage_item
mapping_requirement_list        = []    # List of requirement_item


pass_string = "PASS"
fail_string = "FAIL"
compliant_string = "COMPLIANT"
non_compliant_string = "NON COMPLIANT"
not_tested_compliant_string = "NA"



def write_specification_coverage_file(run_configuration, specification_compliance_list, mapping_requirement_list):
    """
    This method will write all the results to the specification_coverage CSV file.

    Parameters:
    
    run_configuration (dict) : selected configuration for this run.
    
    specification_compliance_list (list) :  a list of partial_coverage_item_struct strutcture items which 
                            are set to COMPLIANT or NON COMPLIANT.

    mapping_requirement_list (list) : a list of mapping_requirement_item_struct 
                            strutcture items which are constructed from the requirement mapping file.
    """

    # Get the global defined delimiter setting for CSV files.
    global delimiter

    #==========================================================================
    # Write the results to CSV
    #==========================================================================

    try:
        with open(run_configuration.get("spec_cov"), mode='w', newline='') as spec_cov_file:
            csv_writer = csv.writer(spec_cov_file, delimiter=delimiter)

            csv_writer.writerow(["Requirement results :", ])
            for spec_cov_item in specification_compliance_list:
                requirement = spec_cov_item.get("requirement")
                requirement_name = requirement.get("name")
                compliance  = spec_cov_item.get("compliance")
                csv_writer.writerow([requirement_name, compliance])


            if mapping_requirement_list:
                # Add a seperator row
                csv_writer.writerow([])
                csv_writer.writerow(["Mapped requirement results :", ])

                for super_requirement in mapping_requirement_list:
                    requirement = super_requirement.get("name")
                    compliance = super_requirement.get("result")
                    csv_writer.writerow([requirement, compliance])

    except:
        error_msg = ("Error %s occurred with file %s" %(sys.exc_info()[0], run_configuration.get("spec_cov")))
        abort(error_code = 1, msg = error_msg)


    #==========================================================================
    # Present a summary to terminal
    #==========================================================================

    # Summary counters
    num_failing_requirements = 0
    num_passing_requirements = 0
    num_untested_requirements = 0
    num_failing_sub_requirements = 0

    passing_requirement_list        = []
    failing_requirement_list        = []
    failing_sub_requirement_list    = []
    untested_requirement_list       = []

    for part_cov_requirement in specification_compliance_list:

        if part_cov_requirement.get("compliance") == non_compliant_string:
            num_failing_requirements += 1
            failing_requirement_list.append(part_cov_requirement.get("requirement"))

        elif part_cov_requirement.get("compliance") == compliant_string:
            num_passing_requirements += 1
            passing_requirement_list.append(part_cov_requirement.get("requirement"))

        elif part_cov_requirement.get("compliance") == not_tested_compliant_string:
            num_untested_requirements += 1
            untested_requirement_list.append(part_cov_requirement.get("requirement"))
        else:
            print("WARNING! Unknown result for %s." %(part_cov_requirement.get("requirement")))


    for requirement in mapping_requirement_list:
        if requirement.get(pass_string) == fail_string:
            num_failing_requirements += 1

            for sub_requirement in requirement.get("sub_requirement"):
                if sub_requirement.get(pass_string) == fail_string:
                    num_failing_sub_requirements += 1
                    failing_sub_requirement_list.append(sub_requirement.get("requirement"))


    print("SUMMARY:")
    print("----------------------------------------------")
    print("Number of passing requirements    : %d" %(num_passing_requirements))
    print("Number of failing requirements    : %d" %(num_failing_requirements))
    print("Number of failing sub-requirement : %s" %(num_failing_sub_requirements))
    print("Number of untested requirements   : %d" %(num_untested_requirements))
    print("\n")

    if failing_requirement_list:
        print("Failing requirement(s) :")
        for item in failing_requirement_list:
            print("%s : %s" %(item.get("name"), item.get("testcase")))
        print("\n")

    if failing_sub_requirement_list:
        print("Failing sub-requirement(s) :")
        for item in failing_sub_requirement_list:
            print("%s : %s" %(item.get("name"), item.get("testcase")))
        print("\n")

    if untested_requirement_list:
        print("Untested requirement(s) :")
        for item in untested_requirement_list:
            print("%s : %s" %(item.get("name"), item.get("testcase")))
        print("\n")





def build_mapping_requirement_list(run_configuration, partial_coverage_list, mapping_requirement_list):
    """
    Constriuct the mapping_reqiurement_list by reading the requirement mapping file and add
    requirement_items with a list of sub_requirements (requirement_items).

    Parameters:

    partial_coverage_list (list) : list of testcase_item, final entry is SUMMARY: PASS/FAIL

    mapping_requirement_list (list) : list of requirement_item 
    """
    # Get the global defined delimiter setting for CSV files.
    global delimiter

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
                        super_requirement = requirement_item_struct.copy()
                        super_requirement["name"] = cell_item.strip()  
                        sub_requirement_list = []  
                    # Rest of the cells are sub-requirements
                    else:
                        sub_requirement = requirement_item_struct.copy()
                        sub_requirement["name"] = cell_item.strip()
                        sub_requirement_list.append(sub_requirement)
                
                # Add sub-requirement list to super_requirement_item
                super_requirement["sub_requirement"] = sub_requirement_list
                # Add the mapping_requirement_item to the mapping_requirement_list
                mapping_requirement_list.append(super_requirement)
            
    except:
        error_msg = ("Error %s occurred with file %s" %(sys.exc_info()[0], requirement_map_file))
        abort(error_code = 1, msg = error_msg)


    #==========================================================================
    # Set result for the super-requirements based on sub-requirement result
    #==========================================================================

    # Check all super-requirements
    for super_requirement in mapping_requirement_list:

        super_requirement_passed    = True
        num_sub_requirements        = len(super_requirement.get("sub_requirement"))
        num_sub_requirements_found  = 0

        # Check all sub-requirements in the super-requirement
        for sub_requirement in super_requirement.get("sub_requirement"):

            # Check with partial_coverage_list
            for testcase_item in partial_coverage_list:

                # Exract the requirement names for comparing
                testcase_requirement_name = testcase_item.get("requirement")
                sub_requirement_name = sub_requirement.get("name")

                # If both are defined, check
                if testcase_requirement_name and sub_requirement_name:
                    # Check if same requirement
                    if testcase_requirement_name.upper() == sub_requirement_name.upper():

                        # Update counter
                        num_sub_requirements_found += 1
                        # Update the sub_requirement PASS/FAIL status
                        sub_requirement["result"] = testcase_item.get("result")

                        # Update boolean for failing super-requirement/mapping requirement.
                        if testcase_item.get("result") == fail_string:
                            super_requirement_passed = False
                      

        # If ALL sub-requirements are PASSed and all sub-requirements are found
        if super_requirement_passed and (num_sub_requirements == num_sub_requirements_found):
            super_requirement["result"] = pass_string
        # Not all sub-requirement are PASSed and/or sub-requirements missing
        else:
            super_requirement["result"] = fail_string




def build_specification_compliance_list(run_configuration, requirement_list, partial_coverage_list, specification_compliance_list):
    """
    This method will build the specification_compliance_list, i.e. create a list 
    with all requirements marked as COMPLIANT / NON COMPLIANT based on
    partial_coverage_list items and strictness level.

    Parameters:
        
    run_configuration (dict) : selected configuration for this run.

    requirement_list (list) : a list of requirement_item_struct 
                            strutcture items which are constructed 
                            from the requirement file.

    partial_coverage_list (list) : a list of requirement_item_struct 
                            strutcture items which are constructed 
                            from the partial_coverage file.

    specification_compliance_list (list) : a list of requirement_item_struct 
                            strutcture items which are set to COMPLIANT or
                            NON COMPLIANT in this method.
    """
    # Get the global defined delimiter setting for CSV files.
    global delimiter

    # Check if requirement file has been specified
    if not(run_configuration.get("requirement_list")):
        return

    # Get the configured strictness level
    strictness = run_configuration.get("strictness")


    #==========================================================================
    # Build the specification_compliance_list with strictness level
    #==========================================================================


    #==========================================================================
    # Strictness = 0 : testcase can be run with any requirement
    #==========================================================================
    if strictness == '0':

        # Check all requirements
        for requirement in requirement_list:
            print("Checking : %s" %(requirement.get("name")))

            requirement_was_found_in_partial_coverage_list = False
            num_testcase_checked = 0
            num_testcase_to_check = len(requirement.get("testcase"))

            testcase_pass = True
            summary_line_ok = False

            # Get testcase names defined for this requirement
            for testcase_name in requirement.get("testcase"):

                # Check with all logged parial coverage testcase results,
                # ignore which reqiuirement has the testcase.
                for partial_testcase in partial_coverage_list:
                    partial_testcase_name = partial_testcase.get("name")

                    # testcase from requirement match testcase from partial_coverage_list
                    if partial_testcase_name and testcase_name:
                        if partial_testcase_name.upper() == testcase_name.upper():
                            num_testcase_checked += 1
                            requirement_was_found_in_partial_coverage_list = True

                            if partial_testcase.get("result") == fail_string:
                                testcase_pass = False

            if num_testcase_checked < num_testcase_to_check:
                testcase_pass = False

            # Check if SUMMARY PASS footer is in CSV file - should be on the last line, 
            # i.e. get the final dictionary in the parial_coverage_list of dictionaries
            # and check the "SUMMARY" keyword.
            summary_seek_dict = partial_coverage_list[len(partial_coverage_list) - 1]
            if "SUMMARY" in summary_seek_dict:
                if summary_seek_dict.get("SUMMARY").strip()  == pass_string:
                    summary_line_ok = True

            # Create a partial_coverage_item and save to specification_compliance_list
            partial_coverage_item = partial_coverage_item_struct.copy()
            partial_coverage_item["requirement"] = requirement

            if testcase_pass and summary_line_ok:
                partial_coverage_item["compliance"] = compliant_string
            else:
                if requirement_was_found_in_partial_coverage_list == False:
                    print("Not found : %s" %(requirement.get("name")))
                    partial_coverage_item["compliance"] = not_tested_compliant_string
                else:
                    partial_coverage_item["compliance"] = non_compliant_string

            specification_compliance_list.append(partial_coverage_item)



    #==========================================================================
    # Strictness = 1 : testcase has to be run with specified requirement
    #==========================================================================
    elif strictness == '1':

        # Check all requirements
        for requirement in requirement_list:
            requirement_name = requirement.get("name")

            requirement_fail = False
            num_testcase_checked = 0
            num_testcase_to_check = len(requirement.get("testcase"))

            testcase_has_been_run_in_requirement = False

            testcase_pass = True
            summary_line_ok = False

            # Get testcase names defined for this requirement
            for testcase_name in requirement.get("testcase"):

                # Check with all logged parial coverage testcase results,
                # ignore which reqiuirement has the testcase.
                for partial_testcase in partial_coverage_list:
                    partial_testcase_name = partial_testcase.get("name")

                    # testcase from requirement match testcase from partial_coverage_list
                    if partial_testcase_name and testcase_name:
                        if partial_testcase_name.upper() == testcase_name.upper():
                            num_testcase_checked += 1
                            
                            if partial_testcase.get("result") == fail_string:
                                testcase_pass = False

                            # Strict checking 1: testcase and requirement has matched
                            partial_testcase_requirement_name = partial_testcase.get("requirement")
                            if partial_testcase_requirement_name.upper() == requirement_name.upper():
                                testcase_has_been_run_in_requirement = True

            if num_testcase_checked < num_testcase_to_check:
                testcase_pass = False

            # Check if SUMMARY PASS footer is in CSV file - should be on the last line, 
            # i.e. get the final dictionary in the parial_coverage_list of dictionaries
            # and check the "SUMMARY" keyword.
            summary_seek_dict = partial_coverage_list[len(partial_coverage_list) - 1]
            if "SUMMARY" in summary_seek_dict:
                if summary_seek_dict.get("SUMMARY").strip()  == pass_string:
                    summary_line_ok = True

            # Create a partial_coverage_item and save to specification_compliance_list
            partial_coverage_item = partial_coverage_item_struct.copy()
            partial_coverage_item["requirement"] = requirement

            if testcase_pass and summary_line_ok and testcase_has_been_run_in_requirement:
                partial_coverage_item["compliance"] = compliant_string
            else:
                partial_coverage_item["compliance"] = non_compliant_string

            specification_compliance_list.append(partial_coverage_item)


    #==========================================================================
    # Strictness = 2 : testcase should only be run with specified requirement
    #==========================================================================
    elif strictness == '2':
        # Check all requirements
        for requirement in requirement_list:
            requirement_name = requirement.get("name")

            requirement_fail = False
            num_testcase_checked = 0
            num_testcase_to_check = len(requirement.get("testcase"))

            testcase_has_been_run_in_other_requirement = False

            testcase_pass = True
            summary_line_ok = False

            # Get testcase names defined for this requirement
            for testcase_name in requirement.get("testcase"):

                # Check with all logged parial coverage testcase results,
                # ignore which reqiuirement has the testcase.
                for partial_testcase in partial_coverage_list:
                    partial_testcase_name = partial_testcase.get("name")

                    # testcase from requirement match testcase from partial_coverage_list
                    if partial_testcase_name and testcase_name:
                        if partial_testcase_name.upper() == testcase_name.upper():

                            if partial_testcase.get("result") == fail_string:
                                testcase_pass = False

                            # Strict checking 2: testcase only match with specified requirement
                            partial_testcase_requirement_name = partial_testcase.get("requirement")
                            if partial_testcase_requirement_name.upper() != requirement_name.upper():
                                testcase_has_been_run_in_other_requirement = True
                            else:
                                num_testcase_checked += 1


            if num_testcase_checked < num_testcase_to_check:
                testcase_pass = False

            # Check if SUMMARY PASS footer is in CSV file - should be on the last line, 
            # i.e. get the final dictionary in the parial_coverage_list of dictionaries
            # and check the "SUMMARY" keyword.
            summary_seek_dict = partial_coverage_list[len(partial_coverage_list) - 1]
            if "SUMMARY" in summary_seek_dict:
                if summary_seek_dict.get("SUMMARY").strip()  == pass_string:
                    summary_line_ok = True

            # Create a partial_coverage_item and save to specification_compliance_list
            partial_coverage_item = partial_coverage_item_struct.copy()
            partial_coverage_item["requirement"] = requirement

            if testcase_pass and summary_line_ok and not(testcase_has_been_run_in_other_requirement):
                partial_coverage_item["compliance"] = compliant_string
            else:
                partial_coverage_item["compliance"] = non_compliant_string

            specification_compliance_list.append(partial_coverage_item)

    else:
        msg = ("strictness level %d outside limits 0-2" %(strictness))
        abort(error_code = 1, msg = msg)




def build_partial_coverage_list(run_configuration, partial_coverage_list):
    """
    This method will read the delimiter written by the spec_cov_pkg.vhd to 
    the partial_coverage CSV files, and updated the global delimiter.
    The method will add requirement_item_struct strutcture items, which are 
    constructed from the partial_coverage file, to the partial_coverage_list.

    Parameters:

    run_configuration (dict) : selected configuration for this run.

    partial_coverage_list (list) : a list of requirement_item_struct 
                            strutcture items which are constructed 
                            from the partial_coverage file.
    """
    # Get the global defined delimiter setting for CSV files.
    global delimiter

    # Get the partial coverage file - note: can be a txt file with
    # a list of partial coverage files.
    partial_coverage_file_name = run_configuration.get("input_cov")
    if not(partial_coverage_file_name):
        msg = "partial coverage file missing"
        abort(msg = msg)

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
    # Start reading CSVs
    #==========================================================================
    try:
        for partial_coverage_file in partial_coverage_files:
            with open(partial_coverage_file) as csv_file:
                csv_reader = csv.reader(csv_file, delimiter=delimiter)

                for idx, row in enumerate(csv_reader):
                    # Skip partial_coveage_file header info on the 4 first lines.
                    if (idx > 3) and (row[0].upper() != "SUMMARY"):
                        testcase_item  = testcase_item_struct.copy()
                        testcase_item["requirement"]  = row[0]
                        testcase_item["name"]         = row[1]
                        testcase_item["result"]       = row[2]

                        partial_coverage_list.append(testcase_item)

                    # Get the testcase summary
                    elif (idx > 3) and (row[0].upper() == "SUMMARY"):
                        partial_coverage_list.append({row[0] : row[2]})
    except:
        error_msg = ("Error %s occurred with file %s" %(sys.exc_info()[0], partial_coverage_file))
        abort(error_code = 1, msg = error_msg)
        






def build_requirement_list(run_configuration, requirement_list):
    """
    Contructs the requirement_list with requirement_items.

    Parameters:

    requirement_list (list) : list with requirement_items
    """
    # Get the global defined delimiter setting for CSV files.
    global delimiter

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
                requirement_item = requirement_item_struct.copy()
                testcase_list    = []

                for idx, cell in enumerate(row):
                    if idx == 0:
                        requirement_item["name"] = row[idx]
                    elif idx == 1:
                        requirement_item["description"] = row[idx]
                    elif idx >= 2:
                        testcase_name = row[idx].strip()
                        testcase_list.append(testcase_name)

                # Save the testcase_list
                requirement_item["testcase"] = testcase_list
                # Save the requirement in the requirement_list
                requirement_list.append(requirement_item)
    except:
        error_msg = ("Error %s occurred with file %s" %(sys.exc_info()[0], req_file))
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
        run_configuration.get("input_cov") or 
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
    global requirement_list
    global partial_coverage_list
    global specification_compliance_list
    global mapping_requirement_list

    #==========================================================================
    # Verify that correct Python version is used
    #==========================================================================

    # Check Python version >= 3.0
    version_check()
    

    #==========================================================================
    # Parse the command line arguments and set the configuration
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
    print("--------------------------------")
    for key, value in run_configuration.items():
        print("%s : %s" %(key, value))
    print("\n")


    #==========================================================================
    # Build structure and process results
    #
    #   Note that partial_coverage files will have to be read first so
    #   we can extract the CSV delimiter.
    #==========================================================================

    build_partial_coverage_list(run_configuration, partial_coverage_list)

    build_requirement_list(run_configuration, requirement_list)

    build_mapping_requirement_list(run_configuration, partial_coverage_list, mapping_requirement_list)
    
    build_specification_compliance_list(run_configuration, requirement_list, partial_coverage_list, specification_compliance_list)


    #==========================================================================
    # Write the results to CSV file
    #==========================================================================
    write_specification_coverage_file(run_configuration, specification_compliance_list, mapping_requirement_list)




if __name__ == "__main__":
    main()