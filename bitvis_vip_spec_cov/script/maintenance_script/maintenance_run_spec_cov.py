#===========================|======================|==================|===========|=======================|========================================================|===============|=============================|=============
# REQ FILE                  | REQ                  | TC               | PC FILE   | MAP FILE	             | DESCRIPTION	                                          | SUB REQ	      | CONFIG	                    | SPEC COV
#===========================|======================|==================|===========|=======================|========================================================|===============|=============================|=============
# req_file.csv	            | REQ_1	               | TC_1             | pc_1.csv  |                       | Testing initialize_req_cov() with no requirement file. |               |                             | sc_1.csv
#---------------------------|----------------------|------------------|-----------------------------------|--------------------------------------------------------|---------------|-----------------------------|-------------
# req_file.csv	            | REQ_2	               | TC_2             | pc_2.csv  |                       | Testing initialize_req_cov() with a requirement file.  |               |                             | sc_2.csv
#---------------------------|----------------------|------------------|-----------------------------------|--------------------------------------------------------|---------------|-----------------------------|-------------
# req_file.csv	            | REQ_3 [REQ_10]       | TC_3 TC_50 TC_1  | pc_3.csv  |                       | Testing log_req_cov() with default testcase, unknown   |               |                             | sc_3.csv
#                           |                      |                  |           |                       |  testcase and unknown requirement label.			   |               |                             |
#---------------------------|----------------------|------------------|-----------------------------------|--------------------------------------------------------|---------------|-----------------------------|-------------
# req_file.csv	            | REQ_4	               | TC_4 TC_4_FAIL   | pc_4.csv  |                       | Testing log_req_cov() with no test_status (i.e. PASS)  |               |                             | sc_4.csv
#                           |                      |                  |           |                       |  and test_status=FAIL.                                 |               |                             |
#---------------------------|----------------------|------------------|-----------------------------------|--------------------------------------------------------|---------------|-----------------------------|-------------
# req_file.csv	            | REQ_5                | TC_5             | pc_5.csv  |                       | Testing log_req_cov() with UVVM status error triggered |               |                             | sc_5.csv
#                           |                      |                  |           |                       | prior to initialize_req_cov().			               |               |                             |
#---------------------------|----------------------|------------------|-----------------------------------|--------------------------------------------------------|---------------|-----------------------------|-------------
# req_file.csv	            | REQ_6                | TC_6             | pc_6.csv  |                       | Testing log_req_cov() with UVVM status error triggered |               |                             | sc_6.csv
#                           |                      |                  |           |                       | after log_req_cov() and prior to finalize_req_cov().   |	              |                             |
#---------------------------|----------------------|------------------|-----------------------------------|--------------------------------------------------------|---------------|-----------------------------|-------------
# req_file.csv	            |                      | TC_7             | pc_7.csv  |                       | Testing initialize_req_cov() with non-existing         |               |                             | sc_7.csv
#                           |                      |                  |           |                       | requirement file.	                                   |               |                             |		
#---------------------------|----------------------|------------------|-----------------------------------|--------------------------------------------------------|---------------|-----------------------------|-------------
# sub_req_file.csv      	| UART_REQ_GENERAL     | TC_SUB_REQ       | pc_8.csv  | sub_req_map_file.csv  | Testing passing sub-requirement with test_status=NA,   | UART_REQ_BR_A | cfg_1_strict_0.txt          | sc_8_0.csv
#                           |                      |                  |           |                       | msg and SCOPE.                                         | UART_REQ_BR_B | cfg_1_strict_1.txt          | sc_8_1.csv
#                           |                      |                  |           |                       |                                                        | UART_REQ_ODD  | cfg_1_strict_2.txt          | sc_8_2.csv
#                           |                      |                  |           |                       |                                                        | UART_REQ_EVEN |                             |
#---------------------------|----------------------|------------------|-----------------------------------|--------------------------------------------------------|---------------|-----------------------------|-------------
# sub_req_file.csv	        | UART_REQ_GENERAL     | TC_SUB_REQ       | pc_9.csv  | sub_req_map_file.csv  | Testing failing sub-requirement with test_status=NA,   | UART_REQ_BR_A | cfg_2_strict_0.txt          | sc_9_0.csv
#                           |                      |                  |           |                       | msg and SCOPE.                                         | UART_REQ_BR_B | cfg_2_strict_1.txt          | sc_9_1.csv
#                           |                      |                  |           |                       |                                                        | UART_REQ_ODD  | cfg_2_strict_2.txt          | sc_9_2.csv
#                           |                      |                  |           |                       |                                                        | UART_REQ_EVEN |                             |
#---------------------------|----------------------|------------------|-----------------------------------|--------------------------------------------------------|---------------|-----------------------------|-------------
# sub_req_file.csv	        |UART_REQ_GENERAL_OMIT | TC_SUB_REQ_OMIT  | pc_16.csv | sub_req_map_file.csv  | Testing omitted sub-requirement.                       | UART_REQ_BR_A |                             | sc_16.csv
#                           |                      |                  | pc_17.csv |                       |                                                        | UART_REQ_BR_B |                             | sc_17.csv
#                           |                      |                  | pc_18.cav |                       |                                                        | UART_REQ_ODD  |                             | sc_18.csv
#                           |                      |                  |           |                       |                                                        | UART_REQ_EVEN |                             |
#                           |                      |                  |           |                       |                                                        | UART_REQ_OMIT |                             |
#---------------------------|----------------------|------------------|-----------|-----------------------|--------------------------------------------------------|---------------|-----------------------------|-------------
# req_file.csv	            | REQ_1	               | TC_1             | pc_10.csv |                       | Testing failing simulations with incomplete testcase.  |               |                             | sc_10.csv
#---------------------------|----------------------|------------------|-----------|-----------------------|--------------------------------------------------------|---------------|-----------------------------|-------------
# req_file.csv	            | REQ_1/2/3/4          | TC_1             | pc_11.csv |                       | Testing multiple REQs with one testcase.               |               |                             | sc_11.csv
#---------------------------|----------------------|------------------|-----------|-----------------------|--------------------------------------------------------|---------------|-----------------------------|-------------
# req_file.csv	            | REQ_88               | TC_8             | pc_12.csv |                       | Testing non-matching requirement name.                 |               |                             | sc_12.csv
#===========================|======================|==================|===========|=======================|========================================================|===============|=============================|=============

