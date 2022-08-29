#!/bin/bash
# ----------------------------------------------------------------------------
#
# Package       : kibana
# Version       : v7.6.0
# Source repo   : https://github.com/elastic/kibana.git
# Tested on     : UBI: 8.5
# Travis-Check  : True
# Language      : Node
# Script License: Apache License Version 2.0
# Maintainer    : Vishaka Desai <Vishaka.Desai@ibm.com>
#
# Disclaimer: This script has been tested in root mode on given
# ==========  platform using the mentioned version of the package.
#             It may not work as expected with newer versions of the
#             package and/or distribution. In such case, please
#             contact "Maintainer" of this script.
#
# ----------------------------------------------------------------------------

PACKAGE_VERSION=${1:-v7.6.0}
WORKDIR=$1
cd $WORKDIR

# install dependencies
yum install -y curl gcc-c++ make git python27

# install nvm
curl -sL https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh -o install_nvm.sh
sh install_nvm.sh
source /root/.nvm/nvm.sh

# install kibana
git clone https://github.com/elastic/kibana.git
cd kibana
git checkout $PACKAGE_VERSION
nvm install
nvm use

# install yarn
npm install -g yarn

# remove chromedriver dependency
sed -i '/"chromedriver"/d' package.json   
sed -i 's/git-common-dir/git-dir/' /root/kibana/src/dev/register_git_hook/register_git_hook.js 
sed -i 's/#server.host: "localhost"/server.host: "0.0.0.0"/' /root/kibana/config/kibana.yml 
sed -i 's@#elasticsearch.hosts: ["http://localhost:9200"]@elasticsearch.hosts: ["http://elasticsearch:9200"]@' /root/kibana/config/kibana.yml 

# setup environment
groupadd kibana && useradd kibana -g kibana
chown kibana:kibana -R /root
su kibana -c 'yarn kbn bootstrap'