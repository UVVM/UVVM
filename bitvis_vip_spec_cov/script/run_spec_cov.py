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




requirement_item_struct = {"requirement" : "", "description" : "", "testcase" : [], "pass" : False, "note" : ""}
# requirement_list: requirement_item_struct (requirements and testcases listed in requirement_list_file)
requirement_list = []  # From the requirement specification document, inputs to VHDL simulations and post-prosessing.
# partial_coverage_list: requirement_item_struct (requirements w/testcases listed in partial_cov_files)
partial_coverage_list = []  # From the output of VHDL simulations, input to post-prosessing.


partial_coverage_item_struct = {"requirement" : "", "compliant" : ""}
# specification_compliance_list: specification coverage list of partial_coverage_item_structs
specification_compliance_list = [] # Buildt from requirement_list, partial_coverage_list and strictness.


mapping_requirement_item_struct = {"requirement" : "", "sub_requirement" : []}
# mapping_requirement_list: mapping_requirement_item_structs (super-requirement and a list of its sub-requirements)
mapping_requirement_list = []





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

    #
    # Write the results to CSV
    #
    try:
        with open(run_configuration.get("spec_cov"), mode='w', newline='') as spec_cov_file:
            csv_writer = csv.writer(spec_cov_file, delimiter=delimiter)

            csv_writer.writerow(["Requirement results :", ])
            for spec_cov_item in specification_compliance_list:
                requirement = spec_cov_item.get("requirement")
                compliance  = spec_cov_item.get("compliant")
                csv_writer.writerow([requirement, compliance])


            if mapping_requirement_list:
                # Add a seperator row
                csv_writer.writerow([])
                csv_writer.writerow(["Mapped requirement results :", ])

                for super_requirement in mapping_requirement_list:
                    requirement = super_requirement.get("requirement")
                    compliance = super_requirement.get("pass")
                    csv_writer.writerow([requirement, compliance])

    except:
        error_msg = ("Error %s occurred with file %s" %(sys.exc_info()[0], run_configuration.get("spec_cov")))
        abort(error_code = 1, msg = error_msg)


    #
    # Present a summary to terminal
    #

    # Summary counters
    num_failing_requirements = 0
    num_passing_requirements = 0

    failing_requirement_list        = []
    failing_sub_requirement_list    = []

    for requirement in specification_compliance_list:
        if not(requirement.get("compliant") == "COMPLIANT"):
            num_failing_requirements += 1
            failing_requirement_list.append(requirement.get("requirement"))
        else:
            num_passing_requirements += 1

    for requirement in mapping_requirement_list:
        if requirement.get("pass") == "FAIL":
            num_failing_requirements += 1

            for sub_requirement in requirement.get("sub_requirement"):
                if sub_requirement.get("pass") == "FAIL":
                    failing_sub_requirement_list.append(sub_requirement.get("requirement"))

        else:
            num_passing_requirements += 1

    print("SUMMARY:")
    print("----------------------------------------------")
    print("Number of passing requirements : %d" %(num_passing_requirements))
    print("Number of failing requirements : %d" %(num_failing_requirements))

    if failing_requirement_list:
        print("Failing requirement(s) : %s" %(failing_requirement_list))
    if failing_sub_requirement_list:
        print("Failing sub-requirement(s) : %s" %(failing_sub_requirement_list))






