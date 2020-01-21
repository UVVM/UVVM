# Script which parses the test requirement matrix and the test results in order to 
# create a report where each requirement is reported as Compliant or NC (Non-Compliant).
#
# If one or more of the tests that are mapped to verify a requirement fails, the requirement
# is marked as NC. If a testcase was not executed (i.e. is missing from the test result file),
# the requirement that the testcase verifies will be marked as NC. 

import os
# csv - Comma Separated Values - This format is most common format for import and export for spreadsheets and databases
import csv
# sys - SYSstem specific parameters - sys.argv the list of command line arguments
import sys
# argparse - Argument parser
import argparse
import shutil

# Constants
C_TEST_CASE    = 0
C_TEST_RESULT  = 2
C_REQ_NAME     = 0
C_REQ_TEST_POS = 1
C_COMPLIANCY_NAME = 0
C_COMPLIANCY_STATE = 1

# Default files and local directory location
config_file        = ""
result_list_file   = ""
subrequirem_file   = ""
SubreqExist        = False
requirement_file   = "Requirements.csv"
test_result_file   = "Results.csv"
output_file        = "ReqCompliance.csv"




def getTestResults():
    if os.path.exists( test_result_file ):
        with open(test_result_file,'r') as f:
            reader = csv.reader(f, delimiter=';')
            result_list = list(reader)
            return result_list
        print('Failed to read test result file: ' + test_result_file)
        return 0
    else:
        print( "\nUVVM test result file "+test_result_file+" not found!")
        quit()

def getRequirements():
    if os.path.exists( requirement_file ):
        with open(requirement_file, 'r') as f:
            reader = csv.reader(f, delimiter=';')
            requirement_list = list(reader)
            return requirement_list
        print('Failed to read test requirement file: ' + requirement_file)
        return 0
    else:
        print( "\nRequirement file "+requirement_file+" not found!")
        quit()

def getSubRequirements():
    if os.path.exists( subrequirem_file ):
        with open(subrequirem_file, 'r') as f:
            reader = csv.reader(f, delimiter=';')
            sub_requirement_list = list(reader)
            return sub_requirement_list
        print('Failed to read test requirement file: ' + subrequirem_file)
        return 0
    else:
        print( "\nRequirement file "+subrequirem_file+" not found!")
        quit()

def composeComplianceReport(test_results, test_requirements, test_sub_requirements=0):
    compliance_list = list()

    # Iterate over all requirements
    for i in range (0, len(test_requirements)):
        compliance_list.append([test_requirements[i][C_REQ_NAME], "COMPLIANT"])
        
        # Iterate over all tests per requirement
        for j in range (C_REQ_TEST_POS, len(test_requirements[i])):
            found_test = False
            for test_result in test_results:
                if test_result[C_TEST_CASE].replace(" ","") == test_requirements[i][C_REQ_NAME].replace(" ",""):
                    found_test = True
                    if test_result[C_TEST_RESULT].replace(" ","") != "PASS":
                        compliance_list[i][C_COMPLIANCY_STATE] = "NONCOMPLIANT"
            if not found_test:
                compliance_list[i][C_COMPLIANCY_STATE] = "NONCOMPLIANT"

    # Iterate over all sub-requirements to check main requirements
    if SubreqExist:
        for sub_req_line in test_sub_requirements:
            all_passed = True
            for i in range(1, len(sub_req_line)):   # Skip first entry, which is the main requirement
                sub_req_found = False
                for test_result in test_results:
                    if test_result[C_TEST_CASE].replace(" ","") == sub_req_line[i].replace(" ",""):
                        sub_req_found = True
                        if test_result[C_TEST_RESULT].replace(" ","") != "PASS":
                            print("Sub-requirement was non-compliant. Super-requirement is viewed as non-compliant.")
                            all_passed = False
                            break   # No point in continuing 
                if ((not all_passed) or (not sub_req_found)):
                    if not sub_req_found:
                        print("Sub-requirement ", sub_req_line[i], " was not found. Super-requirement is viewed as non-compliant.")
                    all_passed = False
                    break   # No point in continuing 
            if all_passed:
                compliance_list.append([sub_req_line[0], "COMPLIANT"])
            else:
                compliance_list.append([sub_req_line[0], "NONCOMPLIANT"])

    # Check also if testcase doesn't exist                        
    outfile = open(output_file,"w")
    for x in range (0, len(compliance_list)):
        req_line = compliance_list[x][C_COMPLIANCY_NAME] + ";" + compliance_list[x][C_COMPLIANCY_STATE] + "\n"
        outfile.write(req_line)
    outfile.close()


