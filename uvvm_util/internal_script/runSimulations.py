
###############################################################################
#  
# Author: Andreas Tornes
# Description: 
# 	This script runs simulations in the release-candidate
# 	folder created by git-release.py. It is primarily designed
#	to be executed by git-release.py, however can be used 
#	independently if the release-candidate folder exists.
# 
#	Parts of this script is generalized for any module in UVVM.
#	However, a marked section in the code is specific for the UUT,
#	and must be modified accordingly
#
# 
###############################################################################

import sys
import os
import re
import argparse


###############################################################################
#   Argument parser
###############################################################################
def argParser(argv):
    parser = argparse.ArgumentParser(description="This is a script for running test-bench simulations."
                                    "Ensure that the script content matches the UUT.")
    parser.add_argument("-n", "--projectName", help="Enter custom project name")
    parser.add_argument("-v", "--version", help="Enter custom version number: x.x.x")
    parser.add_argument("-d", "--startDir", help="The directory that should be set as working directory from the beginning of the script")
    
    args = parser.parse_args()
    
    return args


if __name__ == '__main__':
    sys.path.append(os.path.join(os.getcwd(), '..', 'git-release'))
    import pyUtil

    args = argParser(sys.argv)
    
    #Setting variables required by pyUtil. These are dynamic, thus will not
    #have to be changed depending on which module is being simulated
    myProjectName = args.projectName
    savedDir = args.startDir
    runID = 1
    # releaseVars will containt the list: [revNumber,branchName,tagName,projectName]
    releaseVars = []
    releaseVars.append(args.version)
    releaseVars.append("release-" + releaseVars[0])
    releaseVars.append("v" + releaseVars[0] + "-rc")
    releaseVars.append(myProjectName)
    
    
    #Ensure we are in the correct directory
    if not os.getcwd() == os.path.join(savedDir, "sim"):
        os.chdir(os.path.join(savedDir,"sim"))
    
    # TODO: Put things  in DeploySimulate
    #UVVMUtil->DeploySimulate($ProductAndRevision); 
    
    #################################################################################
    #
    #   This is where the simulations commence...
    #       This section is module specific. Ensure that the command executions
    #       bellow match the UUT
    #
    #################################################################################
    if (re.match(".*" + re.escape(os.path.join(myProjectName, "sim")),os.getcwd())):
        print("current dir: " + os.getcwd())    
        # Test compilation of UVVM Utility Library
        pyUtil.PrintAndRun('vsim -c -do "do ../script/compile_src.do; exit -f -code 0" | tee sim.log', 0, runID, releaseVars);
        
        # Simulate UVVM with the IRQC DUT
        os.chdir(os.path.join('..', '..', 'bitvis_irqc', 'sim'))  
        if (re.match(".*" + re.escape(os.path.join("bitvis_irqc","sim")),os.getcwd())):
            print("Now we run simulations to verify that %s simulates...\n" % myProjectName)
            pyUtil.PrintAndRun('vsim -c -do \"do ../script/compile_and_sim_all.do; exit -f -code 0\"', 0, 0, releaseVars)# runID changed for debug purposes###runID, releaseVars) 
            if not pyUtil.CheckSimSuccess("_Log.txt", 0, releaseVars):# runID changed for debug purposes###runID, releaseVars): 
                print ("--------------------------------------------------------\n") 
                pyUtil.exceptionHandler("Fix compilation errors, then restart release procedure\n", 0, releaseVars)# runID changed for debug purposes###runID, releaseVars) 
                print ("---------------------------------------------------------\n")
                      
            os.chdir(os.path.join('..', '..', '..'))
        else:
            pyUtil.exceptionHandler("Could not chdir to ../../bitvis_irqc/sim: $!", 0, releaseVars)# runID changed for debug purposes###runID, releaseVars)  
    else:
        pyUtil.exceptionHandler("Could not chdir to bitvis_irqc/sim:", 0, releaseVars)# runID changed for debug purposes###runID, releaseVars) 
    
