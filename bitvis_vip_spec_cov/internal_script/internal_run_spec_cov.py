#===========================|==================|==================|==========|=======================|========================================================|===============|=============================|=============
# REQ FILE                  | REQ              | TC               | PC FILE  | MAP FILE	             | DESCRIPTION	                                          | SUB REQ	      | CONFIG	                    | SPEC COV
#===========================|==================|==================|==========|=======================|========================================================|===============|=============================|=============
# internal_req_file.csv	    | REQ_1	           | TC_1             | pc_1.csv |                       | Testing initialize_req_cov() with no requirement file. |               |                             | sc_1.csv
#---------------------------|------------------|------------------|----------------------------------|--------------------------------------------------------|---------------|-----------------------------|-------------
# internal_req_file.csv	    | REQ_2	           | TC_2             | pc_2.csv |                       | Testing initialize_req_cov() with a requirement file.  |               |                             | sc_2.csv
#---------------------------|------------------|------------------|----------------------------------|--------------------------------------------------------|---------------|-----------------------------|-------------
# internal_req_file.csv	    | REQ_3 [REQ_10]   | TC_3 TC_50 TC_1  | pc_3.csv |                       | Testing log_req_cov() with default testcase, unknown   |               |                             | sc_3.csv
#                           |                  |                  |          |                       |  testcase and unknown requirement label.			      |               |                             |
#---------------------------|------------------|------------------|----------------------------------|--------------------------------------------------------|---------------|-----------------------------|-------------
# internal_req_file.csv	    | REQ_4	           | TC_4 TC_4_FAIL   | pc_4.csv |                       | Testing log_req_cov() with no test_status (i.e. PASS)  |               |                             | sc_4.csv
#                           |                  |                  |          |                       |  and test_status=FAIL.                                 |               |                             |
#---------------------------|------------------|------------------|----------------------------------|--------------------------------------------------------|---------------|-----------------------------|-------------
# internal_req_file.csv	    | REQ_5 TC_5       |                  | pc_5.csv |                       | Testing log_req_cov() with UVVM status error triggered |               |                             | sc_5.csv
#                           |                  |                  |          |                       | prior to initialize_req_cov().			              |               |                             |
#---------------------------|------------------|------------------|----------------------------------|--------------------------------------------------------|---------------|-----------------------------|-------------
# internal_req_file.csv	    | REQ_6 TC_6       |                  | pc_6.csv |                       | Testing log_req_cov() with UVVM status error triggered |               |                             | sc_6.csv
#                           |                  |                  |          |                       | after log_req_cov() and prior to finalize_req_cov().	  |	              |                             |
#---------------------------|------------------|------------------|----------------------------------|--------------------------------------------------------|---------------|-----------------------------|-------------
# internal_req_file.csv	    |                  | TC_7             | pc_7.csv |                       | Testing initialize_req_cov() with non-existing         |               |                             | sc_7.csv
#                           |                  |                  |          |                       | requirement file.	                                  |               |                             |		
#---------------------------|------------------|------------------|----------------------------------|--------------------------------------------------------|---------------|-----------------------------|-------------
# internal_sub_req_file.csv	| UART_REQ_GENERAL | TC_SUB_REQ       | pc_8.csv | internal_map_file.csv | Testing passing sub-requirement with test_status=NA,   | UART_REQ_BR_A | internal_cfg_1_strict_0.txt | sc_8_0.csv
#                           |                  |                  |          |                       | msg and SCOPE.                                         | UART_REQ_BR_B | internal_cfg_1_strict_1.txt | sc_8_1.csv
#                           |                  |                  |          |                       |                                                        | UART_REQ_ODD  | internal_cfg_1_strict_2.txt | sc_8_2.csv
#                           |                  |                  |          |                       |                                                        | UART_REQ_EVEN |                             |
#---------------------------|------------------|------------------|----------------------------------|--------------------------------------------------------|---------------|-----------------------------|-------------
# internal_sub_req_file.csv	| UART_REQ_GENERAL | TC_SUB_REQ       | pc_9.csv | internal_map_file.csv | Testing failing sub-requirement with test_status=NA,   | UART_REQ_BR_A | internal_cfg_2_strict_0.txt | sc_9_0.csv
#                           |                  |                  |          |                       | msg and SCOPE.                                         | UART_REQ_BR_B | internal_cfg_2_strict_1.txt | sc_9_1.csv
#                           |                  |                  |          |                       |                                                        | UART_REQ_ODD  | internal_cfg_2_strict_2.txt | sc_9_2.csv
#                           |                  |                  |          |                       |                                                        | UART_REQ_EVEN |                             |
#---------------------------|------------------|------------------|----------------------------------|--------------------------------------------------------|---------------|-----------------------------|-------------
# internal_req_file.csv	    | REQ_1	           | TC_1             | pc_10.csv|                       | Testing failing simulations with incomplete testcase.  |               |                             | sc_10.csv
#===========================|==================|==================|==========|=======================|========================================================|===============|=============================|=============

