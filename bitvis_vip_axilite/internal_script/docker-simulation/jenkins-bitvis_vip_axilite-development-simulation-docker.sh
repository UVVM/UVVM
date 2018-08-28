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
python dependencies/src/dependencies.py clone ssh://git@stash.bitvis.no/bv_vip/bitvis_vip_axilite.git
# Copy Dockerfile to current workdir (required for making
# docker build include current workdir in the domain)
cp bitvis_vip_axilite/internal_script/docker-simulation/Dockerfile ./

# Build and run docker image
docker build -t uvvm_axilite_unencrypted .
docker run --name bitvis_axilite_unencrypted uvvm_axilite_unencrypted

# Copy xunit report
docker cp bitvis_axilite_unencrypted:/uvvm/bitvis_vip_axilite/sim/xunit-report.xml ./bitvis_vip_axilite/sim/xunit-report.xml
# Destroy docker container and image
docker rm bitvis_axilite_unencrypted
docker rmi -f uvvm_axilite_unencrypted
