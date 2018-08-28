###############################################################################
#  
# Author: Steffen Forså
#
# Description: 
#  This perl module defines common perl methods
#  that can be used by various perl scripts
#
###############################################################################

package PerlUtil; 
use strict;

# constructor, this method makes an object that belongs to class PerlUtil
# (not used, Not instantiated as Object)
#sub new  { 
#  my $class      = shift;    # $_[0] contains the class name
#  my $CmdLogName = shift;    
#  my $DryRun     = shift;   
#  # the internal structure we'll use to represent
#  # the data in our class is a hash reference
#  my $self = {};        
#  bless( $self, $class );    # make $self an object of class $class
#
#  open (CMD_LOG, '>../$CmdLogName.txt'); # log commands being executed
#  $self->{CmdLogName} = $CmdLogName;    # give $self->{num} the supplied value
#  $self->{DryRun}     = $DryRun;    # give $self->{num} the supplied value
#  # $self->{num} is our internal number
#  return $self;        # a constructor always returns an blessed()
#  # object
#}

## Nice colors (at least in git/unix shell)
our $Purple = "\e[1;35m" ;
our $Green = "\e[1;32m" ;
our $Blue = "\e[1;34m" ;
our $Cyan = "\e[1;36m" ;
our $Red = "\e[1;31m" ;
our $Yellow = "\e[1;33m" ;
our $White = "\e[1;37m" ;
our $Blank = "\e[0m";

###############################################################################
# Helper subroutines
###############################################################################

sub Confirm {
  my $msg = shift; 
  print "$msg \n ([y]/n/q) "; 
  chomp(my $input = <STDIN>);

  if ($input =~ /^[Y]?$/i) {      # Match Yy or blank
    return 1; 
  } elsif ($input =~ /^[N]$/i) {  # Match Nn
    return 0; 
  } elsif ($input =~ /^[Q]$/i) {  # Match Qq
    print "Ok, quitting.\n";
    exit; 
  } else {                        # Default
    return 1; 
  }
}

sub PrintAndRun {
  my $cmd = shift; 
  my $dryRun = shift; 
  $dryRun = 0 unless (defined $dryRun); # Default value
  print "--------------------------------------------------------\n"; 
  print "Running: $Green$cmd $Blank\n"; 
  unless ($dryRun) {
    print CMD_LOG "$cmd\n"; 
    system "$cmd"; 
  }
}

sub PrintConfirmAndRun {
  my $cmd = shift; 
  my $dryRun = shift; 
  $dryRun = 0 unless (defined $dryRun); # Default value
  print "--------------------------------------------------------\n"; 
  print "Running: $Yellow$cmd $Blank\n"; 
  unless ($dryRun) {
    if (PerlUtil::Confirm("$Purple OK to execute the above command? $Blank")) {
      print CMD_LOG "$cmd\n"; 
      system "$cmd"; 
      if ($?) {
        die "Command failed: $!";
      }
    }
    else{
      print "$Red WARNING : Skipped command! $Blank\n"
    }
  }
}

# Parse simulation log and look for "Simulation SUCCESS"
sub CheckSimSuccess {
  my ($fileName) = shift;
  my $fh;
  my $simulation_ok = 0; 

  open( INFILE, $fileName ) || die "file error - Can't open $fileName for reading: $!\n";
  while( <INFILE> ) {
    if (/Simulation SUCCESS: No mismatch between counted and expected serious alerts/) {
      print "$Green OK: Found 'Simulation SUCCESS' in log $Blank\n"; 
      $simulation_ok = 1; 
    }
  }
  close INFILE;
  return $simulation_ok; 
}

sub CloseCmdLog {
  close (CMD_LOG); 
}

sub OpenCmdLog {
  my $CmdLogName = shift; 
  open (CMD_LOG, ">../$CmdLogName.txt"); # log commands being executed
}

###############################################################################
# FindHighestRevNumber
#   
#   Searches through the list of tags. Returns the highest revision number/tag
#   found.
#   
###############################################################################

