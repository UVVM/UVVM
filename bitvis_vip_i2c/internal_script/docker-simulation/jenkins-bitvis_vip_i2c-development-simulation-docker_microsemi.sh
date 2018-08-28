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
python dependencies/src/dependencies.py clone ssh://git@stash.bitvis.no/bv_vip/bitvis_vip_i2c.git
# Copy Dockerfile to current workdir (required for making
# docker build include current workdir in the domain)
cp bitvis_vip_i2c/internal_script/docker-simulation/Dockerfile_microsemi ./Dockerfile

# Build and run docker image
docker build -t uvvm_i2c .
docker run --name bitvis_vip_i2c uvvm_i2c

# Copy xunit report
docker cp bitvis_vip_i2c:/uvvm/bitvis_vip_i2c/sim/xunit-report.xml ./bitvis_vip_i2c/sim/xunit-report.xml
# Destroy docker container and image
docker rm bitvis_vip_i2c
docker rmi -f uvvm_i2c
