###############################################################################
#  
# Author: Steffen Forså
#
# Description: 
#  This perl module defines perl methods
#  that contain specific actions needed for releasing UVVM Utility Library
#
###############################################################################

package BitvisUtil;
use strict; 
use PerlUtil; # Helper subroutines: Confirm() etc

my $SubDir = "uvvm_util"; 

##################################################
# Subroutines for release and deploy procedures
# Used by git-release.pl
##################################################
sub ReleaseSimulate{
    chdir "$SubDir/sim"; 

    foreach my $VhdlVersion (93, 2002, 2008)
    {
      PerlUtil::PrintConfirmAndRun("vsim -c -do ../internal_script/NA_all_incl_sim_$VhdlVersion.do | tee sim_$VhdlVersion.log");
      
      unless (PerlUtil::CheckSimSuccess("sim_$VhdlVersion.log")) {
        print "$PerlUtil::Red ERROR: SIMULATION not OK! Fix simulation errors before release $PerlUtil::Blank"; 
        exit; 
      }
    }

    chdir "../..";
}

sub DeploySimulate{
    my $ProductAndRevision = shift; 
    print "ProductAndRevision = $ProductAndRevision\n"; 
    #TODO: The $ProductAndRevision string is not passed correctly. 
    #it is BitvisUtil instead of uvvm_utility_Library_v2_1_1 !?
    # printout: 
    # ProductAndRevision = BitvisUtil
    # changing dir to uvvm_utility_Library_v2_1_1/uvvm_util/sim
    print "$PerlUtil::Purple changing dir to $ProductAndRevision/uvvm_util/sim $PerlUtil::Blank\n"; 
}

1; # Required in pm files