def build_mapping_requirement_list(run_configuration, mapping_requirement_list, partial_coverage_list):
    """
    This method will read the requirement mapping file and verify with the
    partial coverage file.
    Results are written to the mapping_requirement_list.

    Parameters:

    run_configuration (dict) : selected configuration for this run.

    mapping_requirement_list (list) : a list of mapping_requirement_item_struct 
                            strutcture items which are constructed from the requirement mapping file.

    parital_coverage_list (list) : a list of requirement_item_struct strutcture items which are 
                            constructed from the partial_coverage file.
    """
    # Get the global defined delimiter setting for CSV files.
    global delimiter

    requirement_map_file = run_configuration.get("requirement_map_list")

    # Skip if not specified in the run_configuration
    if not(requirement_map_file):
        return

    # Read the requirement mapping list
    try:
        with open(requirement_map_file) as csv_map_file:
            csv_reader = csv.reader(csv_map_file, delimiter=delimiter)

            for row in csv_reader:     
                mapping_requirement_item = mapping_requirement_item_struct.copy()
                # A new sub-requirement list for each requirement 
                sub_requirement_list = []
                
                for idx, cell_item in enumerate(row):
                    # Firs cell is the super-requirement
                    if idx == 0:
                        mapping_requirement_item["requirement"] = cell_item
                    # Rest of the cells are sub-requirements
                    else:
                        sub_requirement = requirement_item_struct.copy()
                        sub_requirement["requirement"] = cell_item.strip()
                        sub_requirement_list.append(sub_requirement)
                
                # Add sub-requirement list to mapping_requirement_item
                mapping_requirement_item["sub_requirement"] = sub_requirement_list

                # Add the mapping_requirement_item to the mapping_requirement_list
                mapping_requirement_list.append(mapping_requirement_item)
            
    except:
        error_msg = ("Error %s occurred with file %s" %(sys.exc_info()[0], requirement_map_file))
        abort(error_code = 1, msg = error_msg)


    # Check all super-requirements
    for mapping_requirement in mapping_requirement_list:

        mapped_requirement_passed   = True
        num_sub_requirements        = len(mapping_requirement.get("sub_requirement"))
        num_sub_requirements_found  = 0

        # Check all sub-requirements in the super-requirement
        for sub_requirement in mapping_requirement.get("sub_requirement"):

            # Check with partial_coverage_list
            for partial_requirement in partial_coverage_list:

                # Exract the requirement names for comparing
                partial_requirement_name = partial_requirement.get("requirement")
                sub_requirement_name = sub_requirement.get("requirement")

                # If both are defined, check
                if partial_requirement_name and sub_requirement_name:
                    # Check if same requirement
                    if partial_requirement_name.upper() == sub_requirement_name.upper():
                        # Update counter
                        num_sub_requirements_found += 1
                        # Update the sub_requirement PASS/FAIL status
                        sub_requirement["pass"] = partial_requirement.get("pass")

                        # Update boolean for failing super-requirement/mapping requirement.
                        if partial_requirement.get("pass") == "FAIL":
                            mapped_requirement_passed = False
                      

        #
        # Set the super-requirement to PASS/COMPLIANT or FAIL/NON COMPLIANT
        # 
        # If ALL sub-requirements are PASSed and all sub-requirements are found
        if mapped_requirement_passed and (num_sub_requirements == num_sub_requirements_found):
            mapping_requirement["pass"] = "PASS"
            mapping_requirement["compliant"] = "COMPLIANT"
        # Not all sub-requirement are PASSed or all/some sub-requirements not found
        else:
            mapping_requirement["pass"] = "FAIL"
            mapping_requirement["compliant"] = "NON COMPLIANT"







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

    # Check all requirements
    for requirement in requirement_list:
        # Set default parameters
        compliant = True
        requirement_found = False
        requirement_checked_in_specified_testcase = False
        requirement_checked_in_unspecified_testcase = False
        summary_line_ok = False

        requirement_name = requirement.get("requirement")
        requirement_testcase = requirement.get("testcase")

        for partial_coverage in partial_coverage_list:
            partial_coverage_requirement = partial_coverage.get("requirement")
            partial_coverage_testcase    = partial_coverage.get("testcase")

            # Skip None entries
            if requirement_name and partial_coverage_requirement:

                # Requirement from requirement list found in partial coverage list
                if requirement_name.upper() == partial_coverage_requirement.upper():
                    requirement_found = True
                    # Set non compliant if testcase has FAILed
                    if partial_coverage.get("pass") == "FAIL":
                        compliant = False

                    # Verify if requirement has been checked in specified testcase.
                    # Convert to uppercase and remove any trailing whitespaces.
                    if requirement_testcase and partial_coverage_testcase:
                        if requirement_testcase.upper().strip() == partial_coverage_testcase.upper().strip():
                            requirement_checked_in_specified_testcase = True
                    # Testcase names do not match
                    else:
                        requirement_checked_in_unspecified_testcase = True

        # Check if SUMMARY PASS footer is in CSV file - should be on the last line, 
        # i.e. get the final dictionary in the parial_coverage_list of dictionaries
        # and check the "SUMMARY" keyword.
        summary_seek_dict = partial_coverage_list[len(partial_coverage_list) - 1]
        if "SUMMARY" in summary_seek_dict:
            if summary_seek_dict.get("SUMMARY").strip()  == "PASS":
                summary_line_ok = True

        # Create a parial coverage item
        partial_cov_item = partial_coverage_item_struct.copy()
        partial_cov_item["requirement"] = requirement.get("requirement")
        #
        # Create a partial_coverage_item (scructure) with default NON COMPLIANT.
        # Change from NON COMPLIANT to COMPLIANT if requirement is found 
        # and the testcase has PASSed.
        #
        # Set partial_coverage_item compliance default to NON COMPLIANT
        partial_cov_item["compliant"] = "NON COMPLIANT" # default


        # No strictness: any testcase is OK
        if strictness == '0':
            if summary_line_ok and compliant:
                if requirement_found:
                    partial_cov_item["compliant"] = "COMPLIANT"
                    # Save requirement_item to specification_compliance_list
                    specification_compliance_list.append(partial_cov_item)
            else:
                # Save requirement_item to specification_compliance_list
                specification_compliance_list.append(partial_cov_item)

        # Low strictness: at least checked in specified testcase
        elif strictness == '1':
            if (summary_line_ok and compliant and requirement_found):
                if requirement_found and requirement_checked_in_specified_testcase:
                    partial_cov_item["compliant"] = "COMPLIANT"
                    # Save requirement_item to specification_compliance_list
                    specification_compliance_list.append(partial_cov_item)
            else:
                # Save requirement_item to specification_compliance_list
                specification_compliance_list.append(partial_cov_item)

        elif strictness == '2':
            if (summary_line_ok and requirement_found and compliant and 
                requirement_checked_in_specified_testcase and not(requirement_checked_in_unspecified_testcase)):
                partial_cov_item["compliant"] = "COMPLIANT"
            # Save requirement_item to specification_compliance_list
            specification_compliance_list.append(partial_cov_item)

        else:
            pass





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

    # Create a list of partial_cov_files to read
    partial_coverage_files = []
    try:
        # Check if partial_cov_file is a TXT file, i.e. a list of files.
        if ".txt" in partial_coverage_file_name.lower():
            with open(partial_coverage_file_name) as partial_coverage_file:
                partial_coverage_files.append(partial_coverage_file.readline())
        # Partial_cov_file is a CSV file - add it as a single item to the list.
        else:
            partial_coverage_files.append(partial_coverage_file_name)
    except:
        error_msg = ("Error %s occurred with file %s" %(sys.exc_info()[0], map_partial_coverage_file_namename))
        abort(error_code = 1, msg = error_msg)


    # Get the delimiter from the partial_cov file
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

    # Start reading CSVs
    try:
        # Read from all s
        for partial_coverage_file in partial_coverage_files:
            with open(partial_coverage_file) as csv_file:
                csv_reader = csv.reader(csv_file, delimiter=delimiter)
                for idx, row in enumerate(csv_reader):

                    # Skip partial_coveage_file header info on the 4 first lines.
                    if (idx > 3) and (row[0].upper() != "SUMMARY"):
                        requirement_item = requirement_item_struct.copy()
                        requirement_item["requirement"] = row[0]
                        requirement_item["testcase"]    = row[1]
                        requirement_item["pass"]        = row[2]
                        partial_coverage_list.append(requirement_item)

                    # Get the testcase summary
                    elif (idx > 3) and (row[0].upper() == "SUMMARY"):
                        partial_coverage_list.append({row[0] : row[2]})
    except:
        error_msg = ("Error %s occurred with file %s" %(sys.exc_info()[0], partial_coverage_file))
        abort(error_code = 1, msg = error_msg)
        





