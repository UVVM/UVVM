#!/bin/sh
#ls -al

#Download dependencies tool
# Download dependencies tool
if [ -d dependencies ];
then
  cd dependencies
  git pull
  cd ..
else
  git clone ssh://stash.bitvis.no/BV_TOOLS/dependencies.git
fi

# Run dependencies tool
# Clone non-existant repos
python dependencies/src/dependencies.py clone ssh://stash.bitvis.no/bv_util/uvvm_util.git
# Ensure we're on correct branch
python dependencies/src/dependencies.py checkout 
# Get correct versions
python dependencies/src/dependencies.py pull
# Run status (for debug)
python dependencies/src/dependencies.py status

# Create symbolic link to Vagrant file
# DHB: Note to self - method of doing this for the Windows slave is:
# mklink Vagrantfile uvvm_util\Vagrantfile
if [ ! -e Vagrantfile ];
then
  ln -s uvvm_util/Vagrantfile .
fi


vagrant up
vagrant ssh <<END
set -x
cd /vagrant/
cd uvvm_util/sim/
python internal_run.py --clean --no-color --xunit-xml xunit-report.xml
python internal_compare_sim_output.py
END

vagrant halt