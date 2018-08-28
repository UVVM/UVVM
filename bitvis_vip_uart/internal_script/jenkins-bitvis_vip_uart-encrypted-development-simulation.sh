# Download dependencies tool
if [ -d dependencies ];
then
  cd dependencies
  git pull
  cd ..
else
  git clone ssh://stash.bitvis.no/bv_tools/dependencies.git
fi

# Run dependencies tool
# Clone non-existant repos
python dependencies/src/dependencies.py clone ssh://stash.bitvis.no/bv_vip/bitvis_vip_uart.git

# Create symbolic link to Vagrant file
# Method of doing this for the Windows slave is:
# mklink Vagrantfile bitvis_util\Vagrantfile
if [ ! -e Vagrantfile ];
then
  ln -s bitvis_vip_uart/Vagrantfile .
fi

# Start vagrant box and perform simulation
vagrant up

vagrant ssh << END
set -x
cd /vagrant/
cd uvvm_vvc_framework/internal_script/
vsim -c -do internal_encrypt_src.do
cd ../../bitvis_uart/internal_script/
vsim -c -do internal_encrypt_src.do
cd ../../bitvis_vip_uart/sim/
python internal_run_encrypted.py --clean --no-color --xunit-xml xunit-report.xml
END

vagrant halt