def build_requirement_list(run_configuration, requirement_list):
    """
    This method will read the requirement file and save each
    requirement, description and corresponding testcase in 
    the requirement_list.

    Parameters:

    run_configuration (dict) : selected configuration for this run.

    requirement_list (list) : a list of requirement_item_struct strutcture 
                            items which are constructed from the
                            requirement file.
    """
    # Get the global defined delimiter setting for CSV files.
    global delimiter

    # Get the requirement list file
    req_file = run_configuration.get("requirement_list")

    # Check if requirement file has been specified
    if not(req_file):
        return

    # Read the requirements and save to requirement_list
    try:    
        with open(req_file) as req_file:
            csv_reader = csv.reader(req_file, delimiter=delimiter)
            for row in csv_reader:
                requirement_item = requirement_item_struct.copy()
                for idx, cell in enumerate(row):
                    if idx == 0:
                        requirement_item["requirement"] = row[idx]
                    elif idx == 1:
                        requirement_item["description"] = row[idx]
                    elif idx == 2:
                        requirement_item["testcase"]    = row[idx]
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

    # Check all arguments
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
                
            print("Successfully removed %d CSV files." %(num_files_removed))
            sys.exit(0)

        except:
            msg = ("Error %s occurred" %(sys.exc_info()[0]))
            exit_code = 1

        # Done, exit
        abort(error_code = exit_code, msg = msg)

        


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

    # Check Python version >= 3.0
    version_check()
    
    # Parse arguments and get run selection
    run_configuration = arg_parser(sys.argv[1:])

    # If --clean parameter is applied
    if run_configuration.get("clean"):
        run_housekeeping(run_configuration)

    # If --config parameter is applied
    if run_configuration.get("config"):
        run_configuration = set_run_config_from_file(run_configuration)

    # Start by reading from the partial coverage file - need to sample the CSV delimiter.
    build_partial_coverage_list(run_configuration, partial_coverage_list)

    # Read the requirement file and save in the requirement_list. 
    # Note that the method will return immediately if no requirement file is 
    # passed on as an argument to the script.
    build_requirement_list(run_configuration, requirement_list)

    # Read the requirement mapping file and extract the sub-requirements, check the results from the
    # partial_coverage_list and mark the super-requirements as PASS/COMPLIANT or FAIL/NON COMPLIANT
    # based on the PASS/FAIL setting of the requirements in the partial_coverage_list.
    build_mapping_requirement_list(run_configuration, mapping_requirement_list, partial_coverage_list)

    # Read each requirement from the requirement_list, check with the testcase(s) PASS/FAIL in the 
    # partial_coverage_list, and write to the specification_compliance_list.
    build_specification_compliance_list(run_configuration, requirement_list, partial_coverage_list, specification_compliance_list)

    # Write results in the specification_compliance_list and mapping_requirement_list to the summarizing specification CSV file
    write_specification_coverage_file(run_configuration, specification_compliance_list, mapping_requirement_list)




if __name__ == "__main__":
    main()