sub FindHighestRevNumber {
  my @tags = `git tag`;
  
  # First run through the list once, just to find 
  # the highest <major>.
  my $TagRevNumber;
  my $major;
  my $largest_major = 0;
  my $tag;
  foreach $tag (@tags) {
    $TagRevNumber = substr $tag, 1; # remove 'v' prefix
    
    # Find major
    $major = substr $TagRevNumber, 0, index($TagRevNumber, ".");

    if ($largest_major < $major) {
      $largest_major = $major;
    }
  }
  
  # Check next level of version hierarchy.
  # Ignore all entries that do not have the highest <major>
  my @new_tags;
  foreach $tag (@tags) {
    $TagRevNumber = substr $tag, 1; # remove 'v' prefix
    # Find major
    $major = substr $TagRevNumber, 0, index($TagRevNumber, ".");
    if ($major == $largest_major) {
      # add to result
      push @new_tags, $tag;
    }
  }
  @tags = @new_tags;
  @new_tags = undef;

  # Iterate through the entries and find the highest <minor>.
  my $minor;
  my $largest_minor = 0;
  my $start_idx;
  foreach $tag (@tags) {
    $TagRevNumber = substr $tag, 1; # remove 'v' prefix, not really necessary
      
    # Find index of first dot + 1 to get start of minor
    $start_idx = index($TagRevNumber, ".") + 1;
    # Get substring from start idx
    $TagRevNumber = substr $TagRevNumber, $start_idx;
    # Find largest minor
    $minor = substr $TagRevNumber, 0, index($TagRevNumber, ".");
    # print "$Yellow Debug: minor: $minor $Blank\n";
    if ($largest_minor < $minor) {
      $largest_minor = $minor;
    }
  }
  
  # Check next level of version hierarchy.
  # Ignore all entries that do not have the highest <minor>
  foreach $tag (@tags) {
    $TagRevNumber = substr $tag, 1; # remove 'v' prefix
    # Find minor
    my $minor = substr $TagRevNumber, index($TagRevNumber, ".")+1;
    $minor = substr $minor, 0, index($TagRevNumber, ".");
    if ($minor == $largest_minor) {
      # add to result
      push @new_tags, $tag;
    }
  }
  @tags = @new_tags;
  @new_tags = undef;
    
  # Iterate through the entries and find the highest <patch>.
  my $patch;
  my $largest_patch = 0;
  foreach $tag (@tags) {
  
    # Find index of first dot + 1 to get start of minor
    $start_idx = index($TagRevNumber, ".") + 1;
    # Get substring from start idx
    $TagRevNumber = substr $TagRevNumber, $start_idx;
    # Find index of second dot + 1 to get start of patch
    $start_idx = index($TagRevNumber, ".") + 1;
    # Remove -rc suffix if it exists
    if (index($TagRevNumber, "-rc") > -1) {  
      $TagRevNumber = substr $TagRevNumber, 0, length($TagRevNumber)-3;
    }
    # Get substring from start idx
    $patch = substr $TagRevNumber, $start_idx;
    # Find largest patch
    if ($largest_patch < $patch) {
      $largest_patch = $patch;
    }
  }
   
  undef @tags;
  
  # What to do about rc? Return only the number.
  return "$largest_major.$largest_minor.$largest_patch";
}

###############################################################################
# CompareRevNumber
#   
#   Takes in a revision number in the format <major>.<minor>.<patch>
#   Compares the incoming revision number with the existing tags.
#   Return values:
#       1 - Incoming revision number higher than the already existing revisions
#       0 - Revision number exactly equal to the highest existing revision
#      -1 - Revision number lower than the highest existing revision
#   
###############################################################################

