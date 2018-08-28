# This file may be called with an argument
# arg 1: Part directory of this library/module

onerror {abort all}
quit -sim   #Just in case...

# Set up bitvis_vip_axistream_part_path 
#------------------------------------------------------
quietly set part_name "bitvis_vip_axistream"
# path from mpf-file in sim
quietly set bitvis_vip_axistream_part_path "../..//$part_name"

if { [info exists 1] } {
  # path from this part to target part
  quietly set bitvis_vip_axistream_part_path "$1/..//$part_name"
  unset 1
}


# Model Technology ModelSim ALTERA vhencrypt 10.3c Encryption Utility 2014.09 Sep 20 2014
# Usage: vencrypt [options] files
# Options:
  # -help/hel          Print this message
  # -version           Print the version
  # -d <dirname>       Generate files into directory <dirname>
  # -e <ext>           Specify file name extension <ext>
  # -o <filename>      Concatenate encrypted files into <filename>
  # -l <filename>      Write log to <filename>
  # -f <filename>      Specify a file containing more command line arguments
  # -hea <filename>    Specify header file
  # -p <prefix>        Prepend file names with <prefix>
  # -quiet             Disables encryption messages
  # -stats[=[+-]<args>] Enables executable statistics
                     # <args> are all,none,time,cmd,msg,perf,verbose,list

                     
  
quietly set sourcedir "$bitvis_vip_axistream_part_path/src"

quietly set encryptoptions "-d $sourcedir"

# Delete any exisiting .vhdp files in the directory to avoid releasing
# old code.
file delete [glob -nocomplain -directory $sourcedir *.vhdp]

# Build list of files. Only files that start with internal_
# shall be encrypted.
quietly set files ""
foreach file [glob -directory $sourcedir internal_*.vhd] {
   quietly set files "$files$sourcedir/$file "
}
echo "\n\n\n=== Encrypting $part_name source\n"
eval vhencrypt $encryptoptions $files
echo "\n\n\n=== Encryption finished\n"
echo "\n\n\n=== Renaming encrypted files...\n"
# For each .vhdp file with an internal_ prefix, rename to not internal_prefix
foreach file [glob -directory $sourcedir internal_*.vhdp] {
   set new_filename [regsub {\s*internal_} $file {}]
   echo "Renaming $file"
   echo "New file name is $new_filename\n"
   file rename -force $file $new_filename
}
echo "\n=== Renaming finished...\n"
echo "\n\n\n=== Done\n"
quit