import subprocess
import os
import sys

test_list = [
            ["python", "../script/run_spec_cov.py", "--strictness", "0", "-p", "../sim/pc_1.csv", "-s", "../sim/sc_1.csv"],
            ["python", "../script/run_spec_cov.py", "--strictness", "0", "-r", "../tb/maintenance_tb/req_file.csv", "-p", "../sim/pc_2.csv", "-s", "../sim/sc_2.csv"],
            ["python", "../script/run_spec_cov.py", "--strictness", "0", "-r", "../tb/maintenance_tb/req_file.csv", "-p", "../sim/pc_3.csv", "-s", "../sim/sc_3.csv"],
            ["python", "../script/run_spec_cov.py", "--strictness", "0", "-r", "../tb/maintenance_tb/req_file.csv", "-p", "../sim/pc_4.csv", "-s", "../sim/sc_4.csv"],
            ["python", "../script/run_spec_cov.py", "--strictness", "0", "-r", "../tb/maintenance_tb/req_file.csv", "-p", "../sim/pc_5.csv", "-s", "../sim/sc_5.csv"],
            ["python", "../script/run_spec_cov.py", "--strictness", "0", "-r", "../tb/maintenance_tb/req_file.csv", "-p", "../sim/pc_6.csv", "-s", "../sim/sc_6.csv"],
            ["python", "../script/run_spec_cov.py", "--strictness", "0", "-r", "../tb/maintenance_tb/req_file.csv", "-p", "../sim/pc_7.csv", "-s", "../sim/sc_7.csv"],
            ["python", "../script/run_spec_cov.py", "--config", "../tb/maintenance_tb/cfg_1_strict_0.txt"],
            ["python", "../script/run_spec_cov.py", "--config", "../tb/maintenance_tb/cfg_1_strict_1.txt"],
            ["python", "../script/run_spec_cov.py", "--config", "../tb/maintenance_tb/cfg_1_strict_2.txt"],
            ["python", "../script/run_spec_cov.py", "--config", "../tb/maintenance_tb/cfg_2_strict_0.txt"],
            ["python", "../script/run_spec_cov.py", "--config", "../tb/maintenance_tb/cfg_2_strict_1.txt"],
            ["python", "../script/run_spec_cov.py", "--config", "../tb/maintenance_tb/cfg_2_strict_2.txt"],
            ["python", "../script/run_spec_cov.py", "--strictness", "0", "-r", "../tb/maintenance_tb/req_file.csv", "-p", "../sim/pc_10.csv", "-s", "../sim/sc_10.csv"],
            ["python", "../script/run_spec_cov.py", "--strictness", "0", "-r", "../tb/maintenance_tb/req_file.csv", "-p", "../sim/pc_11.csv", "-s", "../sim/sc_11.csv"],
            ["python", "../script/run_spec_cov.py", "--strictness", "0", "-r", "../tb/maintenance_tb/req_file.csv", "-p", "../sim/pc_12.csv", "-s", "../sim/sc_12.csv"],
            ["python", "../script/run_spec_cov.py", "--strictness", "0", "-r", "../tb/maintenance_tb/req_file.csv", "-p", "../sim/pc_13.csv", "-s", "../sim/sc_13.csv"],
            ["python", "../script/run_spec_cov.py", "--strictness", "0", "-r", "../tb/maintenance_tb/req_file.csv", "-p", "../sim/pc_14.csv", "-s", "../sim/sc_14.csv"],
            ["python", "../script/run_spec_cov.py", "--strictness", "0", "-r", "../tb/maintenance_tb/req_file.csv", "-p", "../sim/pc_15.csv", "-s", "../sim/sc_15.csv"],
            ["python", "../script/run_spec_cov.py", "--strictness", "0", "-r", "../tb/maintenance_tb/sub_req_file.csv", "-m", "../tb/maintenance_tb/sub_req_omit_map_file.csv", "-p", "../sim/pc_16.csv", "-s", "../sim/sc_16.csv"],
            ["python", "../script/run_spec_cov.py", "--strictness", "0", "-r", "../tb/maintenance_tb/sub_req_file.csv", "-m", "../tb/maintenance_tb/sub_req_omit_map_file.csv", "-p", "../sim/pc_17.csv", "-s", "../sim/sc_17.csv"],
            ["python", "../script/run_spec_cov.py", "--strictness", "0", "-r", "../tb/maintenance_tb/sub_req_file.csv", "-m", "../tb/maintenance_tb/sub_req_omit_map_file.csv", "-p", "../sim/pc_18.csv", "-s", "../sim/sc_18.csv"],
            ["python", "../script/run_spec_cov.py", "--strictness", "0", "-r", "../tb/maintenance_tb/sub_req_file.csv", "-m", "../tb/maintenance_tb/sub_req_omit_map_file.csv", "-p", "../sim/pc_19.csv", "-s", "../sim/sc_19.csv"]
            ]

