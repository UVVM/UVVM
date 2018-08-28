#!/usr/bin/perl -w
###############################################################################
#  
# Author: Steffen Forså
#
# Description: 
#  This script releases and deploys a Bitvis project :
#  - UVVM VVC Framework
#
# Most of the code is common for all projects, 
# but if there are specific code for a certain project, 
# a separate Perl module (.pm) file is included for that.
# 
# Usage : See description above the Usage() subroutine 
#
# RunRelease() : Release steps. See description above subroutine
#
# RunDeployToCustomer(): Deploy steps. See description above subroutine
#
###############################################################################

# todo: redo siste release vs incr major/minor
# todo: copy zip fil etterpå til en disk
# todo: Det vil i tillegg være en license_*_pkg.vhd fil med C_VERSION som skal oppdateres til versjonsnummeret, 
# enten manuelt eller av scriptet. 
#


use strict;
use Getopt::Long ();
use Cwd();
# use Git::Repository;

use English;

# Find the path to directory from where script was invoked 
# then set INC to the ../lib dir
use FindBin;
FindBin::again(); # or FindBin->again;
use lib "$FindBin::Bin/../lib";

# Internal perl modules
use PerlUtil; # Helper subroutines: Confirm() etc
# use UVVMUtil; 

my $pwd = Cwd::cwd();


# Tag and branch names
our $branchname;
our $tagname;

# Command line options
our $RevNumber;
our $ProductName;
our $DryRun;
our $Final;


###############################################################################
# Subroutines
###############################################################################

###############################################################################
# Print Usage info
###############################################################################
sub Usage {
  my $msg = $_[0];
  if (defined $msg && length $msg) {
    $msg .= "\n"
    unless $msg =~ /\n$/;
  }

  my $command = $0;
  $command =~ s#^.*/##;

  print STDERR (
    $msg,
    "----------------------------------------------------------------\n" . 
    " Usage: $command [switches] -r RevNumber \n" . 
    " Switches may consist of: \n" . 
    " -final       Finalise existing release (move from Release Candidate to\n" .
    "              tag on master).\n" .
    " -d           Dry run, i.e. do not execute any commands \n" . 
    "               \n" . 
    "\n".
    " - Run $command from a git shell!\n" .
    " - Call $command from the root directory of the repository to be released \n" .
    " - The current directory is used for determining the product name \n" .
    " \n" .
    "----------------------------------------------------------------\n" . 
    " Examples                                                   \n" . 
    " 1. UVVM Utility Library : \n" . 
    "    From directory ~/_git/uvvm, call \n" . 
    "    ~/_git/0007-fpga-bitvis-ip/common/bin/$command -r 1.1.0 \n" . 
    "----------------------------------------------------------------\n" . 
    "\n"
  );

  die("\n")
}