def reportRequirementCompliancy():
    test_results = getTestResults()
    test_requirements = getRequirements()
    test_sub_requirements = 0
    if SubreqExist:
        test_sub_requirements = getSubRequirements()
    
    if len(test_results) == 0 or len(test_requirements) == 0:
        print("Failed to read CSV files, returning...")
        return

    composeComplianceReport(test_results, test_requirements, test_sub_requirements)





########################################################################################################################
#  Argument parser - List attached files
########################################################################################################################
def getConfigFileName():
    Retval = False
    for i in range(0, (len(sys.argv)-1)):
        if (("-c" == str(sys.argv[i]))or("--config" == str(sys.argv[i]))):
            global config_file
            config_file = sys.argv[i+1]
            print("The config file: " + config_file)
            Retval = True
    return Retval

def getRequirementSourceFileName():
    for i in range(0, (len(sys.argv)-1)):
        if(("-r" == str(sys.argv[i]))or("--requirements" == str(sys.argv[i]))):
            global requirement_file
            requirement_file = sys.argv[i+1]
            print("The requirements file: " + requirement_file)

def getSubrequirementFileName():
    for i in range(0, (len(sys.argv)-1)):
        if(("-s" == str(sys.argv[i]))or("--subrequirements" == str(sys.argv[i]))):
            global subrequirem_file
            subrequirem_file = sys.argv[i+1]
            print("The sub-requirements file: " + subrequirem_file)
            global SubreqExist
            SubreqExist = True

def getResultListFileName():
    Retval = False
    for i in range(0, (len(sys.argv)-1)):
        if(("-l"==str(sys.argv[i]))or("--resultlistfile"==str(sys.argv[i]))):
            global result_list_file
            result_list_file = sys.argv[i+1]
            print("The result list file: " + result_list_file)
            Retval = True
    return Retval

def getTestResultFileName():
    for i in range(0, (len(sys.argv)-1)):
        if (("-f" == str(sys.argv[i]))or("--resultfile" == str(sys.argv[i]))):
            global test_result_file
            test_result_file = sys.argv[i+1]
            print("The test result file: " + test_result_file)
            with open(test_result_file) as tmpFile:
                OkResult = False
                tmpFile.seek(0, 0)
                for resline in tmpFile:
                    if "Requirement coverage completed successfully" in resline:
                        OkResult = True
                tmpFile.close()
                if( False == OkResult ):
                    print("Un-complete test result file!")
                    quit()

def getOutputFileName():
    for i in range(0, (len(sys.argv)-1)):
        if(("-o"==str(sys.argv[i]))or("--output"==str(sys.argv[i]))):
            global output_file
            output_file = sys.argv[i+1]
            print("The output compliance file: " + output_file)


def readListOfResultFiles():
    resFile = open(test_result_file, 'w')
    resFile.close()
    resFile = open(test_result_file, 'a')
    with open(result_list_file) as listFile:
        for line in listFile:
            print(line.rstrip('\n'))
            with open(line.rstrip('\n')) as tmpFile:
                OkResult = False
                tmpFile.seek(0, 0)
                for resline in tmpFile:
                    if "Requirement coverage completed successfully" not in resline:
                        resFile.write(resline)
                    else:
                        OkResult = True
                if( False == OkResult ):
                    print("Un-complete test result file!")
                    quit()
    resFile.write("Requirement coverage completed successfully")
    resFile.close()