import subprocess
import os

test_list = [
            ["python3", "../script/run_spec_cov.py", "--strictness", "0", "-p", "../sim/pc_1.csv", "-s", "../sim/sc_1.csv"],
            ["python3", "../script/run_spec_cov.py", "--strictness", "0", "-r", "../internal_tb/internal_req_file.csv", "-p", "../sim/pc_2.csv", "-s", "../sim/sc_2.csv"],
            ["python3", "../script/run_spec_cov.py", "--strictness", "0", "-r", "../internal_tb/internal_req_file.csv", "-p", "../sim/pc_3.csv", "-s", "../sim/sc_3.csv"],
            ["python3", "../script/run_spec_cov.py", "--strictness", "0", "-r", "../internal_tb/internal_req_file.csv", "-p", "../sim/pc_4.csv", "-s", "../sim/sc_4.csv"],
            ["python3", "../script/run_spec_cov.py", "--strictness", "0", "-r", "../internal_tb/internal_req_file.csv", "-p", "../sim/pc_5.csv", "-s", "../sim/sc_5.csv"],
            ["python3", "../script/run_spec_cov.py", "--strictness", "0", "-r", "../internal_tb/internal_req_file.csv", "-p", "../sim/pc_6.csv", "-s", "../sim/sc_6.csv"],
            ["python3", "../script/run_spec_cov.py", "--strictness", "0", "-r", "../internal_tb/internal_req_file.csv", "-p", "../sim/pc_7.csv", "-s", "../sim/sc_7.csv"],
            ["python3", "../script/run_spec_cov.py", "--config", "../internal_tb/internal_cfg_1_strict_0.txt"],
            ["python3", "../script/run_spec_cov.py", "--config", "../internal_tb/internal_cfg_1_strict_1.txt"],
            ["python3", "../script/run_spec_cov.py", "--config", "../internal_tb/internal_cfg_1_strict_2.txt"],
            ["python3", "../script/run_spec_cov.py", "--config", "../internal_tb/internal_cfg_2_strict_0.txt"],
            ["python3", "../script/run_spec_cov.py", "--config", "../internal_tb/internal_cfg_2_strict_1.txt"],
            ["python3", "../script/run_spec_cov.py", "--config", "../internal_tb/internal_cfg_2_strict_2.txt"],
            ["python3", "../script/run_spec_cov.py", "--strictness", "0", "-r", "../internal_tb/internal_req_file.csv", "-p", "../sim/pc_10.csv", "-s", "../sim/sc_10.csv"]
            ]


def remove_specification_coverage_files():
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
    for idx, test in enumerate(test_list):
        output = subprocess.check_output(test, stderr=subprocess.PIPE)
        # Save output for golden check        
        with open("output_" + str(idx + 1) + ".txt", 'w') as file:
            file.write(str(output, 'utf-8'))


remove_specification_coverage_files()
run_tests()
