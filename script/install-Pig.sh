#!/bin/sh

USERNAME=vagrant
USER_HOME=/home/$USERNAME
USER_BASH=$USER_HOME/.bashrc

###############################################################################
# Install Pig                                                                 #
###############################################################################
PIG_VERSION=0.16.0
wget -qO- http://mirror.apache-kr.org/pig/pig-$PIG_VERSION/pig-$PIG_VERSION.tar.gz | tar zx -C $USER_HOME
PIG_HOME=$USER_HOME/pig-$PIG_VERSION
###############################################################################

###############################################################################
# Config Pig                                                                  #
###############################################################################
BASH_CONFIG="export PIG_HOME=$PIG_HOME
export PIG_CONF_DIR=\$PIG_HOME/conf
export PATH=\$PATH:\$PIG_HOME/bin"

echo "$BASH_CONFIG" >> $USER_BASH
###############################################################################