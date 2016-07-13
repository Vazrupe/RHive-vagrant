#!/bin/sh

RUN_PATH=`pwd`

JAVA_HOME=`ls -d /usr/lib/jvm/java-8-openjdk* | tail -l`

USER_NAME=vagrant
USER_HOME=/home/$USER_NAME

INSTALL_BASE=$USER_HOME
USER_BASH=$USER_HOME/.bashrc


###############################################################################
# SSH Key Copy                                                                #
###############################################################################
KEY_PERMISSION=600

USER_SSH_DIR=$USER_HOME/.ssh

PUBLIC_KEY_NAME=authorized_keys
PRIVATE_KEY_NAME=id_rsa

PUBLIC_KEY_PATH=$USER_SSH_DIR/$PUBLIC_KEY_NAME
PRIVATE_KEY_PATH=/vagrant/.vagrant/machines/hadoop/virtualbox/private_key

cp $PRIVATE_KEY_PATH $USER_SSH_DIR/$PRIVATE_KEY_NAME

chmod $KEY_PERMISSION $USER_SSH_DIR/$PRIVATE_KEY_NAME
###############################################################################


###############################################################################
# Install Hadoop                                                              #
###############################################################################
HADOOP_VERSION=2.7.2
HADOOP_DOWNLOAD_PATH=http://apache.tt.co.kr/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz
wget -qO- $HADOOP_DOWNLOAD_PATH | tar zx -C $INSTALL_BASE
HADOOP_HOME=$INSTALL_BASE/hadoop-$HADOOP_VERSION
###############################################################################


###############################################################################
# Install Hive                                                                #
###############################################################################
HIVE_VERSION=2.1.0
HIVE_DOWNLOAD_PATH=http://mirror.apache-kr.org/hive/hive-$HIVE_VERSION/apache-hive-$HIVE_VERSION-bin.tar.gz
wget -qO- $HIVE_DOWNLOAD_PATH | tar zx -C $INSTALL_BASE
HIVE_HOME=$INSTALL_BASE/apache-hive-$HIVE_VERSION
mv $HIVE_HOME-bin $HIVE_HOME
###############################################################################


###############################################################################
# Configure Bash                                                              #
###############################################################################
BASH_BASE_CONFIG="
#JAVA AND HADOOP PATH
export JAVA_HOME=$JAVA_HOME
export HADOOP_HOME=$HADOOP_HOME
export HADOOP_PREFIX=\$HADOOP_HOME
export HADOOP_INSTALL=\$HADOOP_HOME
export HADOOP_CONF_DIR=\$HADOOP_HOME/etc/hadoop
export YARN_HOME=\$HADOOP_HOME
export YARN_CONF_DIR=\$YARN_HOME/etc/hadoop"

BASH_EXP_CONFIG="export HIVE_HOME=$HIVE_HOME
export PATH=\$PATH:\$HADOOP_HOME/bin:\$JAVA_HOME/bin:\$HIVE_HOME/bin
export HADOOP_MAPRED_HOME=\$HADOOP_HOME
export HADOOP_COMMON_HOME=\$HADOOP_HOME
export HADOOP_HDFS_HOME=\$HADOOP_HOME
export HADOOP_COMMON_LIB_NATIVE_DIR=\$HADOOP_HOME/lib/native
export HADOOP_LIBEXEC_DIR=\$HADOOP_HOME/libexec
export JAVA_LIBRARY_PATH=\$HADOOP_HOME/lib/native:\$JAVA_LIBRARY_PATH
export HADOOP_CONF_DIR=\$HADOOP_PREFIX/etc/hadoop
export HADOOP_CLASSPATH=\${JAVA_HOME}/lib/tools.jar"

# Env Setting
echo "$BASH_BASE_CONFIG" >> $USER_BASH
echo "$BASH_EXP_CONFIG" >> $USER_BASH
###############################################################################


###############################################################################
# Configure Hadoop Env                                                        #
###############################################################################
# Hadoop Env
HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
HADOOP_ENV=$HADOOP_CONF_DIR/hadoop-env.sh
echo "$BASH_BASE_CONFIG" >> $HADOOP_ENV

HOST=0.0.0.0

append_property() {
NAME=`echo "$2" | sed -e 's/\//\\\\\//g'`
VALUE=`echo "$3" | sed -e 's/\//\\\\\//g'`

result="\t<property>\n\t\t<name>$NAME<\\/name>\n\t\t<value>$VALUE<\\/value>\n\t<\\/property>\n"

PROPERTIES="s/<\/configuration>/"$result"<\/configuration>/g"
TARGET_FILE=$1

sed -i "$PROPERTIES" $TARGET_FILE
return 0
}

### core-site.xml Config
CORE_SITE_PATH=$HADOOP_CONF_DIR/core-site.xml

append_property $CORE_SITE_PATH fs.default.name hdfs://$HOST:19000
append_property $CORE_SITE_PATH hadoop.proxyuser.$USER_NAME.hosts '*'
append_property $CORE_SITE_PATH hadoop.proxyuser.$USER_NAME.groups '*'

### hdfs-site.xml Config
HDFS_SITE_PATH=$HADOOP_CONF_DIR/hdfs-site.xml


NAME_DIR=$HADOOP_HOME/dfs/name
DATA_DIR=file://$HADOOP_HOME/dfs/data

append_property $HDFS_SITE_PATH dfs.replication 1
append_property $HDFS_SITE_PATH dfs.namenode.datanode.registration.ip-hostname-check false
append_property $HDFS_SITE_PATH dfs.namenode.name.dir $NAME_DIR
append_property $HDFS_SITE_PATH dfs.datanode.data.dir $DATA_DIR

### mapred-site.xml Config
MAPRED_SITE_PATH=$HADOOP_CONF_DIR/mapred-site.xml

cp $MAPRED_SITE_PATH.template $MAPRED_SITE_PATH

append_property $MAPRED_SITE_PATH mapred.job.tracker $HOST:54311

### slaves Config
SLAVES_PATH=$HADOOP_CONF_DIR/slaves

echo $HOST > $SLAVES_PATH
###############################################################################


###############################################################################
# Configure Hive Env                                                          #
###############################################################################
HIVE_CONF_DIR=$HIVE_HOME/conf

### hive-env.sh Config
HIVE_ENV_PATH=$HIVE_CONF_DIR/hive-env.sh
cp $HIVE_ENV_PATH.template $HIVE_ENV_PATH

HIVE_ENV="export HADOOP_HOME=$HADOOP_HOME"

echo "$HIVE_ENV" >> $HIVE_ENV_PATH

cd $HIVE_HOME
bin/schematool -initSchema -dbType derby
cd $RUN_PATH
###############################################################################