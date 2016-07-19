#!/bin/sh

INSTALL_BASE=/usr/local


###############################################################################
# Change Locale                                                               #
###############################################################################
LOCALE_PATH=/etc/default/locale
LANGUAGE=ko_KR.UTF-8
ZONE_LOCALE=Asia/Seoul

sed -i "s/en_US.UTF-8/$LANGUAGE/" $LOCALE_PATH
locale-gen $LANGUAGE
ln -sf /usr/share/zoneinfo/$ZONE_LOCALE /etc/localtime
###############################################################################


###############################################################################
# Swap Memory Setting (2G)                                                    #
###############################################################################
SWAP_PATH=/swapfile

dd if=/dev/zero of=$SWAP_PATH bs=4K count=512K
chmod 600 $SWAP_PATH
mkswap $SWAP_PATH

swapon $SWAP_PATH

echo $SWAP_PATH	none	swap	sw	0	0 >> /etc/fstab
###############################################################################


###############################################################################
# Java, R Install                                                             #
###############################################################################
add-apt-repository ppa:openjdk-r/ppa -y
MIRROR=http://cran.nexr.com
R_DEB="deb $MIRROR/bin/linux/ubuntu trusty/"
SOURCE_PATH=/etc/apt/sources.list
echo "$R_DEB" >> $SOURCE_PATH
aptitude update
aptitude install -y git python openjdk-8-jdk r-base << EOF
Yes
EOF
###############################################################################


###############################################################################
# Install Ant                                                                 #
###############################################################################
ANT_VERSION=1.9.7
ANT_DOWNLOAD_PATH=http://apache.mirror.cdnetworks.com//ant/binaries/apache-ant-$ANT_VERSION-bin.tar.gz
wget -qO- $ANT_DOWNLOAD_PATH | tar zx -C $INSTALL_BASE
ANT_HOME=$INSTALL_BASE/apache-ant-$ANT_VERSION

update-alternatives --install "/usr/bin/ant" "ant" "$ANT_HOME/bin/ant" 1;
###############################################################################