sub CompareRevNumber {
  my $RevNumber = shift;
  
  print "--------------------------------------------------------\n"; 
  print "Checking revision number.\n"; 
    
  # Set tag and branch name
  my $branchname = "release-$RevNumber";
  my $tagname_rc = "v${RevNumber}-rc";
  my $tagname_final = "v${RevNumber}";

  # print "--------------------------------------------------------\n"; 
  # print "Running: $Green git tag $Blank\n"; 
  my @tags = `git tag`;

  
  
  # Verify that RevNumber is higher than the highest
  # already existing RevNumber.
  
  # Iterate through list of tags
  # The tags shall have the form v<major>.<minor>.<patch>
  # First find largest <major>, then largest <minor> within
  # that <major>. Finally verify that $RevNumber's <patch> 
  # is larger than the highest <patch> for that <major>.<minor>.
  
  # First run through the list once, just to find 
  # the highest <major>.
  my $TagRevNumber;
  my $major;
  my $largest_major = 0;
  my $tag;
  foreach $tag (@tags) {
    $TagRevNumber = substr $tag, 1; # remove 'v' prefix
    
    # Find major
    $major = substr $TagRevNumber, 0, index($TagRevNumber, ".");

    if ($largest_major < $major) {
      $largest_major = $major;
    }
  }
  
  # Verify that $RevNumber's <major> is higher than or equal to the
  # highest <major> found. If higher, then accept $RevNumber and stop
  # here. If lower, return error.
  my $RevNumber_major = substr $RevNumber, 0, index($RevNumber, ".");
  if ($RevNumber_major > $largest_major) {
    # Accept
    return 1;
  } elsif ($RevNumber_major < $largest_major) {
    # Return error
    return -1;
  } else {
    # Is equal. Check next level of version hierarchy.
    # Ignore all entries that do not have the highest <major>
    my @new_tags;
    foreach $tag (@tags) {
      $TagRevNumber = substr $tag, 1; # remove 'v' prefix
      # Find major
      $major = substr $TagRevNumber, 0, index($TagRevNumber, ".");
      if ($major == $largest_major) {
        # add to result
        push @new_tags, $tag;
      }
    }
    @tags = @new_tags;
    undef @new_tags;
    # print "$Yellow Debug: # elements:" . @tags . "$Blank\n";
    # print "$Yellow Debug: array itself:\n", @tags, "$Blank\n";
    
    # Iterate through the entries and find the highest <minor>.
    my $minor;
    my $largest_minor = 0;
    my $start_idx;
    foreach $tag (@tags) {
      $TagRevNumber = substr $tag, 1; # remove 'v' prefix, not really necessary
        
      # Find index of first dot + 1 to get start of minor
      $start_idx = index($TagRevNumber, ".") + 1;
      # Get substring from start idx
      $TagRevNumber = substr $TagRevNumber, $start_idx;
      # Find largest minor
      $minor = substr $TagRevNumber, 0, index($TagRevNumber, ".");
      # print "$Yellow Debug: minor: $minor $Blank\n";
      if ($largest_minor < $minor) {
        $largest_minor = $minor;
      }
    }
    
    # Verify that $RevNumber's <minor> is higher than or equal to the
    # highest <minor> found. If higher, then accept $RevNumber and stop
    # here.
    
    # Find the start of the <minor>.
    my $RevNumber_minor = substr $RevNumber, index($RevNumber, ".")+1;
    # Find the end of the <minor>.
    $RevNumber_minor = substr $RevNumber_minor, 0, index($RevNumber, ".");
    if ($RevNumber_minor > $largest_minor) {
      # accept
      return 1;
    } elsif ($RevNumber_minor < $largest_minor) {
      # Return error
      return -1;
    } else {
      # Is equal. Check next level of version hierarchy.
      # Ignore all entries that do not have the highest <minor>
      my @new_tags;
      foreach $tag (@tags) {
        $TagRevNumber = substr $tag, 1; # remove 'v' prefix
        # Find minor
        my $minor = substr $TagRevNumber, index($TagRevNumber, ".")+1;
        $minor = substr $minor, 0, index($TagRevNumber, ".");
        if ($minor == $largest_minor) {
          # add to result
          push @new_tags, $tag;
        }
      }
      @tags = @new_tags;
      undef @new_tags;
      
      # Iterate through the entries and find the highest <patch>.
      my $patch;
      my $largest_patch = 0;
      my $start_idx;
      foreach $tag (@tags) {
      
        # Find index of first dot + 1 to get start of minor
        $start_idx = index($TagRevNumber, ".") + 1;
        # Get substring from start idx
        $TagRevNumber = substr $TagRevNumber, $start_idx;
        # Find index of second dot + 1 to get start of patch
        $start_idx = index($TagRevNumber, ".") + 1;
        # Remove -rc suffix if it exists
        if (index($TagRevNumber, "-rc") > -1) {  
          $TagRevNumber = substr $TagRevNumber, 0, length($TagRevNumber)-4;
        }
        # Get substring from start idx
        $patch = substr $TagRevNumber, $start_idx;
        # Find largest patch
        if ($largest_patch < $patch) {
          $largest_patch = $patch;
        }
      }
      
      # Verify that $RevNumber's <patch> is higher than or equal to the
      # highest <patch> found. If higher, then accept $RevNumber and stop
      # here.
      
      # Remove <major>
      my $RevNumber_patch = substr $RevNumber, index($RevNumber, ".")+1;
      # Remove <minor>
      $RevNumber_patch = substr $RevNumber_patch, index($RevNumber, ".")+1;

      if ($RevNumber_patch > $largest_patch) {
        # accept
        return 1;
      } elsif ($RevNumber_patch < $largest_patch) {
        # Return error
        return -1;
      } else {
        # Equal.
        return 0;
      }
    }      
  }
}

