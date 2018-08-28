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
python dependencies/src/dependencies.py clone ssh://stash.bitvis.no/bv_dip/bitvis_irqc.git
# Copy Dockerfile to current workdir (required for making
# docker build include current workdir in the domain)
cp bitvis_irqc/internal_script/Dockerfile ./

# Build and run docker image
docker build -t uvvm_irqc .
docker run --name bitvis_irqc uvvm_irqc

# Copy xunit report
docker cp bitvis_irqc:/uvvm/bitvis_irqc/sim/xunit-report.xml ./bitvis_irqc/sim/xunit-report.xml
# Destroy uvvm_util docker container and image
docker rm bitvis_irqc
docker rmi -f uvvm_irqc
