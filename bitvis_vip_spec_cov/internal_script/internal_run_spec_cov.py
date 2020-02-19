py ../script/run_spec_cov.py --strictness 0 -r internal_req_file.csv -p pc_1.csv -s sc_1.csv
py ../script/run_spec_cov.py --strictness 0 -r internal_req_file.csv -p pc_2.csv -s sc_2.csv
py ../script/run_spec_cov.py --strictness 0 -r internal_req_file.csv -p pc_3.csv -s sc_3.csv
py ../script/run_spec_cov.py --strictness 0 -r internal_req_file.csv -p pc_4.csv -s sc_4.csv
py ../script/run_spec_cov.py --strictness 0 -r internal_req_file.csv -p pc_5.csv -s sc_5.csv
py ../script/run_spec_cov.py --strictness 0 -r internal_req_file.csv -p pc_6.csv -s sc_6.csv
py ../script/run_spec_cov.py --strictness 0 -r internal_req_file.csv -p pc_7.csv -s sc_7.csv

py ../script/run_spec_cov.py --config internal_cfg_1_strict_0.txt
py ../script/run_spec_cov.py --config internal_cfg_1_strict_1.txt
py ../script/run_spec_cov.py --config internal_cfg_1_strict_2.txt

py ../script/run_spec_cov.py --config internal_cfg_2_strict_0.txt
py ../script/run_spec_cov.py --config internal_cfg_2_strict_1.txt
py ../script/run_spec_cov.py --config internal_cfg_2_strict_2.txt