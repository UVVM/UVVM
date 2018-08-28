#!/bin/bash

# This must be called from the root directory, i.e., ../../../../
# The directory must contain the following subdirectories:
#
# - git_release
# - dependencies
# - uvvm_vvc_framework
# - uvvm_util
# - bitvis_vip_axilite
#
# git_release and dependencies are used to generate the release,
# while the others are part of the release
#
# ONLY CALL THIS SCRIPT AFTER CALLING generate_new_release_candidate.sh first
#
# If the VERSION.TXT is not updated, no action will be taken.
# If no RC is found for this version, no action will be taken.
#
#

echo "Do you wish to generate a final release?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) python git-release/git-release.py -r bitvis_vip_axilite -x uvvm_vvc_framework uvvm_util vunit --final; exit;;
        No ) exit;;
    esac
done