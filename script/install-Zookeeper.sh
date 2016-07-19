#!/bin/sh

USERNAME=vagrant
USER_HOME=/home/$USERNAME
USER_BASH=$USER_HOME/.bashrc

HOST=`hostname`

###############################################################################
# Install Zookeeper                                                           #
###############################################################################
ZOOKEEPER_VERSION=3.4.8
wget -qO- http://apache.tt.co.kr/zookeeper/zookeeper-$ZOOKEEPER_VERSION/zookeeper-$ZOOKEEPER_VERSION.tar.gz | tar zx -C $USER_HOME
ZOOKEEPER_HOME=$USER_HOME/zookeeper-$ZOOKEEPER_VERSION
ZOOKEEPER_CONF_DIR=$ZOOKEEPER_HOME/conf
ZOOKEEPER_DATA=$ZOOKEEPER_HOME/data
###############################################################################

###############################################################################
# Config Zookeeper                                                            #
###############################################################################
ZOOKEEPER_CONFIG="tickTime=2000
initLimit=10
syncLimit=5
clientPort=2181
dataDir=$ZOOKEEPER_DATA
server.1=$HOST:2888:3888"

echo "$ZOOKEEPER_CONFIG" >> $ZOOKEEPER_CONF_DIR/zoo.cfg
mkdir -p $ZOOKEEPER_DATA
echo 1 > $ZOOKEEPER_DATA/myid


BASH_CONFIG="export ZOOKEEPER_HOME=$ZOOKEEPER_HOME
export PATH=\$PATH:\$ZOOKEEPER_HOME/bin"

echo "$BASH_CONFIG" >> $USER_BASH
###############################################################################