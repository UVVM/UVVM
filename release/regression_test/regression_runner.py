import os
import sys
import shutil
import subprocess
from hdlunit import HDLUnit


def execute(command):
    process = subprocess.Popen(command,shell=False,stdout=subprocess.PIPE, env=os.environ.copy(), encoding='UTF-8')

    # Poll process.stdout to show stdout live
    while True:
      output = process.stdout.readline()
      if process.poll() is not None:
        break
      if output:
        print(output.strip())
    rc = process.poll()

    return rc

root_folder = os.path.abspath(os.path.join(os.path.dirname( __file__ ), '../..'))

for subdir, dirs, files in os.walk(root_folder):

    for file in files:
        if 'maintenance_script' in subdir:
            filepath = subdir + os.sep + file
            
            if 'test.py' in filepath:
                sim_path = os.path.abspath(os.path.join(subdir, '../../sim'))
                if not os.path.isdir(sim_path):
                    os.mkdir(sim_path)

                os.chdir(sim_path)
                print('\n%s\nTesting in: %s\n%s' % ("-"*50, sim_path, "-"*50))

                rc = execute([sys.executable, '../script/maintenance_script/test.py', '-t'])
                os.chdir(root_folder)

                if rc != 0:
                    print('\n\n%s\n%sMODULE FAIL!\n%s' % (40*'=', 10*' ', 40*'='))