###############################################################################
# Steps for Release 
###############################################################################
# - Start from the master branch in the repository’s root directory.  
# - Edit the CHANGES.TXT (in the master branch so that it's visible in the future regardless if the release branch is rebased or merged back to master.)  Append this release comment to the top of the list. 
# - Optionally edit README.TXT
# - Make a tag 
# - Commit the tag and the changed txt files
# - Run test bench on 
###############################################################################
sub RunRelease {
  print "---------------------------------------------------------\n"; 
  print "Starting : Release steps for $ProductName $RevNumber\n"; 
  print "---------------------------------------------------------\n"; 

  print "$PerlUtil::Purple NOTE: Make sure you have commited all design changes to git! $PerlUtil::Blank \n"; 

  print "$PerlUtil::Purple NOTE: Make sure you have reviewed .gitattributes to select which files to release. $PerlUtil::Blank \n"; 

  print "$PerlUtil::Purple NOTE: Make sure you have run tests/regressions on current code, and that this is what you want to release $PerlUtil::Blank \n"; 
  print "$PerlUtil::Purple NOTE: To extract log history since last release, try  $PerlUtil::Yellow git lg <tag>...development $PerlUtil::Blank \n"; 


  ############################################
  # Preliminary step:
  # Verify that $RevNumber is higher than
  # what already exists
  #
  
  my $RevNumberStatus = PerlUtil::CompareRevNumber($RevNumber);
  if ($RevNumberStatus == -1) {
    die("Revision number lower than the previous release! Aborting...\n"); 
  } elsif ($RevNumberStatus == 0) {
    print "Revision number equal to previous release.\n";
    if (PerlUtil::Confirm("$PerlUtil::Red Do you wish to replace the previous release?  $PerlUtil::Blank")) {
      if (PerlUtil::Confirm("$PerlUtil::Red Are you sure you wish to replace the previous release?\nPlease realise that this will delete the old tags and branches + zip files,\ni.e., completely remove the existing release from git remote and local. $PerlUtil::Blank")) {
        PerlUtil::RemoveRevision($RevNumber, $DryRun);
      } else {
        die("Revision was not replaced. Aborting...\n"); 
      }
    } else {
      die("Revision was not replaced. Aborting...\n"); 
    }
  }
  
  ############################################
  # Step 1a: 
  # Commit and make tag!

  # Make release branch
  PerlUtil::PrintConfirmAndRun("git checkout -b $branchname", $DryRun);

  # TODO: This should be improved with a pre-release call in the uvvm package.
  # Then, we could make references to pre- and post- release calls when we find
  # $ProductName and simply call it here.
  # if ($ProductName =~ /uvvm_vvc_framework/i ) {

    # # Replace version number in all license files.
    # my @license_files = <src/internal_license*_pkg.vhd>;

    # { # Local scope 
      # local $INPLACE_EDIT = '.bak';
      # print "Updating $PerlUtil::Yellow @license_files $PerlUtil::Blank\n";

      # # Pretend argument list is list of files, in this scope only!
      # local @ARGV = (@license_files); 
      # while (<>) {
        # s/(C_VERSION.*").*";/${1}v$RevNumber";/;
        # print;
      # }

    # }

  # }

  # Edit txt files
  PerlUtil::PrintConfirmAndRun("vim -O CHANGES.TXT README.TXT", $DryRun);  # Open both files in vertical split windows1;

  # Edit dependencies.txt
  { # Local scope 
    local $INPLACE_EDIT = '.bak';
    print "Updating $PerlUtil::Yellow dependencies.txt $PerlUtil::Blank\n";
    
    # Pretend argument list is list of files, in this scope only!
    local @ARGV = ('dependencies.txt'); 
    
    my $first = 1;
    while (<>) {
      if ($first) {
        if (! /^\s*(#.*)?$/) { # Skip empty and comment-only lines
          s/(branch|tag):.*/tag:$tagname/;
          $first = 0;
        }
      }
      print;
    }
  }


  # Commit all changes
  PerlUtil::PrintConfirmAndRun("git commit -am 'rel v$RevNumber, committed by git-release.pl'", $DryRun);  # Commit changes

  # Tag
  PerlUtil::PrintConfirmAndRun("git tag -a $tagname -m 'rel v$RevNumber: see CHANGES.TXT'", $DryRun); #make a tag on release branch

  # Push changes
  PerlUtil::PrintConfirmAndRun("git push -f origin $tagname", $DryRun); # Force push, in case tagname already exists
  PerlUtil::PrintConfirmAndRun("git push --set-upstream origin $branchname", $DryRun);

#  ############################################
#  # Step 1b: 
#  # Simulate design
#
#  #
#  # Simulate UVVM Utility Library
#  #
#  if ($ProductName =~ /uvvm_vvc_framework/i ) {
#    UVVMUtil->ReleaseSimulate; 
#  } 
#  #
#  # Other 
#  #
#  else {
#    chdir "sim"  or die "Could not chdir to sim : $!";
#    PerlUtil::PrintConfirmAndRun("vsim -c -do ../script/1_all_incl_sim.do, $DryRun");
#    chdir ".." or die "Could not chdir to ..: $!";
#  }       

  print "---------------------------------------------------------\n"; 
  print "$PerlUtil::Purple Release steps are done! $PerlUtil::Blank\n"; 
  print "---------------------------------------------------------\n"; 
} # End RunRelease


###############################################################################
# Deploy to customer steps: 
# - Archive the release based on the tag corresponding to the release.
# - Exclude files that should be left out of deployment, 
#   for example bitvis internal files.
#   These files are defined in .gitattributes
# - Unzip the archive and run test bench
# - Insert the customer's license file into the archive. TODO: Where to keep the license files?
###############################################################################
sub RunDeployToCustomer {
  print "---------------------------------------------------------\n"; 
  print "$PerlUtil::Purple Starting : Deploy to customer steps for $ProductName $RevNumber $PerlUtil::Blank\n"; 
  print "---------------------------------------------------------\n"; 

  
  ############################################
  # Step 2a:
  # edit .gitattributes

  # .gitattributes should be set before release. Otherwise, we move off the tag.

  # PerlUtil::PrintConfirmAndRun("vim .gitattributes", $DryRun);  
  # PerlUtil::PrintAndRun("git add .gitattributes", $DryRun); 
  # PerlUtil::PrintConfirmAndRun("git commit . -m 'rel v$RevNumber, committed by git-release.pl'", $DryRun);
  # PerlUtil::PrintConfirmAndRun("git push", $DryRun);

  ############################################
  # Step 2b:  
  # Make Zip file 

  # Requires dependencies.py in path
  PerlUtil::PrintAndRun("dependencies.py archive", $DryRun); 

  # Go to release dir
  my $ReleaseDir = "../release_v${RevNumber}-rc";
  my $AbsDirName = Cwd::abs_path(chomp $ReleaseDir);

  # Test zip: Unzip in temp dir and Verify that the package and the license.vhd compiles 
  chdir $ReleaseDir or die "Could not chdir to $ReleaseDir: $!";

  # This script doesn't have the archive name - TODO (though this is probably good enough)
  PerlUtil::PrintConfirmAndRun("unzip *.zip", $DryRun);    #Extract archive

  if ($ProductName =~ /uvvm_vvc_framework/i ) {
    # TODO: Put things  in DeploySimulate
    #UVVMUtil->DeploySimulate($ProductAndRevision); 
    
    chdir "uvvm_vvc_framework/sim" or die "Could not chdir to uvvm_vvc_framework/sim: $!";
  
    # Test compilation of UVVM
    PerlUtil::PrintConfirmAndRun("vsim -c -do \"do ../script/compile_util.do; exit -f -code 0\" | tee sim.log", $DryRun);
    
    # I don't think the following check is necessary - the vsim command will fail on compile errors,
    # and script will die.
    
    unless (PerlUtil::Confirm("Is the above compilation OK?")) {
      print "--------------------------------------------------------\n"; 
      print "$PerlUtil::Red ERROR: Fix compilation errors, then restart release procedure $PerlUtil::Blank"; 
      print "---------------------------------------------------------\n"; 
      exit; 
    }
    
    PerlUtil::PrintConfirmAndRun("vsim -c -do \"do ../script/compile_src.do; exit -f -code 0\" | tee sim.log", $DryRun);
    
    # I don't think the following check is necessary - the vsim command will fail on compile errors,
    # and script will die.
    
    unless (PerlUtil::Confirm("Is the above compilation OK?")) {
      print "--------------------------------------------------------\n"; 
      print "$PerlUtil::Red ERROR: Fix compilation errors, then restart release procedure $PerlUtil::Blank"; 
      print "---------------------------------------------------------\n"; 
      exit; 
    }
  
    # Simulate UVVM with the uart DUT
    chdir "../../bitvis_uart/sim"  or die "Could not chdir to ../../bitvis_uart/sim: $!";
    print("Now we run UART simulations to verify that UVVM simulates...\n"); 
  

    PerlUtil::PrintConfirmAndRun("vsim -c -do \"do ../script/compile_all_and_sim_uart_vvc_tb.do; exit -f -code 0\"", $DryRun);
    unless (PerlUtil::CheckSimSuccess("_Log.txt")) {
      print "--------------------------------------------------------\n"; 
      print "$PerlUtil::Red ERROR: Fix compilation errors, then restart release procedure $PerlUtil::Blank"; 
      print "---------------------------------------------------------\n"; 
      exit; 
      }
  
    chdir "../../.."  or die "Could not chdir to ../../..: $!";
  
  }
  else { 
    # Other $ProductName
    chdir "sim" or die "Could not chdir to sim: $!";
    PerlUtil::PrintConfirmAndRun("vsim -c -do \"do ../script/compile_src.do; exit -f -code 0\"", $DryRun); 
    unless (PerlUtil::Confirm("Is the above compilation OK?")) {
      print "--------------------------------------------------------\n"; 
      print "$PerlUtil::Red ERROR: Fix compilation errors, then restart release procedure $PerlUtil::Blank"; 
      print "---------------------------------------------------------\n"; 
      exit; 
    }
  }

  print "---------------------------------------------------------\n"; 
  print "$PerlUtil::Purple Deploy to customer steps are done! $PerlUtil::Blank\n"; 
###  print "$PerlUtil::Purple $AbsDirName/$ZipName created! $PerlUtil::Blank\n"; 
  print "$PerlUtil::Purple Please review the zip file in $AbsDirName to ensure correct files are released.$PerlUtil::Blank\n";
  print "$PerlUtil::Purple When satisfied, please run 'git-release.pl -final'$PerlUtil::Blank\n"; 
  print "---------------------------------------------------------\n"; 
}

###############################################################################

sub FinaliseRelease {

  # Update dependencies.txt to use this version (remove -rc)
  { # Local scope 
    local $INPLACE_EDIT = '.bak';
    print "Updating $PerlUtil::Yellow dependencies.txt $PerlUtil::Blank\n";
    
    # Pretend argument list is list of files, in this scope only!
    local @ARGV = ('dependencies.txt'); 
    
    my $first = 1;
    my $match;
    while (<>) {
      if ($first) {
        if (! /^\s*(#.*)?$/) { # Skip empty and comment-only lines
          $match = s/(tag:$tagname)-rc/$1/;

          $first = 0;
        }
      }
      print;
    }

    if (! $match) {
      die "Couldn't find tag '$tagname-rc' on main repo in dependencies.txt.";
    }

  }

  # Commit
  PerlUtil::PrintConfirmAndRun("git commit -m 'Updated dependencies.txt, committed by git-release.pl' dependencies.txt", $DryRun);
  
  # Merge branch back to master
  PerlUtil::PrintAndRun       ("git checkout master", $DryRun);
  PerlUtil::PrintConfirmAndRun("git merge --no-ff -m 'Merge release v$RevNumber, done by git-release.pl' $branchname ", $DryRun);
  
  # Tag
  PerlUtil::PrintConfirmAndRun("git tag $tagname", $DryRun);

  # Push
  PerlUtil::PrintConfirmAndRun("git push origin $tagname", $DryRun);
  PerlUtil::PrintConfirmAndRun("git push", $DryRun);

  
  # Re-run 'dep archive' to get a clean release. NOTE: This is the actual release.
  # Requires dependencies.py in path
  PerlUtil::PrintConfirmAndRun("dependencies.py archive", $DryRun); 


  # Merge changes back to development
  PerlUtil::PrintAndRun       ("git checkout $branchname", $DryRun);
  

  # Update dependencies.txt to use development
  { # Local scope 
    local $INPLACE_EDIT = '.bak';
    print "Updating $PerlUtil::Yellow dependencies.txt $PerlUtil::Blank\n";
    
    # Pretend argument list is list of files, in this scope only!
    local @ARGV = ('dependencies.txt'); 
    
    my $first = 1;
    my $match;
    while (<>) {
      if ($first) {
        if (! /^\s*(#.*)?$/) { # Skip empty and comment-only lines
          $match = s/(tag:$tagname)/branch:development/;

          $first = 0;
        }
      }
      print;
    }

    if (! $match) {
      die "Couldn't find tag '$tagname' on main repo in dependencies.txt.";
    }
  }

  PerlUtil::PrintConfirmAndRun("git commit -m 'Updated dependencies.txt, committed by git-release.pl' dependencies.txt", $DryRun);

  # Merge changes back to development
  PerlUtil::PrintAndRun       ("git checkout development", $DryRun);
  PerlUtil::PrintConfirmAndRun("git merge --no-ff -m 'Merge release v$RevNumber, done by git-release.pl' $branchname", $DryRun);

  # Push
  PerlUtil::PrintConfirmAndRun("git push", $DryRun);
  
  # TODO: Compare the zip-files and verify that the only change is in the versions.txt

  # **********************************************************************************************
  # WORK-AROUND: Rename the final zip file to UVVM_v<x>_<x>_<x>.zip
  #              This work-around shall be removed at a later stage, i.e., if the dependencies.py
  #              script archive command accepts a name prefix parameter.
  #
  my $ReleaseDir = "../release_v${RevNumber}";
  chdir $ReleaseDir or die "Could not chdir to $ReleaseDir: $!";
  
  my $ZipRevNumber = $RevNumber;
  my $ZipProductName = "UVVM";
  $ZipRevNumber =~ tr/./_/; # replace . with _
  my $old_zip = "./uvvm_vvc_frameworkv${ZipRevNumber}.zip";
  my $new_zip = "./${ZipProductName}_v${ZipRevNumber}.zip";

  if (-f $old_zip)
  {
    print "Renaming final release zip file from uvvm_vvc_framework_release_v${ZipRevNumber}\n to ${ZipProductName}_v${ZipRevNumber}\n";
    rename $old_zip, $new_zip;
  }
  if (! -f $new_zip)
  {
    die "Renaming failed!\n";
  }
  
  #
  # **********************************************************************************************
  print "---------------------------------------------------------\n"; 
  print "$PerlUtil::Purple Final release steps are done! $PerlUtil::Blank\n"; 
  print "$PerlUtil::Purple You have a new zip file in release_v$RevNumber$PerlUtil::Blank\n";
  print "$PerlUtil::Purple That file should be diffed against the release candidate in release_v${RevNumber}-rc$PerlUtil::Blank\n";
  print "$PerlUtil::Purple The only difference should be in the version file. (TODO: This step could be done by script)$PerlUtil::Blank\n";
  print "---------------------------------------------------------\n"; 

}

###############################################################################
# Main
###############################################################################

###############################################################################
# Get command line arguments
###############################################################################

Getopt::Long::GetOptions(
  #'p=s'      => \$ProductName,
  "d"  => \$DryRun, # flag
  # Make sure revision number is in the form x.y.z
  'r=s' => sub {
    local *_ = \$_[1];
    /^(\d+).(\d+).(\d+)$/ or die("Invalid format for option -r : Use the form x.y.z\n");
    $RevNumber = "$_[1]";
  },
  'final' => \$Final,
)
  or Usage("Invalid commmand line options.");

Usage("$PerlUtil::Red ERROR : The RevNumber must be specified. $PerlUtil::Blank") unless defined $RevNumber;
print "---------------------------------------------------------\n"; 

if ($DryRun) {
  print " **  DryRun mode! **   \n"; 
  print "---------------------------------------------------------\n"; 
}

#
# Find ProductName from path, unless already defined
#

unless (defined $ProductName) {
  if ($pwd =~ m|\/uvvm_vvc_framework|) {
    $ProductName = "uvvm_vvc_framework"; 
  }
  else { 
    die("#FATAL ERROR: No known product name matched in path!"); 

  }

  print "ProductName is set to $ProductName!\n"; 
}


# Set tag and branch name
$branchname = "release-$RevNumber";
# $tagname;
if ($Final) {
  $tagname    = "v${RevNumber}";
}
else {
  $tagname    = "v${RevNumber}-rc";
}


#
# Run main program!
#
# start from a repository reachable from the current directory
# $repo = Git::Repository->new();

# $perlUtil = PerlUtil->new("ReleaseCmdLog", $DryRun); 
PerlUtil->OpenCmdLog("ReleaseCmdLog.txt");  # open Command log file

if ($Final) {
  FinaliseRelease();
}
else {
  RunRelease();
  RunDeployToCustomer();
}

PerlUtil->CloseCmdLog();                    # Close Command log file


