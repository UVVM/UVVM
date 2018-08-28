
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
# Modified for bitvis_vip_*** by Daniel Blomkvist
# No simulations shall be performed at release as of January 12th 2016.
# The VIPs are not released stand-alone (yet).
# Including this to make the release-script able to generate a zip for 
# this release.
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
    # if not os.getcwd() == os.path.join(savedDir, "sim"):
        # os.chdir(os.path.join(savedDir,"sim"))
    
    # TODO: Put things  in DeploySimulate
    #UVVMUtil->DeploySimulate($ProductAndRevision); 
    
    #################################################################################
    #
    #   This is where the simulations commence...
    #       This section is module specific. Ensure that the command executions
    #       bellow match the UUT
    #
    #################################################################################
    print("Simulations will commence here if needed some day(not implemented now).")    
    
