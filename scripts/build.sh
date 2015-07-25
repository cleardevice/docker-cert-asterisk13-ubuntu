#!/bin/sh -x

minimal_apt_get_args='-y --no-install-recommends'

SERVICE_PACKAGES="nano tar htop"
BUILD_PACKAGES="wget subversion build-essential libncurses5-dev uuid-dev libjansson-dev libxml2-dev libgsm1-dev unixodbc-dev libspeex-dev libspeexdsp-dev libssl-dev libsqlite3-dev pkg-config"
RUN_PACKAGES="openssl sqlite3 fail2ban"

apt-get update -y
apt-get install $minimal_apt_get_args $SERVICE_PACKAGES $BUILD_PACKAGES

# pjsip
svn co http://svn.pjsip.org/repos/pjproject/trunk/ /tmp/pjproject-trunk
cd /tmp/pjproject-trunk

./configure --libdir=/usr/lib/x86_64-linux-gnu --prefix=/usr --enable-shared --disable-sound --disable-resample --disable-video --disable-opencore-amr CFLAGS='-O2 -DNDEBUG'
make dep && make && make install && ldconfig && ldconfig -p | grep pj

# certified-asterisk-13.1-current
cd /tmp
wget http://downloads.asterisk.org/pub/telephony/certified-asterisk/certified-asterisk-13.1-current.tar.gz
mkdir asterisk
tar -xzvf certified-asterisk-13.1-current.tar.gz -C asterisk/ --strip-components=1

cd /tmp/asterisk
sh contrib/scripts/get_mp3_source.sh
cp /tmp/menuselect.makeopts /tmp/asterisk/menuselect.makeopts
./configure CFLAGS='-g -O2 -mtune=native' --libdir=/usr/lib/x86_64-linux-gnu
make && make install && make samples

# clean
apt-get install $minimal_apt_get_args $RUN_PACKAGES

apt-get remove --purge -y $BUILD_PACKAGES
apt-get clean
rm -rf /tmp/* /var/tmp/*
rm -rf /var/lib/apt/lists/*
