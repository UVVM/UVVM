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

# Copy Dockerfile to current workdir (required for making
# docker build include current workdir in the domain)
cp uvvm_util/internal_script/Dockerfile ./

# Build and run docker image
docker build -t uvvm_util_img .
docker run --name uvvm_util uvvm_util_img

# Copy xunit report
docker cp uvvm_util:/uvvm/uvvm_util/sim/xunit-report.xml ./uvvm_util/sim/xunit-report.xml
docker cp uvvm_util:/uvvm/uvvm_util/sim/vunit_out ./uvvm_util/sim/vunit_out
# Destroy uvvm_util docker container and image
docker rm uvvm_util
docker rmi -f uvvm_util_img

cd uvvm_util/sim/
python internal_compare_sim_output.py
