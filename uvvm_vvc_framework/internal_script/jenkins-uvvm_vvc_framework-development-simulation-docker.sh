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
python dependencies/src/dependencies.py clone ssh://stash.bitvis.no/bv_uvvm/uvvm_vvc_framework.git

# Copy Dockerfile to current workdir (required for making
# docker build include current workdir in the domain)
cp uvvm_vvc_framework/internal_script/Dockerfile ./

# Build and run docker image
docker build -t uvvm_vvc_framework .
docker run --name vvc_framework uvvm_vvc_framework

# Copy xunit report
docker cp vvc_framework:/uvvm/uvvm_vvc_framework/sim/xunit-report.xml ./uvvm_vvc_framework/sim/xunit-report.xml
# Destroy docker container and image
docker rm vvc_framework
docker rmi -f uvvm_vvc_framework
