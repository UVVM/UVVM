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
python dependencies/src/dependencies.py clone ssh://stash.bitvis.no/bv_util/uvvm_vvc_framework.git
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
docker build -t uvvm .
docker run --name uvvm_vvc_framework uvvm

# Copy xunit report
docker cp uvvm_vvc_framework:/uvvm/uvvm_vvc_framework/sim/xunit-report.xml ./uvvm_vvc_framework/sim/xunit-report.xml
# Destroy docker container and image
docker rm uvvm_vvc_framework
docker rmi -f uvvm 
