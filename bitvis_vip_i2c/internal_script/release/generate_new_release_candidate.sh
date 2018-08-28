#!/bin/bash

# This must be called from the root directory, i.e., ../../../../
# The directory must contain the following subdirectories:
#
# - git_release
# - dependencies
# - uvvm_vvc_framework
# - uvvm_util
# - bitvis_vip_i2c
# - bitvis_vip_sbi
# - bitvis_vip_wishbone
#
# git_release and dependencies are used to generate the release,
# while the others are part of the release
# 
# REMEMBER TO PERFORM ALL NECESSARY STEPS BEFORE CALLING THIS SCRIPT
# The final step is to update bitvis_vip_i2c/VERSION.TXT
#
# If the VERSION.TXT is not updated, no action will be taken.
#
# When this script has finished verify the contents of the generated zip file.
# Then call on the generate_new_release_final.sh script
#
echo "Do you wish to generate a release candidate?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) python git-release/git-release.py -r bitvis_vip_i2c -x bitvis_vip_sbi bitvis_vip_wishbone uvvm_vvc_framework uvvm_util vunit; exit;;
        No ) exit;;
    esac
done