########################################################################################################################
#  Decode configuration file
########################################################################################################################
def readConfigFile():
    with open(config_file, 'r') as conFile:
        for argLine in conFile:
            size    = len(argLine)
            if(( -1 != argLine.find("--requirements ")) or (-1 != argLine.find("-r "))):
                i = argLine.find("-r")
                while( ' ' != argLine[i] ):
                    i += 1
                while( ' ' == argLine[i] ):
                    i += 1
                global requirement_file
                requirement_file = argLine[i:size]
                requirement_file = requirement_file.rstrip('\n')
                print( requirement_file )
            elif((-1 != argLine.find("--subrequirements ")) or (-1 != argLine.find("-s "))):
                i = argLine.find("-s")
                while( ' ' != argLine[i] ):
                    i += 1
                while( ' ' == argLine[i] ):
                    i += 1
                global subrequirem_file
                subrequirem_file = argLine[i:size]
                subrequirem_file = subrequirem_file.rstrip('\n')
                global SubreqExist
                SubreqExist = True
                print( subrequirem_file )
            elif((-1 != argLine.find("--resultfile ")) or (-1 != argLine.find("-f "))):
                i = argLine.find("f")
                while( ' ' != argLine[i] ):
                    i += 1
                while( ' ' == argLine[i] ):
                    i += 1
                global test_result_file
                test_result_file = argLine[i:size]
                test_result_file = test_result_file.rstrip('\n')
                print( test_result_file )
            elif((-1 != argLine.find("--resultlistfile ")) or (-1 != argLine.find("-l "))):
                i = argLine.find("l")
                while( ' ' != argLine[i] ):
                    i += 1
                while( ' ' == argLine[i] ):
                    i += 1
                global result_list_file
                result_list_file = argLine[i:size]
                result_list_file = result_list_file.rstrip('\n')
                print( result_list_file )
            elif ((-1 != argLine.find("--output ")) or (-1 != argLine.find("-o "))):
                i = argLine.find("-o")
                while( ' ' != argLine[i] ):
                    i += 1
                while( ' ' == argLine[i] ):
                    i += 1
                global output_file
                output_file = argLine[i:size]
                output_file = output_file.rstrip('\n')
                print( output_file )
            else:
                print("\nIllegal argument -"+argLine[i] )
                quit()

########################################################################################################################
#  Main - Program start
########################################################################################################################
if __name__ == '__main__':
#    print("This is the name of the script: ", sys.argv[0])
#    print("Number of arguments: ", len(sys.argv))
#    print("Running: ", str(sys.argv))
    arguments = argparse.ArgumentParser(description='ReqComplienceTest - arguments.')
    arguments.add_argument( "-c", "--config", metavar='in-file', type=argparse.FileType('r'), help="-c path/file.txt contains 1st. prior. arguments")
    arguments.add_argument( "-r", "--requirements", metavar='in-file', type=argparse.FileType('r'), help="-r path/file.csv contains requirements")
    arguments.add_argument( "-s", "--subrequirements", metavar='in-file', type=argparse.FileType('r'), help="-s path/file.csv contains sub-requirements")
    arguments.add_argument( "-f", "--resultfile", metavar='in-file', type=argparse.FileType('r'), help="-f path/file.csv contains test results")
    arguments.add_argument( "-l", "--resultlistfile", metavar='in-file', type=argparse.FileType('r'), help="-l path/file.txt contains list of results")
    arguments.add_argument( "-o", "--output", metavar='out-file', type=argparse.FileType('w'), help="-o path/file.txt contains compliance result")
    args = arguments.parse_args()

    if( False == getConfigFileName() ):
        getRequirementSourceFileName()
        getSubrequirementFileName()
        if( False == getResultListFileName() ):
            getTestResultFileName()
        else:
            readListOfResultFiles()
        getOutputFileName()
    else:
        readConfigFile()
        if( "" != result_list_file ):
            readListOfResultFiles()

    reportRequirementCompliancy()
    print("\nFinished! The output compliance file : "+output_file)
