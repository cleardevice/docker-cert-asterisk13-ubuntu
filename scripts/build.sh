#!/bin/sh -x

minimal_apt_get_args='-y --no-install-recommends'

SERVICE_PACKAGES="nano tar htop curl"
LIBS_PACKAGES="libxml2-dev libjansson-dev libncurses5-dev libgsm1-dev libspeex-dev libspeexdsp-dev libssl-dev libsqlite3-dev"
BUILD_PACKAGES="wget subversion build-essential uuid-dev unixodbc-dev pkg-config"
RUN_PACKAGES="openssl sqlite3 fail2ban iptables"

apt-get update -y
apt-get install $minimal_apt_get_args $SERVICE_PACKAGES $LIBS_PACKAGES $BUILD_PACKAGES

# pjsip
svn co http://svn.pjsip.org/repos/pjproject/trunk/ /tmp/pjproject-trunk
cd /tmp/pjproject-trunk

./configure --libdir=/usr/lib/x86_64-linux-gnu --prefix=/usr --enable-shared --disable-sound --disable-resample --disable-video --disable-opencore-amr CFLAGS='-O2 -DNDEBUG'
make dep && make && make install && ldconfig && ldconfig -p | grep pj

# asterisk-certified-13.1-current.tar.gz
cd /tmp
wget http://downloads.asterisk.org/pub/telephony/certified-asterisk/asterisk-certified-13.1-current.tar.gz
mkdir asterisk
tar -xzvf asterisk-certified-13.1-current.tar.gz -C asterisk/ --strip-components=1

cd /tmp/asterisk
sh contrib/scripts/get_mp3_source.sh

# menuselect
make menuselect
menuselect/menuselect \
--disable-category MENUSELECT_ADDONS \
--disable-category MENUSELECT_APPS \
--disable-category MENUSELECT_BRIDGES \
--disable-category MENUSELECT_CDR \
--disable-category MENUSELECT_CEL \
--disable-category MENUSELECT_CHANNELS \
--enable-category MENUSELECT_CODECS \
--enable-category MENUSELECT_FORMATS \
--disable-category MENUSELECT_FUNCS \
--disable-category MENUSELECT_PBX \
--disable-category MENUSELECT_RES \
--disable-category MENUSELECT_TESTS \
--disable-category MENUSELECT_OPTS_app_voicemail \
--disable-category MENUSELECT_UTILS \
--disable-category MENUSELECT_AGIS \
--disable-category MENUSELECT_EMBED \
--disable-category MENUSELECT_CORE_SOUNDS \
--disable-category MENUSELECT_MOH \
--disable-category MENUSELECT_EXTRA_SOUNDS \
--enable app_controlplayback \
--enable app_dial \
--enable app_exec \
--enable app_originate \
--enable app_queue \
--enable app_record \
--enable app_senddtmf \
--enable app_stasis \
--enable app_verbose \
--enable app_waituntil \
--enable chan_sip \
--enable pbx_config \
--enable pbx_realtime \
--enable res_agi \
--enable res_ari \
--enable res_ari_channels \
--enable res_ari_events \
--enable res_ari_playbacks \
--enable res_ari_recordings \
--enable res_ari_sounds \
--enable res_ari_device_states \
--enable res_realtime \
--enable res_rtp_asterisk \
--enable res_rtp_multicast \
--enable res_stasis \
--enable res_stasis_answer \
--enable res_stasis_device_state \
--enable res_stasis_playback \
--enable res_stasis_recording \
--enable res_stun_monitor \
--enable res_timing_timerfd \
--enable func_callcompletion \
--enable func_callerid \
--disable BUILD_NATIVE

./configure CFLAGS='-g -O2 -mtune=native' --libdir=/usr/lib/x86_64-linux-gnu
make && make install && make samples

# add g729
wget http://asterisk.hosting.lv/bin/codec_g729-ast130-gcc4-glibc-x86_64-pentium4.so -O codec_g729.so
mv codec_g729.so /usr/lib/x86_64-linux-gnu/asterisk/modules/

touch /var/log/auth.log /var/log/asterisk/messages /var/log/asterisk/security

# install run packages
apt-get install $minimal_apt_get_args $RUN_PACKAGES

# fail2ban configure
rm /etc/fail2ban/filter.d/asterisk.conf
cp /tmp/asterisk*.conf /etc/fail2ban/filter.d/
cat /tmp/jail.conf >> /etc/fail2ban/jail.conf

# clean
apt-get remove --purge -y $BUILD_PACKAGES
apt-get -y autoremove
apt-get -y clean
rm -rf /tmp/* /var/tmp/*
rm -rf /var/lib/apt/lists/*