def remove_specification_coverage_files():
    print("Removing old run_spec_cov.py run files...")
    for filename in os.listdir("."):
        if filename[0:3] == "sc_":
            if filename.endswith(".csv"):
                print("Removing : %s" %(filename))
                os.remove(filename)
        elif filename[0:7] == "output_":
            if filename.endswith(".txt"):
                print("Removing : %s" %(filename))
                os.remove(filename)

def run_tests():
    print("Running tests...")
    output = None
    for idx, test in enumerate(test_list):
        print("Test %d : %s" %(idx, test))

        try:
            output = subprocess.check_output(test, stderr=subprocess.PIPE)
            # Save output for golden check        
            with open("output_" + str(idx + 1) + ".txt", 'w') as file:
                file.write(str(output, 'utf-8'))
        except subprocess.CalledProcessError as e:
            print("ERROR: %s" %(e))


def verify_test_results():
    print("Verify test results...")
    num_errors = 0
    try:
        subprocess.check_call(["py", "../script/maintenance_script/verify_with_golden.py"], stderr=subprocess.PIPE)
    except subprocess.CalledProcessError as e:
        num_errors = int(e.returncode)
    if num_errors != 0:
        print("Golden failed with %d errors!" %(num_errors))
    sys.exit(num_errors)


remove_specification_coverage_files()
run_tests()
verify_test_results()