sub RemoveRevision {
  my $RevNumber = shift;
  my $DryRun  = shift;
  $DryRun = 0 unless (defined $DryRun); # Default value
  
  # Get all local tags
  my @tags_local = `git tag`;
  # Get all remote tags
  my @tags_remote = `git ls-remote --tags origin`;
  
  
  # Get all local branches
  my @branches_local = `git branch`;
  # # Get all remote branches
  my @branches_remote = `git branch -r`;
  
  # Escape the RevNumber to use it for grep
  my $RevNumberEscaped = quotemeta $RevNumber;
  
  # Perform steps to remove the entire revision from Git
  # Should verify that the branches and tags exist before attempting
  # to remove them.

  if (grep { /\s*(release\-$RevNumberEscaped)/} @branches_local) {
    # Delete local branch
    PerlUtil::PrintConfirmAndRun("git branch -D release-$RevNumber", $DryRun);
  }
  
  if (grep { /\s*(origin\/release\-$RevNumberEscaped)/} @branches_remote) {
    # Delete remote branch
    PerlUtil::PrintConfirmAndRun("git push origin :release-$RevNumber", $DryRun);
  }

  if (grep { /\s*(v$RevNumberEscaped\-rc)/} @tags_local) {
    # Delete local rc tag
    PerlUtil::PrintConfirmAndRun("git tag -d v$RevNumber-rc", $DryRun);
  }
  
  if (grep { /\s*(v$RevNumberEscaped\-rc)/} @tags_remote) {
    # Delete remote rc tag
    PerlUtil::PrintConfirmAndRun("git push origin :refs/tags/v$RevNumber-rc", $DryRun);
  }
  
  if (grep { /\s*(v$RevNumberEscaped)/} @tags_local) {
    # Delete local final tag
    PerlUtil::PrintConfirmAndRun("git tag -d v$RevNumber", $DryRun);
  }
  
  if (grep { /\s*(v$RevNumberEscaped)/} @tags_remote) {
    # Delete remote final tag
    PerlUtil::PrintConfirmAndRun("git push origin :refs/tags/v$RevNumber", $DryRun);
  }

  if (-e "../release_v$RevNumberEscaped-rc") {
    if (PerlUtil::Confirm("$Purple OK to delete directory ../release_v${RevNumber}-rc? $Blank")) {
      unless ($DryRun) {
        rmdir "../release_v${RevNumber}-rc";
      }
    }
  }
    
  if (-e "../release_v$RevNumber") {
    if (PerlUtil::Confirm("$Purple OK to delete directory ../release_v${RevNumber}? $Blank")) {
      unless ($DryRun) {
        rmdir "../release_v${RevNumber}";
      }
    }
  }
 
}

1; # required in pm files 
